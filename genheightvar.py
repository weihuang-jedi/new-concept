#=========================================================================
import os, sys
import getopt
import numpy as np
import netCDF4 as nc4

import matplotlib
import matplotlib.pyplot as plt
from scipy import interpolate

#---------------------------------------------------------
def interp1d(xi, yi, x, interp_method="linear"):
  if(interp_method == "nearest"):
   #Nearest (aka. piecewise) interpolation
   #takes the value of the nearest point
    interp = interpolate.interp1d(xi, yi, kind = "nearest")
    y = interp(x)
   #Pros
   #only takes values of existing yi.
   #Cons
   #Discontinuous
  elif(interp_method == "linear"):
   #Linear interpolation
   #depends linearly on its closest neighbours.
    interp = interpolate.interp1d(xi, yi, kind = "linear")
    y = interp(x)
   #Pros
   #stays in the limits of yi
   #Continuous
   #Cons
   #Discontinuous first derivative.
  elif(interp_method == "quadratic"):
   #Spline interpolation
    interp = interpolate.interp1d(xi, yi, kind = "quadratic")
    y = interp(x)
   #Pros
   #Smoother
   #Cons
   #Less predictable values between points.
  elif(interp_method == "cubic"):
   #Spline interpolation
    interp = interpolate.interp1d(xi, yi, kind = "cubic")
    y = interp(x)
   #Pros
   #Smoother
   #Cubic generally more reliable than quadratic
   #Cons
   #Less predictable values between points.

  return y

#---------------------------------------------------------
def check_interp(xi, yi, x):
  params = {'font.size'     : 14,
            'figure.figsize':(15.0, 8.0),
            'lines.linewidth': 2.,
            'lines.markersize': 15,}
  matplotlib.rcParams.update(params)

 #---------------------------------------------------------
 #Let’s do it with Python
  y_nearest = interp1d(xi, yi, x, interp_method="nearest")
  y_linear = interp1d(xi, yi, x, interp_method="linear")
  y_quad = interp1d(xi, yi, x, interp_method="quadratic")
  y_cubic = interp1d(xi, yi, x, interp_method="cubic")

  plt.plot(xi,yi, 'o', label = "$Pi$")
  plt.plot(x, y_nearest, "-", label = "Nearest")
  plt.plot(x, y_linear,  "-", label = "Linear")
  plt.plot(x, y_quad,    "-", label = "Quadratic")
  plt.plot(x, y_cubic,   "-", label = "Cubic")
  plt.grid()
  plt.xlabel("x")
  plt.ylabel("y")
  plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))
  plt.show()

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

    self.dict3d = {}
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
         #print('lv_ISBL0 = ', self.prs)
        elif(name == 'lat_0'):
          newname = 'lat'
          x = ncout.createVariable(newname, variable.datatype,  ('lat',))
          orilat = ncf.variables[name][:]
          self.lat = orilat[::-1]
          ncout.variables[newname].setncatts(ncf.variables[name].__dict__)
          ncout.variables[newname][:] = self.lat
        elif(name == 'lon_0'):
          newname = 'lon'
          x = ncout.createVariable(newname, variable.datatype, ('lon',))
          self.lon= ncf.variables[name][:]
          ncout.variables[newname].setncatts(ncf.variables[name].__dict__)
          ncout.variables[newname][:] = self.lon

      if(name in self.ori3dvarlist):
        newname = self.ori2new3d[name]
        print('var name: ', newname)
       #print('variable: ', variable)
       #print('variable.dimensions: ', variable.dimensions)
        x = ncout.createVariable(newname, variable.datatype, self.newdims)
       #ncout.variables[name][:,:,:] = ncf.variables[name][:,:,:]
       #copy variable attributes all at once via dictionary
        ncout.variables[newname].setncatts(ncf.variables[name].__dict__)
        var = ncf.variables[name][:,:,:]
        self.dict3d[name] = var

       #if(name == 'HGT_P0_L100_GLL0'):
       #  print('HGT min: %f, max: %f' %(np.min(var[0,:,:]), np.max(var[0,:,:])))

    self.ter = ncf.variables['HGT_P0_L6_GLL0'][:,:]
    self.get2dvalue(ncf)

   #hgt = self.dict3d[self.new2ori3d['P']]
    hgt = self.dict3d['HGT_P0_L100_GLL0']

   #prs = self.cal_3d_prs(hgt)
   #ncout.variables['P'][:,:,:] = prs

   #self.ori3dvarlist = ['TMP_P0_L100_GLL0', 'SPFH_P0_L100_GLL0', 'RH_P0_L100_GLL0',
   #                     'UGRD_P0_L100_GLL0', 'VGRD_P0_L100_GLL0', 'VVEL_P0_L100_GLL0',
   #                     'DZDT_P0_L100_GLL0', 'HGT_P0_L100_GLL0', 'O3MR_P0_L100_GLL0']
   #self.new3dvarlist = ['T', 'Qv', 'RH',
   #                     'U', 'V', 'VOR',
   #                     'W', 'P', 'O3']
   #self.ori2dvarlist = ['TMP_P0_L1_GLL0', 'SPFH_P0_2L108_GLL0', 'RH_P0_L4_GLL0',
   #                     'UGRD_P0_L6_GLL0', 'VGRD_P0_L6_GLL0', 'VVEL_P0_L104_GLL0',
   #                     'DZDT_P0_L6_GLL0', 'PRMSL_P0_L101_GLL0', 'O3MR_P0_L6_GLL0']
   #self.new2dvarlist = ['tsf', 'qvsf', 'rhsf',
   #                     'usf', 'vsf', 'vorsf',
   #                     'wsf', 'slp', 'o3sf']

    temp = self.dict3d['TMP_P0_L100_GLL0']
    self.dict2d['tsf'] = self.get_tsf(temp, hgt)

    for n in range(len(self.ori3dvarlist)):
      oriname = self.ori3dvarlist[n]
      newname = self.new3dvarlist[n]
      print('Working on newname: %s, oriname: %s' %(newname, oriname))
      if(newname == 'P'):
        hvar = self.get_3d_prs(hgt)
      else:
        pvar = self.dict3d[oriname]
        svar = self.dict2d[self.new2dvarlist[n]]
        print('\tpvar.shape = ', pvar.shape)
        print('\tpvar min: %f, max: %f' %(np.min(pvar), np.max(pvar)))
        print('\tsvar.shape = ', svar.shape)
        print('\tsvar min: %f, max: %f' %(np.min(svar), np.max(svar)))
        hvar = self.p2h(hgt, pvar, svar)
        print('\thvar.shape = ', hvar.shape)
        print('\thvar min: %f, max: %f' %(np.min(hvar), np.max(hvar)))
      ncout.variables[newname][:,:,:] = hvar

    ncout.close()
    ncf.close()

 #-----------------------------------------------------------------------------------------
  def get_tsf(self, temp, hgt):
    t = temp[self.nlev-1, :, :]
    z = hgt[self.nlev-1, :, :]
    tsf = t + 0.0065*z
    print('\ttsf.shape = ', tsf.shape)
    print('\ttsf min: %f, max: %f' %(np.min(tsf), np.max(tsf)))
    return tsf

 #-----------------------------------------------------------------------------------------
  def get_3d_prs(self, hgt):
    prs = np.zeros([self.nalt, self.nlat, self.nlon])
    pori = self.prs[::-1]
    slp = self.dict2d['slp']
    print('working on cal_3d_prs')
    mlat = self.nlat
    for lat in range(self.nlat):
      mlat -= 1
      for lon in range(self.nlon):
        hori = hgt[::-1, lat, lon]
        if(hori[0] > 0.0):
          p = [slp[lat, lon]]
          p.extend(pori)
          h = [0.0]
          h.extend(hori)
        else:
          p = pori
          h = hori
        prs[:, mlat, lon] = interp1d(h, p, self.alt, interp_method="cubic")

        if(self.debug):
          if((lat%180 == 0) and (lon%360 == 0)):
            print('check_interp for lat: %f, lon: %f' %(self.lat[lat], self.lon[lon]))
            check_interp(h, p, self.alt)

    return prs

 #-----------------------------------------------------------------------------------------
  def p2h(self, hgt, pvar, svar):
    hvar = np.zeros([self.nalt, self.nlat, self.nlon])
    mlat = self.nlat
    for lat in range(self.nlat):
      mlat -= 1
      for lon in range(self.nlon):
        vori = pvar[::-1, lat, lon]
        hori = hgt[::-1, lat, lon]
        if(hori[0] > 0.0):
          h = [0.0]
          h.extend(hori)
          v = [svar[lat, lon]]
          v.extend(vori)
        else:
          h = hori
          v = vori
        hvar[:, mlat, lon] = interp1d(h, v, self.alt, interp_method="cubic")

        if(self.debug):
          if((lat%180 == 0) and (lon%360 == 0)):
            print('check_interp for lat: %f, lon: %f' %(self.lat[lat], self.lon[lon]))
            check_interp(h, v, self.alt)

    if(self.debug):
      print('\thvar.shape = ', hvar.shape)
      print('\thvar min: %f, max: %f' %(np.min(hvar), np.max(hvar)))

    return hvar

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

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

 #datadir = '/work2/noaa/gsienkf/weihuang/gfs/data'
 #infile = 'monthly_mean_gfs_4_202201_000.nc'

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/jan2022'
  infile = 'gfs_4_20220116_0000_000.nc'

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
  filename = '%s/%s' %(datadir, infile)
  outfile = '%s/hl_%s' %(datadir, infile)
  i2h.process(filename=filename, outfile=outfile)

