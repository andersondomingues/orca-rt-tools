"""Static t(v) of the image of a pilot run (rttools.wcet) against the costs of the CSV, and the
flow of the paper on that image: t(v) = max(CSV, static) and the handler charge of Eq. (7) with
the handler terms and the budgets of the image (the model of experiments/tt).

    PYTHONPATH=<repo>/orca-rt-tools python static_costs.py <APP> <work dir of pilot.sh> [--out <dir>]

Reads <work dir>/<name>/sim/pkt-sim/software/ucx-os/build/target/image.elf (the image that pilot.sh
simulated), the manifest of the generated application and apps/str2rts/<app>. Params of the
annotations (experiments/wcet/annotations): tcb = tasks of the largest PE plus the idle task;
heap_blocks = blocks of the heap of the largest PE (1 end block, 3 per task and for the idle task,
2 per comm, 1 per output packet and 2 packets in flight per input edge between PEs), rounded up to
a multiple of 8. Writes static.json (default: rtl/<app dir>/) and the costs and handlers files of
rttools.paper.wcet next to it.
"""
from __future__ import annotations

import argparse
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", "..", ".."))


def main(argv=None):
    p = argparse.ArgumentParser()
    p.add_argument("app")
    p.add_argument("work")
    p.add_argument("--out", default=None)
    a = p.parse_args(argv)
    from rttools.modules.frequency import search
    from rttools.modules.io import appparser, nocparser
    from rttools.modules.mapping import mapfile
    from rttools.modules.routing import router
    from rttools.paper import ttflow, wcet
    from rttools.paper.frequency import search_config
    from rttools.tui.model import network
    from rttools.wcet import costs as wcosts

    d = a.app.lower()
    name = "str2rts_" + "".join(c for c in d.split("-", 1)[1] if c.isalnum())
    run = os.path.join(a.work, name)
    out = a.out or os.path.join(HERE, d)
    os.makedirs(out, exist_ok=True)
    base = os.path.join(REPO, "apps", "str2rts", d)
    with open(os.path.join(base, "conversion.json")) as f:
        conv = json.load(f)
    manifest = os.path.join(run, "repo", "pkt-sim", "software", "ucx-os", "app", name + ".json")
    with open(manifest) as f:
        m = json.load(f)
    blocks = 0
    for pe in sorted({t["pe"] for t in m["tasks"]}):
        n = sum(1 for t in m["tasks"] if t["pe"] == pe)
        outs = sum(1 for fl in m["flows"] if fl["src_pe"] == pe)
        ins = sum(1 for fl in m["flows"] if fl["dst_pe"] == pe and not fl["local"])
        blocks = max(blocks, 1 + 3 * (n + 1) + 2 * n + outs + 2 * ins)
    params = {"tcb": max(len(ts) for ts in m["pe_tasks"].values()), "heap_blocks": -(-blocks // 8) * 8}
    ucx = os.path.join(REPO, "pkt-sim", "software", "ucx-os", "wcet")
    spec = {"image": os.path.join(run, "sim", "pkt-sim", "software", "ucx-os", "build", "target", "image.elf"),
            "annotations": [os.path.join(ucx, "ucx-os.json"), os.path.join(ucx, "ucxgen.json")],
            "params": params, "manifest": manifest}
    spec_path = os.path.join(out, "wcet_spec.json")
    with open(spec_path, "w") as f:
        json.dump(spec, f, indent=1)
    with network.quiet():
        res = wcet.static(spec_path, out)
    os.remove(spec_path)
    os.remove(os.path.join(out, "costs.json"))     # full analysis (large); costs_file.json and costs.csv stay

    csv_path = os.path.join(base, conv["files"]["csv"])
    arch = os.path.join(REPO, "arch", conv["arch"])
    entries = mapfile.read(os.path.join(base, conv["files"]["map"]))

    def flow(costs_path):
        with network.quiet():
            g, appname = appparser.loadFromFile(csv_path)
            noc = nocparser.loadFromFile(arch)
        if costs_path:
            wcosts.apply(g, costs_path, wcosts.MAX)
        prev = (router.set_header_wait("bound"), router.set_ni("tt"), router.set_deadline("tick"))
        try:
            with network.quiet():
                fr = search.minimum_frequency(g, noc, entries, appname, search_config(500000000))
                pm = ttflow.phase_model(g, noc, entries, fr["frequency_hz"])
        finally:
            router.set_header_wait(prev[0])
            router.set_ni(prev[1])
            router.set_deadline(prev[2])
        return {"f_cpu_hz": fr["f_cpu_hz"], "f_search_hz": fr["frequency_hz"],
                "r_bound_ms": pm["response_bound"]["ms"]}, g

    image_flow, g = flow(os.path.join(out, "costs_file.json"))
    csv_flow, g0 = flow(None)
    tasks = {}
    for t, r in res["tasks"].items():
        c = int(g0.nodes[t]["wcet"])
        tasks[t] = {"csv": c, "static": r["t"], "used": int(g.nodes[t]["wcet"]), "static_above_csv": r["t"] > c,
                    "isr": r["terms"]["send_isr"] + r["terms"]["receive_isr"]}
    k = res["kernel"]
    summary = {
        "_doc": "static_costs.py: static t(v) of the image of the pilot run against the CSV, and the flow with "
                "t(v) = max(CSV, static) and the handler terms of the image (flow_image) against the flow with the "
                "costs of the CSV and no handler charge (flow_csv); experiments/str2rts/reference.json holds the "
                "flow with the costs of the CSV and the handler terms of the image of CAR with budget 0",
        "app": a.app, "image": res["image"], "params": params,
        "kernel": {x: k[x] for x in ("dispatch", "tick", "release", "send_isr", "receive_isr_size",
                                     "receive_isr_end", "receive_isr")},
        "scheduler_cycles": {"csv": int(g0.graph.get("scheduler_cycles", 0)), "static": res["scheduler_cycles"]},
        "tasks": tasks,
        "tasks_static_above_csv": sorted(t for t, r in tasks.items() if r["static_above_csv"]),
        "largest_static_over_csv": max(r["static"] / r["csv"] for r in tasks.values()),
        "flow_image": image_flow, "flow_csv": csv_flow,
    }
    with open(os.path.join(out, "static.json"), "w") as f:
        json.dump(summary, f, indent=1)
        f.write("\n")
    above = summary["tasks_static_above_csv"]
    print(f"{a.app}: tcb {params['tcb']}, heap_blocks {params['heap_blocks']}; inject {k['send_isr']}, receive "
          f"{k['receive_isr']}; static above the CSV for {len(above)} of {len(tasks)} tasks"
          + (f" ({', '.join(above)})" if above else "")
          + f"; flow of the image: f_CPU {image_flow['f_cpu_hz'] / 1e6:.3f} MHz, f_search "
          f"{image_flow['f_search_hz'] / 1e6:.3f} MHz, R_bound {image_flow['r_bound_ms']:.4f} ms")
    return 0


if __name__ == "__main__":
    sys.exit(main())
