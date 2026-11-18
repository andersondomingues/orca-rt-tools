# RTL pilot of the STR2RTS applications

RTL runs of converted STR2RTS applications on the manycore of the repository (Questa Sim-64 2025.3, riscv64-elf-gcc 12.2.0), each analyzed against the phase model as `experiments/car-v-rtl` does. `summary.md` and `summary.json` (written by `summary.py`) hold one row per run.

| File | Content |
|---|---|
| `pilot.sh <APP> <work dir> [<iterations>]` | Generates the UCX-OS application (`rttools.ucxgen generate` and `tt`), simulates it (`experiments/exp23/simulate.sh`) and analyzes the log (`rttools.paper.rtlapp`, `rttools.paper.phasecheck`); header of the script |
| `static_costs.py <APP> <work dir>` | Static t(v) of the image of a run (`rttools.wcet`) against the CSV, and the flow with t(v) = max(CSV, static) and the handler terms of that image (`static.json`, `costs_file.json`, `costs_file.handlers.json`, `costs.csv`) |
| `summary.py` | `summary.json`, `summary.md` |
| `<app>/` | Run at the clock of `../reference.json`: generated `str2rts_<app>.{c,json,sim}` and `str2rts_<app>_tt.h`, `events.txt`, `RUN_INFO`, `time.log`, `metrics.json` and the CSV files of the analysis, `phasecheck.txt`, `memory.json` |
| `<app>/image-flow/` | Second run (`IMAGE_FLOW=1`) at the clock of the flow of the image, with the injection table of t(v) = max(CSV, static) |

Commands of the runs of this directory (work directory outside /home):

```
export ENV_SETUP="source /usr/share/Modules/init/bash; module load riscv64-elf/12.2.0; module load questa/2025.3"
rtl/pilot.sh APP-CFIR <work>; rtl/pilot.sh APP-CFAR <work>; rtl/pilot.sh APP-DCT <work>
rtl/pilot.sh APP-MATMULT <work>; rtl/pilot.sh APP-FFT <work>
RAM_BYTES=262144 rtl/pilot.sh APP-PERFTEST <work>
PYTHONPATH=../../orca-rt-tools python rtl/static_costs.py APP-CFIR <work>      (and APP-CFAR, APP-DCT, APP-MATMULT)
IMAGE_FLOW=1 rtl/pilot.sh APP-CFIR <work>                                      (and APP-CFAR, APP-DCT)
python rtl/summary.py
```

Do not edit `pilot.sh` while a run of it is in progress (bash reads the script as it runs): the runs of APP-MATMULT, APP-PERFTEST and APP-FFT of this directory lost their last step that way, and the commands of that step (heap check of the image, `rtlapp`, `phasecheck`, copy of the results) ran by hand on the finished simulations; their directories have no `wall.txt`.

## How a run is set up

- The script works on a copy of the repository in the work directory, so the generated application does not enter `pkt-sim/software/ucx-os/app` of this tree. The UCX-OS Makefile builds a generated application through its `GEN_APPS` rule, which lists `car_v`, `wcet_e`, `carv_e` and `e_ucx`; the script passes `GEN_APPS=<name>` in `MAKEFLAGS`. To build these applications with plain `make <name>`, their names have to enter `GEN_APPS` of `pkt-sim/software/ucx-os/Makefile`.
- Clock: the first F_CLK at or above f_search of `../reference.json` whose release period is a whole number of 16-cycle steps of TIMER1 (a multiple of 32 kHz for T = 0.5 ms).
- Injection table (`rttools.ucxgen tt`): link schedule at that clock with the costs of the CSV (`RUN_INFO`: `costs=csv`), so the model of the analysis of the run has no handler charge. The `image-flow` runs follow the procedure of the runs of `experiments/tt` instead.
- Simulated time: warm-up 3 ms + (n(v_last) + 9) T + R_bound + T, rounded up to 0.5 ms, for at least ten complete iterations.
- `RUN_INFO` has `repo_state=nogit` (the copy has no git metadata): the source is commit 830ed4a of branch `ieee-access` plus the files of this task.

## RAM of a PE

| Where | Value | How to change it without editing a file |
|---|---|---|
| `pkt-sim/manycore_modelsim/manycore_top.sv:20` | parameter `RAM_MSIZE = 65536` (bytes; `manycore_pe`, `dual_port_ram` and `ddma` take it; the address mask `RAM_MSIZE - 1` needs a power of two; the RAM region of the PE spans 0x40000000 to 0x5fffffff) | `VSIM_OPTS=-gRAM_MSIZE=<bytes>` of `simulate.sh` |
| `pkt-sim/software/ucx-os/arch/riscv/hf-riscv-e/hf-risc.ld:5` | `RAM (rwx) : ORIGIN = 0x40000000, LENGTH = 64K` (stack at the end of the RAM, heap from `_ebss` to 2 KiB below it) | `LDSCRIPT=<copy of the script with another LENGTH>` on the make command line; `build_sw.sh` passes no such variable, so `pilot.sh` puts it in `MAKEFLAGS` |

`RAM_BYTES=262144 pilot.sh APP-PERFTEST` does both (the image has a heap of 248,032 bytes). To make it a parameter of the repository scripts, `build_sw.sh` and `simulate.sh` need a variable that reaches `make LDSCRIPT=` and `vsim -gRAM_MSIZE=`.

## What the generator and the platform accept

Checked with `rttools.ucxgen generate` and `rttools.ucxgen memory` on the 17 applications (`max tasks per PE`, `in-degree` and heap from the CSV and the .map; heap of the worst PE with 2 packets in flight per input edge between PEs; the heap of a 64 KiB image is about 48 to 50 KiB):

| Application | Tasks | Flows | Tasks of the largest PE | Largest in-degree | Heap of the worst PE (B) | T (ms) | Generator |
|---|---|---|---|---|---|---|---|
| APP-CFIR | 3 | 2 | 1 | 1 | 4,548 | 0.5 | ok |
| APP-CFAR | 4 | 3 | 1 | 1 | 6,380 | 0.5 | ok |
| APP-DCT | 7 | 7 | 4 | 2 | 15,028 | 0.5 | ok |
| APP-PERFTEST | 16 | 18 | 1 | 4 | 201,648 | 0.5 | ok; RAM of 256 KiB |
| APP-AUDIOBEAM | 20 | 33 | 3 | 15 | 9,848 | 0.5 | ok; in-degree above the 8 queue slots |
| APP-MATMULT | 23 | 23 | 3 | 2 | 11,868 | 0.5 | ok |
| APP-FFT | 26 | 26 | 4 | 2 | 14,460 | 0.5 | ok |
| APP-FILTERBANK | 53 | 59 | 7 | 8 | 18,800 | 0.5 | refused: 52 letters |
| APP-BEAMFORMER | 56 | 69 | 9 | 12 | 23,024 | 1 | refused: 52 letters; tags; in-degree |
| APP-FMRADIO | 67 | 85 | 8 | 10 | 20,940 | 0.5 | refused: 52 letters; tags; in-degree |
| APP-DCALC | 84 | 101 | 10 | 2 | 25,292 | 1 | refused: 52 letters; tags |
| APP-80211A | 117 | 148 | 17 | 5 | 387,936 | 1 | refused: 52 letters; tags; tasks per PE; RAM of 512 KiB |
| APP-BITONIC | 122 | 151 | 15 | 4 | 37,684 | 1 | refused: 52 letters; tags |
| APP-FIR | 132 | 131 | 12 | 1 | 29,772 | 1 | refused: 52 letters; tags |
| APP-SERPENT | 234 | 266 | 24 | 2 | 80,788 | 1.5 | refused: 52 letters; tags; tasks per PE; RAM of 128 KiB; T |
| APP-FIRBANK | 340 | 350 | 28 | 12 | 80,508 | 2 | refused: 52 letters; tags; tasks per PE; in-degree; RAM of 128 KiB |
| APP-DES | 423 | 598 | 30 | 8 | 95,556 | 2 | refused: 52 letters; tags; tasks per PE; RAM of 128 KiB |

| Limit | Where | What it stops |
|---|---|---|
| 52 tasks per application | `ITER_LETTERS` of `rttools/ucxgen/model.py`: the iteration markers carry one ASCII letter per task (`include/device/cacc.h`, bits 30:24 of the word; the parser of the log reads `[A-Za-z]`) | Ten applications; the generator stops with `the iteration markers have 52 letters` |
| Tag of 16 bits | `flows x tag_mod + tag_mod - 1 <= 65535` (`model.py`); with the default `tag_mod` 1024, 63 flows | Nine applications with the default; `--tag-mod 64` covers 598 flows (the iteration of a packet then wraps at 64) |
| 15 tasks per PE | `MAX_TASKS 16` of `include/lib/noc.h` (with the idle task; arrays of `lib/noc.c` and `lib/tick_release.c`); `MAX_TASKS_PER_PE` of `model.py` | APP-80211A (17), APP-SERPENT (24), APP-FIRBANK (28), APP-DES (30) |
| 8 packets in the queue of a task | `MAX_PKT_QUEUE_SLOTS 8` of `include/lib/noc.h`; a join holds one packet per input edge until the last one arrives (the generator checks it only in the time-triggered pattern) | In-degree above 8: APP-AUDIOBEAM (15), APP-BEAMFORMER (12), APP-FIRBANK (12), APP-FMRADIO (10); not tried in simulation |
| Heap | 64 KiB of RAM less the image and the stack | APP-PERFTEST, APP-80211A, APP-SERPENT, APP-FIRBANK, APP-DES need more RAM (table above) |
| Release period | `simulate.sh` needs 1e9 / T(ns) whole (F_TICK in Hz) and T F_CLK a multiple of 16 cycles | APP-SERPENT (T = 1.5 ms: F_TICK 666.67 Hz) |
| Payload | 65,532 bytes (`MAX_PAYLOAD`) | None after the conversion (the ceiling of the converter) |

`MAX_TASKS` and `MAX_PKT_QUEUE_SLOTS` are plain `#define` lines of `noc.h`: raising them is an edit of that file (and of `MAX_TASKS_PER_PE` and the queue check of the generator), with more heap per task (2,268 bytes: TCB, scheduler record, stack, queue and its slots, each with a block header).

## Results

Nine runs, every check passed in each: no response above R_bound or the deadline, no phase of a PE above t(V_k), no late packet, no error of the packet monitor, the phases conform (`phasecheck`), no job ends after F, and no violation of the injection checks (injection delay, header wait, RX wait, end wait, occupancy, deadline, overlap at a network interface). `(table clock)`: the clock of `../reference.json` with the injection table of the costs of the CSV; `(image clock)`: the clock of the flow of the image with the table of t(v) = max(CSV, static). R_bound is the bound of the model of the run at its clock.

| Run | Mesh | F_CLK (MHz) | Costs of the table | RAM (B) | Simulated (ms) | vsim wall (s) | Iterations | Largest response (ms) | R_bound (ms) | D (ms) | Smallest CPU margin of a phase (%) | Packets | Late | Smallest packet slack (cycles) | Jobs after F | Injection violations | Phases conform | Every bound holds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| APP-CFAR (table clock) | 2x2 | 412.320 | csv | 65536 | 11.5000 | 304.4 | 14 | 1.5071 | 1.5267 | 2.0000 | 4.7 | 48 | 0 | 13707 | 0 | 0 | True | True |
| APP-CFAR (image clock) | 2x2 | 409.856 | max_csv_static | 65536 | 11.5000 | 294.2 | 14 | 1.5071 | 1.5269 | 2.0000 | 4.7 | 48 | 0 | 12475 | 0 | 0 | True | True |
| APP-CFIR (table clock) | 2x2 | 432.160 | csv | 65536 | 10.5000 | 288.4 | 13 | 1.0154 | 1.0341 | 1.5000 | 4.1 | 29 | 0 | 23279 | 0 | 0 | True | True |
| APP-CFIR (image clock) | 2x2 | 416.576 | max_csv_static | 65536 | 10.5000 | 272.6 | 13 | 1.0160 | 1.0354 | 1.5000 | 4.1 | 29 | 0 | 12430 | 0 | 0 | True | True |
| APP-DCT (table clock) | 2x2 | 412.704 | csv | 65536 | 12.5000 | 339.6 | 15 | 2.0461 | 2.1277 | 2.5000 | 4.7 | 70 | 0 | 13518 | 0 | 0 | True | True |
| APP-DCT (image clock) | 2x2 | 410.240 | max_csv_static | 65536 | 12.5000 | 333.4 | 15 | 2.0451 | 2.1394 | 2.5000 | 4.7 | 70 | 0 | 12286 | 0 | 0 | True | True |
| APP-FFT (table clock) | 4x4 | 463.264 | csv | 65536 | 16.5000 | 1758.4 | 19 | 4.0131 | 4.0503 | 4.5000 | 4.1 | 376 | 0 | 22839 | 0 | 0 | True | True |
| APP-MATMULT (table clock) | 4x4 | 432.224 | csv | 65536 | 19.5000 | 1935.5 | 22 | 5.5584 | 5.5990 | 6.0000 | 4.1 | 463 | 0 | 23391 | 0 | 0 | True | True |
| APP-PERFTEST (table clock) | 4x4 | 462.816 | csv | 262144 | 14.5000 | 1619.3 | 17 | 3.0065 | 3.0240 | 3.5000 | 4.1 | 369 | 0 | 12610 | 0 | 0 | True | True |

Wall time of `vsim` with three simulations at a time: 26 to 29 s per simulated ms on the 2x2 mesh and 99 to 112 s per simulated ms on the 4x4 mesh.

## Static costs of the images

`static_costs.py` on the image of each first run. The flow of `../reference.json` takes the costs of the CSV with inject 622 and receive 4,803 cycles and budget 0; the flow of the image takes t(v) = max(CSV, static), the handler terms of the image and the handler cycles of each task as its budget (the model of `experiments/tt`).

| Application | tcb | heap_blocks | inject | receive | Tasks with static t(v) above the CSV | Largest static / CSV | f_CPU of the image (MHz) | f_search of the image (MHz) | f_search of the table (MHz) | R_bound of the image (ms) |
|---|---|---|---|---|---|---|---|---|---|---|
| APP-CFAR | 2 | 16 | 622 | 2,438 | none | 0.969 | 378.972 | 409.824 | 412.312 | 1.5269 |
| APP-CFIR | 2 | 16 | 622 | 2,438 | none | 0.984 | 379.992 | 416.569 | 432.148 | 1.0354 |
| APP-DCT | 5 | 32 | 622 | 3,873 | T002 (15,426 against 13,822), T006 (17,676 against 14,763) | 1.197 | 379.504 | 410.213 | 412.701 | 2.1394 |
| APP-FFT | 5 | 32 | 622 | 3,873 | T002 (13,476 against 11,872), T025 (14,786 against 11,872) | 1.245 | 379.970 | 450.531 | 463.242 | 4.0582 |
| APP-MATMULT | 4 | 24 | 622 | 3,160 | T002 (12,440 against 11,661), T017 (30,227 against 28,849) | 1.067 | 379.974 | 418.064 | 432.201 | 5.6023 |
| APP-PERFTEST | 2 | 24 | 622 | 3,142 | T002 (19,359 against 13,029), T015 (19,501 against 11,406) | 1.710 | 379.918 | 448.639 | 462.811 | 3.0247 |

The static cost is above the cost of the CSV only for tasks with small bodies and two to four edges on one side (splitters and joiners: the send path costs 2,233 cycles per output edge and the handlers 622 per output and `receive` per input edge), and never on the PE that sets f_CPU, so f_CPU of the image equals f_CPU of the table in the six images. The clock of the flow of each image is below the clock of the table (the handler terms of these images are below those of the image of CAR, and the budgets are not 0). The images of the three `image-flow` runs, built at their clock with their table, have the same static t(v) as the images of the first runs.
