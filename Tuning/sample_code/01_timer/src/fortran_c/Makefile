FC=gfortran

## Select timer mode: make [MODE=elp|cpu|gprof]  (default: elp)
MODE ?= elp

BASE_FFLAGS=-g -Wall -cpp -O0 -std=f2008
BASE_CFLAGS=-g -Wall -O0 -std=gnu11 -I../c

ifeq ($(MODE),elp)
  ## Use of timer for Elapsed time
  FFLAGS=$(BASE_FFLAGS) -DUSE_ELP_TIMER
  CFLAGS=$(BASE_CFLAGS)
else ifeq ($(MODE),cpu)
  ## Use of timer for CPU time
  FFLAGS=$(BASE_FFLAGS) -DUSE_CPU_TIMER
  CFLAGS=$(BASE_CFLAGS)
else ifeq ($(MODE),gprof)
  ## Use of gprof
  FFLAGS=-pg $(BASE_FFLAGS)
  CFLAGS=-pg $(BASE_CFLAGS)
else
  $(error Unknown MODE '$(MODE)'. Use MODE=elp, MODE=cpu, or MODE=gprof)
endif

CC=gcc
SRC = \
	main.f90

CSRC= \
	../c/timer.c

OBJS = $(SRC:.f90=.o)
COBJS= timer.o


.SUFFIXES: .f90 .c .o

run.x: $(OBJS) $(COBJS) 
	$(FC) $(FFLAGS) $(OBJS) $(COBJS) -o $@

.f90.o:
	$(FC) $(FFLAGS) -c $< -o $@

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.f90

timer.o: ../c/timer.h ../c/timer.c
	$(CC) $(CFLAGS) -c ../c/timer.c -o $@

.PHONY: clean
clean:
	rm -f *.o *.mod *~ *genmod.f90

.PHONY: veryclean
veryclean: clean
	rm -f run.x
