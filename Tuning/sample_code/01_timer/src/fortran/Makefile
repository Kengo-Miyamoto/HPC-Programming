FC=gfortran

## Select timer mode: make [MODE=elp|cpu|gprof]  (default: elp)
MODE ?= elp

BASE_FFLAGS=-g -Wall -cpp -O0 -std=f2008

ifeq ($(MODE),elp)
  ## Use of timer for Elapsed time
  FFLAGS=$(BASE_FFLAGS) -DUSE_ELP_TIMER
else ifeq ($(MODE),cpu)
  ## Use of timer for CPU time
  FFLAGS=$(BASE_FFLAGS) -DUSE_CPU_TIMER
else ifeq ($(MODE),gprof)
  ## Use of gprof
  FFLAGS=-pg $(BASE_FFLAGS)
else
  $(error Unknown MODE '$(MODE)'. Use MODE=elp, MODE=cpu, or MODE=gprof)
endif

SRC = \
	main.f90

OBJS = $(SRC:.f90=.o)

.SUFFIXES: .o .f90

run.x: main.o 
	$(FC) $(FFLAGS) $(OBJS) -o $@

.f90.o:
	$(FC) $(FFLAGS) -c $< -o $@

main.o: main.f90

.PHONY: clean
clean:
	rm -f *.o *.mod *~ *genmod.f90 gmon.out

.PHONY: veryclean
veryclean: clean
	rm -f run.x
