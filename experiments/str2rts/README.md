# STR2RTS applications in the analysis flow

Seventeen SDF task graphs of the STR2RTS suite (B. Rouxel and I. Puaut, WCET 2017; https://gitlab.inria.fr/brouxel/STR2RTS, commit `aa57db66774e1f3c06a8a790a3e7097af0591f36`) converted to the application format of the flow (`apps/str2rts/<app>/`) and analyzed with the flow of the paper, without RTL (`rttools/paper/str2rts.py`). `rtl/` holds a pilot of RTL runs of six of them.

| Target | Action | Requirements |
|---|---|---|
| `make` | `run` + `check` | Python with `orca-rt-tools/requirements.txt` |
| `make run` | Analysis of each application of `config.json`; `build/metrics.json`, `build/table.{csv,md}`, `build/apps/<app>.json` (written while the application runs) | 12 min 19 s with `JOBS=5` on the machine of the reference (APP-FMRADIO 739 s and APP-AUDIOBEAM 332 s of link schedules; the other fifteen 1 s to 18 s each) |
| `make check` | `build/metrics.json` against `reference.json` | |
| `make app STR2RTS=<checkout>` | The files of `apps/str2rts` against a new conversion | A checkout of STR2RTS; standard library only; about 2 min |
| `make convert STR2RTS=<checkout>` | Writes `apps/str2rts` | The same |

`ONLY="APP-CFAR APP-CFIR"` restricts a target to some applications; `JOBS` sets the applications that run at the same time; `TIMEOUT` (s, default 1200) stops an application and reports the settings it finished.

## Applications

One XML description per benchmark (`config.json`, with the SHA-256 of each file). The converter reads the XML only: `<task id WCET>`, `<prev id data-sent data-type>` and `<data-type name size>`. The C sources of the suite are not read and are not in this repository.

| Name | XML of STR2RTS (`src/`) | Tasks | Edges |
|---|---|---|---|
| APP-80211A | `802.11a/SDF-transmit_nocache.xml` | 117 | 148 |
| APP-AUDIOBEAM | `Audiobeam/SDF-Audiobeam_nocache.xml` | 20 | 33 |
| APP-BEAMFORMER | `BeamFormer/SDF-BeamFormer_nocache.xml` | 56 | 69 |
| APP-CFIR | `ComplexFIR/SDF-ComplexFIR_nocache.xml` | 3 | 2 |
| APP-FIR | `FIR/SDF-FIR_nocache.xml` | 132 | 131 |
| APP-FMRADIO | `FMRadio/SDF-FMRadio_nocache.xml` | 67 | 85 |
| APP-FILTERBANK | `Filterbank/SDF-FilterBankNew_nocache.xml` | 53 | 59 |
| APP-BITONIC | `bitonicsort/SDF-BitonicSort_nocache.xml` | 122 | 151 |
| APP-CFAR | `cfar/SDF-CFARtest_nocache.xml` | 4 | 3 |
| APP-DCALC | `dcalc/SDF-dcalc_nocache.xml` | 84 | 101 |
| APP-DCT | `dct/SDF-DCTverify_nocache.xml` | 7 | 7 |
| APP-DES | `des/SDF-DES_nocache.xml` | 423 | 598 |
| APP-FFT | `fft/SDF-FFT2_nocache.xml` | 26 | 26 |
| APP-FIRBANK | `firbank/SDF-FIRBank_nocache.xml` | 340 | 350 |
| APP-MATMULT | `matmult/SDF-MatrixMultBlock_nocache.xml` | 23 | 23 |
| APP-PERFTEST | `perftest/SDF-perftest_nocache.xml` | 16 | 18 |
| APP-SERPENT | `serpent/SDF-Serpent_nocache.xml` | 234 | 266 |

Files of `apps/str2rts/<app>/` (the directory is the paper name in lower case):

| File | Content |
|---|---|
| `<app>.csv` | Application: tasks (acronym T001, T002, ... in the order of the XML; the Description column holds the task id of the XML), flows, `release_model,phase`, `scheduler_cycles,11000` |
| `<app>-ONTO-hermes<W>x<H>.map` | Spiral Mapping of the clusters of step 1 (`node:TASK,TASK`, node = y W + x) |
| `names.csv` | Acronym, task id of the XML, WCET of the XML |
| `conversion.json` | Values of the conversion: source XML with its SHA-256 and the commit, k, T, D, n(v_last), budget, criterion, M2, largest cluster, bits of each data type and where they come from, edges at the payload floor, edges above the largest packet (with their bytes), the periods tried and the probes of k |

## Conversion rules

`config.json` holds the parameters; the docstring of `rttools/paper/str2rts.py` states the rules in full.

| Quantity | Rule |
|---|---|
| Cost | c(v) = round(k WCET) + 11,000 cycles (round half up; 11,000 = one scheduler event, as `apps/car-v/car-v.csv`) |
| Payload | ceil(data-sent x bits of the data type / 8) bytes. Bits: the `<data-type>` rows of the XML (every file declares `int` = 64 b and `complex` = 100 b), otherwise float 32, int 32, complex 64, bit 1, void 0. At least 4 bytes, at most 65,532 bytes |
| Mesh | 4x4 with at least 16 tasks, otherwise 2x2 |
| Clustering, mapping | Step 1 of the flow (ORT/GCM with MIN_COMM, MAX_COMM, MIN_PROC, MAX_PROC; smallest M2) on N = mesh nodes, then the Spiral Mapping |
| T | The first multiple of 0.5 ms at which 11,000 x (tasks of the cluster with the most tasks) is at most half of 380e6 x T cycles, with the clustering of k(T) |
| k | k(T): the largest factor with two decimals whose largest cluster cost is at most 380e6 x T cycles (f_CPU <= 380 MHz); bisection with the clustering in the loop, then 64 probes above the result |
| D | (n(v_last) + 1) T for every task, n = phase index of the mapping |

Notes on the rules:

- Payload floor. The analysis accepts a payload of 0 bytes (a packet of the 12-byte kernel header, 3 flits); the time-triggered pattern of `rttools.ucxgen` needs 4 bytes (the job index). The floor of 4 bytes (one flit) is the smallest payload that every tool of the flow takes. Edges at the floor: APP-80211A 16, APP-BEAMFORMER 16, APP-DCALC 5, APP-DES 32, APP-SERPENT 33 (edges of type void or with data-sent 0).
- Largest packet. `payload_size` of `noc_packet_t` has 16 bits and the kernel rounds the payload up to a multiple of 4, so the largest payload is 65,532 bytes (`MAX_PAYLOAD` of `rttools/ucxgen/model.py`), 3 bytes below 65,535. Edges above it are cut to one packet of 65,532 bytes: APP-80211A 11 edges (78,013 to 5,120,000 bytes) and APP-PERFTEST 1 edge (66,000 bytes); `conversion.json` lists them. The application format has one flow per pair of tasks and one packet per flow and period, so the rest of the data of these edges is not modeled.
- Fewer tasks than PEs. APP-CFIR has 3 tasks on the 2x2 mesh: ORT/GCM stops at one cluster per task and the Spiral Mapping places the 3 clusters on the first 3 nodes of the spiral (nodes 0, 1, 3); node 2 stays empty. APP-CFAR (4 tasks) and APP-PERFTEST (16 tasks) have one task per PE.
- k is not monotone. The largest cluster cost jumps when the clustering changes with k, so the set of factors that meet the budget is not an interval. at T = 1 ms APP-80211A exceeds the budget for k from 24 to 25.1 and from 26 to the bound of one task alone (35.59) and meets it from 25.2 to 25.94 (an interval that the probes found; f_CPU 361.5 MHz), and APP-DES stops at k = 61.12 with f_CPU 349.6 MHz at T = 2 ms (61.13 gives a clustering above the budget; no probe up to the bound of one task alone, 731.44, meets it). The other fifteen end within 1.1 MHz of 380 MHz (APP-CFAR 378.97 MHz and APP-DCT 379.50 MHz: one task or one cluster holds most of the cost, and 0.01 of k is 618 and 365 cycles of it).

## Analysis

The defaults of rttools (as `experiments/tt`): header wait w_h = 20 cycles per router, the network interface of each PE as a resource of the link schedule, w_NI = 15,169 cycles in the occupancy, deadline of each packet at the tick of its reader; search from 500 MHz with the parameters of the command line. Handler charge of Eq. (7): inject 622 and receive 4,803 cycles (the image of CAR, the terms that `experiments/automotive` uses and the largest of the stored images) with budget B_v = 0, because the costs of the conversion hold no handler cycles and there is no image of these applications. The costs are those of the CSV (no static t(v)).

`reference.json` (and `build/table.md`) hold, per application: tasks, edges, mesh, criterion, M2, k, T, D, n(v_last), edges between PEs, packets per hyperperiod, f_CPU, f_search, R_bound at f_search, the term that sets the clock, the cluster of each task and the PE of each cluster.

Term that sets the clock (`row.sets_clock`, `row.drop_hz`): the search runs again without the handler charge (`no_handlers`), with w_NI = 0 (`no_wni`, the network interface stays a resource), with w_h = 0 (`no_wh`) and with the three removed (`links_only`), the settings of `rttools.paper.ablation`. The label lists the terms whose removal alone lowers f_search by more than the tolerance of the search (5 kHz), the largest drop first; `cpu` when the flow returns f_CPU; `links` when no removal lowers it.

## RTL pilot (`rtl/`)

`rtl/pilot.sh <APP> <work dir outside /home> [<iterations>]` generates the UCX-OS application of a converted application with `rttools.ucxgen` (application, manifest, setup and the injection table at the clock of the flow), simulates it with `experiments/exp23/simulate.sh` and analyzes the log with `rttools.paper.rtlapp` and `rttools.paper.phasecheck`, as `experiments/car-v-rtl`. It works on a copy of the repository in the work directory and writes only `rtl/<app>/` here. `ENV_SETUP` gives the tools, as in `experiments/exp23`. `RAM_BYTES=<power of two>` simulates PEs with more RAM than 64 KiB (`-gRAM_MSIZE` of `manycore_top` and a copy of the linker script with that `LENGTH`, through `LDSCRIPT` in `MAKEFLAGS`). `rtl/README.md` holds the results.
