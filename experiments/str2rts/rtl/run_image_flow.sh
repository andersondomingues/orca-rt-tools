#!/bin/bash
# RTL runs of the STR2RTS applications at the clock of the flow with the static costs of their own
# image (the procedure of experiments/tt): for each application, build the image, compute its static
# t(v) and handler terms (static_costs.py), then run pilot.sh with IMAGE_FLOW=1. A few at a time,
# resumable. Unlike run_all.sh, no simulation runs with the costs of the CSV alone: a task that sends
# many packets can cost more than its CSV cost (APP-AUDIOBEAM, rtl/README.md).
#
#   run_image_flow.sh <work dir> [<jobs>]
#
# <work dir>: directory outside /home (pilot.sh)
# <jobs>:     applications at the same time (default 3)
#
# Environment:
#   APPS        applications, in the order they start (default: the fourteen without an image-flow run)
#   ITER        complete iterations of each run (default 10, pilot.sh)
#   STEP=costs  stop each application after static_costs.py (no simulation; state "costs")
#   ENV_SETUP, PYTHON: as pilot.sh
#
# Files in <work dir>: status.txt (one line per application), logs/<APP>.log, failed/<APP>.
# An application is complete when rtl/app-<name>/image-flow/ holds metrics.json, events.txt, RUN_INFO
# and phasecheck.txt; a complete application is skipped.
set -uo pipefail

WORK=${1:?usage: run_image_flow.sh <work dir> [<jobs>]}
JOBS=${2:-3}
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../.." && pwd)
PYTHON=${PYTHON:-python3}
ITER=${ITER:-10}
APPS=${APPS:-APP-DES APP-SERPENT APP-DCALC APP-FIR APP-80211A APP-BITONIC APP-FIRBANK APP-BEAMFORMER APP-MATMULT APP-FFT APP-PERFTEST APP-FMRADIO APP-FILTERBANK APP-AUDIOBEAM}
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || { echo "jobs must be a positive integer: $JOBS" >&2; exit 2; }
mkdir -p "$WORK" || exit 2
WORK=$(cd "$WORK" && pwd)
case $WORK in /home/*) echo "work dir must be outside /home: $WORK" >&2; exit 2 ;; esac
mkdir -p "$WORK/logs" "$WORK/failed" "$WORK/state"
STATUS=$WORK/status.txt

complete() {
	local d=$HERE/${1,,}/image-flow
	[ -s "$d/metrics.json" ] && [ -s "$d/events.txt" ] && [ -s "$d/RUN_INFO" ] && [ -s "$d/phasecheck.txt" ]
}

set_state() {
	echo "$2" > "$WORK/state/$1"
	(
		flock 9
		{
			echo "# run_image_flow.sh: $(date '+%Y-%m-%d %H:%M:%S'); jobs $JOBS; iterations $ITER${STEP:+; STEP=$STEP}"
			for a in $APPS; do
				printf '%-15s %s\n' "$a" "$(cat "$WORK/state/$a" 2>/dev/null || echo waiting)"
			done
		} > "$STATUS.tmp" && mv "$STATUS.tmp" "$STATUS"
	) 9> "$WORK/.status.lock"
}

run_one() {
	local app=$1 log=$WORK/logs/$1.log name start t0 rc=0
	name=str2rts_$(echo "${app#APP-}" | tr 'A-Z' 'a-z')
	start=$(date '+%H:%M:%S'); t0=$SECONDS
	rm -f "$WORK/failed/$app"
	: > "$log"
	if [ ! -s "$HERE/${app,,}/static.json" ]; then
		set_state "$app" "building start $start  log logs/$app.log"
		STEP=build "$HERE/pilot.sh" "$app" "$WORK" "$ITER" >> "$log" 2>&1 || rc=$?
		if [ $rc -eq 0 ]; then
			# static_costs.py reads the image of the simulated tree; the build tree has the same image
			[ -e "$WORK/$name/sim" ] || ln -s build "$WORK/$name/sim"
			set_state "$app" "costs    start $start  log logs/$app.log"
			( cd "$HERE/.." && PYTHONPATH="$REPO/orca-rt-tools" "$PYTHON" rtl/static_costs.py "$app" "$WORK" ) >> "$log" 2>&1 || rc=$?
		fi
	fi
	if [ $rc -eq 0 ] && [ "${STEP:-}" != costs ]; then
		set_state "$app" "running  start $start  log logs/$app.log"
		IMAGE_FLOW=1 "$HERE/pilot.sh" "$app" "$WORK" "$ITER" >> "$log" 2>&1 || rc=$?
	fi
	if [ $rc -ne 0 ]; then
		{ echo "exit $rc"; tail -15 "$log"; } > "$WORK/failed/$app"
		set_state "$app" "failed   exit $rc after $(( SECONDS - t0 )) s  log logs/$app.log"
	elif [ "${STEP:-}" = costs ]; then
		set_state "$app" "costs    done in $(( SECONDS - t0 )) s"
	else
		set_state "$app" "done     $start to $(date '+%H:%M:%S') ($(( SECONDS - t0 )) s)"
	fi
}

for app in $APPS; do
	if [ "${STEP:-}" != costs ] && complete "$app"; then set_state "$app" "skipped  results complete"; else set_state "$app" waiting; fi
done
for app in $APPS; do
	if [ "${STEP:-}" != costs ] && complete "$app"; then continue; fi
	while (( $(jobs -rp | wc -l) >= JOBS )); do wait -n; done
	run_one "$app" &
done
wait
cat "$STATUS"
