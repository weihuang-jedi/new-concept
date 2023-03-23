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

    p2z = va + (z-za)*(vb - va)/(zb - za)

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
    kgfs = pgrid%nlev
    do k = 1, zgrid%nalt
      !print *, 'i,j,k,jgfs,kgfs = ', i,j,k,jgfs,kgfs
      !print *, 'zgrid%alt(k) = ', zgrid%alt(k)

       if(zgrid%alt(k) <= pgrid%zf(i,jgfs,pgrid%nlev)) then
         if(zgrid%alt(k) <= pgrid%zh(i,jgfs,pgrid%nlev+1)) then
           v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zh(i,jgfs,pgrid%nlev+1), &
                                          pgrid%zh(i,jgfs,pgrid%nlev), &
                                          pgrid%ph(i,jgfs,pgrid%nlev+1), &
                                          pgrid%ph(i,jgfs,pgrid%nlev))
         end if
       else if(zgrid%alt(k) >= pgrid%zf(i,jgfs,1)) then
         v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zh(i,jgfs,1), &
                                        pgrid%zh(i,jgfs,2), &
                                        pgrid%ph(i,jgfs,1), &
                                        pgrid%ph(i,jgfs,2))
       else
         do while(kgfs > 1)
           if((zgrid%alt(k) > pgrid%zf(i,jgfs,kgfs)) .and. &
              (zgrid%alt(k) <= pgrid%zf(i,jgfs,kgfs-1))) then
              v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,kgfs-1), &
                                             pgrid%zf(i,jgfs,kgfs), &
                                             pgrid%pf(i,jgfs,kgfs-1), &
                                             pgrid%pf(i,jgfs,kgfs))
              exit
           end if
           kgfs = kgfs - 1
         end do
       end if
    end do
    end do
    end do

   !i = 1
   !j = 1
   !do k = 1, zgrid%nalt
   !   print *, 'zgrid%alt(k) = ', zgrid%alt(k), ', v3d(i,j,k) =', v3d(i,j,k)
   !end do
   !do k = 1, pgrid%nlev
   !   print *, 'pgrid%zf(i,j,k) = ', pgrid%zf(i,j,k), ', pgrid%pf(i,j,k) = ', pgrid%pf(i,j,k)
   !end do

   !write p
    call nc_put3Dvar0(zgrid%ncid, 'p', v3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)

   !call check_minmax3d(zgrid%nlon, zgrid%nlat, zgrid%nalt, v3d, 'Pressure')

   !do k = 1, zgrid%nalt
   !  !print *, 'Altitude: ', zgrid%alt(k)
   !   call check_minmax2d(zgrid%nlon, zgrid%nlat, v3d(:,:,k), 'P at level')
   !end do

    deallocate(v3d)

    call p2z4var(pgrid, zgrid, 't', 'tmp')
    call p2z4var(pgrid, zgrid, 'u', 'ugrd')
    call p2z4var(pgrid, zgrid, 'v', 'vgrd')
    call p2z4var(pgrid, zgrid, 'q', 'spfh')

  end subroutine interp_p2z

 !-----------------------------------------------------------------------
  subroutine p2z4var(pgrid, zgrid, z3dname, p3dname)

    implicit none

    type(pressuregrid), intent(in)  :: pgrid
    type(altitudegrid), intent(inout) :: zgrid
    character(len=*), intent(in) :: z3dname, p3dname

    real, dimension(:,:,:), allocatable :: v3d, p3d

    integer :: i,j,k, jgfs, kgfs, kend

    allocate(v3d(zgrid%nlon, zgrid%nlat, zgrid%nalt))
    allocate(p3d(pgrid%nlon, pgrid%nlat, pgrid%nlev))

   !read p3d
    call nc_get3Dvar(pgrid%ncid, trim(p3dname), p3d, 1, 1, pgrid%nlon, &
                     1, pgrid%nlat, 1, pgrid%nlev)
    call check_minmax3d(pgrid%nlon, pgrid%nlat, pgrid%nlev, p3d, trim(p3dname))

    do jgfs = 1, nlat
    j = nlat + 1 - jgfs
    do i = 1, nlon
    kgfs = pgrid%nlev
    do k = 1, zgrid%nalt
       if(zgrid%alt(k) <= pgrid%zf(i,jgfs,pgrid%nlev)) then
         v3d(i,j,k) = p3d(i,jgfs,pgrid%nlev)
       else if(zgrid%alt(k) >= pgrid%zf(i,jgfs,1)) then
         v3d(i,j,k) = p3d(i,jgfs,1)
       else
         do while(kgfs > 1)
           if((zgrid%alt(k) > pgrid%zf(i,jgfs,kgfs)) .and. &
              (zgrid%alt(k) <= pgrid%zf(i,jgfs,kgfs-1))) then
              v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,kgfs-1), &
                               pgrid%zf(i,jgfs,kgfs), &
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

  end subroutine p2z4var

end module interp_module

