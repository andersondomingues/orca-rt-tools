"""Adaptive Guided Search (AGS): Fig. 6.6 of the ORCA RT-Tools reference (2024)
and Fig. 3 of Domingues et al., ICECS 2022.

Published pseudocode, as this module reads it:

    R <- packets in the order of the criterion (LSTF, MBCF or MCPF)
    Q <- empty ordered set; S <- {} (skipped); F <- PF; G <- threshold
    T <- zeros (failures per packet)
    while |R| != 0:
        schedule <- {}; for q in Q: allocate(schedule, q, F)    (reset)
        for r in R:
            if not allocate(schedule, r, F):
                T[r] <- T[r] + 1
                if T[r] < G: R.push_front(r); goto reset
                else: R.remove(r); S.push(r)
        return schedule, S

Reading adopted where the pseudocode leaves room:

- allocate(schedule, r, F) places packet r alone (first fit) and never
  moves a placed packet: it tries the releases a, a + F, a + 2F, ... of
  the window [a, b] of r, with b = deadline - occupancy, truncated at b
  (b is the last candidate when it is not on the grid, as in Fig. 6.5),
  and keeps the first release whose interval [k, k + o] overlaps no
  placed packet on any link of the path of r (closed intervals, as the
  collision test of Sec. 6.3.1).
- push_front moves r to the front of R (R holds each packet once).
- The jump after a failure goes to the reset (line 10 of Fig. 6.6) and
  keeps T. The jump to line 7 of the figure passes line 8, which zeroes
  T; with T zeroed, a packet that never fits makes the search loop
  forever, and the text counts the tries of each packet across resets.
- No line of the pseudocode inserts into Q, so the partial schedule of
  lines 11 to 13 is empty and every reset starts from an empty schedule.
- After a packet reaches G failures, it leaves R into S and the pass
  continues with the next packet (pseudocode, lines 20 and 21).
- The search returns when a pass reaches the end of R.

Each reset follows a failure with T[r] < G, so a run has at most
|P| (G - 1) resets.

Options of the analysis flow (off by default, so the instances of the
ORCA RT-Tools reference keep their published schedules; search.schedule_at
and compose.schedule_union set them around the call, like GUARD):

- PERIODIC: the schedule repeats every hyperperiod H = p['hyperperiod'].
  allocate also rejects a release whose interval overlaps, on a link of
  the packet, a placed interval of the next or of the previous
  hyperperiod ([a + H, b + H] and [a - H, b - H]). Without it a
  reservation that ends after H can meet a reservation of the next
  hyperperiod.
- RELEASE_ORDER: the packets of one flow (p['packets'][j]['flow']) enter
  the network in the order of their releases (min_start), across the
  hyperperiod as well: a later packet of the flow is released after the
  earlier one and before the earlier one of the next hyperperiod.

Counters (module attribute `hsearch`, read by rttools.paper.ch6 and the
TUI): entered = calls to allocate plus one per run for the final node
(the depth-first search before counted its leaf node the same way);
ignored = candidate releases rejected by the collision test; skipped =
packets in S; resets = number of resets.
"""
from types import SimpleNamespace

from rttools.terminal.terminal import debug, error, info, warn

# search counters of the last run
hsearch = SimpleNamespace(entered=0, ignored=0, skipped=[], resets=0)
# predicate (start, occupancy) -> True for a release that the platform excludes
# (rttools.modules.routing.router.release_guard), or None
GUARD = None
# per packet index: such a predicate, or None (applications with distinct ticks); used in place of GUARD
GUARDS = None
# the schedule repeats every hyperperiod: test each release against the next and the previous hyperperiod
PERIODIC = False
# keep the release order of the packets of each flow, across the hyperperiod as well
RELEASE_ORDER = False


'''
Checks whether two ranges overleap.
@param ra range a, the first range
@param rb range b, the second range
@returns True if the ranger overleap, otherwise False

'''
def overleap(ra, rb):
  mina, maxa = ra
  minb, maxb = rb

  return not(maxa < minb or maxb < mina)


def candidates(a, b, step):
  """Releases a, a + step, ... up to b, with b itself as the last
  candidate (truncation at the maximum release). Empty when b < a."""
  if b < a:
    return []
  ks = list(range(a, b + 1, step))
  if ks[-1] != b:
    ks.append(b)
  return ks


def packet_view(p, j):
  """Links, occupancy and release window [a, b] of packet j."""
  links = [l for l in range(len(p['occupancy'])) if p['occupancy'][l][j] is not None]
  if not links:
    return [], 0, 0, 0   # no link: nothing to reserve
  l0 = links[0]
  o = p['occupancy'][l0][j]
  a = p['min_start'][l0][j]
  b = p['deadline'][l0][j] - o
  return links, o, a, b


def collides(rng, iv, period=None):
  """True when `rng` overlaps `iv`, or, with `period`, the interval of
  `iv` in the next or in the previous period (closed intervals)."""
  if overleap(rng, iv):
    return True
  if period:
    # an interval of the next period starts at or after `period`, and one of the previous period
    # reaches a release (at or after 0) only when the interval ends at or after `period`
    if rng[1] >= period and overleap(rng, (iv[0] + period, iv[1] + period)):
      return True
    if iv[1] >= period and overleap(rng, (iv[0] - period, iv[1] - period)):
      return True
  return False


def order_bounds(r, release, flow_of, rank, by_flow, period=None):
  """Open interval (lo, hi) of the releases of packet r that keep the
  release order of its flow against the placed packets of the flow
  (`by_flow`: flow -> placed packet indices): after every earlier packet
  and before every later one and, with `period`, before the earlier
  packets of the next period and after the later ones of the previous
  period. None for no bound."""
  lo = hi = None
  for r2 in by_flow.get(flow_of[r], ()):
    k2 = release[r2]
    if rank[r2] < rank[r]:
      lo2, hi2 = k2, (k2 + period if period else None)
    else:
      lo2, hi2 = (k2 - period if period else None), k2
    if lo2 is not None and (lo is None or lo2 > lo):
      lo = lo2
    if hi2 is not None and (hi is None or hi2 < hi):
      hi = hi2
  return lo, hi


def allocate(placed, view, step, guard=None, period=None, bounds=None):
  """First release of the window of the packet whose interval overlaps no
  interval in `placed` (link -> list of (start, end)) on its links, or
  None. With `period`, the intervals of `placed` repeat every `period`
  (collides). With `bounds` = (lo, hi), the release lies in the open
  interval (order_bounds). Counts the rejected candidates in
  hsearch.ignored."""
  links, o, a, b = view
  lo, hi = bounds if bounds is not None else (None, None)
  for k in candidates(a, b, step):
    rng = (k, k + o)
    if ((guard is not None and guard(k, o))
        or (lo is not None and k <= lo) or (hi is not None and k >= hi)
        or any(collides(rng, iv, period) for l in links for iv in placed[l])):
      hsearch.ignored += 1
      continue
    return k
  return None


def search3(p, heuristic, tries, step):
  """Runs the AGS on problem `p` (tables link x packet min_start,
  occupancy and deadline) with the order of `heuristic`, threshold G =
  `tries` and pruning factor PF = `step`.

  Returns (schedule, skipped): schedule is a link x packet table with the
  release of each placed packet on the links of its path (None
  elsewhere and for skipped packets); skipped is the set S of packet
  indices that reached G failures."""
  hsearch.entered = 0
  hsearch.ignored = 0
  hsearch.skipped = []
  hsearch.resets = 0

  nlinks = len(p['occupancy'])
  npackets = len(p['occupancy'][0]) if nlinks else 0
  views = [packet_view(p, j) for j in range(npackets)]
  period = p.get('hyperperiod') if PERIODIC else None
  flow_of = rank = None
  if RELEASE_ORDER:
    # flow of each packet and its position in the release order of the flow (min_start, then index)
    flow_of = [pk.get('flow') if isinstance(pk, dict) else None for pk in p['packets']]
    rank = [(views[j][2], j) for j in range(npackets)]

  # order of the criterion (rttools/modules/backend/ags/heuristics.py)
  R = list(heuristic(p))
  S = []
  T = [0 for _ in range(npackets)]

  while True:
    # reset: empty schedule (Q is empty)
    placed = [[] for _ in range(nlinks)]
    release = {}
    by_flow = {}
    failed = None
    i = 0
    while i < len(R):
      r = R[i]
      hsearch.entered += 1
      bounds = (order_bounds(r, release, flow_of, rank, by_flow, period)
                if flow_of is not None and flow_of[r] is not None else None)
      k = allocate(placed, views[r], step, GUARDS[r] if GUARDS is not None else GUARD, period, bounds)
      if k is not None:
        release[r] = k
        if flow_of is not None and flow_of[r] is not None:
          by_flow.setdefault(flow_of[r], []).append(r)
        for l in views[r][0]:
          placed[l].append((k, k + views[r][1]))
        i += 1
        continue
      T[r] += 1
      name = p['packets'][r]['name'] if isinstance(p['packets'][r], dict) else str(p['packets'][r])
      if T[r] < tries:
        debug("Could not schedule " + name + " (" + str(T[r]) + "/" + str(tries) + "); reset.")
        failed = r
        break
      error("Could not schedule " + name + " after " + str(T[r]) + " tries; skipped.")
      R.pop(i)
      S.append(r)
    if failed is None:
      break
    R.remove(failed)
    R.insert(0, failed)
    hsearch.resets += 1

  hsearch.entered += 1
  hsearch.skipped = list(S)

  sched = [[None for _ in range(npackets)] for _ in range(nlinks)]
  for r, k in release.items():
    for l in views[r][0]:
      sched[l][r] = k

  info("AGS finished: " + str(len(release)) + " packets placed, " + str(len(S)) + " skipped, "
       + str(hsearch.resets) + " resets")
  info("Ignored nodes: " + str(hsearch.ignored))
  info("Entered nodes: " + str(hsearch.entered))
  return (sched, set(S))
