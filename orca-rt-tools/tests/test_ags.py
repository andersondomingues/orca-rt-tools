"""AGS backend (rttools/modules/backend/ags)."""
from rttools.modules.backend.ags import heuristics, search3


def single_link(occupancy, min_start, deadline):
    """Problem with one link and one packet per entry of the lists."""
    n = len(occupancy)
    return {
        "min_start": [list(min_start)],
        "occupancy": [list(occupancy)],
        "deadline": [list(deadline)],
        "packets": [{"name": "p%d" % i} for i in range(n)],
        "links": ["0-1"],
        "hyperperiod": max(deadline),
    }


def test_zero_slack_packet_is_scheduled():
    # release window [10, 10]: deadline - occupancy = min_start
    p = single_link([5], [10], [15])
    res = search3.search3(p, heuristics.lstf, 3, 1)
    assert res is not None
    sched, skipped = res
    assert skipped == set() and sched[0][0] == 10


def order(*first_to_last):
    """Criterion that allocates the packets in the given order."""
    return lambda problem: list(first_to_last)


def test_truncation_at_maximum_release():
    # p0 holds [0, 10]; p1 (window [0, 16], PF 10) collides at 0 and 10
    # (closed intervals) and fits only at its maximum release 16
    p = single_link([10, 5], [0, 0], [10, 21])
    sched, skipped = search3.search3(p, order(0, 1), 1, 10)
    assert skipped == set() and sched[0] == [0, 16]
    assert search3.candidates(0, 16, 10) == [0, 10, 16]
    assert search3.candidates(0, 20, 10) == [0, 10, 20]
    assert search3.candidates(5, 4, 1) == []


def test_failed_packet_goes_first_after_reset():
    # p0 (window [0, 10]) goes first and takes 0; p1 (window [0, 0]) fails,
    # moves to the front of R, and the reset places p1 at 0 and p0 at 6
    p = single_link([10, 5], [0, 0], [20, 5])
    sched, skipped = search3.search3(p, order(0, 1), 2, 1)
    assert skipped == set() and sched[0] == [6, 0]
    assert search3.hsearch.resets == 1
    # with threshold 1 the first failure discards p1
    sched, skipped = search3.search3(p, order(0, 1), 1, 1)
    assert skipped == {1} and sched[0] == [0, None]
    assert search3.hsearch.resets == 0


def test_threshold_counts_failures_across_resets():
    # p1 never fits (deadline 4 < occupancy 5: empty window); it fails
    # G = 3 times (2 resets), leaves R, and p2 is still placed
    p = single_link([10, 5, 4], [0, 0, 0], [10, 4, 30])
    sched, skipped = search3.search3(p, order(0, 1, 2), 3, 1)
    assert skipped == {1}
    assert search3.hsearch.resets == 2
    assert sched[0][0] is not None and sched[0][2] is not None and sched[0][1] is None
    lo = sorted((sched[0][j], sched[0][j] + [10, 5, 4][j]) for j in (0, 2))
    assert lo[0][1] < lo[1][0]


def options(**flags):
    """Sets the options of the analysis flow (search3.PERIODIC,
    search3.RELEASE_ORDER) and returns the function that restores them."""
    old = {k: getattr(search3, k) for k in flags}
    for k, v in flags.items():
        setattr(search3, k, v)
    return lambda: [setattr(search3, k, v) for k, v in old.items()]


def test_periodic_schedule_avoids_the_next_hyperperiod():
    # H = 100: p0 (window [95, 110], o 20) holds [95, 115], which is [-5, 15] of the next hyperperiod;
    # p1 (window [0, 30], o 20) fits at 0 inside one hyperperiod and only from 16 on when the schedule repeats
    p = single_link([20, 20], [95, 0], [130, 50])
    p["hyperperiod"] = 100
    sched, skipped = search3.search3(p, order(0, 1), 2, 1)
    assert skipped == set() and sched[0] == [95, 0]
    restore = options(PERIODIC=True)
    try:
        sched, skipped = search3.search3(p, order(0, 1), 2, 1)
        assert skipped == set() and sched[0] == [95, 16]
        # p1 first takes 0; p0 meets [100, 120] of the next hyperperiod at every release, fails, and goes first
        sched, skipped = search3.search3(p, order(1, 0), 2, 1)
        assert skipped == set() and sched[0] == [95, 16]
        assert search3.hsearch.resets == 1
    finally:
        restore()
    assert search3.collides((95, 115), (0, 20), 100) and not search3.collides((95, 115), (0, 20))
    assert search3.collides((0, 20), (95, 115), 100) and not search3.collides((16, 36), (95, 115), 100)


def one_flow(occupancy, min_start, deadline, flows, hyperperiod):
    p = single_link(occupancy, min_start, deadline)
    p["packets"] = [{"name": "%s:%d" % (f, i), "flow": f} for i, f in enumerate(flows)]
    p["hyperperiod"] = hyperperiod
    return p


def test_release_order_of_a_flow_is_kept():
    # packets 0 and 1 of flow f (releases 0 and 10, o 10). Packet 1 goes first and takes [10, 20];
    # packet 0 then fits only at 21, after the later packet of its flow
    p = one_flow([10, 10], [0, 10], [100, 100], ["f", "f"], 200)
    sched, skipped = search3.search3(p, order(1, 0), 2, 1)
    assert skipped == set() and sched[0] == [21, 10]
    restore = options(RELEASE_ORDER=True)
    try:
        # packet 0 must precede 10: no release fits, it fails and goes first; packet 1 follows it
        sched, skipped = search3.search3(p, order(1, 0), 2, 1)
        assert skipped == set() and sched[0] == [0, 11]
        assert search3.hsearch.resets == 1
        # packets of distinct flows keep no order
        q = one_flow([10, 10], [0, 10], [100, 100], ["f", "g"], 200)
        sched, skipped = search3.search3(q, order(1, 0), 2, 1)
        assert skipped == set() and sched[0] == [21, 10]
    finally:
        restore()


def test_release_order_across_the_hyperperiod():
    # H = 100: packet 0 of flow f takes [0, 10]; a packet of flow g holds [50, 99]; packet 1 of f
    # (window [50, 190]) fits at 111, after packet 0 of the next hyperperiod ([100, 110])
    p = one_flow([10, 49, 10], [0, 50, 50], [10, 99, 200], ["f", "g", "f"], 100)
    restore = options(PERIODIC=True)
    try:
        sched, skipped = search3.search3(p, order(0, 1, 2), 1, 1)
        assert skipped == set() and sched[0] == [0, 50, 111]
        search3.RELEASE_ORDER = True
        sched, skipped = search3.search3(p, order(0, 1, 2), 1, 1)
        assert skipped == {2} and sched[0] == [0, 50, None]
    finally:
        restore()
        search3.RELEASE_ORDER = False
    assert search3.order_bounds(1, {0: 5}, ["f", "f"], [(0, 0), (9, 1)], {"f": [0]}, 100) == (5, 105)
    assert search3.order_bounds(0, {1: 30}, ["f", "f"], [(0, 0), (9, 1)], {"f": [1]}, 100) == (-70, 30)
    assert search3.order_bounds(0, {1: 30}, ["f", "f"], [(0, 0), (9, 1)], {"f": [1]}) == (None, 30)


def test_analysis_flow_options_are_off_by_default():
    assert search3.PERIODIC is False and search3.RELEASE_ORDER is False


def test_dct_verify_schedule_is_valid():
    from rttools.paper.ch6 import load_problem
    p = load_problem("problem_dctVerify")
    sched, skipped = search3.search3(p, heuristics.mbcf, 10, 10)
    assert skipped == set()
    for l, row in enumerate(p["occupancy"]):
        iv = sorted((sched[l][j], sched[l][j] + o) for j, o in enumerate(row) if o is not None)
        assert all(a[1] < b[0] for a, b in zip(iv, iv[1:]))
        for j, o in enumerate(row):
            if o is not None:
                assert p["min_start"][l][j] <= sched[l][j] <= p["deadline"][l][j] - o


def criteria_problem():
    # link 0 carries a0, a1 and b; link 1 carries only c
    # flow a: 2 packets in HP = 100 (T = 50), o = 10
    # flow b: 1 packet (T = 100), o = 30; flow c: 1 packet, o = 45
    occ = [[10, 10, 30, None],
           [None, None, None, 45]]
    return {"occupancy": occ,
            "min_start": [[0 if v is not None else None for v in r] for r in occ],
            "deadline": [[100 if v is not None else None for v in r] for r in occ],
            "packets": [{"name": "a:0"}, {"name": "a:1"}, {"name": "b:0"}, {"name": "c:0"}],
            "links": ["0-1", "1-2"], "hyperperiod": 100}


def test_lstf_follows_eq_6_2():
    # T - o: a 40, a 40, b 70, c 55
    assert heuristics.lstf(criteria_problem()) == [0, 1, 3, 2]


def test_mbcf_follows_eq_6_3():
    # o * HP / T: a 20, a 20, b 30, c 45
    assert heuristics.mbcf(criteria_problem()) == [3, 2, 0, 1]
    # the period key of the unwrapped packets takes precedence
    p = criteria_problem()
    p["packets"] = [dict(k, flow=k["name"][0], period=100) for k in p["packets"]]
    p["packets"][2]["period"] = 25
    # a 10, a 10, b 120, c 45
    assert heuristics.mbcf(p) == [2, 3, 0, 1]


def test_mcpf_allocates_most_critical_first():
    # usage: link 0 = 50, link 1 = 45; a0, a1 and b score 50, c scores 45
    assert heuristics.mcpf(criteria_problem()) == [0, 1, 2, 3]
    p = criteria_problem()
    p["occupancy"][1][3] = 60
    assert heuristics.mcpf(p)[0] == 3
