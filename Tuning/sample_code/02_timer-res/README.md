# Timer Resolution Sample: API-reported vs. Measured Resolution
* Author:     Yukihiro Ota (yota@rist.or.jp)
* Revised by: Kengo Miyamoto (AI-assisted revision)
* Last update: 1st Sep., 2026

## Purpose
This sample compares, for every language variant covered in `01_timer`, two notions of timer resolution:

1. The **nominal resolution** reported by a dedicated API function (e.g., `clock_getres()`).
2. The resolution **measured empirically** by repeatedly calling the timer around a small workload until a non-zero elapsed/CPU time difference is observed (Wadleigh & Crawford, *Software Optimization for HPC* (2000), pp.136-138).

Comparing these two values illustrates that the value returned by a "resolution" API is not always what you actually observe in practice: function-call overhead, vDSO fast paths, and tick interpolation can all make the measured resolution coarser (or, less intuitively, finer) than the nominal one.

## Directory layout
```
02_timer-res/
├── src/            # Source code and Makefiles
│   ├── c/          # C version; timer.c/timer.h shared with fortran_c
│   ├── fortran/    # Fortran version (pure)
│   ├── fortran_c/  # Fortran with a C timer (via iso_c_binding); reuses src/c/timer.c and src/c/timer.h
│   └── cpp/        # C++ with std::chrono / std::clock
└── tests/          # Job scripts (run.sh) for each language
    ├── c/
    ├── fortran/
    ├── fortran_c/
    └── cpp/
```

| Language | Elapsed timer | Nominal elapsed resolution | CPU timer | Nominal CPU resolution |
|---|---|---|---|---|
| C | `clock_gettime(CLOCK_MONOTONIC)` | `clock_getres(CLOCK_MONOTONIC)` | `clock_gettime(CLOCK_PROCESS_CPUTIME_ID)` | `clock_getres(CLOCK_PROCESS_CPUTIME_ID)` |
| Fortran (pure) | `system_clock` | `system_clock(count_rate=...)` → `1.0d0/count_rate` | `cpu_time` | *no API available* (measured value only) |
| Fortran + C timer | C `get_elp_time()` via iso_c_binding | C `get_elp_res()` via iso_c_binding | C `get_cpu_time()` | C `get_cpu_res()` via iso_c_binding |
| C++ | `std::chrono::steady_clock` | `steady_clock::period::num / steady_clock::period::den` (compile-time) | `std::clock()` | `1.0 / CLOCKS_PER_SEC` |

## Building and Running

The procedure is identical for all languages (`<lang>` = `c`, `cpp`, `fortran`, or `fortran_c`):
```text
$ cd src/<lang>
$ make
$ cd ../../tests/<lang>
$ bash run.sh
```
Then check `outfile` for the comparison output.

The code has been verified with GNU compilers (11.4.0) on x86-64 systems.

If linking fails with C or C++, try adding `LIB=-lm -lrt` in the Makefile.

## Common output format (all languages)
```
[Wallclock timer]
 [API]      nominal resolution   =   0.000000001 sec.
 [Measured] observed resolution  =   0.000000030 sec. (nn = 27 iterations)
 ratio (measured / API)          =        30.00
[CPU timer]
 ...
```
If the measured resolution cannot be determined within the safety limit (`nn_max` iterations, currently 10,000,000), a warning is printed instead.

## Implementation Notes by Language

### C (`src/c/`)
- `timer.c` provides `get_elp_res()` and `get_cpu_res()`, built on `clock_getres()`, returning seconds as `double`.
- `main.c` runs the existing measurement loop and prints the API/measured/ratio comparison for both the wallclock and the CPU timer.

### Fortran (`src/fortran/`)
- The nominal elapsed resolution is obtained from `system_clock(count_rate=...)` as `1.0d0 / count_rate`.
- The measured resolution uses the same iteration loop as the C version, driven by `system_clock` and `cpu_time`.
- `cpu_time()` has no API to query its nominal resolution, so only the measured value is printed for the CPU timer.

### Fortran with C timer (`src/fortran_c/`)
- Mirrors the structure of `01_timer/src/fortran_c/`: it reuses `src/c/timer.c` and `src/c/timer.h` (no duplicated C sources) and binds `get_elp_time`, `get_cpu_time`, `get_elp_res`, and `get_cpu_res` via `iso_c_binding`.
- Since it calls the same C timer routines as the C version, results should be equivalent to the C version on the same machine.

### C++ (`src/cpp/`)
- The nominal elapsed resolution is `steady_clock::period::num / steady_clock::period::den`, a compile-time constant.
- The nominal CPU resolution is `1.0 / CLOCKS_PER_SEC`.
- The measured resolution uses the same iteration loop, driven by `std::chrono::steady_clock` and `std::clock()`.

## Questions to consider
1. Why do the API-reported nominal resolution and the measured resolution differ? Consider function-call overhead, vDSO fast paths in `clock_gettime`, and tick interpolation.
2. `steady_clock::period` is a compile-time constant. Does it guarantee anything about the clock's actual runtime behavior?
3. What are the practical implications of `cpu_time()` having no API to query its nominal resolution? How would you estimate it if you needed to?
4. Compare the `c` and `fortran_c` results. Are they consistent? What would it mean if they were not?
5. When the CPU timer's resolution is much coarser than the elapsed timer's, how should you choose the granularity (loop count, workload size) of the code you measure?
6. Check the resolution of other timers, such as `omp_get_wtime` in OpenMP and `MPI_Wtime` in MPI, using the same idea.
