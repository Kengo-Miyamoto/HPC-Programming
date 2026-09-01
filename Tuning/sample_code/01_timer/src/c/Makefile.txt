CC=gcc

## Select timer mode: make [MODE=elp|cpu|gprof]  (default: elp)
MODE ?= elp

## -std=gnu17: modern GNU C dialect (default of recent gcc)
## -D_POSIX_C_SOURCE=199309L: explicitly require the POSIX.1b timer API
##   (clock_gettime); redundant with a gnu* dialect but self-documenting
BASE_CFLAGS=-g -Wall -O0 -std=gnu17 -D_POSIX_C_SOURCE=199309L

ifeq ($(MODE),elp)
  ## Use of timer for Elapsed time
  CFLAGS=$(BASE_CFLAGS) -DUSE_ELP_TIMER
else ifeq ($(MODE),cpu)
  ## Use of timer for CPU time
  CFLAGS=$(BASE_CFLAGS) -DUSE_CPU_TIMER
else ifeq ($(MODE),gprof)
  ## Use of gprof
  CFLAGS=-pg $(BASE_CFLAGS)
else
  $(error Unknown MODE '$(MODE)'. Use MODE=elp, MODE=cpu, or MODE=gprof)
endif

LIB=-lm
#LIB=-lm -lrt # if linking is failed

SRC = \
	timer.c \
	main.c

OBJS = $(SRC:.c=.o)

.SUFFIXES: .o .c

run.x: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIB) -o $@

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.c

timer.o: timer.c timer.h

.PHONY: clean
clean:
	rm -f *.o *~ gmon.out

.PHONY: veryclean
veryclean: clean
	rm -f run.x
