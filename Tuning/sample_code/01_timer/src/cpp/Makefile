CXX=g++

## Select timer mode: make [MODE=elp|cpu|gprof]  (default: elp)
MODE ?= elp

BASE_CXXFLAGS=-g -Wall -std=gnu++11 -O0

ifeq ($(MODE),elp)
  ## Use of timer for elapsed time (std::chrono in C++11)
  CXXFLAGS=$(BASE_CXXFLAGS) -DUSE_ELP_TIMER
else ifeq ($(MODE),cpu)
  ## Use of timer for CPU time
  CXXFLAGS=$(BASE_CXXFLAGS) -DUSE_CPU_TIMER
else ifeq ($(MODE),gprof)
  ## Use of gprof
  CXXFLAGS=-pg $(BASE_CXXFLAGS)
else
  $(error Unknown MODE '$(MODE)'. Use MODE=elp, MODE=cpu, or MODE=gprof)
endif

LIB=-lm

SRC = \
	main.cpp

OBJS = $(SRC:.cpp=.o)

.SUFFIXES: .o .cpp

run.x: $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) $(LIB) -o $@

.cpp.o:
	$(CXX) $(CXXFLAGS) -c $< -o $@

main.o: main.cpp

.PHONY: clean
clean:
	rm -f *.o *~ gmon.out

.PHONY: veryclean
veryclean: clean
	rm -f run.x
