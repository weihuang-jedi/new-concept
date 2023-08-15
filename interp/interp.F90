!--------------------------------------------------------------------
PROGRAM interp

   use namelist_module
   use pressure_module
   use altitude_module
   use interp_module

   IMPLICIT NONE

   type(pressuregrid) :: pgrid
   type(altitudegrid) :: zgrid

   call read_namelist('input.nml')

   print *, 'File: ', __FILE__, ', line: ', __LINE__

   call initialize_pressure_grid(pgrid)
   call initialize_altitude_grid(zgrid, pgrid)

   print *, 'File: ', __FILE__, ', line: ', __LINE__

   call interp_p2z(pgrid, zgrid)

   print *, 'File: ', __FILE__, ', line: ', __LINE__

   call finalize_pressure_grid(pgrid)
   call finalize_altitude_grid(zgrid)

END PROGRAM interp

