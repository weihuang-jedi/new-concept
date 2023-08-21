module altitude_module

  use netcdf
  use status_module
  use namelist_module
  use pressure_module

  implicit none

  !-----------------------------------------------------------------------
  ! Define interfaces and attributes for module routines

  private
  public :: altitudegrid
  public :: initialize_altitude_grid
  public :: finalize_altitude_grid

  !-----------------------------------------------------------------------

  type altitudegrid
     character(len=1024)                   :: filename
     integer                               :: ncid
     integer                               :: dimid_lon, dimid_lat, dimid_alt, &
                                              dimid_time
     integer                               :: nlon, nlat, nalt, ntime
     real,    dimension(:),    allocatable :: lon, lat
     real*8,  dimension(:),    allocatable :: alt, ftime
     real*8                                :: dz
  end type altitudegrid

  !-----------------------------------------------------------------------

contains

 !-----------------------------------------------------------------------
  subroutine initialize_altitude_grid(zgrid, pgrid)

    implicit none

    type(altitudegrid), intent(out) :: zgrid
    type(pressuregrid), intent(in)  :: pgrid

    integer :: k

   !print *, 'enter initialize_altitude_grid'

    zgrid%nlon = nlon
    zgrid%nlat = nlat
    zgrid%nalt = nalt

    allocate(zgrid%lon(nlon))
    allocate(zgrid%lat(nlat))
    allocate(zgrid%alt(nalt))

    do k = 1, nalt
      zgrid%alt(k) = dble(k-1)*dz
     !print *, 'zgrid%alt(', k, ')= ', zgrid%alt(k)
    end do

    zgrid%lon(:) = pgrid%lon(:)
    do k = 1, nlat
       zgrid%lat(k) = pgrid%lat(nlat+1-k)
    end do

    zgrid%filename = output_flnm

    call define_altitude_grid(zgrid)

  end subroutine initialize_altitude_grid

 !----------------------------------------------------------------------
  subroutine finalize_altitude_grid(zgrid)

    use netcdf

    implicit none

    type(altitudegrid), intent(inout) :: zgrid
    integer :: rc

    deallocate(zgrid%lon)
    deallocate(zgrid%lat)
    deallocate(zgrid%alt)

    rc =  nf90_close(zgrid%ncid)
    call check_status(rc)
   !print *, 'Finished Write to file: ', trim(zgrid%filename)

  end subroutine finalize_altitude_grid

!----------------------------------------------------------------------------------------
  subroutine define_altitude_grid(zgrid)

   use netcdf
   use status_module

   implicit none

   type(altitudegrid), intent(inout) :: zgrid

   integer :: i, j, n, rc

   rc = nf90_noerr
  !Create the file. 
  !rc = nf90_create(trim(zgrid%filename), NF90_CLOBBER, zgrid%ncid)
  !rc = nf90_create(trim(zgrid%filename), NF90_64BIT_OFFSET, zgrid%ncid)
   rc = nf90_create(trim(zgrid%filename), NF90_NETCDF4, zgrid%ncid)
   call check_status(rc)

   print *, 'zgrid%ncid = ', zgrid%ncid

   rc = nf90_def_dim(zgrid%ncid, 'lon', zgrid%nlon, zgrid%dimid_lon)
   call check_status(rc)
   rc = nf90_def_dim(zgrid%ncid, 'lat', zgrid%nlat, zgrid%dimid_lat)
   call check_status(rc)
   rc = nf90_def_dim(zgrid%ncid, 'alt', zgrid%nalt, zgrid%dimid_alt)
   call check_status(rc)
  !rc = nf90_def_dim(zgrid%ncid, 'time', zgrid%ntime, zgrid%dimid_time)
  !call check_status(rc)

   call write_global_attr4zgrid(zgrid%ncid, trim(zgrid%filename), 'Variable on altitude')

   call write_var_attr4zgrid(zgrid)

  !End define mode.
   rc = nf90_enddef(zgrid%ncid)
   if(rc /= nf90_noerr) then
      write(unit=0, fmt='(a,i6,a)') "Problem to enddef zgrid%ncid: <", zgrid%ncid, ">."
      write(unit=0, fmt='(2a)') "Error status: ", trim(nf90_strerror(rc))
      write(unit=0, fmt='(3a, i4)') &
           "Stop in file: <", __FILE__, ">, line: ", __LINE__
      stop
   end if

  !write lon
   call nc_put1Dvar0(zgrid%ncid, 'lon', zgrid%lon, 1, zgrid%nlon)

  !write lat
   call nc_put1Dvar0(zgrid%ncid, 'lat', zgrid%lat, 1, zgrid%nlat)

  !write alt
   call nc_put1Ddbl0(zgrid%ncid, 'alt', zgrid%alt, 1, zgrid%nalt)

  !write time
  !call nc_put1Dvar0(zgrid%ncid, 'time', zgrid%ftime, 1, zgrid%ntime)

  !rc =  nf90_close(zgrid%ncid)
  !print *, 'nf90_close rc = ', rc
  !print *, 'nf90_noerr = ', nf90_noerr

  !if(rc /= nf90_noerr) then
  !   write(unit=0, fmt='(a,i6,a)') "Problem to close zgrid%ncid: <", zgrid%ncid, ">."
  !   write(unit=0, fmt='(2a)') "Error status: ", trim(nf90_strerror(rc))
  !   write(unit=0, fmt='(3a, i4)') &
  !        "Stop in file: <", __FILE__, ">, line: ", __LINE__
  !   stop
  !end if

  !print *, 'Finished Write to file: ', trim(flnm)

  end subroutine define_altitude_grid

  !-------------------------------------------------------------------------------------
  subroutine write_var_attr4zgrid(zgrid)

   use netcdf

   implicit none

   type(altitudegrid), intent(in) :: zgrid

   integer, dimension(6) :: dimids
   integer :: rc, nd
   integer :: missing_int
   real    :: missing_real8

   missing_real8 = -1.0e38
   missing_int = -999999

   dimids(1) = zgrid%dimid_lon
   nd = 1
!--Field lon
   call nc_putAxisAttr(zgrid%ncid, nd, dimids, NF90_REAL, &
                      "lon", &
                      "Lontitude Coordinate", &
                      "degree_east", &
                      "Longitude" )

   dimids(1) = zgrid%dimid_lat
   nd = 1
!--Field lat
   call nc_putAxisAttr(zgrid%ncid, nd, dimids, NF90_REAL, &
                      "lat", &
                      "Latitude Coordinate", &
                      "degree_north", &
                      "Latitude" )

   dimids(1) = zgrid%dimid_alt
   nd = 1
!--Field alt
   call nc_putAxisAttr(zgrid%ncid, nd, dimids, NF90_DOUBLE, &
                      "alt", &
                      "Altitude Coordinate", &
                      "upward", &
                      "Level" )

  !dimids(1) = zgrid%dimid_time
  !nd = 1
!--Field time
  !call nc_putAxisAttr(zgrid%ncid, nd, dimids, NF90_DOUBLE, &
  !                   "time", &
  !                   "time Coordinate", &
  !                   "forward", &
  !                   "center" )

   dimids(1) = zgrid%dimid_lon
   dimids(2) = zgrid%dimid_lat
   dimids(3) = zgrid%dimid_alt
   nd = 3
!--Field 1, u
   call nc_putAttr(zgrid%ncid, nd, dimids, NF90_DOUBLE, &
                   "u", &
                   "Eastward Wind", &
                   "m/s", &
                   "alt lat lon", &
                   missing_real8)
!--Field 2, v
   call nc_putAttr(zgrid%ncid, nd, dimids, NF90_DOUBLE, &
                   "v", &
                   "Northward Wind", &
                   "m/s", &
                   "alt lat lon", &
                   missing_real8)
!--Field 3, t
   call nc_putAttr(zgrid%ncid, nd, dimids, NF90_DOUBLE, &
                   "t", &
                   "Temperature", &
                   "K", &
                   "alt lat lon", &
                   missing_real8)
!--Field 4, p
   call nc_putAttr(zgrid%ncid, nd, dimids, NF90_DOUBLE, &
                   "p", &
                   "Pressure", &
                   "Pa", &
                   "alt lat lon", &
                   missing_real8)
!--Field 5, q
!  call nc_putAttr(zgrid%ncid, nd, dimids, NF90_DOUBLE, &
!                  "q", &
!                  "Specific Humidity", &
!                  "kg/kg", &
!                  "alt lat lon", &
!                  missing_real8)
  end subroutine write_var_attr4zgrid

  !---------------------------------------------------------------------------
  subroutine write_global_attr4zgrid(ncid, filename, title)

     implicit none

     integer, intent(in) :: ncid
     character(len = *), intent(in) :: filename, title

    !output global attributes
     call nc_putGlobalCharAttr(ncid, 'filename', trim(filename))
     call nc_putGlobalCharAttr(ncid, 'title', trim(title))

  end subroutine write_global_attr4zgrid

end module altitude_module

