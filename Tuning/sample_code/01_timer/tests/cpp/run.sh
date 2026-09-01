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

# Remove stale profiling artifacts so gprof never reports old data
if [ "$MODE" = "gprof" ]; then
  rm -f gmon.out prof.out
fi

# Run
$EXE > outfile

# Get profiler data
# Run gprof only when MODE=gprof (expected: binary built with -pg via make MODE=gprof)
if [ "$MODE" = "gprof" ]; then
  if [ -f gmon.out ]; then
    gprof "$EXE" > prof.out
  else
    echo "gmon.out not found. Rebuild with 'make MODE=gprof' and re-run." >&2
  fi
fi

echo -n "END: " 
date
