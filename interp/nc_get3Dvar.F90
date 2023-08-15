!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine nc_get3Dvar(ncid, var_name, var, nrec, &
                       nxs, nxe, nys, nye, nzs, nze)

   use netcdf

   implicit none
  
   integer, intent(in) :: ncid, nrec
   integer, intent(in) :: nxs, nxe, nys, nye, nzs, nze

   character(len = *), intent(in) :: var_name
   real*8, dimension(nxs:nxe, nys:nye, nzs:nze), intent(out) :: var

   integer*2, dimension(nxs:nxe, nys:nye, nzs:nze) :: ivar

   integer, dimension(4) :: start, count

 ! Variable id
   integer :: varid

 ! Return status
   integer :: status

   real*8 :: add_offset, scale_factor
   integer :: i, j, k

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
   start(3) = nzs
   start(4) = nrec

   count(1) = nxe - nxs + 1
   count(2) = nye - nys + 1
   count(3) = nze - nzs + 1
   count(4) = 1

   status = nf90_get_var(ncid,varid,ivar,start=start(1:4),count=count(1:4))
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

   do k = nzs, nze
   do j = nys, nye
   do i = nxs, nxe
      var(i,j,k) = scale_factor * ivar(i,j,k) + add_offset
   end do
   end do
   end do

end subroutine nc_get3Dvar

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine nc_get3Dvar0(ncid, var_name, var, &
                        nxs, nxe, nys, nye, nzs, nze)

   use netcdf

   implicit none
  
   integer, intent(in) :: ncid
   integer, intent(in) :: nxs, nxe, nys, nye, nzs, nze

   character(len = *), intent(in) :: var_name
   real, dimension(nxs:nxe, nys:nye, nzs:nze), intent(out) :: var

   integer, dimension(3) :: start, count

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
   start(3) = nzs

   count(1) = nxe - nxs + 1
   count(2) = nye - nys + 1
   count(3) = nze - nzs + 1

   status = nf90_get_var(ncid,varid,var,start=start,count=count)
   if(status /= nf90_noerr) then
       write(unit=0, fmt='(3a)') "Problem to read: <", trim(var_name), ">.", &
                                "Error status: ", trim(nf90_strerror(status))
       write(unit=0, fmt='(3a, i4)') &
            "Stop in file: <", __FILE__, ">, line: ", __LINE__
       stop
   end if

end subroutine nc_get3Dvar0


