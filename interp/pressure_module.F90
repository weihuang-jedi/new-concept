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
     integer                               :: nlon, nlat, nlev, nbnds, ntime
     real, dimension(:),    allocatable    :: lon, lat
    !real, dimension(:),    allocatable    :: ftime
     real*8, dimension(:),    allocatable    :: lev
     real*8, dimension(:, :), allocatable    :: psl, u10, v10, t2m
     real*8, dimension(:, :, :), allocatable :: z3d, t3d
  end type pressuregrid

  !-----------------------------------------------------------------------

contains

 !-----------------------------------------------------------------------
  subroutine initialize_pressure_grid(pgrid)

    implicit none

    type(pressuregrid), intent(inout) :: pgrid

    integer :: i, j, k

    print *, 'enter initialize_pressure_grid'

    pgrid%nlon = nlon
    pgrid%nlat = nlat
    pgrid%nlev = nlev
    pgrid%nbnds = 2
    pgrid%ntime = ntime

    allocate(pgrid%psl(nlon, nlat))
    allocate(pgrid%u10(nlon, nlat))
    allocate(pgrid%v10(nlon, nlat))
    allocate(pgrid%t2m(nlon, nlat))
    allocate(pgrid%z3d(nlon, nlat, nlev))
    allocate(pgrid%t3d(nlon, nlat, nlev))

    allocate(pgrid%lon(nlon))
    allocate(pgrid%lat(nlat))
    allocate(pgrid%lev(nlev))
   !allocate(pgrid%ftime(1))
    
    call read_pressure_grid(input_zt_flnm, pgrid)
    call read_surface_data(input_sfc_flnm, pgrid)

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
!   integer, dimension(:), allocatable :: varids

    character(len=128) :: dimname
    integer :: status, i, include_parents, dimsize, j, k

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

       if(trim(dimname) == 'longitude') then
          if(pgrid%nlon /= dimsize) then
             print *, 'Dim lon: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlon
             stop 'Wrong nlon'
          end if
       else if(trim(dimname) == 'latitude') then
          if(pgrid%nlat /= dimsize) then
             print *, 'Dim lat: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlat
             stop 'Wrong nlat'
          end if
       else if(trim(dimname) == 'level') then
          if(pgrid%nlev /= dimsize) then
             print *, 'Dim lev: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlev
             stop 'Wrong nlev'
          end if
       end if
    end do

   !print *, 'File: ', __FILE__, ', line: ', __LINE__

   !read lon
    call nc_get1Dvar0(fileid, 'longitude', pgrid%lon, 1, pgrid%nlon)

   !read lat
    call nc_get1Dvar0(fileid, 'latitude', pgrid%lat, 1, pgrid%nlat)

   !read lev
    call nc_get1Ddbl0(fileid, 'level', pgrid%lev, 1, pgrid%nlev)

   !read hgt
    call nc_get3Dvar(fileid, 'z', pgrid%z3d, 1, 1, pgrid%nlon, &
                      1, pgrid%nlat, 1, pgrid%nlev)

    do k = 1, pgrid%nlev
    do j = 1, pgrid%nlat
    do i = 1, pgrid%nlon
       pgrid%z3d(i,j,k) = pgrid%z3d(i,j,k)/9.806
    end do
    end do
    end do

    do k = 1, pgrid%nlev
       pgrid%lev(k) = 100.0*pgrid%lev(k)
      !print *, 'pgrid%lev(', k, ')=', pgrid%lev(k), ', pgrid%z3d(', k, ')=', pgrid%z3d(1,1,k)
    end do

    call check_minmax3d(pgrid%nlon, pgrid%nlat, pgrid%nlev, pgrid%z3d, 'HGT')

   !read temperature
    call nc_get3Dvar(fileid, 't', pgrid%t3d, 1, 1, pgrid%nlon, &
                      1, pgrid%nlat, 1, pgrid%nlev)

    call check_minmax3d(pgrid%nlon, pgrid%nlat, pgrid%nlev, pgrid%t3d, 'TEMP')

    status =  nf90_close(fileid)
    call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__

   !print *, 'lon = ', pgrid%lon
   !print *, 'lat = ', pgrid%lat
   !print *, 'lev = ', pgrid%lev

   !Deallocate memory.
   !deallocate(pgrid%dimids)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
   !print *, 'Finished Read pressure grid info from file: ', trim(input_flnm)

  end subroutine read_pressure_grid

!----------------------------------------------------------------------------------------
  subroutine read_surface_data(input_flnm, pgrid)

    use netcdf
    use status_module

    implicit none

    character(len=*),    intent(in)    :: input_flnm
    type (pressuregrid), intent(inout) :: pgrid

    integer                           :: fileid
    integer                           :: nDims, nVars, &
                                         nGlobalAtts, unlimDimID
    integer, dimension(:), allocatable :: dimids

    character(len=128) :: dimname
    integer :: status, i, include_parents, dimsize, j

   !print *, 'Start Read pgrid grid info from file: ', trim(input_flnm)
   !print *, 'File: ', __FILE__, ', line: ', __LINE__

    include_parents = 0

    status = nf90_noerr

   !Open the file. 
    status = nf90_open(trim(input_flnm), nf90_nowrite, fileid)
    call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
    status = nf90_inquire(fileid, nDims, nVars, &
                          nGlobalAtts, unlimdimid)
    call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
   !print *, 'nVars: ', nVars
   !print *, 'nDims: ', nDims

   !Allocate memory.
    allocate(dimids(nDims))

    status = nf90_inq_dimids(fileid, nDims, dimids, include_parents)
    call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
   !print *, 'dimids: ', dimids

   !read psl
    call nc_get2Dvar(fileid, 'msl', pgrid%psl, 1, 1, pgrid%nlon, 1, pgrid%nlat)
    call check_minmax2d(pgrid%nlon, pgrid%nlat, pgrid%psl, 'PSL')

   !read u10
    call nc_get2Dvar(fileid, 'u10', pgrid%u10, 1, 1, pgrid%nlon, 1, pgrid%nlat)
    call check_minmax2d(pgrid%nlon, pgrid%nlat, pgrid%u10, 'U10')

   !read v10
    call nc_get2Dvar(fileid, 'v10', pgrid%v10, 1, 1, pgrid%nlon, 1, pgrid%nlat)
    call check_minmax2d(pgrid%nlon, pgrid%nlat, pgrid%v10, 'V10')

   !read t2m
   !call nc_get2Dvar(fileid, 't2m', pgrid%t2m, 1, 1, pgrid%nlon, 1, pgrid%nlat)
    call nc_get2Dvar(fileid, 'skt', pgrid%t2m, 1, 1, pgrid%nlon, 1, pgrid%nlat)
    call check_minmax2d(pgrid%nlon, pgrid%nlat, pgrid%t2m, 'T2m')

    deallocate(dimids)

    status =  nf90_close(fileid)
    call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__

   !print *, 'lon = ', pgrid%lon
   !print *, 'lat = ', pgrid%lat
   !print *, 'lev = ', pgrid%lev

   !Deallocate memory.
   !deallocate(pgrid%dimids)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__
   !print *, 'Finished Read surface grid info from file: ', trim(input_flnm)

  end subroutine read_surface_data

 !----------------------------------------------------------------------
  subroutine finalize_pressure_grid(pgrid)

    use netcdf

    implicit none

    type(pressuregrid), intent(inout) :: pgrid
    integer :: rc

    deallocate(pgrid%lon)
    deallocate(pgrid%lat)
    deallocate(pgrid%lev)
   !if(allocated(pgrid%ftime)) deallocate(pgrid%ftime)
    if(allocated(pgrid%dimids)) deallocate(pgrid%dimids)

    deallocate(pgrid%psl)
    deallocate(pgrid%u10)
    deallocate(pgrid%v10)
    deallocate(pgrid%t2m)

    deallocate(pgrid%z3d)
    deallocate(pgrid%t3d)

    rc =  nf90_close(pgrid%ncid)
    call check_status(rc)

   !print *, 'Finished Write to file: ', trim(pgrid%filename)

  end subroutine finalize_pressure_grid

end module pressure_module

