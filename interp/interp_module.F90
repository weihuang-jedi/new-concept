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

  function q_from_rh(t, rh)
    implicit none
    real, intent(in) :: t, rh
    real :: q_from_rh
    real, parameter :: t0 = 273.16
    real :: factor

    factor = exp(17.67*(t-t0)/(t-29.65))
    q_from_rh = 0.01*rh*factor

  end function q_from_rh

  function rh_from_q(t, p, q)
    implicit none
    real, intent(in) :: t, p, q
    real :: rh_from_q
    real, parameter :: t0 = 273.16
    real :: factor

    factor = exp(17.67*(t-t0)/(t-29.65))
    rh_from_q = 26.3*p*q/factor

  end function rh_from_q

 !-----------------------------------------------------------------------
  subroutine interp_p2z(pgrid, zgrid)

    implicit none

    type(pressuregrid), intent(in)  :: pgrid
    type(altitudegrid), intent(inout) :: zgrid

    real, dimension(:,:,:), allocatable :: u3d, v3d, t3d, p3d, q3d

    integer :: i,j,k, jgfs, kgfs, kb, kk
    real :: rh, tm, fac
    real, parameter :: g = 9.80
    real, parameter :: r = 287.0
    real, parameter :: lapse_rate = 0.0065

   !print *, 'enter interp_p2z'

    allocate(u3d(nlon, nlat, nalt))
    allocate(v3d(nlon, nlat, nalt))
    allocate(t3d(nlon, nlat, nalt))
    allocate(p3d(nlon, nlat, nalt))
    allocate(q3d(nlon, nlat, nalt))

    do jgfs = 1, nlat
    j = nlat + 1 - jgfs
    do i = 1, nlon
       kgfs = pgrid%nlev
       kb = 0
       do k = 1, zgrid%nalt
         !print *, 'i,j,k,jgfs,kgfs = ', i,j,k,jgfs,kgfs
         !print *, 'zgrid%alt(k) = ', zgrid%alt(k)

          if(zgrid%alt(k) < pgrid%zf(i,jgfs,pgrid%nlev)) then
            kb = k
          else if(zgrid%alt(k) >= pgrid%zf(i,jgfs,1)) then
            u3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,1), &
                                           pgrid%zf(i,jgfs,2), &
                                           pgrid%uf(i,jgfs,1), &
                                           pgrid%uf(i,jgfs,2))
            v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,1), &
                                           pgrid%zf(i,jgfs,2), &
                                           pgrid%vf(i,jgfs,1), &
                                           pgrid%vf(i,jgfs,2))
            t3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,1), &
                                           pgrid%zf(i,jgfs,2), &
                                           pgrid%tf(i,jgfs,1), &
                                           pgrid%tf(i,jgfs,2))
            p3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,1), &
                                           pgrid%zf(i,jgfs,2), &
                                           pgrid%pf(i,jgfs,1), &
                                           pgrid%pf(i,jgfs,2))
            q3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,1), &
                                           pgrid%zf(i,jgfs,2), &
                                           pgrid%qf(i,jgfs,1), &
                                           pgrid%qf(i,jgfs,2))
          else
            do while(kgfs > 1)
              if((zgrid%alt(k) >= pgrid%zf(i,jgfs,kgfs)) .and. &
                 (zgrid%alt(k) <  pgrid%zf(i,jgfs,kgfs-1))) then
                 u3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,kgfs-1), &
                                                pgrid%zf(i,jgfs,kgfs), &
                                                pgrid%uf(i,jgfs,kgfs-1), &
                                                pgrid%uf(i,jgfs,kgfs))
                 v3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,kgfs-1), &
                                                pgrid%zf(i,jgfs,kgfs), &
                                                pgrid%vf(i,jgfs,kgfs-1), &
                                                pgrid%vf(i,jgfs,kgfs))
                 t3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,kgfs-1), &
                                                pgrid%zf(i,jgfs,kgfs), &
                                                pgrid%tf(i,jgfs,kgfs-1), &
                                                pgrid%tf(i,jgfs,kgfs))
                 p3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,kgfs-1), &
                                                pgrid%zf(i,jgfs,kgfs), &
                                                pgrid%pf(i,jgfs,kgfs-1), &
                                                pgrid%pf(i,jgfs,kgfs))
                 q3d(i,j,k) = p2z(zgrid%alt(k), pgrid%zf(i,jgfs,kgfs-1), &
                                                pgrid%zf(i,jgfs,kgfs), &
                                                pgrid%qf(i,jgfs,kgfs-1), &
                                                pgrid%qf(i,jgfs,kgfs))
                 exit
              end if
              kgfs = kgfs - 1
            end do
          end if
       end do
   
       if(kb > 0) then
          rh = rh_from_q(t3d(i,j,kb+1), p3d(i,j,kb+1), q3d(i,j,kb+1))
          do k = kb, 1, -1
             u3d(i,j,k) = pgrid%uf(i,jgfs,pgrid%nlev)
             v3d(i,j,k) = pgrid%vf(i,jgfs,pgrid%nlev)
             t3d(i,j,k) = t3d(i,j,k+1) + lapse_rate*(zgrid%alt(k+1) - zgrid%alt(k))
             tm = 0.5*(t3d(i,j,k) + t3d(i,j,k+1))
             fac = 0.5*g*(zgrid%alt(k+1) - zgrid%alt(k))/(r*tm)
             p3d(i,j,k) = p3d(i,j,k+1)*(1.0+fac)/(1.0-fac)
             q3d(i,j,k) = q_from_rh(t3d(i,j,k), rh)
          end do
       end if
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

   !write u
    call nc_put3Dvar0(zgrid%ncid, 'u', u3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)
   !write v
    call nc_put3Dvar0(zgrid%ncid, 'v', v3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)
   !write t
    call nc_put3Dvar0(zgrid%ncid, 't', t3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)
   !write p
    call nc_put3Dvar0(zgrid%ncid, 'p', p3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)
   !write q
    call nc_put3Dvar0(zgrid%ncid, 'q', q3d, 1, zgrid%nlon, &
                      1, zgrid%nlat, 1, zgrid%nalt)

   !call check_minmax3d(zgrid%nlon, zgrid%nlat, zgrid%nalt, v3d, 'Pressure')

   !do k = 1, zgrid%nalt
   !  !print *, 'Altitude: ', zgrid%alt(k)
   !   call check_minmax2d(zgrid%nlon, zgrid%nlat, v3d(:,:,k), 'P at level')
   !end do

    deallocate(u3d)
    deallocate(v3d)
    deallocate(t3d)
    deallocate(p3d)
    deallocate(q3d)

  end subroutine interp_p2z

end module interp_module

