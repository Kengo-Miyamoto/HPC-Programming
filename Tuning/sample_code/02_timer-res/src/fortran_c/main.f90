! Copyright 2024 Research Organization for Information Science and Technology
!*************************************************************************
!  Check resolution of your timer (Fortran with C timer via iso_c_binding)
!  Author:      Yukihiro Ota (yota@rist.or.jp)
!  Description: The original idea comes from Wadleigh and Crawford,
!               "Software Optimization for HPC: Creating Faster 
!                Applications" (2000) pp.136-138 
!  This variant reuses the C timer routines (get_elp_time, get_cpu_time,
!  get_elp_res, get_cpu_res) declared in ../c/timer.h and defined in
!  ../c/timer.c, called from Fortran via iso_c_binding.
!*************************************************************************
program main

  use, intrinsic :: iso_c_binding, only: c_double
  implicit none

  !! local var
  integer :: i, nn
  integer,parameter :: nn_max = 10000000

  real(kind=c_double) :: t1, t2, res_api

  !! interface to C timer routines (../c/timer.c)
  interface
    real(kind=c_double) function get_elp_time() bind(c)
      use, intrinsic :: iso_c_binding, only: c_double
    end function get_elp_time
    real(kind=c_double) function get_cpu_time() bind(c)
      use, intrinsic :: iso_c_binding, only: c_double
    end function get_cpu_time
    real(kind=c_double) function get_elp_res() bind(c)
      use, intrinsic :: iso_c_binding, only: c_double
    end function get_elp_res
    real(kind=c_double) function get_cpu_res() bind(c)
      use, intrinsic :: iso_c_binding, only: c_double
    end function get_cpu_res
  end interface

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
  res_api = get_elp_res()
  write(6,'(" [API]      nominal resolution   = ",1F17.9," sec.")') res_api

  t2 = -1.0_c_double
  nn = 0
  do while ( t2 .le. 0.0_c_double .and. nn .lt. nn_max )
    nn = nn + 1
    t1 = get_elp_time()
    i = func(nn)
    t2 = get_elp_time()
    t2 = t2 - t1
  end do

  if ( nn .ge. nn_max ) then
    write(6,'("Warning: wallclock timer resolution could not be determined.")')
  else
    write(6,'(" [Measured] observed resolution  = ",1F17.9," sec. (nn = ",1I0," iterations)")') t2, nn
    write(6,'(" ratio (measured / API)          = ",1F13.2)') t2 / res_api
  end if

  write(6,'("----------------------------------------------------------")')

  !! check resolution of cpu timer
  write(6,'("[CPU timer]")')
  res_api = get_cpu_res()
  write(6,'(" [API]      nominal resolution   = ",1F17.9," sec.")') res_api

  t2 = -1.0_c_double
  nn = 0
  do while ( t2 .le. 0.0_c_double .and. nn .lt. nn_max )
    nn = nn + 1
    t1 = get_cpu_time()
    i = func(nn)
    t2 = get_cpu_time()
    t2 = t2 - t1
  end do

  if ( nn .ge. nn_max ) then
    write(6,'("Warning: cpu timer resolution could not be determined.")')
  else
    write(6,'(" [Measured] observed resolution  = ",1F17.9," sec. (nn = ",1I0," iterations)")') t2, nn
    write(6,'(" ratio (measured / API)          = ",1F13.2)') t2 / res_api
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
