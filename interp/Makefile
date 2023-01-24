#-----------------------------------------------------------------------------

include make_rules

####################################################

OBJS =	namelist_module.o \
	nc_get1Dint.o \
	nc_get1Dvar.o \
	nc_get2Dint.o \
	nc_get2Dvar.o \
	nc_get3Dint.o \
	nc_get3Dvar.o \
	nc_get4Dvar.o \
	nc_get5Dvar.o \
	nc_getGlobalIntAttr.o \
	nc_getGlobalRealAttr.o \
	nc_getGlobalCharAttr.o \
	nc_put_single_int.o \
	nc_put1Dvar.o \
	nc_put1Dint.o \
	nc_put2Dvar.o \
	nc_put2Dint.o \
	nc_put3Dvar.o \
	nc_put3Dint.o \
	nc_put4Dvar.o \
	nc_put5Dvar.o \
	nc_putChar.o \
	nc_putAttr.o \
	nc_putAxisAttr.o \
	nc_putAxisIntAttr.o \
	nc_putIntAttr.o \
	nc_putGlobalIntAttr.o \
	nc_putGlobalRealAttr.o \
	nc_putGlobalCharAttr.o \
	status_module.o \
	pressure_module.o

####################################################

deflt :	clean_modulde nc4_lib interp

clean_modulde :
	$(RM) namelist_module.o namelist_module.mod \
	pressure_module.o pressure_module.mod

nc4_lib : $(OBJS)
	$(RM) libnc4.a
	$(AR) libnc4.a $(OBJS)
	$(RANLIB) libnc4.a

interp : interp.o
	$(FC) -o interp.exe interp.o $(FFLAGS) $(LOC_LIBS) \
	libnc4.a

clean :
	$(RM) libnc4.a $(OBJS) interp.o \
	*.f90 *.mod *.exe

####################################################

# DEPENDENCIES : only dependencies after this line (don't remove the word DEPENDENCIES)

interp.o : interp.F90 \
		namelist_module.o \
		pressure_module.o

pressure_module.o : pressure_module.F90 \
		status_module.o

