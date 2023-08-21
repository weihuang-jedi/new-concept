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
    real*8, intent(in) :: z, za, zb, va, vb
    real*8 :: p2z

    p2z = vb + (z-zb)*(va - vb)/(za - zb)

  end function p2z

 !-----------------------------------------------------------------------
  subroutine interp_p2z(pgrid, zgrid)

    implicit none

    type(pressuregrid), intent(in)  :: pgrid
    type(altitudegrid), intent(inout) :: zgrid

    real*8, dimension(:,:,:), allocatable :: v3d
    real*8, dimension(:,:,:), allocatable :: p3d

    integer                           :: fileid
    integer                           :: nDims, nVars, &
                                         nGlobalAtts, unlimDimID
    integer :: status, include_parents
    integer :: i,j,k, jgfs, kgfs

    real*8, parameter :: one = 1.0D0
    real*8, parameter :: zero = 0.0D0

   !print *, 'enter interp_p2z'

    allocate(v3d(nlon, nlat, zgrid%nalt))
    allocate(p3d(nlon, nlat, pgrid%nlev))

    do jgfs = 1, nlat
    j = nlat + 1 - jgfs
    do i = 1, nlon
    kgfs = pgrid%nlev
    do k = 1, zgrid%nalt
       if(zgrid%alt(k) < pgrid%z3d(i,jgfs,pgrid%nlev)) then
         if(pgrid%z3d(i,jgfs,pgrid%nlev) < one) then
           v3d(i,j,k) = pgrid%psl(i,jgfs)
         else
           v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%z3d(i,jgfs,pgrid%nlev), zero, &
                            pgrid%lev(pgrid%nlev), pgrid%psl(i,jgfs))
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

   !do k = 1, zgrid%nalt
   !   print *, 'zgrid%alt(', k, ') = ', zgrid%alt(k)
   !end do

   !write p
    call nc_put3Dvar0(zgrid%ncid, 'p', v3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)

    call check_minmax3d(zgrid%nlon, zgrid%nlat, zgrid%nalt, v3d, 'Pressure')

   !do k = 1, zgrid%nalt
   !  !print *, 'Altitude: ', zgrid%alt(k)
   !   call check_minmax2d(zgrid%nlon, zgrid%nlat, v3d(:,:,k), 'P at level')
   !end do

    deallocate(v3d)

    print *, 'File: ', __FILE__, ', line: ', __LINE__
    print *, 'Working on t'
    call p2z4var(pgrid, zgrid, 't', pgrid%t3d, pgrid%t2m)
    print *, 'Finished t'

    include_parents = 0

    status = nf90_noerr

   !Open the file. 
    status = nf90_open(trim(input_uvq_flnm), nf90_nowrite, fileid)
    call check_status(status)

    status = nf90_inquire(fileid, nDims, nVars, &
                          nGlobalAtts, unlimdimid)
    call check_status(status)

   !read u
    call nc_get3Dvar(fileid, 'u', p3d, 1, 1, pgrid%nlon, &
                      1, pgrid%nlat, 1, pgrid%nlev)
    print *, 'File: ', __FILE__, ', line: ', __LINE__
    print *, 'Working on u'
    call p2z4var(pgrid, zgrid, 'u', p3d, pgrid%u10)
    print *, 'Finished u'

   !read v
    call nc_get3Dvar(fileid, 'v', p3d, 1, 1, pgrid%nlon, &
                      1, pgrid%nlat, 1, pgrid%nlev)
    print *, 'File: ', __FILE__, ', line: ', __LINE__
    print *, 'Working on v'
    call p2z4var(pgrid, zgrid, 'v', p3d, pgrid%v10)
    print *, 'Finished v'

   !read q
   !call nc_get3Dvar(fileid, 'q', p3d, 1, 1, pgrid%nlon, &
   !                  1, pgrid%nlat, 1, pgrid%nlev)
   !call p2z4var(pgrid, zgrid, 'q', p3d, pgrid%q2m)

    deallocate(p3d)

  end subroutine interp_p2z

 !-----------------------------------------------------------------------
  subroutine p2z4var(pgrid, zgrid, z3dname, p3d, p2d)

    implicit none

    type(pressuregrid), intent(in) :: pgrid
    type(altitudegrid), intent(in) :: zgrid
    character(len=*), intent(in) :: z3dname
    real*8, dimension(nlon, nlat, zgrid%nalt), intent(in) :: p3d
    real*8, dimension(nlon, nlat), intent(in) :: p2d

    real*8, dimension(:,:,:), allocatable :: v3d

    real*8, parameter :: one = 1.0D0
    real*8, parameter :: zero = 0.0D0

    integer :: i,j,k, jgfs, kgfs

    allocate(v3d(zgrid%nlon, zgrid%nlat, zgrid%nalt))

    do jgfs = 1, nlat
    j = nlat + 1 - jgfs
    do i = 1, nlon
    kgfs = pgrid%nlev
    do k = 1, zgrid%nalt
       if(zgrid%alt(k) < pgrid%z3d(i,jgfs,pgrid%nlev)) then
         if(pgrid%z3d(i,jgfs,pgrid%nlev) < one) then
           v3d(i,j,k) = p2d(i,jgfs)
         else
           v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%z3d(i,jgfs,pgrid%nlev), zero, &
                            p3d(i,jgfs,pgrid%nlev), p2d(i,jgfs))
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

    do k = 1, zgrid%nalt
       print *, 'Altitude: ', zgrid%alt(k)
       call check_minmax2d(zgrid%nlon, zgrid%nlat, v3d(:,:,k), trim(z3dname))
    end do

    deallocate(v3d)

  end subroutine p2z4var

end module interp_module

