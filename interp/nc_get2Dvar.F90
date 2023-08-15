!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! svn propset svn:keywords "URL Rev Author Date Id"
! $URL: file:///data/zhuming/.vdras_source_code/SVN_REPOSITORY/VDRAS/trunk/vdras/io/netcdf4/nc_get2Dvar.F90 $
! $Rev: 355 $
! $Author: zhuming $
! $Date: 2014-09-30 11:02:42 -0600 (Tue, 30 Sep 2014) $
! $Id: nc_get2Dvar.F90 355 2014-09-30 17:02:42Z zhuming $
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine nc_get2Dvar(ncid, var_name, var, nrec, &
                       nxs, nxe, nys, nye)

   use netcdf

   implicit none
  
   integer, intent(in) :: ncid, nrec
   integer, intent(in) :: nxs, nxe, nys, nye

   character(len = *), intent(in) :: var_name
   real*8, dimension(nxs:nxe, nys:nye), intent(out) :: var

   integer, dimension(3) :: start, count

 ! Variable id
   integer :: varid

   integer*2, dimension(nxs:nxe, nys:nye) :: ivar

   real*8 :: add_offset, scale_factor
   integer :: i, j

 ! Return status
   integer :: status

   status = nf90_inq_varid(ncid, var_name, varid)
   if(status /= nf90_noerr) then 
       write(unit=0, fmt='(3a)') "Problem to get id for: <", trim(var_name), ">.", &
                                 "Error status: ", trim(nf90_strerror(status))
       write(unit=0, fmt='(3a, i4)') &
            "Stop in file: <", __FILE__, ">, line: ", __LINE__
       stop
   end if

   start(1) = nxs
   start(2) = nys
   start(3) = nrec

   count(1) = nxe - nxs + 1
   count(2) = nye - nys + 1
   count(3) = 1

   status = nf90_get_var(ncid,varid,ivar,start=start(1:3),count=count(1:3))
   if(status /= nf90_noerr) then
       write(unit=0, fmt='(3a)') "Problem to read: <", trim(var_name), ">.", &
                                "Error status: ", trim(nf90_strerror(status))
       write(unit=0, fmt='(3a, i4)') &
            "Stop in file: <", __FILE__, ">, line: ", __LINE__
       stop
   end if

   status = nf90_get_att(ncid, varid, 'add_offset', add_offset)
   if(status /= nf90_noerr) then
       write(unit=0, fmt='(2a)') "Problem to read attribute add_offset, ", &
                                "Error status: ", trim(nf90_strerror(status))
       write(unit=0, fmt='(3a, i4)') &
            "Stop in file: <", __FILE__, ">, line: ", __LINE__
       stop
   end if

   write(unit=0, fmt='(a,ES24.17)') 'add_offset = ', add_offset

  status = nf90_get_att(ncid, varid, 'scale_factor', scale_factor)
   if(status /= nf90_noerr) then
       write(unit=0, fmt='(2a)') "Problem to read attribute scale_factor, ", &
                                "Error status: ", trim(nf90_strerror(status))
       write(unit=0, fmt='(3a, i4)') &
            "Stop in file: <", __FILE__, ">, line: ", __LINE__
       stop
   end if

   write(unit=0, fmt='(a,ES24.17)') 'scale_factor = ', scale_factor

   do j = nys, nye
   do i = nxs, nxe
      var(i,j) = scale_factor * ivar(i,j) + add_offset
   end do
   end do

end subroutine nc_get2Dvar

!--------------------------------------------------------------------------------------

subroutine nc_get2Dvar0(ncid, var_name, var, &
                        nxs, nxe, nys, nye)

   use netcdf

   implicit none
  
   integer, intent(in) :: ncid
   integer, intent(in) :: nxs, nxe, nys, nye

   character(len = *), intent(in) :: var_name
   real*4, dimension(nxs:nxe, nys:nye), intent(out) :: var

   integer, dimension(2) :: start, count

 ! Variable id
   integer :: varid

 ! Return status
   integer :: status

   status = nf90_inq_varid(ncid, var_name, varid)
   if(status /= nf90_noerr) then 
       write(unit=0, fmt='(3a)') "Problem to get id for: <", trim(var_name), ">.", &
                                 "Error status: ", trim(nf90_strerror(status))
       write(unit=0, fmt='(3a, i4)') &
            "Stop in file: <", __FILE__, ">, line: ", __LINE__
       stop
   end if

   start(1) = nxs
   start(2) = nys

   count(1) = nxe - nxs + 1
   count(2) = nye - nys + 1

   status = nf90_get_var(ncid,varid,var,start=start(1:2),count=count(1:2))
   if(status /= nf90_noerr) then
       write(unit=0, fmt='(3a)') "Problem to read: <", trim(var_name), ">.", &
                                "Error status: ", trim(nf90_strerror(status))
       write(unit=0, fmt='(3a, i4)') &
            "Stop in file: <", __FILE__, ">, line: ", __LINE__
       stop
   end if

end subroutine nc_get2Dvar0

