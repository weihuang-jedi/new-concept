#=========================================================================
import os, sys
import getopt
import numpy as np
import netCDF4 as nc4

import matplotlib
import matplotlib.pyplot as plt

import cartopy.crs as ccrs

import tkinter
import matplotlib
matplotlib.use('TkAgg')
#---------------------------------------------------------
def plotit(x, y, z, title):
  X, Y = np.meshgrid(x, y)

  print('Plotting ', title)
   
  fig = plt.figure(figsize=(10, 5))
  ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
  proj = ccrs.PlateCarree()

 #cs = plt.contourf(X, Y, z, cmap ="jet")
  cs = ax.contourf(X, Y, z,
                   transform=proj,
                   cmap='nipy_spectral')
 #cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.85)
  cbar = plt.colorbar(cs, ax=ax, orientation='horizontal', pad=.1, fraction=0.06,)
  ax.set_extent([-180, 180, -90, 90], crs=proj)
  ax.coastlines(resolution='auto', color='k')
  ax.gridlines(color='lightgrey', linestyle='-', draw_labels=True)
  ax.set_global()
  plt.title(title)
  plt.show()

#=========================================================================
class PlotVariable():
  def __init__(self, debug=0):
    self.debug = debug

    print('debug: ', debug)

    self.dimlist = ('time', 'level', 'latitude', 'longitude')

 #-----------------------------------------------------------------------------------------
  def process(self, upfile=None, uvfile=None, sffile=None):
    if(os.path.exists(upfile)):
      print('Processing %s' %(upfile))
      ncf = nc4.Dataset(upfile, 'r')
    else:
      print('upper file: %s does not exist. Stop' %(upfile))
      sys.exit(-1)

    if(os.path.exists(uvfile)):
      print('Processing %s' %(uvfile))
      ncuv = nc4.Dataset(uvfile, 'r')
    else:
      print('uvq file: %s does not exist. Stop' %(uvfile))
      sys.exit(-1)

    if(os.path.exists(sffile)):
      print('Processing %s' %(sffile))
      ncsfc = nc4.Dataset(sffile, 'r')
    else:
      print('surface file: %s does not exist. Stop' %(sffile))
      sys.exit(-1)

   #dimensions
    for name, dimension in ncf.dimensions.items():
      print('dim name: ', name)

      if(name == 'time'):
        self.ntime = len(dimension)
        self.time = ncf.variables[name][:]
      elif(name == 'level'):
        self.nlev = len(dimension)
        self.prs = 100.0*ncf.variables[name][:]
      elif(name == 'latitude'):
        self.nlat = len(dimension)
        self.lat = ncf.variables[name][:]
      elif(name == 'longitude'):
        self.nlon = len(dimension)
        self.lon = ncf.variables[name][:]

    print('self.prs = ', self.prs)

    self.newdims = ('time', 'alt', 'lat', 'lon')

    slpvar = ncsfc.variables['msl']
    offset = getattr(slpvar, 'add_offset')
    scale_factor = getattr(slpvar, 'scale_factor')

   #for nt in range(self.ntime):
    for nt in range(0):
      print('Workin on slp time level: ', nt)

      slp = slpvar[nt,:,:]
     #slp = 100.0*(scale_factor*slp + offset)
      print('slp:', slp[0,0])

      title = 'SLP at time level %d' %(nt)
      plotit(self.lon, self.lat, slp, title)

    t2mvar = ncsfc.variables['t2m']
    for nt in range(1):
      print('Workin on t2m time level: ', nt)

      t2m = t2mvar[nt,:,:]
     #slp = 100.0*(scale_factor*slp + offset)
      print('t2m:', t2m[0,0])

      title = 't2m at time level %d' %(nt)
      plotit(self.lon, self.lat, t2m, title)

    u10var = ncsfc.variables['u10']
    for nt in range(1):
      print('Workin on u10 time level: ', nt)

      u10 = u10var[nt,:,:]
      print('u10:', u10[0,0])

      title = 'u10 at time level %d' %(nt)
      plotit(self.lon, self.lat, u10, title)

    v10var = ncsfc.variables['v10']
    for nt in range(1):
      print('Workin on v10 time level: ', nt)

      v10 = v10var[nt,:,:]
      print('v10:', v10[0,0])

      title = 'v10 at time level %d' %(nt)
      plotit(self.lon, self.lat, v10, title)

    zv = ncf.variables['z']
   #self.z = zv[:,:,:,:]
   #offset = getattr(zv, 'add_offset')
   #scale_factor = getattr(zv, 'scale_factor')

   #print('z offset = ', offset)
   #print('z scale_factor = ', scale_factor)

   #print('z column:', self.z[0,::-1,0,0])
    for nt in range(self.ntime):
      print('Workin on z time level: ', nt)
      for k in range(self.nlev):
        print('Workin on z prs level: ', self.prs[k])
        hgt = zv[nt,k,:,:]
        title = 'HGT at time level %d, pressure level: %d' %(nt, self.prs[k])
        plotit(self.lon, self.lat, hgt, title)

    ncf.close()
    ncuv.close()
    ncsfc.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/data'
  infile = 'dec2021.nc'
  sfcfile = 'dec2021_surfvar.nc'
  uvqfile = 'dec2021_uvq.nc'

 #-----------------------------------------------------------------------------------------
  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'datadir=', 'infile=',
                                                'sfcfile=', 'uvqfile='])
  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--datadir'):
      datadir = a
    elif o in ('--infile'):
      infile = a
    elif o in ('--sfcfile'):
      sfcfile = a
    elif o in ('--uvqfile'):
      uvqfile = a
    else:
      assert False, 'unhandled option'

 #-----------------------------------------------------------------------------------------
  pv = PlotVariable(debug=debug)
  upfile = '%s/%s' %(datadir, infile)
  uvfile = '%s/%s' %(datadir, uvqfile)
  sffile = '%s/%s' %(datadir, sfcfile)
  pv.process(upfile=upfile, uvfile=uvfile, sffile=sffile)

