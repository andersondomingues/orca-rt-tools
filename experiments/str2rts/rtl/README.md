# RTL pilot of the STR2RTS applications

RTL runs of converted STR2RTS applications on the manycore of the repository (Questa Sim-64 2025.3, riscv64-elf-gcc 12.2.0), each analyzed against the phase model as `experiments/car-v-rtl` does. `summary.md` and `summary.json` (written by `summary.py`) hold one row per run.

| File | Content |
|---|---|
| `pilot.sh <APP> <work dir> [<iterations>]` | Generates the UCX-OS application (`rttools.ucxgen generate` and `tt`), simulates it (`experiments/exp23/simulate.sh`) and analyzes the log (`rttools.paper.rtlapp`, `rttools.paper.phasecheck`); header of the script |
| `static_costs.py <APP> <work dir>` | Static t(v) of the image of a run (`rttools.wcet`) against the CSV, and the flow with t(v) = max(CSV, static) and the handler terms of that image (`static.json`, `costs_file.json`, `costs_file.handlers.json`, `costs.csv`) |
| `run_all.sh <work dir> [<jobs>]` | Batch of the applications without a run, resumable (section below) |
| `summary.py` | `summary.json`, `summary.md` |
| `<app>/` | Run at the clock of `../reference.json`: generated `str2rts_<app>.{c,json,sim}` and `str2rts_<app>_tt.h`, `events.txt`, `RUN_INFO`, `time.log`, `metrics.json` and the CSV files of the analysis, `phasecheck.txt`, `memory.json` |
| `<app>/image-flow/` | Second run (`IMAGE_FLOW=1`) at the clock of the flow of the image, with the injection table of t(v) = max(CSV, static) |

Commands of the runs of this directory (work directory outside /home):

```
export ENV_SETUP="source /usr/share/Modules/init/bash; module load riscv64-elf/12.2.0; module load questa/2025.3"
rtl/pilot.sh APP-CFIR <work>; rtl/pilot.sh APP-CFAR <work>; rtl/pilot.sh APP-DCT <work>
rtl/pilot.sh APP-MATMULT <work>; rtl/pilot.sh APP-FFT <work>
RAM_BYTES=262144 rtl/pilot.sh APP-PERFTEST <work>
rtl/pilot.sh APP-FILTERBANK <work>; rtl/pilot.sh APP-AUDIOBEAM <work>     (after the limits were lifted)
PYTHONPATH=../../orca-rt-tools python rtl/static_costs.py APP-CFIR <work>      (and APP-CFAR, APP-DCT, APP-MATMULT)
IMAGE_FLOW=1 rtl/pilot.sh APP-CFIR <work>                                      (and APP-CFAR, APP-DCT)
python rtl/summary.py
```

Do not edit `pilot.sh` in place while a run of it is in progress (bash reads the script as it runs; replace the file instead): the runs of APP-MATMULT, APP-PERFTEST and APP-FFT of this directory lost their last step that way, and the commands of that step (heap check of the image, `rtlapp`, `phasecheck`, copy of the results) ran by hand on the finished simulations; their directories have no `wall.txt`. The first six applications ran before the limits of the next section were lifted, with `GEN_APPS=<name>` in `MAKEFLAGS` and, for APP-PERFTEST, `LDSCRIPT` in `MAKEFLAGS` and `VSIM_OPTS=-gRAM_MSIZE=262144`; APP-CFAR ran again with the present scripts and gave the same `metrics.json`, `events.txt` and analysis files.

## How a run is set up

- The script works on a copy of the repository in the work directory, so the generated application does not enter `pkt-sim/software/ucx-os/app` of this tree. The UCX-OS Makefile builds every `app/str2rts_*.c` with the rule of the generated applications.
- Clock: the first F_CLK at or above f_search of `../reference.json` whose release period is a whole number of cycles and of 16-cycle steps of TIMER1 (a multiple of 32 kHz for T = 0.5 ms and 1.5 ms, 16 kHz for 1 ms, 8 kHz for 2 ms).
- Injection table (`rttools.ucxgen tt`): link schedule at that clock with the costs of the CSV (`RUN_INFO`: `costs=csv`), so the model of the analysis of the run has no handler charge. The `image-flow` runs follow the procedure of the runs of `experiments/tt` instead.
- Simulated time: warm-up 3 ms + (n(v_last) + 9) T + R_bound + T, rounded up to 0.5 ms, for at least ten complete iterations.
- Limits and RAM: next section. `<work>/<name>/build.txt` (copied to `<app>/build.txt`) records the limits, the RAM and the heap of the build.
- `RUN_INFO` has `repo_state=nogit` (the copy has no git metadata).

## Limits of the kernel, of the generator and of the scripts

Every limit below keeps its value for the applications of the tree: their generated files and their images are byte-identical to those before the change (commit messages of `pkt-sim/software/ucx-os`, `rttools/ucxgen` and `experiments/exp23`).

| Limit | Default | Above it |
|---|---|---|
| Tasks of an application | 52: one marker letter per task (`ITER_LETTERS` of `rttools/ucxgen/model.py`) | One letter per task of a PE (manifest `"iter_letters": "pe"`); the log line of a marker names the PE and `rttools.paper.rtlapp` reads (PE, letter). At most 52 tasks on one PE. One release period only: the time-triggered pattern and the composition keep the limit |
| Flows | 63 with the tag modulus 1024 (16-bit tag = flow x modulus + iteration mod modulus) | The generator takes the largest power of two that fits (64 for the 598 flows of APP-DES); the analysis unwraps the iteration of a packet in time order per flow |
| Tasks of a PE | 15 (`MAX_TASKS` 16 of `include/lib/noc.h`, with the idle task) | The generator writes `MAX_TASKS=<tasks + 1>` in `<name>.sim`; `simulate.sh` passes it to the build (`make MAX_TASKS=`) |
| Packets in the queue of a task | 8 (`MAX_PKT_QUEUE_SLOTS` of `noc.h`) | For a task with 5 input edges or more the generator writes `MAX_PKT_QUEUE_SLOTS=<power of two of at least 2 x input edges>` in `<name>.sim`: one packet per input edge of the iteration the task waits for and one of the next |
| Packets of a PE that wait for their injection instant | 8 (`NOC_TT_SLOTS` of `lib/noc_tt.c`) | `rttools.ucxgen tt` writes the line `Queue: NOC_TT_SLOTS <n>` in the injection table instead of stopping; `simulate.sh` passes it to the build |
| RAM of a PE | 64 KiB (`RAM_MSIZE` of `manycore_top.sv`, `LENGTH` of `hf-risc.ld`) | `RAM_BYTES=<power of two>` of `simulate.sh` and `build_sw.sh` sets both; `pilot.sh` takes the first size from 64 KiB whose image links and whose heap holds the demand of the worst PE |
| Release period | 1e9 / T(ns) whole (F_TICK in Hz) | `simulate.sh` gives the build the tick in cycles (`TICK_CYCLES`, `UCX_TICK_CYCLES` of `hal.c`) for another period (1.5 ms of APP-SERPENT); T F_CLK stays a multiple of 16 cycles |
| Payload | 65,532 bytes (`MAX_PAYLOAD`) | Not lifted (the ceiling of the converter) |

What each application takes above the defaults (`rttools.ucxgen generate` and `tt`, build of `pilot.sh` with `STEP=build`; heap demand of the worst PE with 2 packets in flight per input edge between PEs):

| Application | Tasks | Flows | Marker letters | Tag modulus | MAX_TASKS | MAX_PKT_QUEUE_SLOTS | NOC_TT_SLOTS | RAM | Heap of the image (B) | Demand (B) | T (ms) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| APP-FILTERBANK | 53 | 59 | per PE | 1024 | default | 16 | default | 64 KiB | 42,256 | 19,024 | 0.5 |
| APP-AUDIOBEAM | 20 | 33 | per task | 1024 | default | 32 | 16 | 64 KiB | 45,584 | 10,136 | 0.5 |
| APP-BEAMFORMER | 56 | 69 | per PE | 512 | default | 32 | 16 | 64 KiB | 39,360 | 23,888 | 1 |
| APP-FMRADIO | 67 | 85 | per PE | 512 | default | 32 | 16 | 64 KiB | 38,656 | 21,708 | 0.5 |
| APP-DCALC | 84 | 101 | per PE | 512 | default | default | default | 64 KiB | 42,672 | 25,292 | 1 |
| APP-80211A | 117 | 148 | per PE | 256 | 18 | 16 | default | 512 KiB | 495,132 | 388,288 | 1 |
| APP-BITONIC | 122 | 151 | per PE | 256 | default | default | default | 128 KiB | 102,368 | 37,684 | 1 |
| APP-FIR | 132 | 131 | per PE | 256 | default | default | default | 64 KiB | 40,192 | 29,772 | 1 |
| APP-SERPENT | 234 | 266 | per PE | 128 | 25 | default | default | 128 KiB | 94,684 | 80,788 | 1.5 |
| APP-FIRBANK | 340 | 350 | per PE | 128 | 29 | 32 | 16 | 256 KiB | 182,132 | 83,196 | 2 |
| APP-DES | 423 | 598 | per PE | 64 | 31 | 16 | default | 256 KiB | 183,984 | 96,516 | 2 |

The six applications of the first pilot take every default except the RAM of APP-PERFTEST (256 KiB).

## Batch of the remaining applications (`run_all.sh`)

```
export ENV_SETUP="source /usr/share/Modules/init/bash; module load riscv64-elf/12.2.0; module load questa/2025.3"
STEP=build rtl/run_all.sh <work> 3      # dry run: generate, build and check the heap of each application (about 2 min)
nohup rtl/run_all.sh <work> 3 > <work>/run_all.out 2>&1 &
```

The batch runs the applications without a run (APP-DES, APP-SERPENT, APP-DCALC, APP-FIR, APP-80211A, APP-BITONIC, APP-FIRBANK, APP-BEAMFORMER, APP-FMRADIO; `APPS=` names others), the longest first, three at a time. `<work>/status.txt` has one line per application (waiting, running, done, failed, skipped, built), `<work>/logs/<APP>.log` the output of `pilot.sh`, `<work>/failed/<APP>` the exit code and the last lines of a failed one; a failure does not stop the others. An application whose `rtl/<app>/` holds `metrics.json`, `events.txt`, `RUN_INFO` and `phasecheck.txt` is skipped, so the same command resumes an interrupted batch. At the end `summary.py` rewrites `summary.json` and `summary.md`.

Simulated time and expected wall time of `vsim` (105 s per simulated ms on the 4x4 mesh with three at a time, the rate of the pilot): APP-DES 85 ms (2 h 29 min), APP-SERPENT 64 ms (1 h 52 min), APP-DCALC 45.5 ms (1 h 20 min), APP-FIR 44 ms (1 h 17 min), APP-80211A 40 ms (1 h 10 min), APP-BITONIC 38 ms (1 h 6 min), APP-FIRBANK 36.5 ms (1 h 4 min), APP-BEAMFORMER 21.5 ms (38 min), APP-FMRADIO 12.5 ms (22 min); 11 h 18 min of `vsim` in all, about 4 hours with three at a time.

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

## Runs at the clock of the image (`run_image_flow.sh`), 18 November 2026

The runs of the tables above with the costs of the CSV ("table clock") are kept as they were made, with
the kernel before the correction of the queue of a task. They are not the procedure of the paper. The
procedure is the one of `experiments/tt`: build the image, compute its static t(v) and handler terms
(`static_costs.py`), take the clock of the flow with t(v) = max(CSV, static), and simulate at that clock
(`IMAGE_FLOW=1 pilot.sh`, results in `app-<name>/image-flow/`). `run_image_flow.sh <work dir> [<jobs>]`
does this for every application, a few at a time, and is resumable. `summary.py` lists both kinds of run
in `summary.json` and `summary.md`.

Three findings of these runs:

- **Costs of the CSV alone are not sound for a task that sends many packets.** APP-AUDIOBEAM at the
  table clock (690.368 MHz): task T002, a splitter with 15 output packets, has a CSV cost of 100,500
  cycles and a static t(v) of 141,745; 40 of 379 jobs ended after F and 39 packets were injected after
  the injection bound. With the static costs the flow returns 728.40 MHz. For the large applications
  the static cost exceeds the CSV cost for almost every task (422 of 423 in APP-DES), so the clocks of
  `../reference.json`, which take the costs of the CSV, are below the clocks of the complete flow.
- **A data race in the kernel lost counts of the queue of a task** (`lib/noc.c`, `ucx_noc_receive()`:
  dequeue with interrupts enabled). APP-AUDIOBEAM at the image clock met every bound for 13 iterations,
  then the join of 15 inputs found its queue reported as empty with packets in it and ran one phase
  late. Commit f97a8a8 adds the critical section (`NOC_QUEUE_DI=1`), and `pilot.sh` builds every STR2RTS
  image with it. Every run of `image-flow/` has it (`noc_queue_di=1` in `RUN_INFO`).
- **Start-up of APP-80211A.** Each task does its one-time setup on its first dispatch, one task per
  tick. With 13 tasks on a PE and a tick of 1 ms, the setup of three tasks was still running after the
  first release at 3 ms: three PEs exceeded their CPU estimate in the first three phases and the first
  job of one task ended 4,836 cycles after F. The stored run has `WARMUP_NS=8000000` (first release at
  8 ms) and five more iterations (`WARMUP_NS=8000000 IMAGE_FLOW=1 pilot.sh APP-80211A <work> 15`).

Result: the fifteen applications whose tick fits TIMER1 meet every bound at the clock of their image
(`summary.md`). APP-DES and APP-FIRBANK need a tick above 16 x 65,536 cycles at their image clock and
do not build on this tree; branch `platform-all` widens TIMER1.
