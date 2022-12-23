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
  imagename = '%s.png' %(title.replace(' ', '_'))
  plt.savefig(imagename)
  plt.show()

#=========================================================================
class PlotVariable():
  def __init__(self, debug=0):
    self.debug = debug

    print('debug: ', debug)

    self.dimlist = ('time', 'level', 'latitude', 'longitude')

 #-----------------------------------------------------------------------------------------
  def process(self, flnm=None):
    if(os.path.exists(flnm)):
      print('Processing %s' %(flnm))
      ncf = nc4.Dataset(flnm, 'r')
    else:
      print('file: %s does not exist. Stop' %(flnm))
      sys.exit(-1)

    lat = ncf.variables['lat_0'][:]
    lon = ncf.variables['lon_0'][:]
   #pw  = ncf.variables['PWAT_P0_L200_GLL0'][:,:]
   #title = 'Precipitable Water Dec 2021'
   #prate = 1000.0*ncf.variables['PRATE_P0_L1_GLL0'][:,:]
   #title = 'Precipitable Rate Dec 2021, units: g m-2s-1'
   #rain = ncf.variables['RWMR_P0_L105_GLL0'][:,:]
   #title = 'Rain mixing ratio Dec 2021, units: g kg-1'
    pmsl = 0.01*ncf.variables['PRMSL_P0_L101_GLL0'][:,:]
    title = 'Pressure reduced to MSL Dec 2021, units: hPa'
    plotit(lon, lat, pmsl, title)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/dec2021'
  infile = 'monthly_mean_gfs_4_202112.nc'

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
  pv = PlotVariable(debug=debug)
  flnm = '%s/%s' %(datadir, infile)
  pv.process(flnm=flnm)

