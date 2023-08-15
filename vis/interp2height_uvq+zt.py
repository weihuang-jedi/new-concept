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

    self.dimlist = ('time', 'level', 'latitude', 'longitude')
    self.vlist = ['z', 't']

   #HGT min: 75873.484375, max: 80451.648438
    zmin = 0.0
    zmax = 25000.0
    NZ = 501
    self.alt = np.linspace(zmin, zmax, NZ)

   #print('self.alt = ', self.alt)

 #-----------------------------------------------------------------------------------------
  def process(self, uvqfile=None, zt_file=None, sfcfile=None, outfile=None):
    print('outfile: ', outfile)

    if(os.path.exists(uvqfile)):
      print('Processing %s' %(uvqfile))
      ncuvq = nc4.Dataset(uvqfile, 'r')
    else:
      print('uvqfile: %s does not exist. Stop' %(uvqfile))
      sys.exit(-1)

    if(os.path.exists(zt_file)):
      print('Processing %s' %(zt_file))
      nczt = nc4.Dataset(zt_file, 'r')
    else:
      print('zt_file: %s does not exist. Stop' %(zt_file))
      sys.exit(-1)

    if(os.path.exists(sfcfile)):
      print('Processing %s' %(sfcfile))
      ncsfc = nc4.Dataset(sfcfile, 'r')
    else:
      print('surface file: %s does not exist. Stop' %(sfcfile))
      sys.exit(-1)

    ncout = nc4.Dataset(outfile, 'w')
   #copy global attributes all at once via dictionary
    ncout.source = 'Interpolated from: %s' %(zt_file)
    ncout.setncatts(nczt.__dict__)

   #copy dimensions
    for name, dimension in nczt.dimensions.items():
      print('dim name: ', name)
      print('dimension: ', dimension)

      if(name == 'time'):
        self.ntime = len(dimension)
        ncout.createDimension(name, len(dimension))
      elif(name == 'level'):
        newname = 'alt'
        self.nlev = len(dimension)
        self.nalt = len(self.alt)
        ncout.createDimension(newname, len(self.alt))
      elif(name == 'latitude'):
        newname = 'lat'
        self.nlat = len(dimension)
        ncout.createDimension(newname, len(dimension))
      elif(name == 'longitude'):
        newname = 'lon'
        self.nlon = len(dimension)
        ncout.createDimension(newname, len(dimension))

    for name, variable in nczt.variables.items():
      if(name in self.dimlist):
        if(name == 'level'):
          newname = 'alt'
          x = ncout.createVariable(newname, variable.datatype, ('alt',))
          x[:] = self.alt
          ncout.variables[newname].long_name = 'altitude'
          ncout.variables[newname].units = 'meter'
          self.prs = 100.0*nczt.variables[name][:]
        elif(name == 'latitude'):
          newname = 'lat'
          x = ncout.createVariable(newname, variable.datatype,  ('lat',))
          orilat = nczt.variables[name][:]
          self.lat = orilat[::-1]
          ncout.variables[newname].setncatts(nczt.variables[name].__dict__)
          ncout.variables[newname][:] = self.lat
        elif(name == 'longitude'):
          newname = 'lon'
          x = ncout.createVariable(newname, variable.datatype, ('lon',))
          self.lon= nczt.variables[name][:]
          ncout.variables[newname].setncatts(nczt.variables[name].__dict__)
          ncout.variables[newname][:] = self.lon
        elif(name == 'time'):
          x = ncout.createVariable(name, variable.datatype, ('time',))
          self.time= nczt.variables[name][:]
          ncout.variables[name][:] = self.time

    zv = nczt.variables['z']
    self.z = zv[:,:,:,:]/9.806

    print('z column:', self.z[0,::-1,0,0])

    self.newdims = ('time', 'alt', 'lat', 'lon')
    self.cal_v_height('u', 'u10', ncuvq, ncsfc, ncout)
    self.cal_v_height('v', 'v10', ncuvq, ncsfc, ncout)
    self.cal_v_height('t', 't2m', nczt, ncsfc, ncout)
    self.cal_3d_prs(nczt, ncsfc, ncout)

    nczt.close()
    ncsfc.close()
    ncout.close()

 #-----------------------------------------------------------------------------------------
  def cal_3d_prs(self, ncin, ncsfc, ncout):
    prs = np.zeros([self.nalt, self.nlat, self.nlon])
    p4d = ncout.createVariable('p', float, self.newdims,
                               complevel=4, chunksizes=(1,1,self.nlat,self.nlon))

    pori = self.prs[::-1]
    npl = len(self.prs)
    pnew = np.zeros([npl+1])
    pnew[1:npl+1] = pori[:]
    hnew = np.zeros([npl+1])
    hnew[0] = 0.0

    slpvar = ncsfc.variables['msl']

    for nt in range(self.ntime):
      print('Workin on cal_3d_prs time level: ', nt)

      slp = slpvar[nt,:,:]

      mlat = self.nlat
      for lat in range(self.nlat):
        mlat -= 1
        for lon in range(self.nlon):
          hori = self.z[nt,::-1,lat,lon]
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
      p4d[nt,:,:,:] = prs[:,:,:]

 #-----------------------------------------------------------------------------------------
  def cal_v_height(self, uname, sname, ncin, ncsfc, ncout):
    upv = ncin.variables[uname]
    sfv = ncsfc.variables[sname]

    hvar = np.zeros([self.nalt, self.nlat, self.nlon])
   #v4d = ncout.createVariable(uname, float, self.newdims, compression='zlib')
    v4d = ncout.createVariable(uname, float, self.newdims,
                               complevel=4, chunksizes=(1,1,self.nlat,self.nlon))

    npl = len(self.prs)
    vnew = np.zeros([npl+1])
    hnew = np.zeros([npl+1])
    hnew[0] = 0.0

    for nt in range(self.ntime):
      print('Workin on cal_v_height for %s at time level: %d' %(uname, nt))
      vup = upv[nt,:,:,:]
      vsf = sfv[nt,:,:]
      mlat = self.nlat
      for lat in range(self.nlat):
        mlat -= 1
        for lon in range(self.nlon):
          hori = self.z[nt,::-1,lat,lon]
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
      v4d[nt,:,:,:] = hvar[:,:,:]

      mlat = self.nlat
      for lat in range(self.nlat):
        mlat -= 1
        for lon in range(self.nlon):
          hori = self.z[nt,::-1,lat,lon]
          vori = vup[::-1,lat,lon]
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
      v4d[nt,:,:,:] = hvar[:,:,:]

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/data'
  uvqfile = 'monthly_mean_dec2021_uvq.nc'
  zt_file = 'monthly_mean_dec2021_zt.nc'
  sfcfile = 'monthly_mean_dec2021_sealevel.nc'
  outfile = 'monthly-mean-dec2021-height-level.nc'

 #-----------------------------------------------------------------------------------------
  i2h = Interpolate2Height(debug=debug)
  uvqflnm = '%s/%s' %(datadir, uvqfile)
  zt_flnm = '%s/%s' %(datadir, zt_file)
  sfcflnm = '%s/%s' %(datadir, sfcfile)
  outflnm = '%s/%s' %(datadir, outfile)
  i2h.process(uvqfile=uvqflnm, zt_file=zt_flnm, sfcfile=sfcflnm, outfile=outflnm)

