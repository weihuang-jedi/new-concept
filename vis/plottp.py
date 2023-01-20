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

  print('z min: %f, z max: %f' %(np.min(z), np.max(z)))
   
  fig = plt.figure(figsize=(10, 5))
  ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
  proj = ccrs.PlateCarree()

 #levels = np.linspace(0, 4, 81)
  levels = np.linspace(0, 2.5, 51)
 #cs = plt.contourf(X, Y, z, cmap ="jet")
 #cmap='nipy_spectral'
  cmap='jet'
  cs = ax.contourf(X, Y, z, levels,
                   transform=proj, cmap=cmap)
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

    lat = ncf.variables['latitude'][:]
    lon = ncf.variables['longitude'][:]
    tp = ncf.variables['tp'][:,:,:]
    title = 'Total Precipitation Dec 2021'
    tpa = 100.0*np.sum(tp, axis=0, dtype=np.float)
    plotit(lon, lat, tpa, title)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/data'
  infile = 'dec2021_surfvar.nc'

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

