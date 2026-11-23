# Regeneration of the stored results with the queue section in every image

The critical section around the queue of a task (`pkt-sim/software/ucx-os/lib/noc.c`: dequeue of `ucx_noc_receive()`, local enqueue of `ucx_noc_send()`) is part of every image of this tree. The stored RTL logs, images, static costs and references of the runs up to tag r11-rc9 come from the code without it. This file gives the ordered commands that produce a new round of runs and every reference derived from them, what each step feeds, its time, and the values of the paper it can change. Section 7 records the round that these steps produced on this tree (round r12).

`<R>` stands for the letter of the new round (the round of tag r11-rc9 used V: VG, VH, VCV, VMA, W4, W5, CF6; round r12 uses X: XG, XH, XCV, XMA, with W6, W7, CF7 and XUCV). `$ENV_SETUP` is the value of `experiments/exp23/README.md` (Questa and riscv64-elf-gcc 12.2.0); `$PY` is a Python with `orca-rt-tools/requirements.txt`. Every `make` below takes `PYTHON=$PY`.

## 1. What changes and what does not

| Change | Effect on the images | Effect on the stored results |
|---|---|---|
| 32-bit TIMER1, CTC and OCR (RTL), limits of `hal.c`, step type of `lib/noc_tt.c` | none for a tick of at most 1,048,576 cycles: the images of `weird_a`, `car_v`, `wcet_e`, `carv_e` and `car_full` are byte-identical to those of commit 9aa22aa, and the RTL gives the same events log (application E, parameters of run VH) | none |
| Queue section in every image | every image changes: `ucx_noc_receive` 29 to 42 instructions, `ucx_noc_send` 99 to 106; the image is the one that commit 9aa22aa builds with `NOC_QUEUE_DI=1` | every RTL log, image and static cost of the applications below |

| Directory | Depends on the images | Regenerate |
|---|---|---|
| `ch6`, `ch7`, `zll`, `car-v`, `figures` (contraction) | no (analysis of graphs, Hermes RTL, costs of the CSV) | no |
| `exp23` `frequency`, `frequency-l0`, `tick`; `multiapp` `run check`; `car-full` `run check`; `str2rts` `run check` | no (costs of the CSV; the handler terms inject 622 and receive 4,803 of `str2rts/config.json` do not change, Section 5) | no |
| `wcet` (`images/tt`, `costs/tt`, `reference_tt.json`) | yes: static t(v) of the images | steps 1, 2, 5 |
| `tt` (`reference.json`), injection tables `app/<image>_tt.h` | yes: t(v) = max(CSV, static) | steps 3, 4 |
| `exp23` (runs VG, VH), `car-v-rtl` (VCV), `multiapp` (VMA), `wcet` (W4, W5, `reference_r11g.json`), `car-full` (CF6) | yes: RTL logs | steps 6, 7 |
| `cputime`, `ablation` | yes: read the logs, the job tables and the handler files of the runs | step 8 |
| `automotive` | reads the kernel terms of `wcet/reference_tt.json`, which do not change (Section 5) | check only (step 8) |
| `str2rts/rtl` | the stored runs and the runs of `run_all.sh` / `run_image_flow.sh` were built with `NOC_QUEUE_DI=1`, the code of this tree | APP-DES and APP-FIRBANK only (step 9); their `RUN_INFO` has the line `noc_queue_di=1`, which `simulate.sh` of this tree does not write |
| `exp23` run F (`reference_head.json`), `figures` (`reference_exp23.json`), runs A to H, T*, U*, CV, CV2, MA, W1 to W3, CF to CF5 | historical runs of their tags (other release rule, crt0, injection) | no, unless the paper keeps a number of them (Section 6) |

## 2. Before the runs

1. Keep the costs files of the stored runs, so that their analyses still find them by hash (`rttools/paper/ttcheck.py`, `costs_of_run`):

   ```
   cd experiments/wcet/costs/tt
   for a in weird_a car_v wcet_e carv_e car_full; do
     s=$(sha256sum $a.json | cut -c1-12)
     cp $a.json previous/$a-$s.json; cp $a.handlers.json previous/$a-$s.handlers.json
   done
   ```

   Hashes of the files of this tree: weird_a a863a70d841e, car_v e2f7ef03a6e1, wcet_e 23c7616402d2, carv_e d198619e24f8, car_full 390624704f2d.

## 3. Steps

| # | Command | Needs | Time | Writes | Feeds |
|---|---|---|---|---|---|
| 1 | `make -C experiments/wcet images-tt ENV_SETUP="$ENV_SETUP"`, then copy `build/img-tt/<app>/pkt-sim/software/ucx-os/build/target/image.elf` to `images/tt/<app>.elf` for the five applications and update `images/tt/BUILD.txt` | toolchain | 10 s | `wcet/images/tt/*.elf` | step 2 |
| 2 | `make -C experiments/wcet analyze-tt costs-tt`; write `reference_tt.json` from `build/tt/metrics.json` | Python | 11 s | `wcet/costs/tt/<app>.json`, `<app>.handlers.json`, `wcet/reference_tt.json` | steps 3, 4, 8; `tt`, `cputime`, `ablation`, `automotive`, `str2rts/config.json` (handlers) |
| 3 | `make -C experiments/tt run` (do not check yet: the tables of the tree still have the old costs) | Python | 14 s | `tt/build/metrics.json`: f_CPU, f_NoC, clock of each run | step 4 |
| 4 | Set the clocks of step 3 in the Makefiles (`exp23` `TT_CLOCKS`, `car-v-rtl` `TT_CLOCKS`, `wcet` `TT_CLOCKS` and the `F_CLK` lines of `images-tt`, `multiapp` `F_CLK`, `car-full` `F_CLK`), then `make -C experiments/exp23 tt`, `make -C experiments/car-v-rtl tt`, `make -C experiments/wcet app`, `make -C experiments/multiapp app`, `make -C experiments/car-full ucx` | Python | 5 s | `pkt-sim/software/ucx-os/app/{weird_a,car_v,wcet_e,carv_e,car_full}_tt.h` | steps 5, 6 |
| 5 | Check that the costs do not move, with no file of `wcet` replaced: `make -C experiments/wcet images-tt` (the images at the clocks and with the tables of step 4) and the static analysis of those images in another directory (`BUILD=build/again`, with `images/tt` pointing to them in a copy). Then `make -C experiments/wcet check-tt`, and `make -C experiments/tt run check` after `tt/reference.json` takes `tt/build/metrics.json` | toolchain, Python | 40 s | `tt/reference.json` | the costs of the new images must equal those of step 2 in every field but the hash of the image (the tables are data); `images/tt` and `costs/tt` stay those of steps 1 and 2, because each table names the hash of its costs file and each costs file the hash of its image; if a cost differs, repeat steps 1 to 5 |
| 6 | Commit, tag, and run from a clean checkout of the tag or a `git archive` of it (`REQUIRE_CLEAN=1`), in a directory outside /home. Runs of Section 4 | Questa, toolchain | Section 4 | `build/sim*/{events.txt,RUN_INFO,time.log}`, image and listing | step 7 |
| 7 | Store each run as `logs/<run>.{events.txt,RUN_INFO,time.txt,image.elf,image.lst}` (`exp23` also `noinstr.lst`, from `make software-without` at the clock of the run), analyze it and write its reference (Section 4, last column); add the runs to `TICK_RUNS` (`exp23`), to `check` (`car-v-rtl`, `wcet`, `car-full`), and a `check-<r>ma` target (`multiapp`) | Python | 1 to 2 min | `reference_<run>.json` | step 8 |
| 8 | `wcet`: a `config_<round>.json` as `config_r11g.json` on the new runs, `make analyze-<round> check-<round>`; `cputime/config.json` and `ablation/config.json` on the new runs and job tables, `make -C experiments/cputime`, `make -C experiments/ablation`; `make -C experiments/automotive`; `make -C experiments/tt timing` | Python | 3 min | `wcet/reference_<round>.json`, `cputime/reference.json`, `ablation/reference.json` | the paper |
| 9 | `APPS="APP-DES APP-FIRBANK" experiments/str2rts/rtl/run_image_flow.sh <work dir> 2`, then `python experiments/str2rts/rtl/summary.py` | Questa, toolchain, Python | Section 4 | `str2rts/rtl/app-{des,firbank}/` | `str2rts/rtl/summary.md` |
| 10 | `make -k -C experiments`; `cd orca-rt-tools && python -m pytest -q`; update the run names and clocks in `ARTIFACT.md`, `experiments/README.md` and the README of each directory | Python | 4 min + 7 min | | |

## 4. RTL runs

Wall time of `vsim` alone from the stored `logs/<run>.time.txt` of the same application and length (simulation host of `ARTIFACT.md`, one simulation at a time). A clock in bold differs from the stored run (Section 5).

| New run | Replaces | Command (in `experiments/<dir>`) | Clock (MHz) | Simulated | vsim wall | Analysis and reference |
|---|---|---|---|---|---|---|
| `<R>G` | VG | `exp23`: `make sim F_CLK=500000000 SIMDIR=build/sim-<R>G`; `make software-without F_CLK=500000000 SW=build/sw-<R>G` | 500 | 20 ms | 6 min 23 s | `make analyze check phase-check LOG=logs/<R>G.events.txt REF=reference_<R>G.json OUTDIR=build/results_<R>G` |
| `<R>H` | VH | `exp23`: the same with `F_CLK=449152000` | 449.152 | 20 ms | 5 min 53 s | the same with `<R>H` |
| `<R>CV` | VCV | `car-v-rtl`: `make sim F_CLK=441088000` | 441.088 | 11.5 ms | 16 min 34 s | `make analyze check-run phase-check LOG=logs/<R>CV.events.txt REF=reference_<R>CV.json OUTDIR=build/results_<R>CV` |
| `<R>MA` | VMA | `multiapp`: `make sim` | **458.016** | 11.5 ms | 23 min 12 s | `make analyze check-run phase-check LOG=logs/<R>MA.events.txt OUTDIR=build/results_<R>MA RUN_ID=<R>MA` |
| `W6` | W4 | `wcet`: `make sim F_CLK=500000000 SIM_NS=10500000` | 500 | 10.5 ms | 2 min 55 s | `make run-analyze check-run LOG=logs/W6.events.txt REF=reference_W6.json SPEC=specs/wcet_e_tt.json` |
| `W7` | W5 | `wcet`: `make sim F_CLK=234784000 SIM_NS=10500000` | **234.784** | 10.5 ms | 1 min 34 s | the same with `W7` |
| `CF7` | CF6 | `car-full`: `make sim` | **526.656** | 64 ms | 1 h 48 min | `make analyze check-run LOG=logs/CF7.events.txt REF=reference_CF7.json OUTDIR=build/results_CF7` |
| | UCV | `car-v-rtl`: `INJECTION=finish make sim F_CLK=380000000` (only if the event-triggered baseline of Table V must come from this kernel, Section 6) | 380 | 11.5 ms | 14 min 37 s | as `<R>CV`, reference of UCV |
| APP-FIRBANK | (none) | step 9 | 583.904 | 37 ms | about 1 h 30 min (estimate: 110 s per simulated ms of a 4x4 run at 450 MHz with three simulations, `str2rts/rtl/README.md`, scaled by the clock) | `pilot.sh` |
| APP-DES | (none) | step 9 | 725.768 | 85 ms | about 4 h 10 min (same estimate) | `pilot.sh` |

Total of the seven runs that replace the round of tag r11-rc9: 2 h 44 min 32 s of `vsim`, one at a time; with four at a time the wall time is the 1 h 48 min of `CF7` plus the load. With the event-triggered run: 2 h 59 min. The two STR2RTS runs add about 5 h 40 min (estimate). On this machine, with four other simulations, a 2x2 run of 20 ms took 12 min 13 s against the stored 5 min 53 s.

## 5. Values that the analysis steps already show (scratch copy of this tree, nothing overwritten)

Steps 1 to 5 ran in a scratch copy (images of riscv64-elf-gcc 12.2.0).

| Value | Reference | New |
|---|---|---|
| `wcet/reference_tt.json`: static t(v) of a task | | + 70 cycles per input edge (term `receive` 200 to 270 per packet); 231 keys differ: t(v) and terms of the tasks with an input edge, t(V_k) of the PEs, the hash of the five images, `read_one` of CAR-FULL 332 to 402 |
| t(v) of E: B, C, D, E, F, G, H, I | 53,972 88,375 20,371 44,590 77,278 98,471 32,876 66,178 | each + 70 |
| t(v) of E: J (three inputs) | 103,957 | 104,167 |
| Kernel terms (dispatch, tick, release, send_isr, receive_isr), w_NI of each image, longest section | E 13,225 and 1,151; CAR-V 11,924 and 1,098; CAR-FULL 14,893 and 1,191 | the same (the new sections: `ucx_noc_receive` 96, `ucx_noc_send` 107 cycles) |
| `tt`: E, f_CPU / f_NoC / clock of VH | 434.900 / 449.150 / 449.152 MHz | the same; R_bound 1.7481 ms the same |
| `tt`: CAR-V, f_CPU / f_NoC / clock of VCV | 380.000 / 441.082 / 441.088 MHz | the same |
| `tt`: WCET-E, f_CPU | 220.388 MHz | 220.528 MHz |
| `tt`: WCET-E, f_NoC and clock of W5 | 234.638, 234.656 MHz | 234.779, 234.784 MHz; R_bound 1.69772 to 1.69761 ms |
| `tt`: CARV-E, f_CPU | 443.346 MHz | 443.766 MHz |
| `tt`: CARV-E, f_NoC and clock of VMA | 457.596, 457.600 MHz | 458.015, 458.016 MHz |
| `tt`: CAR-FULL, f_CPU | 477.952 MHz | 479.352 MHz |
| `tt`: CAR-FULL, f_NoC and clock of CF6 | 526.056, 526.080 MHz | 526.617, 526.656 MHz |
| `tt`: CAR-FULL, largest data age bound | 14,975,294 cycles | 14,991,698 cycles |
| Injection tables at the new clocks, entries that change | | `weird_a_tt.h` 2, `car_v_tt.h` 8, `wcet_e_tt.h` 8, `carv_e_tt.h` 10, `car_full_tt.h` 222 |
| `automotive` (`make`, with the new `reference_tt.json`) | | `match` |
| Application E simulated on this tree with the parameters and the table of run VH (449.152 MHz, 20 ms; one run, not stored): CPU time per iteration of ABDF, C, EHI, GJ | 147,032 81,920 123,063.1 179,407.1 cycles | 147,383 81,980 123,357.1 179,699.9 cycles |
| The same run: largest response | 762,527 cycles (1.69770 ms) | 762,769 cycles (1.69824 ms); R_bound 785,171 cycles; no job after F (smallest slack 11,730 cycles), no packet enqueued after s, no injection violation, no monitor error, phases conform |
| Bound of the instrumentation writes per send (`exp23`, image of `weird_a_data` with `INJECTION=finish`) | 55 cycles, 23 instructions | 66 cycles, 26 instructions (`tests/test_paper_instrumentation.py`) |

With the old clocks the new costs have no link schedule for WCET-E (W5), CARV-E and CAR-FULL, so the three clocks must move before the runs.

## 6. Values of the paper that each step can change

| Step | Values |
|---|---|
| 2 | Static t(v) and t(V_k) of every table that lists them (Table IV, Sections VI-C to VI-I); the instrumentation bound per send |
| 3, 4 | f_CPU, f_NoC and the clock of WCET-E, CARV-E and CAR; R_bound and the data age bounds at those clocks; injection instants |
| 6, 7 | Every measured value of RQ1 and RQ2: CPU time per PE and per iteration, responses, packet latencies and slacks, margins to F(v) and to s, counts of packets and jobs |
| 8 | The intervals of `cputime` (Table IV, Fig. 5(a)); the minimum frequencies of `ablation` (Table V, Section VI-J: they use the costs of step 2 and the beta of the runs) |
| 9 | The rows of APP-DES and APP-FIRBANK of the STR2RTS table |

Decisions that the steps do not take:

- Runs TCV and UCV (event-triggered injection, Table V and Section VI-J) are of tags r11-rc3 and r11-rc5. A run with this kernel is `INJECTION=finish` (the crt0 of UCV); TCV has the crt0 of tag r11-rc3, which this platform does not use.
- `exp23` `make` and `figures` analyze run F (tag exp23-F: data-driven release, nested interrupts, injection at the end of the job). The application of that run on this kernel is `weird_a_data` with `INJECTION=finish`; the Gantt and the response per iteration of the article then come from another code than the runs of RQ1 and RQ2.
- `wcet/images/tt13` (riscv64-unknown-elf-gcc 13.2.0) needs that compiler; without it the gcc 13 rows of `reference_tt.json` stay those of the old images.

## 7. Round r12 (done)

The steps above ran on this tree. The runs come from a `git archive` of commit de85565 of branch `platform-all` (`repo_state=archive`, no tag), Questa Sim-64 2025.3 and riscv64-elf-gcc 12.2.0, with other simulations on the machine.

| Run | Replaces | Clock (MHz) | Simulated | vsim wall | Stored in |
|---|---|---|---|---|---|
| XG | VG | 500 | 20 ms | 11 min 37 s | `exp23/logs/XG.*`, `reference_XG.json` |
| XH | VH | 449.152 | 20 ms | 10 min 30 s | `exp23/logs/XH.*`, `reference_XH.json` |
| XCV | VCV | 441.088 | 11.5 ms | 22 min 14 s | `car-v-rtl/logs/XCV.*`, `reference_XCV.json` |
| XMA | VMA | 458.016 | 11.5 ms | 29 min 27 s | `multiapp/logs/XMA.*`, `reference_XMA_{CARV,E}.json` |
| W6 | W4 | 500 | 10.5 ms | 6 min 35 s | `wcet/logs/W6.*`, `reference_W6.json` |
| W7 | W5 | 234.784 | 10.5 ms | 2 min 53 s | `wcet/logs/W7.*`, `reference_W7.json` |
| CF7 | CF6 | 526.656 | 64 ms | 2 h 26 min 26 s | `car-full/logs/CF7.*`, `reference_CF7.json` |
| XUCV | TCV, UCV | 380 | 11.5 ms | 19 min 30 s | `car-v-rtl/logs/XUCV.*`, `reference_XUCV.json` |

Differences from the steps as written:

- Step 5: `wcet/images/tt` holds the images of step 1, built with the tables of the costs of round r11g, and `costs/tt` names their hashes. The images of the runs have the tables of the new costs: the same symbols, the same code and the same static t(v), other bytes inside the injection tables only (1 byte for E, 4 for CAR-V, 4 for WCET-E; `orca-rt-tools/tests/test_r11g_runs.py`). A round whose `images/tt` equals the images of its runs needs steps 1 and 2 once more after step 4 and before the runs.
- `wcet/images/tt13` comes from the module riscv64-elf/13.2.0 of the simulation host (`riscv64-elf-gcc (GCC) 13.2.0`), not from the container toolchain of round r11g.
- XUCV is the one run with the event-triggered injection (`INJECTION=finish`); the kernel of this tree has one `crt0.s`, so it replaces both TCV and UCV in `ablation/config.json`. Its `RUN_INFO` has `costs=max_csv_static`, because `app/car_v_tt.h` exists in the tree; the image does not use the table and the analysis takes the model of `injection=finish` (costs of the CSV).
- `tt/config.json`, `cputime/config.json` and `ablation/config.json` name the runs of round r12; `wcet/config_r12.json` and `make analyze-r12 check-r12` are the analysis of `config_r11g.json` on them. The runs of round r11g stay in the tree with their references and checks.
- APP-DES ran at 725.768 MHz (`str2rts/rtl/app-des/image-flow`). Its release comes in the middle of a tick, and the run analysis took the tick before as the start of each phase; `rttools/paper/ttcheck.py` (`release_tick`) and `rttools/paper/rtlapp.py` (`release_offset`) take the tick that applies the release. No stored analysis changes with it.
- `experiments/REGENERATED_VALUES.json` lists every number of the paper that comes from a stored reference, with its value in round r11g and in round r12.
