#!/bin/bash

## Select timer mode: bash run.sh [MODE=elp|cpu|gprof]  (default: elp)
## Or: MODE=gprof bash run.sh
for arg in "$@"; do
  case $arg in
    MODE=*) MODE="${arg#MODE=}" ;;
  esac
done
MODE=${MODE:-elp}

case $MODE in
  elp|cpu|gprof) ;;
  *) echo "Unknown MODE '$MODE'. Use MODE=elp, MODE=cpu, or MODE=gprof" >&2; exit 1 ;;
esac

echo -n "START: " 
date
ulimit -s unlimited

# Set load module (absolute path could be preferable)
EXE=$(echo "../../src/cpp/run.x")

# Run
$EXE > outfile

# Get profiler data
# Executed only when the program was built with -pg (make MODE=gprof)
if [ "$MODE" = "gprof" ]; then
  sleep 10s
  gprof $EXE > prof.out
fi

echo -n "END: " 
date
