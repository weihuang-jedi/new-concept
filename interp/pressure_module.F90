module pressure_module

  use netcdf
  use status_module
  use namelist_module

  implicit none

  !-----------------------------------------------------------------------
  ! Define interfaces and attributes for module routines

  private
  public :: initialize_pressure_grid
  public :: finalize_pressure_grid
  public :: pressuregrid

  !-----------------------------------------------------------------------

  type pressuregrid
     character(len=1024)                   :: filename
     integer                               :: ncid
     integer                               :: nDims, nVars, &
                                              nGlobalAtts, unlimdimid
     integer, dimension(:), allocatable    :: dimids
     integer                               :: dimid_lon, dimid_lat, dimid_lev, &
                                              dimid_time
     integer                               :: nlon, nlat, nlev, ntime
     real, dimension(:),    allocatable    :: lon, lat, lev, hlev, ftime
     real, dimension(:, :), allocatable    :: ter, psf
     real, dimension(:, :, :), allocatable :: zf, zh, pf, ph, tf
  end type pressuregrid

  !-----------------------------------------------------------------------

contains

 !-----------------------------------------------------------------------
  subroutine initialize_pressure_grid(pgrid)

    implicit none

    type(pressuregrid), intent(inout) :: pgrid

    integer :: i, j, k

   !print *, 'enter initialize_pressure_grid'

    pgrid%nlon = nlon
    pgrid%nlat = nlat
    pgrid%nlev = nlev
    pgrid%ntime = ntime

    allocate(pgrid%ter(nlon, nlat))
    allocate(pgrid%psf(nlon, nlat))
    allocate(pgrid%tf(nlon, nlat, nlev))
    allocate(pgrid%zf(nlon, nlat, nlev))
    allocate(pgrid%zh(nlon, nlat, nlev+1))
    allocate(pgrid%pf(nlon, nlat, nlev))
    allocate(pgrid%ph(nlon, nlat, nlev+1))

    allocate(pgrid%lon(nlon))
    allocate(pgrid%lat(nlat))
    allocate(pgrid%lev(nlev))
    allocate(pgrid%hlev(nlev+1))
    allocate(pgrid%ftime(1))
    
    call read_pressure_grid(input_flnm, pgrid)

   !print *, 'pgrid%lon = ', pgrid%lon
   !print *, 'pgrid%lat = ', pgrid%lat

   !print *, 'leave initialize_pressure_grid'

  end subroutine initialize_pressure_grid

!----------------------------------------------------------------------------------------
  subroutine read_pressure_grid(input_flnm, pgrid)

    use netcdf
    use status_module

    implicit none

    character(len=*),    intent(in)    :: input_flnm
    type (pressuregrid), intent(inout) :: pgrid

    integer                           :: fileid
    integer                           :: nDims, nVars, &
                                         nGlobalAtts, unlimDimID

    character(len=128) :: dimname
    integer :: status, i, j, k, dimsize, include_parents

   !print *, 'Start Read pgrid grid info from file: ', trim(input_flnm)
   !print *, 'File: ', __FILE__, ', line: ', __LINE__

    include_parents = 0

    status = nf90_noerr

   !Open the file. 
    status = nf90_open(trim(input_flnm), nf90_nowrite, fileid)
    call check_status(status)
    pgrid%ncid = fileid

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
    status = nf90_inquire(fileid, nDims, nVars, &
                          nGlobalAtts, unlimdimid)
    call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
   !print *, 'nVars: ', nVars
   !print *, 'nDims: ', nDims

    pgrid%nDims = nDims
    pgrid%nVars = nVars
    pgrid%nGlobalAtts = nGlobalAtts

   !Allocate memory.
    allocate(pgrid%dimids(nDims))

    status = nf90_inq_dimids(fileid, nDims, pgrid%dimids, include_parents)
    call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
   !print *, 'pgrid%dimids: ', pgrid%dimids

    do i = 1, nDims
       status = nf90_inquire_dimension(fileid, pgrid%dimids(i), dimname, dimsize)
       call check_status(status)
      !print *, 'Dim No. ', i, ': ', trim(dimname), ', dimsize=', dimsize

       if(trim(dimname) == 'grid_xt') then
          if(pgrid%nlon /= dimsize) then
             print *, 'Dim lon: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlon
             stop 'Wrong nlon'
          end if
       else if(trim(dimname) == 'grid_yt') then
          if(pgrid%nlat /= dimsize) then
             print *, 'Dim lat: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlat
             stop 'Wrong nlat'
          end if
       else if(trim(dimname) == 'pfull') then
          if(pgrid%nlev /= dimsize) then
             print *, 'Dim lev: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlev
             stop 'Wrong nlev'
          end if
       end if
    end do

   !print *, 'File: ', __FILE__, ', line: ', __LINE__

   !read lon
    call nc_get1Dvar0(fileid, 'grid_xt', pgrid%lon, 1, pgrid%nlon)

   !read lat
    call nc_get1Dvar0(fileid, 'grid_yt', pgrid%lat, 1, pgrid%nlat)

   !read lev
    call nc_get1Dvar0(fileid, 'pfull', pgrid%lev, 1, pgrid%nlev)

   !print *, 'pgrid%lev = ', pgrid%lev

   !read hlev
    call nc_get1Dvar0(fileid, 'phalf', pgrid%hlev, 1, pgrid%nlev+1)

   !print *, 'pgrid%hlev = ', pgrid%hlev

   !read ter
    call nc_get2Dvar(fileid, 'hgtsfc', pgrid%ter, 1, 1, pgrid%nlon, 1, pgrid%nlat)

   !call check_minmax2d(pgrid%nlon, pgrid%nlat, pgrid%ter, 'Ter')

   !read psf
    call nc_get2Dvar(fileid, 'pressfc', pgrid%psf, 1, 1, pgrid%nlon, 1, pgrid%nlat)

   !call check_minmax2d(pgrid%nlon, pgrid%nlat, pgrid%psf, 'PSF')

   !read hgt
    call nc_get3Dvar(fileid, 'delz', pgrid%zf, 1, 1, pgrid%nlon, &
                     1, pgrid%nlat, 1, pgrid%nlev)

   !read prs
    call nc_get3Dvar(fileid, 'dpres', pgrid%pf, 1, 1, pgrid%nlon, &
                     1, pgrid%nlat, 1, pgrid%nlev)

   !read tmp
    call nc_get3Dvar(fileid, 'tmp', pgrid%tf, 1, 1, pgrid%nlon, &
                     1, pgrid%nlat, 1, pgrid%nlev)

   !call check_minmax3d(pgrid%nlon, pgrid%nlat, pgrid%nlev, pgrid%z3d, 'HGT')

   !status =  nf90_close(fileid)
   !call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__

   !print *, 'lon = ', pgrid%lon
   !print *, 'lat = ', pgrid%lat
   !print *, 'lev = ', pgrid%lev

    k = pgrid%nlev+1
    do j = 1, pgrid%nlat
    do i = 1, pgrid%nlon
       pgrid%zh(i,j,k) = pgrid%ter(i,j)
       pgrid%ph(i,j,k) = pgrid%psf(i,j)
    end do
    end do

   !print *, 'pgrid%zh(1,1,k) = ', pgrid%zh(1,1,k), ', pgrid%ph(1,1,k) = ', pgrid%ph(1,1,k)

    do k = pgrid%nlev, 1, -1

   !print *, 'pgrid%zf(1,1,k) = ', pgrid%zf(1,1,k), ', pgrid%pf(1,1,k) = ', pgrid%pf(1,1,k)
    do j = 1, pgrid%nlat
    do i = 1, pgrid%nlon
       pgrid%zh(i,j,k) = pgrid%zh(i,j,k+1) - pgrid%zf(i,j,k)
       pgrid%ph(i,j,k) = pgrid%ph(i,j,k+1) - pgrid%pf(i,j,k)
       pgrid%zf(i,j,k) = 0.5*(pgrid%zh(i,j,k+1) + pgrid%zh(i,j,k))
       pgrid%pf(i,j,k) = 0.5*(pgrid%ph(i,j,k+1) + pgrid%ph(i,j,k))
    end do
    end do

   !print *, 'pgrid%zh(1,1,k) = ', pgrid%zh(1,1,k), ', pgrid%ph(1,1,k) = ', pgrid%ph(1,1,k)
   !print *, 'pgrid%zf(1,1,k) = ', pgrid%zf(1,1,k), ', pgrid%pf(1,1,k) = ', pgrid%pf(1,1,k)
    end do

   !Deallocate memory.
   !deallocate(pgrid%dimids)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
   !print *, 'Finished Read pressure grid info from file: ', trim(input_flnm)

  end subroutine read_pressure_grid

 !----------------------------------------------------------------------
  subroutine finalize_pressure_grid(pgrid)

    use netcdf

    implicit none

    type(pressuregrid), intent(inout) :: pgrid
    integer :: rc

    deallocate(pgrid%lon)
    deallocate(pgrid%lat)
    deallocate(pgrid%lev)
    if(allocated(pgrid%ftime)) deallocate(pgrid%ftime)
    if(allocated(pgrid%dimids)) deallocate(pgrid%dimids)

    deallocate(pgrid%ter)
    deallocate(pgrid%psf)
    deallocate(pgrid%tf)
    deallocate(pgrid%zf)
    deallocate(pgrid%zh)
    deallocate(pgrid%pf)
    deallocate(pgrid%ph)

    rc =  nf90_close(pgrid%ncid)
    call check_status(rc)

   !print *, 'Finished Write to file: ', trim(pgrid%filename)

  end subroutine finalize_pressure_grid

end module pressure_module

