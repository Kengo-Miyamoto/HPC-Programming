! Copyright 2024 Research Organization for Information Science and Technology
!-----------------------------------------------------------------------
!  Hand-coded timer and Use of gprof
!  Author:      Yukihiro Ota (yota@rist.or.jp)
!  Last Update: 18th Apr. 2023
!  Reference:   M. Metcalf et al. "Modern Fortran explained"
!               (Oxford, 2011) Chap.12
!-----------------------------------------------------------------------
program main
  use, intrinsic::iso_c_binding, only: c_double
  use iso_fortran_env, only: real64

  implicit none

  integer,parameter :: nn = 20000
  integer :: i, k

  real(real64) :: a(nn)

#ifdef USE_ELP_TIMER
  real(kind=c_double) :: elp1, elp2
#endif
#ifdef USE_CPU_TIMER
  real(kind=c_double) :: cpu1, cpu2
#endif

  interface
    !! timer.c
    real(kind=c_double) function get_elp_time() bind(c)
      use, intrinsic::iso_c_binding, only: c_double
    end function get_elp_time 
    real(kind=c_double) function get_cpu_time() bind(c)
      use, intrinsic::iso_c_binding, only: c_double
    end function get_cpu_time
  end interface

! set values
  do i = 1, nn
    a(i) = 0.0_real64
  enddo

! routine 1
#ifdef USE_ELP_TIMER
  elp1 = get_elp_time() 
#endif
#ifdef USE_CPU_TIMER
  cpu1 = get_cpu_time()
#endif
  do k = 1, 100000
    call sub1 ( a, nn ) 
  enddo
#ifdef USE_ELP_TIMER
  elp2 = get_elp_time() 
  write (6,'(1a30,1f13.6)') "sub1: Elapsed time (sec)     ", elp2 - elp1
#endif
#ifdef USE_CPU_TIMER
  cpu2 = get_cpu_time()
  write (6,'(1a30,1f13.6)') "sub1: CPU time (sec)         ", cpu2 - cpu1 
#endif
  write (6,'(1a24,1f13.6)') "a(1) =                 ", a(1)

! routine 2
#ifdef USE_ELP_TIMER
  elp1 = get_elp_time() 
#endif
#ifdef USE_CPU_TIMER
  cpu1 = get_cpu_time()
#endif
  do k = 1, 200000
    call sub2 ( a, nn ) 
  enddo
#ifdef USE_ELP_TIMER
  elp2 = get_elp_time() 
  write (6,'(1a30,1f13.6)') "sub2: Elapsed time (sec)     ", elp2 - elp1
#endif
#ifdef USE_CPU_TIMER
  cpu2 = get_cpu_time()
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
   real(real64),intent(inout) :: a(nn)
   integer,intent(in) :: nn
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
   real(real64),intent(inout) :: a(nn)
   integer,intent(in) :: nn
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
   real(real64),intent(inout) :: a(nn)
   integer,intent(in) :: nn
   !*** local variables ***
   integer :: i

   a(1) = sin(a(1))

   do i = 1, nn
     a(i) = a(i) + 1.0_real64
   enddo

   return 
end subroutine 
