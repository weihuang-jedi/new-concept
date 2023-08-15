!-------------------------------------------------------------

MODULE namelist_module

  implicit none

  integer :: nml_unit
  integer, parameter :: max_types = 5

  CHARACTER(LEN=1024) :: program_name
  character(len=1024) :: input_uvq_flnm, input_zt_flnm, &
                         input_sfc_flnm, output_flnm
  integer :: nlat, nlon, nlev, ntime
  real    :: dz
  real, dimension(:), allocatable :: alt
  integer :: nalt
  integer :: debug_level
  logical :: debug_on

contains
  subroutine read_namelist(file_path)
    implicit none

    !! Reads Namelist from given file.
    character(len=*),  intent(in)  :: file_path
    integer :: rc
    character(len=1000) :: line

    ! Namelist definition.
    namelist /control_param/ input_uvq_flnm, input_zt_flnm, &
                             input_sfc_flnm, output_flnm, &
                             nlat, nlon, nlev, ntime, &
                             nalt, dz, &
                             debug_on, debug_level

    program_name = 'Interpolate pressure level data to altitude level'

    input_uvq_flnm = '/work2/noaa/gsienkf/weihuang/era5/data/monthly_mean_dec2021_uvq.nc'
    input_zt_flnm = '/work2/noaa/gsienkf/weihuang/era5/data/monthly_mean_dec2021_zt.nc'
    input_sfc_flnm = '/work2/noaa/gsienkf/weihuang/era5/data/monthly_mean_dec2021_surface.nc'
    output_flnm = '/work2/noaa/gsienkf/weihuang/era5/data/monthly-mean-dec2021-height-level-fortran.nc'

    nlon = 720
    nlat = 361
    nlev = 41
    ntime = 1

    nalt = 251
    dz = 100.0

    debug_on = .false.
    debug_level = 0

   !Check whether file exists.
   !inquire(file=file_path, iostat=rc)

   !if(rc /= 0) then
   !  write(unit=0, fmt='(3a)') 'Error: input file "', &
   !                         trim(file_path), '" does not exist.'
   !  return
   !end if

    open(newunit=nml_unit, file=trim(file_path), status='OLD')

    read(nml_unit, nml=control_param, iostat=rc)

    if(rc/=0) then
       backspace(nml_unit)
       read(nml_unit, fmt='(A)') line
       write(*, '(A)') &
           'Invalid line in namelist: '//trim(line)
    end if

   !print *, 'file_path: ', trim(file_path)
   !write(*, control_param)

    close(nml_unit)

   !print *, 'nlon, nlat, nlev, ntime = ', nlon, nlat, nlev, ntime
   !print *, 'nalt, dz = ', nalt, dz

  end subroutine read_namelist

END MODULE namelist_module

