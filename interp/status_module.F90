!-----------------------------------------------------------------------
!  The status module check the return code meaning
!-----------------------------------------------------------------------

module status_module

  use netcdf

  implicit none

  private
  public :: check_status
  public :: check_minmax2d

contains

  !----------------------------------------------------------------------
  subroutine check_status(rc)

    implicit none

    integer, intent(in) :: rc
    
    if(rc /= nf90_noerr) then 
      print *, trim(nf90_strerror(rc))
      print *, 'rc = ', rc, ', nf90_noerr = ', nf90_noerr
      stop 'in check_status'
    end if

  end subroutine check_status  

  !----------------------------------------------------------------------
  subroutine check_minmax2d(nx, ny, var, symbol)

    implicit none

    integer, intent(in) :: nx, ny
    real, dimension(nx, ny), intent(in) :: var
    character(len=*), intent(in) :: symbol

    integer :: i, j
    real :: vmin, vmax

    vmin = 1.0e32
    vmax = -1.0e32

    do j = 1, ny
    do i = 1, nx
       if(var(i,j) > vmax) vmax = var(i,j)
       if(var(i,j) < vmin) vmin = var(i,j)
    end do
    end do

    print *, trim(symbol), ' min: ', vmin, ', max: ', vmax

  end subroutine check_minmax2d

end module status_module

