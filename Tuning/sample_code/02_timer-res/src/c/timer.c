/* Copyright 2024 Research Organization for Information Science and Technology */
/*----------------------------------------------------------------------
 *   timer.c                                                          
 *   Author:    Yukihiro Ota (yota@rist.or.jp)
 *--------------------------------------------------------------------*/
#include "timer.h"

/* These routines may NOT be compatible with -std=c99 and -std=c11 
   because clock_gettime is within the POSIX standard, rather than 
   the C standard.
   Several ways of using clock_gettime exist, depending on kinds of 
   compilers. Use of GNU extensions in Intel, e.g., -std=gnu99, works.
   Note: Some glibc (e.g., before 2.17) requires linking with -lrt.
   I suggest that you check manual of clock_gettime and your compiler 
   before the use.                                                    */

#include <time.h>

/* Wall clock (Elapsed time)
   Default: CLOCK_MONOTONIC (safe for interval timing; unaffected by
   NTP adjustments or manual clock changes).
   Define USE_REALTIME to use CLOCK_REALTIME instead.               */
#if ! defined(USE_REALTIME)
double get_elp_time () {
  struct timespec tp ;
  if ( clock_gettime ( CLOCK_MONOTONIC, &tp ) != 0 ) return -1.0 ;
  return  tp.tv_sec + (double)tp.tv_nsec*1.0e-9 ;
}
#else
double get_elp_time () {
  struct timespec tp ;
  if ( clock_gettime ( CLOCK_REALTIME, &tp ) != 0 ) return -1.0 ;
  return  tp.tv_sec + (double)tp.tv_nsec*1.0e-9 ;
}
#endif

/* CPU time */
double get_cpu_time () {
  struct timespec tp ;
  if ( clock_gettime ( CLOCK_PROCESS_CPUTIME_ID, &tp ) != 0 ) return -1.0 ;
  return  tp.tv_sec + (double)tp.tv_nsec*1.0e-9 ;
}

/* Get nominal resolution (in seconds), as reported by clock_getres() */
#if ! defined(USE_REALTIME)
double get_elp_res () {
  struct timespec res ;
  if ( clock_getres ( CLOCK_MONOTONIC, &res ) != 0 ) return -1.0 ;
  return  res.tv_sec + (double)res.tv_nsec*1.0e-9 ;
}
#else
double get_elp_res () {
  struct timespec res ;
  if ( clock_getres ( CLOCK_REALTIME, &res ) != 0 ) return -1.0 ;
  return  res.tv_sec + (double)res.tv_nsec*1.0e-9 ;
}
#endif

double get_cpu_res () {
  struct timespec res ;
  if ( clock_getres ( CLOCK_PROCESS_CPUTIME_ID, &res ) != 0 ) return -1.0 ;
  return  res.tv_sec + (double)res.tv_nsec*1.0e-9 ;
}
