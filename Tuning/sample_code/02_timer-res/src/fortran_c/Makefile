FC=gfortran
CC=gcc

FFLAGS=-Wall -O0 -std=f2008
CFLAGS=-Wall -O0 -std=gnu11 -I../c

SRC = \
	main.f90

OBJS = $(SRC:.f90=.o)
COBJS = timer.o

.SUFFIXES: .f90 .c .o

run.x: $(OBJS) $(COBJS)
	$(FC) $(FFLAGS) $(OBJS) $(COBJS) -o $@

.f90.o:
	$(FC) $(FFLAGS) -c $< -o $@

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.f90

# Reuse the C timer sources shared with src/c/ -- no duplicated copies here.
timer.o: ../c/timer.h ../c/timer.c
	$(CC) $(CFLAGS) -c ../c/timer.c -o $@

.PHONY: clean
clean:
	rm -f *.o *.mod *~ *genmod.f90

.PHONY: veryclean
veryclean: clean
	rm -f run.x
