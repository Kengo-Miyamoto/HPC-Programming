// Copyright 2024 Research Organization for Information Science and Technology 
//----------------------------------------------------------------------
//  Check resolution of your timer 
//  Author:      Yukihiro Ota (yota@rist.or.jp)
//  Description: The original idea comes from Wadleigh and Crawford,
//               "Software Optimization for HPC: Creating Faster 
//                Applications" (2000) pp.136-138 
//  Extended to compare the nominal resolution reported by the API
//  (std::chrono::steady_clock::period and CLOCKS_PER_SEC) with the
//  resolution measured empirically by the iteration loop.
//----------------------------------------------------------------------
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <ctime>

int func ( const int nn ) ;

//----------------------------------------------------------------------
//  main                                                              
//----------------------------------------------------------------------
int main ( int argc, char* argv[] )
{
  int nn ;
  int nn_max = 10000000 ; // safety limit to prevent infinite loop
  double t ;
  double res_api ;

  printf ("--------------------------------------------------------\n");

  // check resolution of wallclock timer with steady_clock
  printf ("[Wallclock timer]\n") ;
  res_api = static_cast<double>(std::chrono::steady_clock::period::num) /
            static_cast<double>(std::chrono::steady_clock::period::den) ;
  printf (" [API]      nominal resolution   = %17.9f sec.\n", res_api) ;

  nn = 0 ;
  t = -1.0 ;
  while ( t <= 0.0 && nn < nn_max ) {
    nn++ ;
    const auto elp1 = std::chrono::steady_clock::now();
    func (nn);
    const auto elp2 = std::chrono::steady_clock::now();
    const std::chrono::duration<double> elapsed = elp2 - elp1;
    t = static_cast<double>(elapsed.count());
  }

  if ( nn >= nn_max ) {
    printf ("Warning: wallclock timer resolution could not be determined.\n") ;
  } else {
    printf (" [Measured] observed resolution  = %17.9f sec. (nn = %d iterations)\n", t, nn) ;
    printf (" ratio (measured / API)          = %13.2f\n", t / res_api) ;
  }

  printf ("--------------------------------------------------------\n");

  // check resolution of cpu timer with std::clock
  printf ("[CPU timer]\n") ;
  res_api = 1.0 / static_cast<double>(CLOCKS_PER_SEC) ;
  printf (" [API]      nominal resolution   = %17.9f sec.\n", res_api) ;

  nn = 0 ;
  t = -1.0 ;
  while ( t <= 0.0 && nn < nn_max ) {
    nn++ ;
    const std::clock_t cpu1 = std::clock();
    func (nn);
    const std::clock_t cpu2 = std::clock();
    t = static_cast<double>(cpu2 - cpu1) / CLOCKS_PER_SEC ;
  }

  if ( nn >= nn_max ) {
    printf ("Warning: cpu timer resolution could not be determined.\n") ;
  } else {
    printf (" [Measured] observed resolution  = %17.9f sec. (nn = %d iterations)\n", t, nn) ;
    printf (" ratio (measured / API)          = %13.2f\n", t / res_api) ;
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
