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
    self.vlist = ['z', 't']

   #HGT min: 75873.484375, max: 80451.648438
    zmin = 0.0
    zmax = 25000.0
    NZ = 501
    self.alt = np.linspace(zmin, zmax, NZ)

   #print('self.alt = ', self.alt)

 #-----------------------------------------------------------------------------------------
  def process(self, infile=None, outfile=None):
    print('outfile: ', outfile)

    if(os.path.exists(infile)):
      print('Processing %s' %(infile))
      ncin = nc4.Dataset(infile, 'r')
    else:
      print('infile: %s does not exist. Stop' %(infile))
      sys.exit(-1)

    ncout = nc4.Dataset(outfile, 'w')
   #copy global attributes all at once via dictionary
    ncout.source = 'Interpolated from: %s' %(infile)
    ncout.setncatts(ncin.__dict__)

   #copy dimensions
    for name, dimension in ncin.dimensions.items():
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

    for name, variable in ncin.variables.items():
      if(name in self.dimlist):
        if(name == 'lv_ISBL0'):
          newname = 'alt'
          x = ncout.createVariable(newname, variable.datatype, ('alt',))
          x[:] = self.alt
          ncout.variables[newname].long_name = 'altitude'
          ncout.variables[newname].units = 'meter'
          self.prs = ncin.variables[name][:]
        elif(name == 'lat_0'):
          newname = 'lat'
          x = ncout.createVariable(newname, variable.datatype,  ('lat',))
          orilat = ncin.variables[name][:]
          self.lat = orilat[::-1]
          ncout.variables[newname].setncatts(ncin.variables[name].__dict__)
          ncout.variables[newname][:] = self.lat
        elif(name == 'lon_0'):
          newname = 'lon'
          x = ncout.createVariable(newname, variable.datatype, ('lon',))
          self.lon= ncin.variables[name][:]
          ncout.variables[newname].setncatts(ncin.variables[name].__dict__)
          ncout.variables[newname][:] = self.lon

    zv = ncin.variables['HGT_P0_L100_GLL0']
   #self.z = zv[:,:,:]/9.806
    self.z = zv[:,:,:]

    np = len(self.prs)
    for n in range(np):
       print('level %d: z: %f, pressure: %f' %(n, self.z[n,0,0], self.prs[n]))

    self.chunklevel = 4
    self.chunksizes = (1,self.nlat,self.nlon)

    self.newdims = ('alt', 'lat', 'lon')
    self.cal_v_height('u', 'UGRD_P0_L100_GLL0', 'UGRD_P0_L6_GLL0', ncin, ncout)
    self.cal_v_height('v', 'VGRD_P0_L100_GLL0', 'VGRD_P0_L6_GLL0', ncin, ncout)
    self.cal_v_height('t', 'TMP_P0_L100_GLL0', 'TMP_P0_L1_GLL0', ncin, ncout)
    self.cal_v_height('q', 'SPFH_P0_L100_GLL0', 'SPFH_P0_2L108_GLL0', ncin, ncout)
    self.cal_3d_prs(ncin, ncout)

    ncin.close()
    ncout.close()

 #-----------------------------------------------------------------------------------------
  def cal_3d_prs(self, ncin, ncout):
    prs = np.zeros([self.nalt, self.nlat, self.nlon])
    p3d = ncout.createVariable('p', float, self.newdims,
                               complevel=self.chunklevel, chunksizes=self.chunksizes)

    pori = self.prs[::-1]
    npl = len(self.prs)
    pnew = np.zeros([npl+1])
    pnew[1:npl+1] = pori[:]
    hnew = np.zeros([npl+1])
    hnew[0] = 0.0

    slpvar = ncin.variables['PRMSL_P0_L101_GLL0']

    slp = slpvar[:,:]

    mlat = self.nlat
    for lat in range(self.nlat):
      mlat -= 1
      for lon in range(self.nlon):
        hori = self.z[::-1,lat,lon]
        if(hori[0] > 0.0):
          pnew[0] = slp[lat, lon]
          hnew[1:npl+1] = hori[:]
          prs[:, mlat, lon] = interp1d(hnew, pnew, self.alt, interp_method="cubic")
        else:
          prs[:, mlat, lon] = interp1d(hori, pori, self.alt, interp_method="cubic")

        if(self.debug):
          if((lat%180 == 0) and (lon%360 == 0)):
            print('check_interp for lat: %f, lon: %f' %(self.lat[lat], self.lon[lon]))
            check_interp(h, p, self.alt)
    p3d[:,:,:] = prs[:,:,:]

 #-----------------------------------------------------------------------------------------
  def cal_v_height(self, name, uname, sname, ncin, ncout):
    upv = ncin.variables[uname]
    sfv = ncin.variables[sname]

    hvar = np.zeros([self.nalt, self.nlat, self.nlon])
   #v3d = ncout.createVariable(name, float, self.newdims, compression='zlib')
    v3d = ncout.createVariable(name, float, self.newdims,
                               complevel=self.chunklevel, chunksizes=self.chunksizes)

    npl = len(self.prs)
    vnew = np.zeros([npl+1])
    hnew = np.zeros([npl+1])
    hnew[0] = 0.0

    vup = upv[:,:,:]
    vsf = sfv[:,:]
    mlat = self.nlat
    for lat in range(self.nlat):
      mlat -= 1
      for lon in range(self.nlon):
        hori = self.z[::-1,lat,lon]
        vori = vup[::-1,lat,lon]
       #print('hori.shape = ', hori.shape)
       #print('vori.shape = ', vori.shape)
        if(hori[0] > 0.0):
          hnew[1:npl+1] = hori[:]
          vnew[0] = vsf[lat,lon]
          vnew[1:npl+1] = vori[:]
          hvar[:, mlat, lon] = interp1d(hnew, vnew, self.alt, interp_method="cubic")
        else:
          hvar[:, mlat, lon] = interp1d(hori, vori, self.alt, interp_method="cubic")

        if(self.debug):
          if((lat%180 == 0) and (lon%360 == 0)):
            print('check_interp for lat: %f, lon: %f' %(self.lat[lat], self.lon[lon]))
            check_interp(h, v, self.alt)
    v3d[:,:,:] = hvar[:,:,:]

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/dec2021'
  infile = 'monthly_mean_gfs_4_202112.nc'
  outfile = 'monthly_mean_gfs_4_202112-height-level.nc'

 #-----------------------------------------------------------------------------------------
  i2h = Interpolate2Height(debug=debug)
  inflnm = '%s/%s' %(datadir, infile)
  outflnm = '%s/%s' %(datadir, outfile)
  i2h.process(infile=inflnm, outfile=outflnm)

