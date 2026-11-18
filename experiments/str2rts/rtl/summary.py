"""One row per pilot run of this directory (metrics.json of rttools.paper.rtlapp, RUN_INFO, time.log):
clock, simulated time, wall time of vsim, complete iterations and every check of the run against the
phase model. Writes summary.json and summary.md next to this file.

    python summary.py
"""
from __future__ import annotations

import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))


def run_row(d, previous=None):
    with open(os.path.join(d, "metrics.json")) as f:
        m = json.load(f)
    info = dict(line.split("=", 1) for line in open(os.path.join(d, "RUN_INFO")).read().split() if "=" in line)
    # wall time of vsim: time.log of the run (not stored in the repository: *.log is ignored), else the line
    # vsim_wall_s of wall.txt, else the value of the stored summary.json
    wall = previous
    if os.path.exists(os.path.join(d, "wall.txt")):
        k = re.search(r"^vsim_wall_s=([\d.]+)", open(os.path.join(d, "wall.txt")).read(), re.M)
        if k:
            wall = float(k.group(1))
    if os.path.exists(os.path.join(d, "time.log")):
        for line in open(os.path.join(d, "time.log")):
            k = re.search(r"Elapsed \(wall clock\) time.*: (?:(\d+):)?(\d+):([\d.]+)", line)
            if k:
                wall = int(k.group(1) or 0) * 3600 + int(k.group(2)) * 60 + float(k.group(3))
    r, cw, tt, pc = m["responses"], m["cpu_windows"], m["tt"], m["phase_conformance"]
    mesh = re.search(r"mesh=(\d+x\d+)", open(os.path.join(d, "RUN_INFO")).read()).group(1)
    pes = cw["pes"]
    row = {
        "mesh": mesh, "clock_hz": m["clock"]["clock_hz"], "costs": info.get("costs"),
        "ram_bytes": int(re.search(r"RAM_MSIZE=(\d+)", open(os.path.join(d, "RUN_INFO")).read()).group(1))
        if "RAM_MSIZE" in open(os.path.join(d, "RUN_INFO")).read() else 65536,
        "sim_ms": int(info["sim_ns"]) / 1e6, "vsim_wall_s": wall,
        "releases": m["releases"]["count"], "complete_iterations": r["complete"],
        "r_bound_ms": m["model"]["response_bound"]["ms"], "deadline_ms": m["model"]["deadline"]["ms"],
        "response_max_ms": r["max_ms"], "responses_above_r_bound": r["above_bound"],
        "responses_above_deadline": r["above_deadline"],
        "cpu_pes": len(pes), "cpu_pes_mean_above_estimate": sum(p["mean"] > p["estimated"] for p in pes.values()),
        "cpu_phases_above_estimate": sum(p["phases_above_estimate"] for p in pes.values()),
        "cpu_smallest_margin_percent": min(100 * (p["estimated"] - p["phase_busy_max"]) / p["estimated"]
                                           for p in pes.values()),
        "packets_between_pes": m["packets"]["remote_packets"], "packets_late": m["packets"]["late"],
        "packet_slack_min_cycles": m["packets"]["min_slack_remote_cycles"],
        "monitor_errors": m["monitor"]["errors"],
        "phase_conforms": pc["conforms"], "phases": pc["phases"], "jobs": pc["jobs"],
        "jobs_after_F": tt["jobs"]["late"], "job_slack_min_cycles": tt["jobs"]["slack_min"],
        "tt_packets": tt["packets"], "tt_violations": tt["violations"], "tt_ni_overlaps": tt["ni_overlaps"],
        "tt_inject_delay_max": tt["inject_delay_max"], "tt_rx_wait_max": tt["rx_wait_max"],
        "tt_end_wait_max": tt["end_wait_max"], "tt_occupancy_slack_min": tt["occupancy_slack_min"],
        "tt_deadline_slack_min": tt["deadline_slack_min"],
    }
    row["all_bounds_hold"] = (row["responses_above_r_bound"] == 0 and row["responses_above_deadline"] == 0
                              and row["cpu_phases_above_estimate"] == 0 and row["cpu_pes_mean_above_estimate"] == 0
                              and row["packets_late"] == 0 and row["monitor_errors"] == 0 and row["phase_conforms"]
                              and row["jobs_after_F"] == 0 and row["tt_violations"] == 0)
    return row


def main():
    rows = {}
    old = {}
    if os.path.exists(os.path.join(HERE, "summary.json")):
        with open(os.path.join(HERE, "summary.json")) as f:
            old = json.load(f)
    for app in sorted(os.listdir(HERE)):
        for sub, label in (("", "table"), ("image-flow", "image")):
            d = os.path.join(HERE, app, sub)
            if os.path.isfile(os.path.join(d, "metrics.json")):
                key = f"{app.upper()} ({label} clock)"
                rows[key] = run_row(d, (old.get(key) or {}).get("vsim_wall_s"))
    with open(os.path.join(HERE, "summary.json"), "w") as f:
        json.dump(rows, f, indent=1)
        f.write("\n")
    cols = [("mesh", "Mesh"), ("clock_hz", "F_CLK (MHz)"), ("costs", "Costs of the table"), ("ram_bytes", "RAM (B)"),
            ("sim_ms", "Simulated (ms)"), ("vsim_wall_s", "vsim wall (s)"), ("complete_iterations", "Iterations"),
            ("response_max_ms", "Largest response (ms)"), ("r_bound_ms", "R_bound (ms)"), ("deadline_ms", "D (ms)"),
            ("cpu_smallest_margin_percent", "Smallest CPU margin of a phase (%)"),
            ("packets_between_pes", "Packets"), ("packets_late", "Late"),
            ("packet_slack_min_cycles", "Smallest packet slack (cycles)"), ("jobs_after_F", "Jobs after F"),
            ("tt_violations", "Injection violations"), ("phase_conforms", "Phases conform"),
            ("all_bounds_hold", "Every bound holds")]

    def cell(k, v):
        if k == "clock_hz":
            return f"{v / 1e6:.3f}"
        if isinstance(v, float):
            return f"{v:.4f}" if k.endswith("_ms") else f"{v:.1f}"
        return "-" if v is None else str(v)
    with open(os.path.join(HERE, "summary.md"), "w") as f:
        f.write("| Run | " + " | ".join(t for _, t in cols) + " |\n|" + "---|" * (len(cols) + 1) + "\n")
        for name, r in rows.items():
            f.write(f"| {name} | " + " | ".join(cell(k, r[k]) for k, _ in cols) + " |\n")
    for name, r in rows.items():
        print(f"{name}: {r['clock_hz'] / 1e6:.3f} MHz, {r['sim_ms']:g} ms in {r['vsim_wall_s'] or 0:.0f} s, "
              f"{r['complete_iterations']} iterations, response {r['response_max_ms']:.4f} <= R_bound "
              f"{r['r_bound_ms']:.4f} <= D {r['deadline_ms']:g} ms, every bound holds: {r['all_bounds_hold']}")


if __name__ == "__main__":
    main()
