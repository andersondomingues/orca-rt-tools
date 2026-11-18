"""STR2RTS (Rouxel and Puaut, WCET 2017): the SDF task graphs of the suite in
the application format of the analysis flow, and the flow on each of them
(no RTL).

    python -m rttools.paper.str2rts convert --config <config.json> --str2rts <STR2RTS checkout> --apps <apps dir>
           [--check] [--only APP ...]
    python -m rttools.paper.str2rts run --config <config.json> --apps <apps dir> --arch <arch dir> --out <dir>
           [--only APP ...] [--jobs N] [--timeout S]
    python -m rttools.paper.exp23 check <dir>/metrics.json <reference.json>

`convert` reads the XML description of each application of the config (only
the XML: tasks, WCET, predecessors, data types; the C sources of the suite
are not read) and writes, under <apps dir>/<dir of the config>/<app>/:
<app>.csv (application), <app>-ONTO-hermes<W>x<H>.map (Spiral Mapping),
names.csv (acronym, XML task id, WCET of the XML) and conversion.json (the
values of the conversion). `run` needs only these files.

Conversion rules (parameters in the config):

| Quantity | STR2RTS | Application of the flow |
|---|---|---|
| Task | <task id WCET> | one task, acronym T001, T002, ... in the order of the XML (names.csv); cost c(v) = round(k WCET) + sigma cycles (round half up; sigma = scheduler_cycles, 11,000, one scheduler event as car-v.csv) |
| Edge | <prev id data-sent data-type> of a task | one flow from the predecessor to the task, in the order of the XML |
| Payload | data-sent tokens of data-type | ceil(data-sent x bits of the type / 8) bytes; bits: the <data-type name size="N b"> rows of the XML, otherwise default_bits of the config; at least floor_bytes (an edge without data keeps one word, the smallest payload that every tool of the flow takes: the analysis takes 0 bytes, the time-triggered pattern of rttools.ucxgen needs 4), at most max_bytes (65,532: payload_size of noc_packet_t is 16 bits and the kernel rounds the payload up to whole words; an edge above it is cut to one packet of that size and listed in conversion.json) |
| Mesh | - | 4x4 with at least min_tasks_4x4 tasks, otherwise 2x2; ORT/GCM stops at one cluster per task when the application has fewer tasks than PEs, and the Spiral Mapping places the clusters on the first nodes of the spiral |
| Period | - | one release period T for every task and flow |
| Deadline | - | end-to-end deadline D = (n(v_last) + 1) T of every task, with the phase index n of the mapping (the rule of CAR-V: R_bound = n(v_last) P + F(v_last) <= D whenever every task ends within its phase, so D does not move the clock) |

T and k (`choose_scale`): with the budget B(T) = reference_hz x T cycles
(380 MHz), for T = period_step_s, 2 period_step_s, ...: k(T) is the
largest factor with factor_decimals decimals whose clustering (step 1 of
the flow on N = mesh nodes: ORT/GCM with the four criteria, smallest M2,
spiral.cluster_application, on the costs of that factor) has its largest
cluster cost at or below B(T), that is f_CPU <= 380 MHz; T is the first
period at which the clustering of k(T) has sigma x (tasks of its cluster
with the most tasks) <= scheduler_share x B(T). k(T) comes from a
bisection on the grid of the factor (the largest cluster cost is not
monotone in k, because the clustering changes with k): after the
bisection, `probes` factors between the result and the bound of one task
alone ((B - sigma) / largest WCET) are tried, and the bisection restarts
above a feasible one (conversion.json: "probe").

Analysis (`run`), for each application, with the defaults of rttools
(header wait w_h = 20 cycles per router, the network interface of each PE
as a resource of the link schedule and w_NI = 15,169 cycles in the
occupancy, deadline of a packet at the tick of its reader) and the handler
charge of Eq. (7) of the paper: graph attribute handlers with inject and
receive of the config (the terms of the image of CAR, as
experiments/automotive) and budget B_v = 0, because c(v) of the conversion
holds no handler cycles (there is no image of these applications):

| Step | Function |
|---|---|
| Clustering and mapping | carv.clustering_rows, spiral.map_application on the CSV; the result must equal the stored .map |
| CPU test | release.cpu_bound (f_CPU) |
| Flows, link schedule (AGS), frequency search | search.minimum_frequency from f0_hz (f_search = its result) |
| R_bound | ttflow.phase_model at f_search |
| Term that sets the clock | the search again without the handler charge (no_handlers), with w_NI = 0 (no_wni), with w_h = 0 (no_wh) and with the three removed (links_only), the settings of rttools.paper.ablation |

Each application runs in its own process; one that exceeds the timeout is
stopped and reported with the settings it finished.

Outputs of `run`: metrics.json (one entry per application: "row" with the
values of the table, "clusters", "settings", "detail"), table.csv and
table.md.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import multiprocessing
import os
import sys
import time
from fractions import Fraction

class ConvertError(ValueError):
    pass


# ------------------------------------------------------------ STR2RTS input

def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        h.update(f.read())
    return h.hexdigest()


def checkout_commit(root):
    """Commit of the STR2RTS checkout from the files of .git (no git
    command runs on the checkout); None when they do not give one."""
    git = os.path.join(root, ".git")
    try:
        with open(os.path.join(git, "HEAD")) as f:
            head = f.read().strip()
        if not head.startswith("ref:"):
            return head if _is_hash(head) else None
        ref = head.split(":", 1)[1].strip()
        path = os.path.join(git, *ref.split("/"))
        if ".." in ref.split("/"):
            return None
        if os.path.exists(path):
            with open(path) as f:
                value = f.read().strip()
            return value if _is_hash(value) else None
        with open(os.path.join(git, "packed-refs")) as f:
            for line in f:
                parts = line.split()
                if len(parts) == 2 and parts[1] == ref and _is_hash(parts[0]):
                    return parts[0]
    except OSError:
        return None
    return None


def _is_hash(text):
    return len(text) == 40 and all(c in "0123456789abcdef" for c in text)


def type_bits(text, where):
    """Bits of a size attribute: "64 b" (bits), "16 B" (bytes, the form of
    the README of the suite)."""
    parts = str(text).split()
    if len(parts) != 2 or not parts[0].isdigit() or parts[1] not in ("b", "B"):
        raise ConvertError(f"{where}: size {text!r}: `<number> b` (bits) or `<number> B` (bytes) expected")
    return int(parts[0]) * (8 if parts[1] == "B" else 1)


def read_xml(path):
    """Task graph of one XML description of STR2RTS: {"tasks": [(id, WCET)],
    "edges": [(source id, target id, data-sent, data-type)], "types": {name:
    bits}}, tasks and edges in the order of the file (the edges of a task in
    the order of its <prev> rows). The graph must be acyclic, with unique
    task ids, one source, one sink and at most one edge per pair of tasks."""
    import xml.etree.ElementTree as ET
    with open(path, encoding="utf-8") as f:
        text = f.read()
    if "<!DOCTYPE" in text or "<!ENTITY" in text:
        raise ConvertError(f"{path}: document type declarations are not accepted")
    root = ET.fromstring(text)
    types = {}
    for d in root.iter("data-type"):
        name = d.get("name") or d.get("id")
        if not name or d.get("size") is None:
            raise ConvertError(f"{path}: data-type without name or size")
        types[name] = type_bits(d.get("size"), f"{path}: data-type {name}")
    node = root.find("tasks")
    if node is None:
        raise ConvertError(f"{path}: no <tasks>")
    tasks, edges = [], []
    for t in node.findall("task"):
        tid, wcet = t.get("id"), t.get("WCET")
        if not tid or wcet is None or not wcet.isdigit():
            raise ConvertError(f"{path}: task {tid!r}: id and integer WCET expected, got WCET {wcet!r}")
        tasks.append((tid, int(wcet)))
        for p in t.findall("prev"):
            sent = p.get("data-sent")
            if p.get("id") is None or sent is None or not sent.isdigit():
                raise ConvertError(f"{path}: task {tid}: prev needs id and integer data-sent")
            edges.append((p.get("id"), tid, int(sent), p.get("data-type")))
    ids = [t for t, _ in tasks]
    if len(set(ids)) != len(ids):
        raise ConvertError(f"{path}: repeated task id")
    known = set(ids)
    for a, b, _, _ in edges:
        if a not in known:
            raise ConvertError(f"{path}: task {b}: unknown predecessor {a!r}")
    pairs = [(a, b) for a, b, _, _ in edges]
    if len(set(pairs)) != len(pairs):
        raise ConvertError(f"{path}: more than one edge between two tasks")
    depth = longest_path(ids, pairs)       # ValueError on a cycle
    sources = [t for t in ids if all(b != t for _, b in pairs)]
    sinks = [t for t in ids if all(a != t for a, _ in pairs)]
    if len(sources) != 1 or len(sinks) != 1:
        raise ConvertError(f"{path}: {len(sources)} sources and {len(sinks)} sinks; one of each expected")
    return {"tasks": tasks, "edges": edges, "types": types, "longest_path": depth,
            "source": sources[0], "sink": sinks[0]}


def longest_path(tasks, edges):
    """Number of edges of the longest path of an acyclic graph."""
    succ = {t: [] for t in tasks}
    indeg = {t: 0 for t in tasks}
    for a, b in edges:
        succ[a].append(b)
        indeg[b] += 1
    depth = {t: 0 for t in tasks}
    ready = [t for t in tasks if indeg[t] == 0]
    seen = 0
    while ready:
        t = ready.pop()
        seen += 1
        for v in succ[t]:
            depth[v] = max(depth[v], depth[t] + 1)
            indeg[v] -= 1
            if indeg[v] == 0:
                ready.append(v)
    if seen != len(tasks):
        raise ConvertError("the task graph has a cycle")
    return max(depth.values()) if depth else 0


# ------------------------------------------------------------ conversion

def payload(sent, dtype, types, rule):
    """(bytes of the flow, raw bytes, bits of the type, source of the bits)
    of one edge."""
    if dtype in types:
        bits, src = types[dtype], "xml"
    elif dtype in rule["default_bits"]:
        bits, src = int(rule["default_bits"][dtype]), "default"
    else:
        raise ConvertError(f"data type {dtype!r}: no size in the XML and no default")
    raw = -(-sent * bits // 8)
    return min(max(raw, int(rule["floor_bytes"])), int(rule["max_bytes"])), raw, bits, src


def graph(x, rule):
    """Application graph of an XML description: acronyms, WCET of the XML
    and payloads. {"tasks": [(acronym, xml id, WCET)], "flows": [{"source",
    "target", "bytes", "raw_bytes", "sent", "type", "bits", "bits_source"}],
    "types": {type: {"bits", "source", "edges"}}}."""
    width = max(3, len(str(len(x["tasks"]))))
    acr = {tid: "T%0*d" % (width, i) for i, (tid, _) in enumerate(x["tasks"], 1)}
    flows, types = [], {}
    for a, b, sent, dtype in x["edges"]:
        nbytes, raw, bits, src = payload(sent, dtype, x["types"], rule)
        flows.append({"source": acr[a], "target": acr[b], "bytes": nbytes, "raw_bytes": raw, "sent": sent,
                      "type": dtype, "bits": bits, "bits_source": src})
        t = types.setdefault(str(dtype), {"bits": bits, "source": src, "edges": 0})
        t["edges"] += 1
    return {"tasks": [(acr[tid], tid, w) for tid, w in x["tasks"]], "flows": flows, "types": types,
            "longest_path": x["longest_path"], "source": acr[x["source"]], "sink": acr[x["sink"]]}


def cost(wcet, k100, sigma, scale=100):
    """c(v) = round(k WCET) + sigma, k = k100 / scale, round half up."""
    return (2 * k100 * wcet + scale) // (2 * scale) + sigma


def cluster(app, n, k100, sigma, scale=100):
    """Step 1 of the flow on the costs of factor k100 / scale: (criterion,
    clusters, rows of spiral.cluster_application)."""
    from rttools.modules.mapping import spiral
    tasks = [(a, cost(w, k100, sigma, scale)) for a, _, w in app["tasks"]]
    edges = [(f["source"], f["target"], f["bytes"]) for f in app["flows"]]
    return spiral.cluster_application(tasks, edges, n)


def largest_factor(app, n, budget, sigma, scale=100, probes=64):
    """Largest k (as k100 / scale) whose clustering has every cluster cost
    <= budget: bisection on the grid, then `probes` factors above the
    result (evenly spaced up to the bound of one task alone); a feasible
    probe restarts the bisection above it. Returns (k100 or None, probe
    record, cache {k100: (largest cluster cost, most tasks in a cluster,
    criterion)})."""
    cache = {}

    def look(k):
        if k not in cache:
            crit, clusters, rows = cluster(app, n, k, sigma, scale)
            row = next(r for r in rows if r["criterion"] == crit)
            cache[k] = (max(row["wcet"]), max(len(ts) for ts in clusters.values()), crit)
        return cache[k]

    def ok(k):
        return look(k)[0] <= budget

    # largest factor at which the task with the largest WCET alone fits the budget
    top = -(-scale * (2 * (budget - sigma) + 1) // (2 * max(w for _, _, w in app["tasks"]))) - 1
    if top < 0 or not ok(0):
        return None, {"probes": 0, "feasible_above": 0, "restarts": 0}, cache
    record = {"probes": 0, "feasible_above": 0, "restarts": 0, "bound_of_one_task": top / scale}

    def bisect(lo, hi):
        # ok(lo); hi not ok or hi == top + 1
        while hi - lo > 1:
            mid = (lo + hi) // 2
            if ok(mid):
                lo = mid
            else:
                hi = mid
        return lo

    best = top if ok(top) else bisect(0, top)
    while best < top:
        span = top - best
        steps = sorted({best + max(1, span * i // probes) for i in range(1, probes + 1)} | {best + 1})
        feasible = [k for k in steps if k <= top and ok(k)]
        record["probes"] += len(steps)
        if not feasible:
            break
        record["feasible_above"] += len(feasible)
        record["restarts"] += 1
        lo = max(feasible)
        above = [k for k in steps if k > lo]
        best = bisect(lo, min(above) if above else top + 1)
    return best, record, cache


def choose_scale(app, n, rule):
    """T and k of one application (module docstring). Returns {"period_s"
    (Fraction), "k100", "budget_cycles", "largest_cluster_cost",
    "largest_cluster_tasks", "criterion", "periods_tried", "probe"}."""
    sigma = int(rule["scheduler_cycles"])
    scale = 10 ** int(rule["factor_decimals"])
    step = Fraction(str(rule["period_step_s"]))
    share = Fraction(str(rule["scheduler_share"]))
    f_ref = Fraction(str(rule["reference_hz"]))
    tried = []
    m = 0
    while True:
        m += 1
        T = m * step
        if T > Fraction(str(rule["period_max_s"])):
            raise ConvertError(f"no period up to {rule['period_max_s']} s meets the rule; tried {tried}")
        budget = f_ref * T
        if budget.denominator != 1:
            raise ConvertError(f"budget {budget} cycles of T = {T} s is not an integer")
        budget = int(budget)
        # a cluster holds at least ceil(tasks / N) tasks
        least = -(-len(app["tasks"]) // n)
        if sigma * least > share * budget:
            tried.append({"period_s": float(T), "k": None, "reason": "scheduler cost of ceil(tasks / N) tasks"})
            continue
        k100, probe, cache = largest_factor(app, n, budget, sigma, scale, int(rule.get("probes", 64)))
        if k100 is None:
            tried.append({"period_s": float(T), "k": None, "reason": "no factor fits the budget"})
            continue
        demand, most, crit = cache[k100]
        fits = sigma * most <= share * budget
        tried.append({"period_s": float(T), "k": k100 / scale, "largest_cluster_tasks": most,
                      "scheduler_cycles_of_largest_cluster": sigma * most, "accepted": bool(fits)})
        if fits:
            return {"period_s": T, "k100": k100, "scale": scale, "budget_cycles": budget,
                    "largest_cluster_cost": demand, "largest_cluster_tasks": most, "criterion": crit,
                    "periods_tried": tried, "probe": probe}


def dec(x):
    """Decimal text of a Fraction with a finite expansion (0.0005)."""
    x = Fraction(x)
    s = f"{float(x):.12f}".rstrip("0").rstrip(".")
    if Fraction(s) != x:
        raise ConvertError(f"{x} has no short decimal form")
    return s


def place(app, sc, width, height, sigma):
    """Clustering and Spiral Mapping on the costs of the chosen factor, the
    phase index of each task and the deadline. Returns {"tasks": [(acronym,
    cost)], "edges", "result" (spiral.map_application), "entries", "phases",
    "v_last", "deadline_s"}."""
    from rttools.bench_t import estimate
    from rttools.modules.mapping import mapfile, spiral
    tasks = [(a, cost(w, sc["k100"], sigma, sc["scale"])) for a, _, w in app["tasks"]]
    edges = [(f["source"], f["target"], f["bytes"]) for f in app["flows"]]
    res = spiral.map_application(tasks, edges, width, height)
    entries = mapfile.from_dict(res["mapping"])
    pairs = [(a, b) for a, b, _ in edges]
    # dispatch order of each PE and phase index, as release.pe_sequences and ttflow.phase_model give them for
    # a CSV without sequence and creation rows (creation order = the order of the .map line); `run` checks
    # the phase index of the last task against the flow
    node_of = {t: e["node"] for e in entries for t in e["tasks"]}
    first = estimate.phases(pairs, node_of)
    seqs = {e["node"]: estimate.dispatch_order(e["tasks"], pairs, first) for e in entries}
    phi = estimate.phases(pairs, node_of, {t: i for ts in seqs.values() for i, t in enumerate(ts)})
    n_last = max(phi.values())
    return {"tasks": tasks, "edges": edges, "result": res, "entries": entries, "phases": phi,
            "n_last": n_last, "deadline_s": (n_last + 1) * sc["period_s"]}


def csv_text(name, app, sc, pl, src, rule):
    """CSV in the format of apps/car-v/car-v.csv."""
    T, D = dec(sc["period_s"]), dec(pl["deadline_s"])
    k = dec(Fraction(sc["k100"], sc["scale"]))
    sigma = int(rule["scale"]["scheduler_cycles"])
    buf = io.StringIO()
    buf.write(f"# {name}: task graph {src['xml']} of STR2RTS (commit {src['commit']}); generated by "
              "python -m rttools.paper.str2rts convert (config experiments/str2rts/config.json); do not edit\n")
    buf.write(f"# Task rows: Period = release period T (s); Capacity = c(v) = round({k} WCET) + {sigma} cycles "
              f"(WCET of the XML, names.csv); Deadline = end-to-end deadline D = (n(v_last) + 1) T, "
              f"n(v_last) = {pl['n_last']} (s); Description = task id of the XML\n")
    buf.write("# Flow rows: Period = T (s); Data = ceil(data-sent x bits of the data type / 8) bytes, at least "
              f"{rule['payload']['floor_bytes']} and at most {rule['payload']['max_bytes']}; "
              "Deadline = T (s), not used by the phase model\n")
    w = csv.writer(buf, lineterminator="\n")
    w.writerow(["#tasks", "", "", "", "", ""])
    w.writerow(["Task", "Period", "Capacity", "Deadline", "Acronym", "Description"])
    xml_id = {a: tid for a, tid, _ in app["tasks"]}
    for i, (a, c) in enumerate(pl["tasks"], 1):
        w.writerow([i, T, c, D, a, xml_id[a]])
    w.writerow(["#flows", "", "", "", "", ""])
    w.writerow(["Flow", "Period", "Data", "Deadline", "Source", "Target"])
    for i, (a, b, d) in enumerate(pl["edges"], 1):
        w.writerow([i, T, d, T, a, b])
    w.writerow(["#parameters", "", "", "", "", ""])
    w.writerow(["Parameter", "Value", "", "", "", ""])
    w.writerow(["release_model", "phase", "", "", "", ""])
    w.writerow(["scheduler_cycles", sigma, "", "", "", ""])
    return buf.getvalue()


def names_text(app):
    buf = io.StringIO()
    w = csv.writer(buf, lineterminator="\n")
    w.writerow(["Acronym", "XML task id", "WCET"])
    for a, tid, wcet in app["tasks"]:
        w.writerow([a, tid, wcet])
    return buf.getvalue()


def app_dir_name(name):
    return name.lower()


def mesh_of(n_tasks, rule):
    m = rule["mesh"]
    key = "large" if n_tasks >= int(m["min_tasks_4x4"]) else "small"
    return m[key]["width"], m[key]["height"], m[key]["arch"]


def files_of(name, width, height):
    d = app_dir_name(name)
    return {"csv": f"{d}.csv", "map": f"{d}-ONTO-hermes{width}x{height}.map", "names": "names.csv",
            "conversion": "conversion.json"}


def convert_one(entry, cfg, root, commit):
    """Texts of the files of one application: {file name: text} and the
    conversion record."""
    from rttools.modules.mapping import mapfile
    path = os.path.join(root, *entry["xml"].split("/"))
    digest = sha256(path)
    if entry.get("sha256") and digest != entry["sha256"]:
        raise ConvertError(f"{entry['xml']}: sha256 {digest} differs from the config ({entry['sha256']})")
    app = graph(read_xml(path), cfg["payload"])
    width, height, arch = mesh_of(len(app["tasks"]), cfg)
    n = width * height
    sc = choose_scale(app, n, cfg["scale"])
    sigma = int(cfg["scale"]["scheduler_cycles"])
    pl = place(app, sc, width, height, sigma)
    res = pl["result"]
    name = entry["name"]
    files = files_of(name, width, height)
    src = {"xml": entry["xml"], "commit": commit, "sha256": digest}
    floor, top = int(cfg["payload"]["floor_bytes"]), int(cfg["payload"]["max_bytes"])
    numbered = list(enumerate(app["flows"], 1))
    row = next(r for r in res["rows"] if r["criterion"] == res["criterion"])
    T = sc["period_s"]
    record = {
        "_doc": "values of the conversion of python -m rttools.paper.str2rts convert; do not edit",
        "name": name, "source": src, "files": files,
        "tasks": len(app["tasks"]), "edges": len(app["flows"]), "longest_path": app["longest_path"],
        "source_task": app["source"], "sink_task": app["sink"],
        "mesh": f"{width}x{height}", "arch": arch, "clusters": len(res["clusters"]),
        "factor": sc["k100"] / sc["scale"], "period_s": float(T), "deadline_s": float(pl["deadline_s"]),
        "phase_last": pl["n_last"], "budget_cycles": sc["budget_cycles"],
        "scheduler_cycles": sigma,
        "criterion": res["criterion"], "m2": row["sigma"],
        "largest_cluster_cost": max(row["wcet"]),
        "largest_cluster_tasks": max(len(ts) for ts in res["clusters"].values()),
        "f_cpu_hz": float(max(row["wcet"]) / T),
        "scheduler_share_of_largest_cluster": sigma * max(len(ts) for ts in res["clusters"].values())
        / sc["budget_cycles"],
        "wcet_xml": {"min": min(w for _, _, w in app["tasks"]), "max": max(w for _, _, w in app["tasks"]),
                     "sum": sum(w for _, _, w in app["tasks"])},
        "payload": {
            "types": app["types"],
            "floor_bytes": floor, "max_bytes": top,
            "edges_at_floor": sum(1 for f in app["flows"] if f["raw_bytes"] < floor),
            "edges_of_zero_bytes": sum(1 for f in app["flows"] if f["raw_bytes"] == 0),
            "edges_above_max": [{"flow": i, "source": f["source"], "target": f["target"], "bytes": f["raw_bytes"],
                                 "data_sent": f["sent"], "type": f["type"]}
                                for i, f in numbered if f["raw_bytes"] > top],
            "smallest_bytes": min(f["bytes"] for f in app["flows"]),
            "largest_bytes": max(f["bytes"] for f in app["flows"]),
        },
        "periods_tried": sc["periods_tried"], "probe": sc["probe"],
    }
    texts = {files["csv"]: csv_text(name, app, sc, pl, src, cfg),
             files["map"]: mapfile.to_text(pl["entries"]),
             files["names"]: names_text(app),
             files["conversion"]: json.dumps(record, indent=1) + "\n"}
    return texts, record


def selected(cfg, only):
    apps = cfg["apps"]
    if only:
        unknown = sorted(set(only) - {a["name"] for a in apps})
        if unknown:
            raise ConvertError("unknown application: " + ", ".join(unknown))
        apps = [a for a in apps if a["name"] in only]
    return apps


def convert(cfg, root, apps_dir, check=False, only=None):
    commit = checkout_commit(root)
    want = cfg["source"].get("commit")
    if commit is None:
        print(f"warning: no commit in {root}/.git; taking the commit of the config ({want})", file=sys.stderr)
        commit = want
    elif want and commit != want:
        raise ConvertError(f"checkout at commit {commit}; the config expects {want}")
    base = os.path.join(apps_dir, cfg["dir"])
    same = True
    for entry in selected(cfg, only):
        t0 = time.time()
        texts, rec = convert_one(entry, cfg, root, commit)
        d = os.path.join(base, app_dir_name(entry["name"]))
        if check:
            diff = [n for n, text in texts.items() if not _same(os.path.join(d, n), text)]
            same = same and not diff
            print(f"{entry['name']}: " + ("up to date" if not diff else "differs from the converter: "
                                          + ", ".join(diff)))
            continue
        os.makedirs(d, exist_ok=True)
        for n, text in texts.items():
            with open(os.path.join(d, n), "w") as f:
                f.write(text)
        p = rec["payload"]
        print(f"{entry['name']}: {rec['tasks']} tasks, {rec['edges']} edges, mesh {rec['mesh']}, "
              f"{rec['criterion']}, k = {rec['factor']:g}, T = {rec['period_s'] * 1e3:g} ms, "
              f"D = {rec['deadline_s'] * 1e3:g} ms, f_CPU {rec['f_cpu_hz'] / 1e6:.3f} MHz, "
              f"{p['edges_at_floor']} edges at the floor, {len(p['edges_above_max'])} above the largest packet "
              f"({time.time() - t0:.1f} s) -> {d}")
    return same


def _same(path, text):
    if not os.path.exists(path):
        return False
    with open(path) as f:
        return f.read() == text


# ------------------------------------------------------------ analysis

SETTINGS = {
    "flow": {"wait": "bound", "ni": "tt", "handlers": True},
    "no_handlers": {"wait": "bound", "ni": "tt", "handlers": False},
    "no_wni": {"wait": "bound", "ni": (True, 0), "handlers": True},
    "no_wh": {"wait": 0, "ni": "tt", "handlers": True},
    "links_only": {"wait": 0, "ni": (True, 0), "handlers": False},
}


def _load(d, files, arch_path, handlers):
    from rttools.modules.io import appparser, nocparser
    from rttools.modules.mapping import mapfile
    from rttools.tui.model import network
    with network.quiet():
        g, appname = appparser.loadFromFile(os.path.join(d, files["csv"]))
        noc = nocparser.loadFromFile(arch_path)
    entries = mapfile.read(os.path.join(d, files["map"]))
    bad = mapfile.problems(entries, list(g.nodes), list(noc.nodes), unknown=True)
    if bad:
        raise ValueError(files["map"] + ": " + "; ".join(bad))
    if handlers is not None:
        g.graph["handlers"] = {"inject": int(handlers["inject"]), "receive": int(handlers["receive"]),
                               "budget": {n: 0 for n in g.nodes}}
    return g, appname, noc, entries


def _setting(s):
    """Context of one setting: header wait, network-interface model and
    deadline model of the process (rttools/modules/routing/router.py)."""
    import contextlib
    from rttools.modules.routing import router

    @contextlib.contextmanager
    def ctx():
        prev = (router.set_header_wait(s["wait"]), router.set_ni(s["ni"]), router.set_deadline("tick"))
        try:
            yield
        finally:
            router.set_header_wait(prev[0])
            router.set_ni(prev[1])
            router.set_deadline(prev[2])
    return ctx()


def search_setting(d, files, arch_path, handlers, f0, s):
    """search.minimum_frequency of one setting: (summary, graph, noc,
    entries)."""
    from rttools.modules.frequency import search
    from rttools.paper.frequency import search_config
    from rttools.tui.model import network
    g, appname, noc, entries = _load(d, files, arch_path, handlers if s["handlers"] else None)
    t0 = time.time()
    with _setting(s), network.quiet():
        freq = search.minimum_frequency(g, noc, entries, appname, search_config(f0))
    net = freq["network"]
    above = freq["final_search"]
    out = {"f_cpu_hz": freq["f_cpu_hz"], "f_star_hz": freq["f_star_hz"], "minimum_hz": freq["frequency_hz"],
           "attempts": (len(net["attempts"]) if net else 0) + (len(above["attempts"]) if above else 0)
           + (1 if freq["final_check"] else 0),
           "network_at_f_cpu": None if freq["final_check"] is None else freq["final_check"]["feasible"]}
    return out, time.time() - t0, (g, appname, noc, entries, freq)


def setter(settings, tolerance):
    """Term that sets the clock of the flow, from the minimum frequency of
    each setting: (label, {term: Hz that its removal alone takes from the
    minimum}). Label: "cpu" when the flow returns f_CPU; otherwise the
    terms whose removal alone lowers the minimum by more than `tolerance`
    Hz, the largest drop first ("handlers", "w_ni", "w_h"); "handlers, w_ni
    and w_h together" when only the removal of the three lowers it;
    "links" when no removal lowers it (the link schedule with o_i = L0 and
    the network interfaces as resources already needs that clock). (None,
    {}) while a setting is missing."""
    flow = settings.get("flow")
    if flow is None or flow.get("minimum_hz") is None:
        return None, {}
    f = flow["minimum_hz"]
    names = {"no_handlers": "handlers", "no_wni": "w_ni", "no_wh": "w_h"}
    drops = {names[k]: f - settings[k]["minimum_hz"] for k in names
             if k in settings and settings[k].get("minimum_hz") is not None}
    if flow["f_cpu_hz"] is not None and f <= flow["f_cpu_hz"] + tolerance:
        return "cpu", drops
    if len(drops) < len(names) or settings.get("links_only", {}).get("minimum_hz") is None:
        return None, drops
    lower = sorted((t for t in drops if drops[t] > tolerance), key=lambda t: -drops[t])
    if lower:
        return " + ".join(lower), drops
    if settings["links_only"]["minimum_hz"] < f - tolerance:
        return "handlers, w_ni and w_h together", drops
    return "links", drops


def analyze(name, d, arch_dir, cfg, out_path):
    """The flow on one converted application; writes the result to
    out_path after each setting (a stopped run keeps the settings it
    finished)."""
    from rttools import __main__ as cli
    from rttools.modules.instances import instantiator
    from rttools.modules.mapping import mapfile, spiral
    from rttools.modules.unwrapper import flowUnwrapper
    from rttools.paper import carv, ttflow
    from rttools.paper.frequency import search_config
    from rttools.tui.model import network
    t_start = time.time()
    with open(os.path.join(d, "conversion.json")) as f:
        conv = json.load(f)
    files = conv["files"]
    an = cfg["analysis"]
    handlers = an["handlers"]
    f0 = an["f0_hz"]
    arch_path = os.path.join(arch_dir, conv["arch"])
    g, appname, noc, entries = _load(d, files, arch_path, None)
    width, height = cli.mesh_size(noc)

    # steps 1 and 2 on the CSV: must give the stored mapping
    tasks, edges = spiral.from_networkx(g)
    chosen, clusters, rows = carv.clustering_rows(tasks, edges, width * height, spiral.CRITERIA)
    res = spiral.map_application(tasks, edges, width, height)
    with open(os.path.join(d, files["map"])) as f:
        map_same = f.read() == mapfile.to_text(mapfile.from_dict(res["mapping"]))
    names = ["C%02d" % i for i in range(1, len(res["clusters"]) + 1)]
    cl = {c: {"pe": res["cluster_nodes"][key], "tasks": list(ts), "cost": sum(dict(tasks)[t] for t in ts),
              "volume_bytes": res["volumes"][key]}
          for c, (key, ts) in zip(names, res["clusters"].items())}
    pe_of = {t: str(c["pe"]) for c in cl.values() for t in c["tasks"]}
    cross = [(a, b, w) for a, b, w in edges if pe_of[a] != pe_of[b]]
    T = Fraction(str(conv["period_s"]))
    crit_row = next(r for r in rows if r["chosen"])
    out = {
        "row": {
            "name": name, "xml": conv["source"]["xml"], "commit": conv["source"]["commit"],
            "tasks": len(tasks), "edges": len(edges), "mesh": conv["mesh"], "clusters": len(cl),
            "criterion": chosen, "m2": crit_row["M2"], "k": conv["factor"], "phase_last": conv["phase_last"],
            "period_ms": conv["period_s"] * 1e3, "deadline_ms": conv["deadline_s"] * 1e3,
            "edges_between_pes": len(cross), "edges_at_payload_floor": conv["payload"]["edges_at_floor"],
            "edges_above_largest_packet": len(conv["payload"]["edges_above_max"]),
            "largest_cluster_tasks": max(len(c["tasks"]) for c in cl.values()),
        },
        "clusters": {"pe_of_cluster": {c: v["pe"] for c, v in cl.items()},
                     "cluster_of_task": {t: c for c, v in cl.items() for t in v["tasks"]},
                     "cost_of_cluster": {c: v["cost"] for c, v in cl.items()}},
        "checks": {"map_matches_spiral": map_same, "criterion_matches_conversion": chosen == conv["criterion"],
                   "csv_sha256": sha256(os.path.join(d, files["csv"]))},
        "settings": {},
        "detail": {"clustering": [{k: r[k] for k in ("criterion", "M2", "clusters", "inter_edges", "noc_volume",
                                                      "largest_cost", "smallest_cost", "chosen")} for r in rows],
                   "cluster_tasks": {c: v["tasks"] for c, v in cl.items()},
                   "cluster_volume_bytes": {c: v["volume_bytes"] for c, v in cl.items()},
                   "handlers": {"inject": handlers["inject"], "receive": handlers["receive"], "budget": 0}},
        "timing_s": {},
        "complete": False,
    }

    def save():
        out["timing_s"]["total"] = round(time.time() - t_start, 2)
        tmp = out_path + ".tmp"
        with open(tmp, "w") as f:
            json.dump(out, f, indent=1)
        os.replace(tmp, out_path)

    save()
    tol = search_config(f0)["scaling_tolerance"]
    for key in an["settings"]:
        s = SETTINGS[key]
        summary, seconds, (g2, appname, noc2, entries2, freq) = search_setting(d, files, arch_path, handlers, f0, s)
        out["settings"][key] = summary
        out["timing_s"][key] = round(seconds, 2)
        if key == "flow":
            fmin = freq["frequency_hz"]
            row = out["row"]
            row["f_cpu_hz"] = freq["f_cpu_hz"]
            row["f_search_hz"] = fmin
            row["f_star_hz"] = freq["f_star_hz"]
            if fmin is not None:
                with _setting(s), network.quiet():
                    m = ttflow.phase_model(g2, noc2, entries2, fmin)
                    inst = instantiator.createInstance(g2, noc2, fmin)
                    packets, hp, _ = flowUnwrapper.unwrap(inst, noc2, entries2)
                rb = m["response_bound"]
                P = m["period_cycles"]
                row["phase_last"] = rb["phase"]
                row["v_last"] = rb["task"]
                row["r_bound_ms"] = rb["ms"]
                row["r_bound_percent_of_deadline"] = 100 * rb["ms"] / row["deadline_ms"]
                row["deadline_is_phase_rule"] = conv["deadline_s"] == float((rb["phase"] + 1) * T)
                out["checks"]["phase_last_matches_conversion"] = rb["phase"] == conv["phase_last"]
                out["checks"]["f_cpu_matches_conversion"] = abs(freq["f_cpu_hz"] - conv["f_cpu_hz"]) < 1e-3
                row["packets_per_hyperperiod"] = len(packets)
                row["hyperperiod_cycles"] = hp
                det = out["detail"]
                det["period_cycles"] = P
                det["r_bound_cycles"] = rb["cycles"]
                det["cpu_fits"] = m["cpu_fits"]
                det["demand_cycles"] = {str(n): v for n, v in freq["cpu"]["demand"].items()}
                det["largest_finish_cycles"] = max(t["finish"] for t in m["tasks"].values())
                # handler charge of Eq. (7): F(v) less the finish of v in the sequence of its PE
                c_of, charge = dict(tasks), 0
                for seq in m["sequences"].values():
                    done = 0
                    for v in seq:
                        done += c_of[v]
                        charge = max(charge, m["tasks"][v]["finish"] - done)
                det["largest_handler_charge_cycles"] = charge
                det["phases"] = {v: t["phase"] for v, t in m["tasks"].items()}
                det["largest_occupancy_cycles"] = max([p["net_time"] for p in packets] or [0])
                det["hops_max"] = max([len(p["path"]) - 2 for p in packets] or [0])
                # clock of a run: first clock at or above f_search whose phase is a whole number of 16-cycle steps
                steps = -(-Fraction(fmin).limit_denominator(10 ** 6) * T // 16)
                det["clock_of_a_run_hz"] = float(16 * steps / T)
        out["row"]["sets_clock"], out["row"]["drop_hz"] = setter(out["settings"], tol)
        save()
    out["complete"] = True
    save()
    return out


def _worker(args):
    name, d, arch_dir, cfg, out_path = args
    try:
        analyze(name, d, arch_dir, cfg, out_path)
    except BaseException as e:      # reported by the parent
        import traceback
        with open(out_path + ".error", "w") as f:
            f.write("".join(traceback.format_exception(type(e), e, e.__traceback__)))
        raise


def run(cfg, apps_dir, arch_dir, out_dir, only=None, jobs=1, timeout=None):
    """Every application of the config in its own process, at most `jobs`
    at a time; a process that runs longer than `timeout` s is stopped."""
    an = cfg["analysis"]
    timeout = an["timeout_s"] if timeout is None else timeout
    work = os.path.join(out_dir, "apps")
    os.makedirs(work, exist_ok=True)
    base = os.path.join(apps_dir, cfg["dir"])
    todo = [(a["name"], os.path.join(base, app_dir_name(a["name"]))) for a in selected(cfg, only)]
    ctx = multiprocessing.get_context("fork")
    running, results = {}, {}
    queue = list(todo)
    while queue or running:
        while queue and len(running) < max(1, jobs):
            name, d = queue.pop(0)
            path = os.path.join(work, app_dir_name(name) + ".json")
            for stale in (path, path + ".error", path + ".tmp"):
                if os.path.exists(stale):
                    os.remove(stale)
            p = ctx.Process(target=_worker, args=((name, d, arch_dir, cfg, path),))
            p.start()
            running[name] = (p, time.time(), path)
        time.sleep(0.2)
        for name in list(running):
            p, t0, path = running[name]
            elapsed = time.time() - t0
            status = None
            if not p.is_alive():
                status = "done" if p.exitcode == 0 else "failed"
            elif timeout and elapsed > timeout:
                p.terminate()
                p.join(10)
                if p.is_alive():
                    p.kill()
                status = "timeout"
            if status is None:
                continue
            p.join()
            del running[name]
            r = None
            if os.path.exists(path):
                with open(path) as f:
                    r = json.load(f)
            r = r or {"row": {"name": name}, "settings": {}, "complete": False}
            r["status"] = status
            r["wall_s"] = round(elapsed, 1)
            if status == "failed" and os.path.exists(path + ".error"):
                with open(path + ".error") as f:
                    r["error"] = f.read().strip().splitlines()[-1]
            results[name] = r
            print(_line(name, r), flush=True)
    m = {"_doc": "python -m rttools.paper.str2rts run: the analysis flow on the STR2RTS applications of "
                 "apps/" + cfg["dir"] + " (rttools/paper/str2rts.py, module docstring)",
         "model": {"header_wait_cycles": 20, "ni": "tt", "handlers": an["handlers"], "f0_hz": an["f0_hz"],
                   "settings": an["settings"]},
         "apps": {name: _public(results[name]) for name, _ in todo}}
    with open(os.path.join(out_dir, "metrics.json"), "w") as f:
        json.dump(m, f, indent=1)
    write_tables(out_dir, m)
    return m


def _public(r):
    """Result of one application without the wall times (metrics.json is
    compared with the reference)."""
    out = {k: v for k, v in r.items() if k not in ("timing_s", "wall_s")}
    out["finished_settings"] = sorted(r.get("settings", {}))
    return out


def _mhz(v):
    return "none" if v is None else f"{v / 1e6:.3f}"


def _line(name, r):
    row = r.get("row", {})
    if r["status"] == "failed":
        return f"{name}: FAILED ({r.get('error', 'no message')})"
    head = f"{name}: " + ("" if r["status"] == "done" else f"STOPPED after {r['wall_s']} s; ")
    if "f_search_hz" not in row:
        return head + "no result"
    return (head + f"{row['tasks']} tasks, {row['edges_between_pes']} edges between PEs, {row['criterion']}, "
            f"k {row['k']:g}, T {row['period_ms']:g} ms, f_CPU {_mhz(row['f_cpu_hz'])} MHz, "
            f"f_search {_mhz(row['f_search_hz'])} MHz, R_bound {row.get('r_bound_ms', float('nan')):.4f} ms of "
            f"D {row['deadline_ms']:g} ms, clock set by {row.get('sets_clock')}; "
            + ", ".join(f"{k} {_mhz(v['minimum_hz'])}" for k, v in r["settings"].items() if k != "flow")
            + f" ({r['wall_s']} s)")


COLUMNS = [("name", "Application"), ("tasks", "Tasks"), ("edges", "Edges"), ("mesh", "Mesh"),
           ("criterion", "Criterion"), ("m2", "M2"), ("k", "k"), ("period_ms", "T (ms)"),
           ("deadline_ms", "D (ms)"), ("phase_last", "n(v_last)"), ("edges_between_pes", "Edges between PEs"),
           ("packets_per_hyperperiod", "Packets per hyperperiod"), ("f_cpu_hz", "f_CPU (MHz)"),
           ("f_search_hz", "f_search (MHz)"), ("r_bound_ms", "R_bound (ms)"), ("sets_clock", "Clock set by")]


def write_tables(out_dir, m):
    def cell(key, v):
        if v is None:
            return "-"
        if key in ("f_cpu_hz", "f_search_hz"):
            return f"{v / 1e6:.3f}"
        if key == "m2":
            return f"{v:.1f}"
        if key == "r_bound_ms":
            return f"{v:.4f}"
        if key in ("k", "period_ms", "deadline_ms"):
            return f"{v:g}"
        return str(v)
    extra = [k for k in SETTINGS if k != "flow"]
    with open(os.path.join(out_dir, "table.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow([k for k, _ in COLUMNS] + [k + "_hz" for k in extra] + ["status"])
        for name, r in m["apps"].items():
            row = r.get("row", {})
            w.writerow([row.get(k) for k, _ in COLUMNS]
                       + [r["settings"].get(k, {}).get("minimum_hz") for k in extra] + [r["status"]])
    with open(os.path.join(out_dir, "table.md"), "w") as f:
        f.write("| " + " | ".join(t for _, t in COLUMNS) + " | " + " | ".join(k + " (MHz)" for k in extra) + " |\n")
        f.write("|" + "---|" * (len(COLUMNS) + len(extra)) + "\n")
        for name, r in m["apps"].items():
            row = r.get("row", {})
            f.write("| " + " | ".join(cell(k, row.get(k)) for k, _ in COLUMNS) + " | "
                    + " | ".join(_mhz(r["settings"].get(k, {}).get("minimum_hz")) if k in r["settings"] else "-"
                                 for k in extra) + " |\n")


def main(argv=None):
    p = argparse.ArgumentParser(prog="rttools.paper.str2rts", description=__doc__.split("\n\n")[0])
    sub = p.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("convert", help="write the applications from a STR2RTS checkout")
    c.add_argument("--config", required=True)
    c.add_argument("--str2rts", required=True, help="root of the STR2RTS checkout (the directory with src/)")
    c.add_argument("--apps", required=True, help="directory apps/ of the repository")
    c.add_argument("--check", action="store_true", help="compare with the files instead of writing them")
    c.add_argument("--only", nargs="*", default=None)
    r = sub.add_parser("run", help="analysis flow on the converted applications")
    r.add_argument("--config", required=True)
    r.add_argument("--apps", required=True)
    r.add_argument("--arch", required=True, help="directory arch/ of the repository")
    r.add_argument("--out", required=True)
    r.add_argument("--only", nargs="*", default=None)
    r.add_argument("--jobs", type=int, default=1)
    r.add_argument("--timeout", type=float, default=None, help="seconds per application (default: the config)")
    a = p.parse_args(argv)
    with open(a.config) as f:
        cfg = json.load(f)
    if a.cmd == "convert":
        try:
            same = convert(cfg, a.str2rts, a.apps, a.check, a.only)
        except ConvertError as e:
            print("error: " + str(e), file=sys.stderr)
            return 1
        return 0 if same else 1
    t0 = time.time()
    m = run(cfg, a.apps, a.arch, a.out, a.only, a.jobs, a.timeout)
    bad = [n for n, r in m["apps"].items() if r["status"] != "done"]
    print(f"wrote {a.out} ({len(m['apps'])} applications, {time.time() - t0:.0f} s"
          + (f"; not finished: {', '.join(bad)}" if bad else "") + ")")
    return 0


if __name__ == "__main__":
    if not __package__:
        # run as a file (python -I <this file> ...: the isolated mode of the Makefile for `convert`, which
        # reads a checkout from outside the repository): the package root is not on the module path
        sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    sys.exit(main())
