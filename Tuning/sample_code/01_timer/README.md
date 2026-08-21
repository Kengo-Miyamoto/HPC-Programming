# Timer Sample: Hand-coded Timers and gprof
* Author:     Yukihiro Ota (yota@rist.or.jp)
* Revised by: Kengo Miyamoto (AI-assisted revision)
* Last update: 19th Aug., 2026

## Purpose
This sample demonstrates three basic techniques for measuring the performance of a program, which are the first steps of any tuning work:

1. **Elapsed (wall-clock) time measurement** with a hand-coded timer inserted in the source code
2. **CPU time measurement** with a hand-coded timer inserted in the source code
3. **Profiling with `gprof`** to find hotspots without modifying the source code

A *hotspot* is a part of a program (a function, loop, or code section) that consumes a disproportionately large share of the total execution time. Because tuning effort pays off most where the program spends most of its time, finding hotspots is the essential first step of performance tuning.

The sample program (`main.c` / `main.f90` / `main.cpp`) calls `sub1` and `sub2`, which in turn call `sub3`, with different call counts and workloads. By timing and profiling them, you will learn how to identify which part of a program dominates the execution time.

## Directory layout
```
01_timer/
├── src/            # Source code and Makefiles
│   ├── c/          # C version (default); timer.c/timer.h shared with fortran_c
│   ├── fortran/    # Fortran version (pure)
│   ├── fortran_c/  # Fortran with a C timer (via iso_c_binding); reuses src/c/timer.c and src/c/timer.h
│   └── cpp/        # C++ with std::chrono / std::clock
└── tests/          # Job scripts (run.sh) for each language
    ├── c/
    ├── fortran/
    ├── fortran_c/
    └── cpp/
```

You can choose C, Fortran (pure), Fortran with C timer, or C++. Select the variant and language pair that suits your needs:

| Language | Timer | Build Directory | Test Directory |
|---|---|---|---|
| C | hand-coded (POSIX `clock_gettime`) | `src/c/` | `tests/c/` |
| Fortran | built-in `system_clock` / `cpu_time` | `src/fortran/` | `tests/fortran/` |
| Fortran + C timer | C timer via iso_c_binding | `src/fortran_c/` | `tests/fortran_c/` |
| C++ | `std::chrono` / `std::clock` | `src/cpp/` | `tests/cpp/` |

## Building and Running

All language variants use the same `MODE` variable to select the timer mode, both at build time (`make MODE=...`) and at run time (`bash run.sh MODE=...`):

| Mode | Meaning | Default |
|---|---|---|
| `MODE=elp` | Elapsed time (wall clock) | yes |
| `MODE=cpu` | CPU time | |
| `MODE=gprof` | gprof profiling (`-pg`) | |

Internally, `MODE=elp` and `MODE=cpu` define `-DUSE_ELP_TIMER` and `-DUSE_CPU_TIMER` (C/C++) or select the corresponding Fortran timer, and `MODE=gprof` adds the `-pg` compiler flag. The `MODE` argument to `run.sh` is optional; the default is `MODE=elp`.

The code has been verified with GNU compilers (11.4.0) on x86-64 systems.

### General Build Instructions

The procedure is identical for all languages (`<lang>` = `c`, `cpp`, `fortran`, or `fortran_c`):
```text
$ cd src/<lang>
$ make [MODE=elp|cpu|gprof]         # Default: MODE=elp
$ cd ../../tests/<lang>
$ bash run.sh [MODE=elp|cpu|gprof]  # Mode parameter optional for run.sh
```

When switching modes, always rebuild from scratch with `make veryclean` first.

If linking fails with C or C++, try adding `LIB=-lm -lrt` in the Makefile.

For the C version, the `01_timer` section of `Tuning/sample_code/sample_code.ipynb` automates the same three steps described below by rebuilding with `make veryclean && make MODE=elp|cpu|gprof` from the notebook.

## Exercise steps

### Step 1: Measure elapsed (wall-clock) time

#### C version
1. Move to the source directory and build in elapsed-time mode (the default):
   ```
   $ cd src/c
   $ make MODE=elp
   ```
2. Move to the test directory and run the job script in elapsed-time mode (the default):
   ```
   $ cd ../../tests/c
   $ bash run.sh MODE=elp
   ```
3. Check `outfile`. The elapsed time of each timed section is printed as:
   ```
   Section name: Elapsed time (sec) = ...
   ```
4. Compare the elapsed times of the two timed loops and consider which is more expensive and why.

#### Fortran version
1. Move to the source directory and build in elapsed-time mode (the default):
   ```
   $ cd src/fortran
   $ make MODE=elp
   ```
2. Move to the test directory and run the job script in elapsed-time mode (the default):
   ```
   $ cd ../../tests/fortran
   $ bash run.sh MODE=elp
   ```
3. Check `outfile`. The elapsed time is printed as:
   ```
   Section name: Elapsed time (sec)     = ...
   ```
   - Uses Fortran intrinsic `system_clock()` for wall-clock timing.
4. Compare the elapsed times and consider which routine is more expensive.

#### Fortran with C timer version
1. Move to the source directory and build in elapsed-time mode (the default):
   ```
   $ cd src/fortran_c
   $ make MODE=elp
   ```
2. Move to the test directory and run the job script in elapsed-time mode (the default):
   ```
   $ cd ../../tests/fortran_c
   $ bash run.sh MODE=elp
   ```
3. Check `outfile`. The elapsed time is printed as:
   ```
   Section name: Elapsed time (sec)     = ...
   ```
   - This variant uses iso_c_binding to call the C timer functions (`get_elp_time()`) from Fortran.
   - Demonstrates language interoperability and comparison with the C version.
   - Timing results should be equivalent to the C version for the same machine.

#### C++ version
1. Move to the source directory and build in elapsed-time mode (the default):
   ```
   $ cd src/cpp
   $ make MODE=elp
   ```
2. Move to the test directory and run the job script in elapsed-time mode (the default):
   ```
   $ cd ../../tests/cpp
   $ bash run.sh MODE=elp
   ```
3. Check `outfile`. The elapsed time is printed as:
   ```
   Section name: Elapsed time (sec)   = ...
   ```
   - Uses `std::chrono::steady_clock` for precise, portable timing without external dependencies.
4. The C++ version uses modern C++11 standard library features.

### Step 2: Measure CPU time

#### C version
1. Go back to the source directory and rebuild in CPU-timer mode:
   ```
   $ cd src/c
   $ make veryclean && make MODE=cpu
   ```
2. Move to the test directory and run the job script in CPU-timer mode:
   ```
   $ cd ../../tests/c
   $ bash run.sh MODE=cpu
   ```
3. Check `outfile` for:
   ```
   Section name: CPU time (sec)     = ...
   ```
4. Compare CPU time with the elapsed time from Step 1.

#### Fortran version
1. Go back to the source directory and rebuild in CPU-timer mode:
   ```
   $ cd src/fortran
   $ make veryclean && make MODE=cpu
   ```
2. Move to the test directory and run the job script in CPU-timer mode:
   ```
   $ cd ../../tests/fortran
   $ bash run.sh MODE=cpu
   ```
3. Check `outfile` for:
   ```
   Section name: CPU time (sec)         = ...
   ```
   - Uses Fortran intrinsic `cpu_time()`.
4. Compare CPU time with the elapsed time from Step 1.

#### Fortran with C timer version
1. Go back to the source directory and rebuild in CPU-timer mode:
   ```
   $ cd src/fortran_c
   $ make veryclean && make MODE=cpu
   ```
2. Move to the test directory and run the job script in CPU-timer mode:
   ```
   $ cd ../../tests/fortran_c
   $ bash run.sh MODE=cpu
   ```
3. Check `outfile` for:
   ```
   Section name: CPU time (sec)         = ...
   ```
   - Uses the C timer function `get_cpu_time()` called from Fortran via iso_c_binding.
4. Compare results with the Fortran-only CPU time measurement to verify consistency.

#### C++ version
1. Go back to the source directory and rebuild in CPU-timer mode:
   ```
   $ cd src/cpp
   $ make veryclean && make MODE=cpu
   ```
2. Move to the test directory and run the job script in CPU-timer mode:
   ```
   $ cd ../../tests/cpp
   $ bash run.sh MODE=cpu
   ```
3. Check `outfile` for:
   ```
   Section name: CPU time (sec)     = ...
   ```
   - Uses `std::clock()` from the C++ standard library (`<ctime>`).
4. Compare CPU time with the elapsed time from Step 1.

### Understanding CPU Time vs. Elapsed Time

For a **single-threaded program** (like this sample):
- CPU time ≤ elapsed time
- A noticeable gap indicates the process was waiting (I/O, scheduling, etc.)

For a **multi-threaded program** (e.g., with OpenMP):
- CPU time can exceed elapsed time
- The ratio (CPU time / elapsed time) estimates the number of cores kept busy
- The CPU timer sums the CPU time of all threads

**Note:** CPU timer resolution is coarser than elapsed time. You may need to enlarge the array size (`nn`) or increase loop counts to obtain meaningful values.

### Step 3: Profile with gprof

#### C version
1. Go back to the source directory and rebuild with profiling mode:
   ```
   $ cd src/c
   $ make veryclean && make MODE=gprof
   ```
2. Move to the test directory and run the job script in profiling mode:
   ```
   $ cd ../../tests/c
   $ bash run.sh MODE=gprof
   ```
   - In `MODE=gprof`, `run.sh` automatically sleeps and runs `gprof` after the execution.
3. In profiling mode, the output includes:
   - `outfile`: program output (`a[0] = ...` lines)
   - `gmon.out`: raw profiling data
   - `prof.out`: `gprof` report with flat profile and call graph
4. Examine `prof.out` to identify hotspots.

#### Fortran version
1. Go back to the source directory and rebuild with profiling mode:
   ```
   $ cd src/fortran
   $ make veryclean && make MODE=gprof
   ```
2. Move to the test directory and run the job script in profiling mode:
   ```
   $ cd ../../tests/fortran
   $ bash run.sh MODE=gprof
   ```
3. `run.sh` automatically handles profiling: execution, sleep, and `gprof` report generation.
4. Examine `prof.out` for the flat profile and call graph to identify hotspots.

#### Fortran with C timer version
1. Go back to the source directory and rebuild with profiling mode:
   ```
   $ cd src/fortran_c
   $ make veryclean && make MODE=gprof
   ```
2. Move to the test directory and run the job script in profiling mode:
   ```
   $ cd ../../tests/fortran_c
   $ bash run.sh MODE=gprof
   ```
3. Examine `prof.out` to compare profiling results between pure Fortran and Fortran-with-C-timer versions.
   - Both should identify the same hotspots, confirming interoperability.

#### C++ version
1. Go back to the source directory and rebuild with profiling mode:
   ```
   $ cd src/cpp
   $ make veryclean && make MODE=gprof
   ```
2. Move to the test directory and run the job script in profiling mode:
   ```
   $ cd ../../tests/cpp
   $ bash run.sh MODE=gprof
   ```
3. `run.sh` automatically handles profiling: execution, sleep, and `gprof` report generation (`gmon.out` and `prof.out`).
4. Examine `prof.out` to identify hotspots.

### Cleaning Up Profiling Data

> **Note:** The profiling data file `gmon.out` is created in the directory where the program *runs*, i.e., `tests/<lang>/` when using `run.sh` — not in `src/<lang>/`. 
> To clean up profiling results, run:
> ```
> $ cd tests/<lang>
> $ rm -f gmon.out prof.out outfile
> ```

## Implementation Details by Language

### C
- **Elapsed timer**: POSIX `clock_gettime()` with `CLOCK_MONOTONIC`
- **CPU timer**: POSIX `clock_gettime()` with `CLOCK_PROCESS_CPUTIME_ID`
- **Files**: `src/c/timer.c`, `src/c/timer.h`, `src/c/main.c`
- **Compilation**: Hand-coded timer functions compiled separately
- **Advantages**: Precise timing, portable (POSIX standard), low overhead

### Fortran (pure)
- **Elapsed timer**: Fortran intrinsic `system_clock()` for wall-clock timing
- **CPU timer**: Fortran intrinsic `cpu_time()` 
- **Files**: `src/fortran/main.f90`
- **Compilation**: Single source file; no external timer library needed
- **Advantages**: Simple, language-native, no external dependencies

### Fortran with C timer
- **Timer**: Same POSIX C timer as the C version, called via iso_c_binding (Fortran2008+)
- **Files**: `src/fortran_c/main.f90`, `src/c/timer.c`, `src/c/timer.h`
  (timer sources are shared with the C variant — no duplicated copies in `src/fortran_c/`)
- **Compilation**: Fortran and C files compiled separately, then linked
- **Advantages**: Demonstrates language interoperability, allows direct comparison with C implementation
- **Use cases**: Learning mixed-language programming, verifying consistency between implementations

### C++
- **Elapsed timer**: `std::chrono::steady_clock` (C++11 standard library)
- **CPU timer**: `std::clock()` (`<ctime>`, C++ standard library)
- **Files**: `src/cpp/main.cpp`
- **Compilation**: No external timer library; uses standard C++11 features
- **Advantages**: Modern, type-safe, header-only, portable, no external dependencies
- **Notes**: `std::chrono` provides high-resolution timing and handles platform differences transparently; note that `std::clock()` resolution depends on `CLOCKS_PER_SEC`

## Questions to consider
1. Which function is the hotspot, and how do the call counts of `sub1`, `sub2`, and `sub3` explain it?
2. When do elapsed time and CPU time differ, and which one should you use for tuning?
3. What are the pros and cons of hand-coded timers vs. `gprof`?
4. How do timer implementations differ across C, Fortran, C++, and Fortran-C interoperability?
5. What are the trade-offs between POSIX timers (`clock_gettime`), Fortran intrinsics (`system_clock`, `cpu_time`), and C++ `std::chrono`?
6. For your use case, which language and timer approach is most appropriate and why?
