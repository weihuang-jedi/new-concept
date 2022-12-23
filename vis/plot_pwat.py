#=========================================================================
import os, sys
import getopt
import numpy as np
import netCDF4 as nc4
import operator as op

import matplotlib
import matplotlib.pyplot as plt

import cartopy.crs as ccrs

import tkinter
import matplotlib
matplotlib.use('TkAgg')
#---------------------------------------------------------
def plotit(x, y, z, title):
  levels = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
  colors = ('magenta', 'navy', 'orange', 'cyan', 'red', 'blue', 'brown')

  X, Y = np.meshgrid(x, y)

  print('Plotting ', title)
   
  fig = plt.figure(figsize=(10, 5))
  ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
  proj = ccrs.PlateCarree()

  cs = plt.contourf(X, Y, z, cmap ="jet")
 #cs = ax.contourf(X, Y, Z, levels, colors=colors,
 #                 transform=proj)
 #cs.cmap.set_under('magenta')
 #cs.cmap.set_over('blue')

 #cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.85)
  cbar = plt.colorbar(cs, ax=ax, orientation='horizontal',
                      pad=.1, fraction=0.06, extend='neither')
 #cblabel =    '1. Thermal High           2. Thermal Low           3. Warm High             '
 #cblabel = '%s 4. Cold Low               5. Warm Low              6. Cold High        ' %(cblabel)
 #cbar.set_label(label=cblabel, weight='bold')
 #cbar.set_label(label=cblabel)
 #cbar.ax.tick_params(labelsize=10)
 #cbar.ax.tick_params(labelsize=5)
 #cbar.ax.tick_params(labelsize='xx-small')

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
  def process(self, infile=None):
    if(os.path.exists(infile)):
      print('Processing %s' %(infile))
      ncf = nc4.Dataset(infile, 'r')
    else:
      print('input file: %s does not exist. Stop' %(infile))
      sys.exit(-1)

    lat = ncf.variables['lat_0']
    lon = ncf.variables['lon_0']
    print('lat = ', lat)
    print('lon = ', lon)
    pw = ncf.variables['PWAT_P0_L200_GLL0']
    print('pw.shape = ', pw.shape)
   #prate = ncf.variables['PRATE_P0_L1_GLL0']
    title = 'Precipitable Water, Dec 2021'
    plotit(lon, lat, pw, title)

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
  infile = '%s/%s' %(datadir, infile)
  pv.process(infile=infile)

