// Copyright 2024 Research Organization for Information Science and Technology 
//----------------------------------------------------------------------
//   Hand-coded timer (C++11) and Use of gprof 
//   Author:      Yukihiro Ota (yota@rist.or.jp)
// ---------------------------------------------------------------------
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <vector>
//#include <thread>

void sub1 ( double *a, const int nn ) ;
void sub2 ( double *a, const int nn ) ;
void sub3 ( double *a, const int nn ) ;
//void sub4 ( );

//----------------------------------------------------------------------
//  main                                                              
//----------------------------------------------------------------------
int main ( int argc, char* argv[] )
{
  int nn = 20000 ;
  std::vector<double> a(nn, 0.0) ;

  // set values -- already zero-initialized via std::vector

#if defined(USE_CPU_TIMER)
  std::clock_t cpu1, cpu2;
#endif
#if defined(USE_ELP_TIMER)
  std::chrono::steady_clock::time_point elp1, elp2;
#endif

  // routine 1 
#if defined(USE_CPU_TIMER)
  cpu1 = std::clock();
#endif
#if defined(USE_ELP_TIMER)
  elp1 = std::chrono::steady_clock::now();
#endif

  for ( int k=0; k<100000; ++k ) sub1 ( a.data(), nn ) ;

#if defined(USE_CPU_TIMER)
  cpu2 = std::clock();
  fprintf (stdout, "sub1: CPU time (sec)     = %17.6f\n", static_cast<double>(cpu2 - cpu1) / CLOCKS_PER_SEC) ;
#endif
#if defined(USE_ELP_TIMER)
  elp2 = std::chrono::steady_clock::now();
  fprintf (stdout, "sub1: Elapsed time (sec) = %17.6f\n", std::chrono::duration<double>(elp2 - elp1).count()) ;
#endif

  fprintf (stdout, "a[0] = %13.6f\n", a[0] ) ;

  // routine 2 
#if defined(USE_CPU_TIMER)
  cpu1 = std::clock();
#endif
#if defined(USE_ELP_TIMER)
  elp1 = std::chrono::steady_clock::now();
#endif

  for ( int k=0; k<200000; ++k ) sub2 ( a.data(), nn ) ;

#if defined(USE_CPU_TIMER)
  cpu2 = std::clock();
  fprintf (stdout, "sub2: CPU time (sec)     = %17.6f\n", static_cast<double>(cpu2 - cpu1) / CLOCKS_PER_SEC) ;
#endif
#if defined(USE_ELP_TIMER)
  elp2 = std::chrono::steady_clock::now();
  fprintf (stdout, "sub2: Elapsed time (sec) = %17.6f\n", std::chrono::duration<double>(elp2 - elp1).count()) ;
#endif

  fprintf (stdout, "a[0] = %13.6f\n", a[0] ) ;

  // finalization 
  return EXIT_SUCCESS ;
}
//----------------------------------------------------------------------
//  sub1                                                              
//----------------------------------------------------------------------
void sub1 ( double *a, const int nn ) {

  for ( int i=0; i<nn; ++i ) a[i] += 1.0 ;

  for ( int k=0; k<2; ++k ) sub3( a, nn ) ;

}
//----------------------------------------------------------------------
//  sub2                                                              
//----------------------------------------------------------------------
void sub2 ( double *a, const int nn ) {

  a[0] = sin(a[0]) ;

  for ( int i=0; i<nn; ++i ) a[i] += 1.0 ;

  for ( int k=0; k<4; ++k ) sub3( a, nn ) ;

}
//----------------------------------------------------------------------
//  sub3                                                              
//----------------------------------------------------------------------
void sub3 ( double *a, const int nn ) {

  a[0] = sin(a[0]) ;

  for ( int i=0; i<nn; ++i ) a[i] += 1.0 ;

}
//----------------------------------------------------------------------
//  sub4                                                              
//----------------------------------------------------------------------
//void sub4 ( ) {
//  // sleep 
//  std::this_thread::sleep_for(std::chrono::seconds(30)); 
//}
