#=========================================================================
import os, sys
import getopt
import numpy as np
import netCDF4 as nc4

#=========================================================================
class Interpolate2Height():
  def __init__(self, debug=0):
    self.debug = debug

    print('debug: ', debug)

    self.dimlist = ('lv_ISBL0', 'lat_0', 'lon_0')
    self.ori3dvarlist = ['TMP_P0_L100_GLL0', 'SPFH_P0_L100_GLL0', 'RH_P0_L100_GLL0',
                         'UGRD_P0_L100_GLL0', 'VGRD_P0_L100_GLL0', 'VVEL_P0_L100_GLL0',
                         'DZDT_P0_L100_GLL0', 'HGT_P0_L100_GLL0', 'O3MR_P0_L100_GLL0']
    self.new3dvarlist = ['T', 'Qv', 'RH',
                         'U', 'V', 'VOR',
                         'W', 'P', 'O3']

    self.ori2dvarlist = ['TMP_P0_L1_GLL0', 'SPFH_P0_2L108_GLL0', 'RH_P0_L4_GLL0',
                         'UGRD_P0_L6_GLL0', 'VGRD_P0_L6_GLL0', 'VVEL_P0_L104_GLL0',
                         'DZDT_P0_L6_GLL0', 'PRMSL_P0_L101_GLL0', 'O3MR_P0_L6_GLL0']
    self.new2dvarlist = ['tsf', 'qvsf', 'rhsf',
                         'usf', 'vsf', 'vorsf',
                         'wsf', 'slp', 'o3sf']

    self.ori2new2d = {}
    self.new2ori2d = {}
    n = 0
    for n in range(len(self.ori2dvarlist)):
      self.ori2new2d[self.ori2dvarlist[n]] = self.new2dvarlist[n]
      self.new2ori2d[self.new2dvarlist[n]] = self.ori2dvarlist[n]

    self.ori2new3d = {}
    self.new2ori3d = {}
    n = 0
    for n in range(len(self.ori3dvarlist)):
      self.ori2new3d[self.ori3dvarlist[n]] = self.new3dvarlist[n]
      self.new2ori3d[self.new3dvarlist[n]] = self.ori3dvarlist[n]

   #HGT min: 75873.484375, max: 80451.648438
    zmin = 0.0
    zmax = 50000.0
    NZ = 1001
    self.newdims = ('alt', 'lat', 'lon')
    self.alt = np.linspace(zmin, zmax, NZ)

   #print('self.alt = ', self.alt)

 #-----------------------------------------------------------------------------------------
  def process(self, filename=None, outfile=None):
    print('outfile: ', outfile)

    if(os.path.exists(filename)):
      print('Processing %s' %(filename))
      ncf = nc4.Dataset(filename, 'r')
    else:
      print('increment file: %s does not exist. Stop' %(filename))
      sys.exit(-1)

    ncout = nc4.Dataset(outfile, 'w')
   #copy global attributes all at once via dictionary
    ncout.source = 'Interpolated from: %s' %(filename)
    ncout.setncatts(ncf.__dict__)

   #copy dimensions
    for name, dimension in ncf.dimensions.items():
      if(name in self.dimlist):
        print('dim name: ', name)
        print('dimension: ', dimension)

        if(name == 'lv_ISBL0'):
          newname = 'alt'
          self.nlev = len(dimension)
          self.nalt = len(self.alt)
          ncout.createDimension(newname, len(self.alt))
        elif(name == 'lat_0'):
          newname = 'lat'
          self.nlat = len(dimension)
          ncout.createDimension(newname, len(dimension))
        elif(name == 'lon_0'):
          newname = 'lon'
          self.nlon = len(dimension)
          ncout.createDimension(newname, len(dimension))
     #if dimension.isunlimited():
     #  ncout.createDimension(name, None)
     #else:
     #  ncout.createDimension(name, len(dimension))

    self.oridimsize = [self.nlev, self.nlat, self.nlon]
    self.newdimsize = [self.nalt, self.nlat, self.nlon]

    self.allvarlist = []
    nv = 0
   #copy all var in baselist
    for name, variable in ncf.variables.items():
      self.allvarlist.append(name)
      if(name in self.dimlist):
        if(name == 'lv_ISBL0'):
          newname = 'alt'
          x = ncout.createVariable(newname, variable.datatype, ('alt',))
          x[:] = self.alt
          ncout.variables[newname].standard_name = 'altitude'
          ncout.variables[newname].long_name = 'altitude'
          ncout.variables[newname].units = 'meter'
          ncout.variables[newname].positive = 'up'
          ncout.variables[newname].axis = 'Z'
          self.prs = ncf.variables[name][:]
          print('lv_ISBL0 = ', self.prs)
        elif(name == 'lat_0'):
          newname = 'lat'
          x = ncout.createVariable(newname, variable.datatype,  ('lat',))
          self.lat = ncf.variables[name][:]
          ncout.variables[newname].setncatts(ncf.variables[name].__dict__)
        elif(name == 'lon_0'):
          newname = 'lon'
          x = ncout.createVariable(newname, variable.datatype, ('lon',))
          self.lon= ncf.variables[name][:]
          ncout.variables[newname].setncatts(ncf.variables[name].__dict__)

      if(name in self.ori3dvarlist):
        newname = self.ori2new3d[name]
        print('var name: ', newname)
       #print('variable: ', variable)
       #print('variable.dimensions: ', variable.dimensions)
        x = ncout.createVariable(newname, variable.datatype, self.newdims)
       #ncout.variables[name][:,:,:] = ncf.variables[name][:,:,:]
       #copy variable attributes all at once via dictionary
        ncout.variables[newname].setncatts(ncf.variables[name].__dict__)

    self.get2dvalue(ncf)
    self.get3dvalue(ncf)

    ncout.close()
    ncf.close()

 #-----------------------------------------------------------------------------------------
  def get2dvalue(self, ncf):
    self.dict2d = {}
    n = 0
    for n in range(len(self.ori2dvarlist)):
      oriname = self.ori2dvarlist[n]
      newname = self.new2dvarlist[n]
      if(oriname in self.allvarlist):
        var = ncf.variables[oriname][:,:]
      else:
        print('Zero 2d var: ', newname)
        var = np.zeros([self.nlat, self.nlon])
      self.dict2d[newname] = var

 #-----------------------------------------------------------------------------------------
  def get3dvalue(self, ncf):
    self.dict3d = {}
    n = 0
    for n in range(len(self.ori3dvarlist)):
      oriname = self.ori3dvarlist[n]
      newname = self.new3dvarlist[n]
      if(oriname in self.allvarlist):
        var = ncf.variables[oriname][:,:,:]
      else:
        print('Zero 3d var: ', newname)
        var = np.zeros([self.nlev, self.nlat, self.nlon])
        self.dict3d[newname] = var

       #if(name == 'HGT_P0_L100_GLL0'):
       #  print('HGT min: %f, max: %f' %(np.min(var[0,:,:]), np.max(var[0,:,:])))

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 1

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data'
  infile = 'monthly_mean_gfs_4_202201_000.nc'

 #-----------------------------------------------------------------------------------------
  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'datadir=', 'infile='])
  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--datadir'):
      datadir = a
    elif o in ('--infile'):
      infile = a
    else:
      assert False, 'unhandled option'

 #-----------------------------------------------------------------------------------------
  i2h = Interpolate2Height(debug=debug)
  infile = '%s/%s' %(datadir, infile)
  outfile = infile.replace('monthly_mean', 'hl_monthly_mean')
  i2h.process(filename=infile, outfile=outfile)

