#!/bin/bash
echo -n "START: " 
date
ulimit -s unlimited

# Set load module (absolute path could be preferable)
EXE=$(echo "../../src/fortran_c/run.x")



# Run
${EXE} &> outfile

echo -n "END: " 
date
