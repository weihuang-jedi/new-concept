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
     real, dimension(:),    allocatable    :: lon, lat, lev, ftime
     real, dimension(:, :), allocatable    :: ter, psl
     real, dimension(:, :, :), allocatable :: z3d
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
    pgrid%ntime = ntime

    allocate(pgrid%ter(nlon, nlat))
    allocate(pgrid%psl(nlon, nlat))
    allocate(pgrid%z3d(nlon, nlat, nlev))

    allocate(pgrid%lon(nlon))
    allocate(pgrid%lat(nlat))
    allocate(pgrid%lev(nlev))
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

       if(trim(dimname) == 'lon_0') then
          if(pgrid%nlon /= dimsize) then
             print *, 'Dim lon: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlon
             stop 'Wrong nlon'
          end if
       else if(trim(dimname) == 'lat_0') then
          if(pgrid%nlat /= dimsize) then
             print *, 'Dim lat: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlat
             stop 'Wrong nlat'
          end if
       else if(trim(dimname) == 'lv_ISBL0') then
          if(pgrid%nlev /= dimsize) then
             print *, 'Dim lev: ', dimsize, ' in file is different to what read in: ', &
                       pgrid%nlev
             stop 'Wrong nlev'
          end if
       end if
    end do

   !print *, 'File: ', __FILE__, ', line: ', __LINE__

   !read lon
    call nc_get1Dvar0(fileid, 'lon_0', pgrid%lon, 1, pgrid%nlon)

   !read lat
    call nc_get1Dvar0(fileid, 'lat_0', pgrid%lat, 1, pgrid%nlat)

   !read lev
    call nc_get1Dvar0(fileid, 'lv_ISBL0', pgrid%lev, 1, pgrid%nlev)

   !read ter
    call nc_get2Dvar0(fileid, 'HGT_P0_L1_GLL0', pgrid%ter, 1, pgrid%nlon, 1, pgrid%nlat)

    call check_minmax2d(pgrid%nlon, pgrid%nlat, pgrid%ter, 'Ter')

   !read psl
    call nc_get2Dvar0(fileid, 'PRMSL_P0_L101_GLL0', pgrid%psl, 1, pgrid%nlon, 1, pgrid%nlat)

    call check_minmax2d(pgrid%nlon, pgrid%nlat, pgrid%psl, 'PSL')

   !read hgt
    call nc_get3Dvar0(fileid, 'HGT_P0_L100_GLL0', pgrid%z3d, 1, pgrid%nlon, &
                      1, pgrid%nlat, 1, pgrid%nlev)

    call check_minmax3d(pgrid%nlon, pgrid%nlat, pgrid%nlev, pgrid%z3d, 'HGT')

   !status =  nf90_close(fileid)
   !call check_status(status)

   !print *, 'File: ', __FILE__, ', line: ', __LINE__

   !print *, 'lon = ', pgrid%lon
   !print *, 'lat = ', pgrid%lat
   !print *, 'lev = ', pgrid%lev

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
    deallocate(pgrid%psl)
    deallocate(pgrid%z3d)

    rc =  nf90_close(pgrid%ncid)
    call check_status(rc)

   !print *, 'Finished Write to file: ', trim(pgrid%filename)

  end subroutine finalize_pressure_grid

end module pressure_module

