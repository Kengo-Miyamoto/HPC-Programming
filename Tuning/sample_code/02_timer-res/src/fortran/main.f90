! Copyright 2024 Research Organization for Information Science and Technology
!*************************************************************************
!  Check resolution of your timer
!  Author:      Yukihiro Ota (yota@rist.or.jp)
!  Description: The original idea comes from Wadleigh and Crawford,
!               "Software Optimization for HPC: Creating Faster 
!                Applications" (2000) pp.136-138 
!  Extended to compare the nominal resolution reported by
!  system_clock(count_rate=...) with the resolution measured
!  empirically by the iteration loop. cpu_time() has no API to query
!  its nominal resolution, so only the measured value is printed for
!  the CPU timer.
!*************************************************************************

!=========================================================================
!   module: mytype 
!=========================================================================
module mytype
  implicit none
  integer,parameter :: SP = kind(1.0)
  integer,parameter :: DP = selected_real_kind(2*precision(1.0_SP))
end module mytype
!=========================================================================
!   main 
!=========================================================================
program main

  use mytype,only: DP
  use iso_fortran_env, only: int64

  implicit none

  !! local var
  integer :: i, nn
  integer(int64) :: cnt1, cnt2, cnt_rate, cnt_max
  integer,parameter :: nn_max = 10000000

  real(kind=DP) :: tval, tval0, res_api
  real(kind=DP),parameter :: ZERO = 0.0_DP

  !! interface to function
  interface
    
    function func(nn)
      integer :: func
      integer,intent(in) :: nn
    end function func

  end interface

  write(6,'("----------------------------------------------------------")')

  !! check resolution of wallclock timer  
  write(6,'("[Wallclock timer]")')
  call system_clock (count_rate = cnt_rate)
  if ( cnt_rate > 0 ) then
    res_api = 1.0_DP / dble(cnt_rate)
  else
    res_api = -1.0_DP
  end if
  write(6,'(" [API]      nominal resolution   = ",1F17.9," sec.")') res_api

  tval = -1.0_DP 
  nn = 0
  do while ( tval .le. ZERO .and. nn .lt. nn_max )
    nn = nn + 1
    call system_clock (cnt1)
    i = func(nn)
    call system_clock (cnt2, cnt_rate, cnt_max)
    if ( cnt_rate > 0 ) then
      if ( cnt2 .ge. cnt1 ) then
         tval = (cnt2 - cnt1) / dble(cnt_rate)
      else
         tval = (cnt2 - cnt1 + cnt_max + 1) / dble(cnt_rate)
      end if
    end if
  end do

  if ( nn .ge. nn_max ) then
    write(6,'("Warning: wallclock timer resolution could not be determined.")')
  else
    write(6,'(" [Measured] observed resolution  = ",1F17.9," sec. (nn = ",1I0," iterations)")') tval, nn
    if ( res_api > ZERO ) then
      write(6,'(" ratio (measured / API)          = ",1F13.2)') tval / res_api
    end if
  end if

  write(6,'("----------------------------------------------------------")')

  !! check resolution of cpu timer  
  write(6,'("[CPU timer]")')
  write(6,'(" [API]      no nominal-resolution API is available for cpu_time()")')

  tval = -1.0_DP 
  nn = 0
  do while ( tval .le. ZERO .and. nn .lt. nn_max )
    nn = nn + 1
    call cpu_time (tval0)
    i = func(nn)
    call cpu_time (tval)
    tval = tval - tval0
  end do

  if ( nn .ge. nn_max ) then
    write(6,'("Warning: cpu timer resolution could not be determined.")')
  else
    write(6,'(" [Measured] observed resolution  = ",1F17.9," sec. (nn = ",1I0," iterations)")') tval, nn
  end if

  write(6,'("----------------------------------------------------------")')

  stop
end program main
!==========================================================================
!   func 
!==========================================================================
function func (nn)

  implicit none

  integer :: func
  integer,intent(in) :: nn

  integer :: j

  func = 0
  do j = 1, nn
    func = func + 1
  end do
end function func
