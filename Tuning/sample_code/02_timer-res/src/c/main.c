/* Copyright 2024 Research Organization for Information Science and Technology */
/*----------------------------------------------------------------------
 *  Check resolution of your timer 
 *  Author:      Yukihiro Ota (yota@rist.or.jp)
 *  Description: The original idea comes from Wadleigh and Crawford,
 *               "Software Optimization for HPC: Creating Faster 
 *                Applications" (2000) pp.136-138 
 *  Extended to compare the nominal resolution reported by clock_getres()
 *  with the resolution measured empirically by the iteration loop.
 *--------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include "timer.h"

int func ( const int nn ) ;

/*--------------------------------------------------------------------*/
/*  main                                                              */
/*--------------------------------------------------------------------*/
int main ( int argc, char* argv[] )
{
  int nn ;
  int nn_max = 10000000 ; /* safety limit to prevent infinite loop */
  double t1, t2 ;
  double res_api ;

  printf ("--------------------------------------------------------\n");

  /* check resolution of wallclock timer */
  printf ("[Wallclock timer]\n") ;
  res_api = get_elp_res () ;
  printf (" [API]      nominal resolution   = %17.9f sec.\n", res_api) ;

  t2 = -1.0 ;
  nn = 0 ;
  while ( t2 <= 0.0 && nn < nn_max ) {
    nn++ ;
    t1 = get_elp_time () ; 
    func ( nn ) ;
    t2 = get_elp_time () ;
    t2 -= t1 ;
  }
  if ( nn >= nn_max ) {
    printf ("Warning: wallclock timer resolution could not be determined.\n") ;
  } else {
    printf (" [Measured] observed resolution  = %17.9f sec. (nn = %d iterations)\n", t2, nn) ;
    printf (" ratio (measured / API)          = %13.2f\n", t2 / res_api) ;
  }

  printf ("--------------------------------------------------------\n");

  /* check resolution of cpu timer */
  printf ("[CPU timer]\n") ;
  res_api = get_cpu_res () ;
  printf (" [API]      nominal resolution   = %17.9f sec.\n", res_api) ;

  t2 = -1.0 ;
  nn = 0 ;
  while ( t2 <= 0.0 && nn < nn_max ) {
    nn++ ;
    t1 = get_cpu_time () ; 
    func ( nn ) ;
    t2 = get_cpu_time () ;
    t2 -= t1 ;
  }
  if ( nn >= nn_max ) {
    printf ("Warning: cpu timer resolution could not be determined.\n") ;
  } else {
    printf (" [Measured] observed resolution  = %17.9f sec. (nn = %d iterations)\n", t2, nn) ;
    printf (" ratio (measured / API)          = %13.2f\n", t2 / res_api) ;
  }

  printf ("--------------------------------------------------------\n");

  /* finalization */
  return EXIT_SUCCESS ;
}
/*--------------------------------------------------------------------*/
/*  func                                                              */
/*--------------------------------------------------------------------*/
int func ( const int nn ) 
{
  int i, j ;
  i = 0 ;
  for ( j = 0 ; j < nn ; ++j ) i++ ;
  return i ;
}
