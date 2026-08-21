! Copyright 2024 Research Organization for Information Science and Technology
!-----------------------------------------------------------------------
!  Hand-coded timer and Use of gprof 
!  Author:      Yukihiro Ota (yota@rist.or.jp)
!-----------------------------------------------------------------------
program main

  use iso_fortran_env, only: int64, real64

  implicit none

  integer,parameter :: nn = 20000
  integer :: i, k

  real(real64) :: a(nn)

#ifdef USE_ELP_TIMER
  integer(int64) :: ielp1, ielp2, icount_rate, icount_max
  real(real64) :: elp
#endif
#ifdef USE_CPU_TIMER
  real(real64) :: cpu1, cpu2
#endif

! set values
  do i = 1, nn
    a(i) = 0.0_real64
  enddo

! routine 1
#ifdef USE_ELP_TIMER
  call system_clock ( ielp1, icount_rate, icount_max )
#endif
#ifdef USE_CPU_TIMER
  call cpu_time ( cpu1 )
#endif
  do k = 1, 100000
    call sub1 ( a, nn ) 
  enddo
#ifdef USE_ELP_TIMER
  call system_clock ( ielp2, icount_rate, icount_max )
  if ( icount_rate > 0 ) then
    if ( ielp1 <= ielp2 ) then
      elp = (ielp2 - ielp1) / real(icount_rate, real64)
    else
      elp = (ielp2 - ielp1 + icount_max + 1) / real(icount_rate, real64)
    endif
    write (6,'(1a30,1f13.6)') "sub1: Elapsed time (sec)     ", elp
  else
    write (6,'(1a37)') "sub1: Elapsed time: clock unavailable"
  endif
#endif
#ifdef USE_CPU_TIMER
  call cpu_time ( cpu2 )
  write (6,'(1a30,1f13.6)') "sub1: CPU time (sec)         ", cpu2 - cpu1 
#endif
  write (6,'(1a24,1f13.6)') "a(1) =                 ", a(1)

! routine 2
#ifdef USE_ELP_TIMER
  call system_clock ( ielp1, icount_rate, icount_max )
#endif
#ifdef USE_CPU_TIMER
  call cpu_time ( cpu1 )
#endif
  do k = 1, 200000
    call sub2 ( a, nn ) 
  enddo
#ifdef USE_ELP_TIMER
  call system_clock ( ielp2, icount_rate, icount_max )
  if ( icount_rate > 0 ) then
    if ( ielp1 <= ielp2 ) then
      elp = (ielp2 - ielp1) / real(icount_rate, real64)
    else
      elp = (ielp2 - ielp1 + icount_max + 1) / real(icount_rate, real64)
    endif
    write (6,'(1a30,1f13.6)') "sub2: Elapsed time (sec)     ", elp
  else
    write (6,'(1a37)') "sub2: Elapsed time: clock unavailable"
  endif
#endif
#ifdef USE_CPU_TIMER
  call cpu_time ( cpu2 )
  write (6,'(1a30,1f13.6)') "sub2: CPU time (sec)         ", cpu2 - cpu1 
#endif
  write (6,'(1a24,1f13.6)') "a(1) =                 ", a(1)

! finalization
  stop
end
!-----------------------------------------------------------------------
!   sub 1
!-----------------------------------------------------------------------
subroutine sub1 ( a, nn )
   use iso_fortran_env, only: real64
   implicit none
   integer,intent(in) :: nn
   real(real64),intent(inout) :: a(nn)
   !*** local variables ***
   integer :: i, k

   do i = 1, nn
     a(i) = a(i) + 1.0_real64
   enddo

   do k = 1, 2
     call sub3 ( a, nn )
   enddo

   return
end subroutine 
!-----------------------------------------------------------------------
!   sub 2
!-----------------------------------------------------------------------
subroutine sub2 ( a, nn )
   use iso_fortran_env, only: real64
   implicit none
   integer,intent(in) :: nn
   real(real64),intent(inout) :: a(nn)
   !*** local variables ***
   integer :: i, k

   a(1) = sin(a(1))

   do i = 1, nn
     a(i) = a(i) + 1.0_real64
   enddo

   do k = 1, 4
     call sub3 ( a, nn )
   enddo

   return
end subroutine 
!-----------------------------------------------------------------------
!   sub 3
!-----------------------------------------------------------------------
subroutine sub3 ( a, nn )
   use iso_fortran_env, only: real64
   implicit none
   integer,intent(in) :: nn
   real(real64),intent(inout) :: a(nn)
   !*** local variables ***
   integer :: i

   a(1) = sin(a(1))

   do i = 1, nn
     a(i) = a(i) + 1.0_real64
   enddo

   return 
end subroutine 
