#!/bin/bash
# Batch of the RTL runs of the STR2RTS applications that have none yet: one pilot.sh per application,
# a few at a time, resumable.
#
#   run_all.sh <work dir> [<jobs>]
#
# <work dir>: directory outside /home (pilot.sh); about 150 MB per application
# <jobs>:     simulations at the same time (default 3)
#
# Environment:
#   APPS        applications, in the order they start (default: the nine below, the longest first, which
#               gives the shortest batch with three at a time)
#   ITER        complete iterations of each run (default 10, pilot.sh)
#   STEP=build  dry run: generate and build every application with its limits and RAM, check the heap,
#               simulate nothing (seconds per application; state "built")
#   FORCE=1     run an application again although its results are complete
#   ENV_SETUP, PYTHON: as pilot.sh
#
# Per application (pilot.sh): generation with the limits it needs (letters per PE, tag modulus,
# MAX_TASKS, MAX_PKT_QUEUE_SLOTS, NOC_TT_SLOTS), build with the first RAM that holds its heap, simulation
# at the clock of ../reference.json for at least ITER complete iterations, analysis, copy of the small
# result files to rtl/app-<name>/ (the work directory written as <work>).
#
# Files in <work dir>:
#   status.txt          one line per application: state (waiting, running, done, failed, skipped, built),
#                       start and end time, seconds, log; rewritten at every change
#   logs/<APP>.log      output of pilot.sh
#   failed/<APP>        marker of a failed application (exit code and the last lines of its log); a
#                       failure does not stop the others, and the next run of this script tries it again
# An application is complete when rtl/app-<name>/ holds metrics.json, events.txt, RUN_INFO and
# phasecheck.txt; a complete application is skipped. After the last application, summary.py rewrites
# summary.json and summary.md (not after a dry run).
set -uo pipefail

WORK=${1:?usage: run_all.sh <work dir> [<jobs>]}
JOBS=${2:-3}
HERE=$(cd "$(dirname "$0")" && pwd)
PYTHON=${PYTHON:-python3}
ITER=${ITER:-10}
APPS=${APPS:-APP-DES APP-SERPENT APP-DCALC APP-FIR APP-80211A APP-BITONIC APP-FIRBANK APP-BEAMFORMER APP-FMRADIO}
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || { echo "jobs must be a positive integer: $JOBS" >&2; exit 2; }
mkdir -p "$WORK" || exit 2
WORK=$(cd "$WORK" && pwd)
case $WORK in /home/*) echo "work dir must be outside /home: $WORK" >&2; exit 2 ;; esac
mkdir -p "$WORK/logs" "$WORK/failed" "$WORK/state"
STATUS=$WORK/status.txt

complete() { # complete <APP>: its results are in rtl/app-<name>/
	local d=$HERE/${1,,}
	[ -s "$d/metrics.json" ] && [ -s "$d/events.txt" ] && [ -s "$d/RUN_INFO" ] && [ -s "$d/phasecheck.txt" ]
}

set_state() { # set_state <APP> <text>: state file of the application and status.txt
	echo "$2" > "$WORK/state/$1"
	(
		flock 9
		{
			echo "# run_all.sh: $(date '+%Y-%m-%d %H:%M:%S'); jobs $JOBS; iterations $ITER${STEP:+; STEP=$STEP}"
			for a in $APPS; do
				printf '%-15s %s\n' "$a" "$(cat "$WORK/state/$a" 2>/dev/null || echo waiting)"
			done
		} > "$STATUS.tmp" && mv "$STATUS.tmp" "$STATUS"
	) 9> "$WORK/.status.lock"
}

run_one() { # run_one <APP>
	local app=$1 log=$WORK/logs/$1.log start t0 rc
	start=$(date '+%H:%M:%S'); t0=$SECONDS
	rm -f "$WORK/failed/$app"
	set_state "$app" "running  start $start  log logs/$app.log"
	STEP=${STEP:-} PYTHON="$PYTHON" "$HERE/pilot.sh" "$app" "$WORK" "$ITER" > "$log" 2>&1
	rc=$?
	if [ $rc -eq 0 ] && { [ "${STEP:-}" = build ] || complete "$app"; }; then
		if [ "${STEP:-}" = build ]; then
			set_state "$app" "built    start $start  end $(date '+%H:%M:%S')  $(( SECONDS - t0 )) s  $(sed -n 3,4p "$WORK/str2rts_$(echo "${app#APP-}" | tr 'A-Z' 'a-z')/build.txt" | tr '\n' ' ')"
		else
			set_state "$app" "done     start $start  end $(date '+%H:%M:%S')  $(( SECONDS - t0 )) s  log logs/$app.log"
		fi
	else
		{ echo "exit code $rc at $(date '+%Y-%m-%d %H:%M:%S')"; tail -n 15 "$log"; } > "$WORK/failed/$app"
		set_state "$app" "failed   start $start  end $(date '+%H:%M:%S')  $(( SECONDS - t0 )) s  exit $rc  see failed/$app and logs/$app.log"
	fi
}

for a in $APPS; do
	[ -d "$HERE/../../../apps/str2rts/${a,,}" ] || { echo "unknown application: $a" >&2; exit 2; }
	rm -f "$WORK/state/$a"
done
for a in $APPS; do set_state "$a" waiting; done
for a in $APPS; do
	if [ "${FORCE:-0}" != 1 ] && [ "${STEP:-}" != build ] && complete "$a"; then
		set_state "$a" "skipped  results complete in rtl/${a,,}"
		continue
	fi
	while (( $(jobs -rp | wc -l) >= JOBS )); do wait -n; done
	run_one "$a" &
	sleep 2
done
wait
if [ "${STEP:-}" != build ]; then
	"$PYTHON" "$HERE/summary.py" > "$WORK/logs/summary.log" 2>&1 || echo "summary.py failed (logs/summary.log)" >&2
fi
cat "$STATUS"
! grep -q " failed " "$STATUS"
