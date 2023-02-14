module interp_module

  use netcdf
  use status_module
  use namelist_module
  use pressure_module
  use altitude_module

  implicit none

  !-----------------------------------------------------------------------
  ! Define interfaces and attributes for module routines

  private
  public :: interp_p2z

  !-----------------------------------------------------------------------

contains
 !-----------------------------------------------------------------------
  function p2z(z, za, zb, va, vb)
    implicit none
    real, intent(in) :: z, za, zb, va, vb
    real :: p2z

    p2z = vb + (z-za)*(vb - va)/(zb - za)

  end function p2z

 !-----------------------------------------------------------------------
  subroutine interp_p2z(pgrid, zgrid)

    implicit none

    type(pressuregrid), intent(in)  :: pgrid
    type(altitudegrid), intent(inout) :: zgrid

    real, dimension(:,:,:), allocatable :: v3d

    integer :: i,j,k, jgfs, kgfs, kend

   !print *, 'enter interp_p2z'

    allocate(v3d(nlon, nlat, nalt))

    do jgfs = 1, nlat
    j = nlat + 1 - jgfs
    do i = 1, nlon
    kgfs = nlev
    do k = 1, zgrid%nalt
      !print *, 'i,j,k,jgfs,kgfs = ', i,j,k,jgfs,kgfs
      !print *, 'zgrid%alt(k) = ', zgrid%alt(k)
      !print *, 'pgrid%z3d(i,jgfs,pgrid%nlev) = ', pgrid%z3d(i,jgfs,pgrid%nlev)

       if(zgrid%alt(k) < pgrid%z3d(i,jgfs,pgrid%nlev)) then
         if(pgrid%z3d(i,jgfs,pgrid%nlev) < 1.0) then
           v3d(i,j,k) = pgrid%psl(i,jgfs)
         else
           v3d(i,j,k) = p2z(zgrid%alt(k), 0.0, pgrid%z3d(i,jgfs,pgrid%nlev), &
                            pgrid%psl(i,jgfs), pgrid%lev(nlev))
         end if
       else if(zgrid%alt(k) >= pgrid%z3d(i,jgfs,1)) then
         v3d(i,j,k) = pgrid%lev(1)
       else
         do while(kgfs > 1)
           if((zgrid%alt(k) < pgrid%z3d(i,jgfs,kgfs-1)) .and. &
              (zgrid%alt(k) >= pgrid%z3d(i,jgfs,kgfs))) then
              v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%z3d(i,jgfs,kgfs-1), &
                               pgrid%z3d(i,jgfs,kgfs), &
                               pgrid%lev(kgfs-1), pgrid%lev(kgfs))
              exit
           end if
           kgfs = kgfs - 1
         end do
       end if
    end do
    end do
    end do

   !write p
    call nc_put3Dvar0(zgrid%ncid, 'p', v3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)

    call check_minmax3d(zgrid%nlon, zgrid%nlat, zgrid%nalt, v3d, 'Pressure')

    do k = 1, zgrid%nalt
      !print *, 'Altitude: ', zgrid%alt(k)
       call check_minmax2d(zgrid%nlon, zgrid%nlat, v3d(:,:,k), 'P at level')
    end do

    deallocate(v3d)

    call p2z4var(pgrid, zgrid, 't', 'TMP_P0_L100_GLL0', 'TMP_P0_L1_GLL0')
    call p2z4var(pgrid, zgrid, 'u', 'UGRD_P0_L100_GLL0', 'UGRD_P0_L220_GLL0')
    call p2z4var(pgrid, zgrid, 'v', 'VGRD_P0_L100_GLL0', 'VGRD_P0_L220_GLL0')
    call p2z4var(pgrid, zgrid, 'q', 'SPFH_P0_L100_GLL0', 'SPFH_P0_2L108_GLL0')

  end subroutine interp_p2z

 !-----------------------------------------------------------------------
  subroutine p2z4var(pgrid, zgrid, z3dname, p3dname, p2dname)

    implicit none

    type(pressuregrid), intent(in)  :: pgrid
    type(altitudegrid), intent(inout) :: zgrid
    character(len=*), intent(in) :: z3dname, p3dname, p2dname

    real, dimension(:,:,:), allocatable :: v3d, p3d
    real, dimension(:,:), allocatable :: p2d

    integer :: i,j,k, jgfs, kgfs, kend

    allocate(v3d(zgrid%nlon, zgrid%nlat, zgrid%nalt))
    allocate(p3d(pgrid%nlon, pgrid%nlat, pgrid%nlev))
    allocate(p2d(pgrid%nlon, pgrid%nlat))

   !read p2d
    call nc_get2Dvar0(pgrid%ncid, trim(p2dname), p2d, 1, pgrid%nlon, 1, pgrid%nlat)
    call check_minmax2d(pgrid%nlon, pgrid%nlat, p2d, trim(p2dname))

   !read p3d
    call nc_get3Dvar0(pgrid%ncid, trim(p3dname), p3d, 1, pgrid%nlon, &
                      1, pgrid%nlat, 1, pgrid%nlev)
    call check_minmax3d(pgrid%nlon, pgrid%nlat, pgrid%nlev, p3d, trim(p3dname))

    do jgfs = 1, nlat
    j = nlat + 1 - jgfs
    do i = 1, nlon
    kgfs = nlev
    do k = 1, zgrid%nalt
       if(zgrid%alt(k) < pgrid%z3d(i,jgfs,pgrid%nlev)) then
         if(pgrid%z3d(i,jgfs,pgrid%nlev) < 1.0) then
           v3d(i,j,k) = p2d(i,jgfs)
         else
           v3d(i,j,k) = p2z(zgrid%alt(k), 0.0, pgrid%z3d(i,jgfs,pgrid%nlev), &
                            p2d(i,jgfs), p3d(i,jgfs,nlev))
         end if
       else if(zgrid%alt(k) >= pgrid%z3d(i,jgfs,1)) then
         v3d(i,j,k) = p3d(i,jgfs,1)
       else
         do while(kgfs > 1)
           if((zgrid%alt(k) < pgrid%z3d(i,jgfs,kgfs-1)) .and. &
              (zgrid%alt(k) >= pgrid%z3d(i,jgfs,kgfs))) then
              v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%z3d(i,jgfs,kgfs-1), &
                               pgrid%z3d(i,jgfs,kgfs), &
                               p3d(i,jgfs,kgfs-1), p3d(i,jgfs,kgfs))
              exit
           end if
           kgfs = kgfs - 1
         end do
       end if
    end do
    end do
    end do

   !write v3d
    call nc_put3Dvar0(zgrid%ncid, trim(z3dname), v3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)

    call check_minmax3d(zgrid%nlon, zgrid%nlat, zgrid%nalt, v3d, trim(z3dname))

   !do k = 1, zgrid%nalt
   !   print *, 'Altitude: ', zgrid%alt(k)
   !   call check_minmax2d(zgrid%nlon, zgrid%nlat, v3d(:,:,k), 'P at level')
   !end do

    deallocate(v3d)
    deallocate(p3d)
    deallocate(p2d)

  end subroutine p2z4var

end module interp_module

