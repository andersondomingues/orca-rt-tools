# STR2RTS (Rouxel and Puaut, WCET 2017): the SDF task graphs of the suite in the application format
# of the flow (apps/str2rts, one directory per application) and the analysis flow of the paper on
# each of them on the 4x4 mesh (2x2 below 16 tasks), without RTL (rttools/paper/str2rts.py).
#
#   make          run + check (README.md gives the run time: the link schedules of APP-AUDIOBEAM and
#                 APP-FMRADIO take most of it; the other fifteen take less than 1 min together)
#   make run      for each application of config.json: ORT/GCM (four criteria, smallest M2) and the
#                 Spiral Mapping against the stored .map, f_CPU, the frequency search (handler charge
#                 of Eq. (7), w_h, w_NI and the network interfaces as resources), R_bound, and the
#                 search again without each term (which term sets the clock); $(BUILD)/metrics.json,
#                 $(BUILD)/table.csv, $(BUILD)/table.md, $(BUILD)/apps/<app>.json (one file per
#                 application, written while it runs)
#   make check    compare $(BUILD)/metrics.json with reference.json
#   make app STR2RTS=<checkout>      compare apps/str2rts with the converter (fails when they differ)
#   make convert STR2RTS=<checkout>  write apps/str2rts from the XML files of the checkout (about 2 min)
#   make clean
#
# ONLY="APP-CFAR APP-CFIR" restricts run, app and convert to some applications; TIMEOUT (s) stops an
# application that runs longer (default: config.json, 1200 s) and reports it as stopped; JOBS:
# applications at the same time.
#
# convert and app read a checkout of STR2RTS (https://gitlab.inria.fr/brouxel/STR2RTS, commit of
# config.json) from outside this repository: they run the interpreter in isolated mode (-I: no
# PYTHONPATH, no user site directory, neither this directory nor the directory of the script on the
# module path) and read only the XML descriptions and .git/HEAD of the checkout, as data. The
# converter needs the standard library only.

PYTHON  ?= python3
RTTOOLS := $(abspath ../../orca-rt-tools)
APPS    := $(abspath ../../apps)
ARCH    := $(abspath ../../arch)
BUILD   ?= build
JOBS    ?= 4
ONLY    ?=
TIMEOUT ?=
STR2RTS ?=
RUN      = PYTHONPATH=$(RTTOOLS) $(PYTHON) -m rttools.paper.str2rts
CONVERT  = $(PYTHON) -I $(RTTOOLS)/rttools/paper/str2rts.py convert --config config.json \
	--str2rts $(STR2RTS) --apps $(APPS) $(if $(ONLY),--only $(ONLY))

.PHONY: all app convert run check clean need-str2rts

all: run check

need-str2rts:
	@test -n "$(STR2RTS)" -a -d "$(STR2RTS)/src" || { echo "STR2RTS=<checkout of STR2RTS> expected"; exit 2; }

app: need-str2rts
	$(CONVERT) --check

convert: need-str2rts
	$(CONVERT)

run:
	$(RUN) run --config config.json --apps $(APPS) --arch $(ARCH) --out $(BUILD) --jobs $(JOBS) \
		$(if $(ONLY),--only $(ONLY)) $(if $(TIMEOUT),--timeout $(TIMEOUT))

check:
	PYTHONPATH=$(RTTOOLS) $(PYTHON) -m rttools.paper.exp23 check $(BUILD)/metrics.json reference.json

clean:
	rm -rf $(BUILD)
