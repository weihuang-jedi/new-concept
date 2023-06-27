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
#matplotlib.use('TkAgg')
#---------------------------------------------------------
def plotit(x, y, z, title, imgname):
  X, Y = np.meshgrid(x, y)

  print('Plotting ', title)
   
  fig = plt.figure(figsize=(10, 5))
  ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
  proj = ccrs.PlateCarree()

 #cmapname = coolwarm, bwr, rainbow, jet, seismic, nipy_spectral
  cmapname = 'jet'

 #clevs = np.arange(-100.0, 102.0, 2.0)
 #cblevs = np.arange(-100.0, 110.0, 10.0)

  clevs = np.arange(-20.0, 21.0, 1.0)
  cblevs = np.arange(-20.0, 25.0, 5.0)

 #cs = plt.contourf(X, Y, z, cmap ="jet")
  cs = ax.contourf(X, Y, z, levels=clevs, extend='both',
                   transform=proj,
                   cmap=cmapname)
 #cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.85)
  cbar = plt.colorbar(cs, ax=ax, orientation='horizontal', ticks=cblevs,
                      pad=0.1, fraction=0.06,)
  ax.set_extent([-180, 180, -90, 90], crs=proj)
  ax.coastlines(resolution='auto', color='k')
  ax.gridlines(color='lightgrey', linestyle='-', draw_labels=True)
  ax.set_global()

  plt.title(title)
  plt.savefig(imgname)
 #plt.show()

#=========================================================================
class PlotVariable():
  def __init__(self, debug=0):
    self.debug = debug

    print('debug: ', debug)

 #-----------------------------------------------------------------------------------------
  def process(self, flnm=None, imgname='ERA5 VIDFD'):
    if(os.path.exists(flnm)):
      print('Processing %s' %(flnm))
      ncf = nc4.Dataset(flnm, 'r')
    else:
      print('file: %s does not exist. Stop' %(flnm))
      sys.exit(-1)

    self.lat = ncf.variables['lat_0'][:]
    self.lon = ncf.variables['lon_0'][:]

    pvar = ncf.variables['vidfd'][:,:]
    title = imgname.replace(' ', '_')
    plotit(self.lon, self.lat, pvar, title, imgname)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/vis/vidfd/data'
 #flnm = 'monthly_mean_ERA5_VIDFD_00Z_Dec_2021.nc'
 #flnm = 'monthly_mean_ERA5_VIDFD_06Z_Dec_2021.nc'
  flnm = 'monthly_mean_ERA5_VIDFD_18Z_Dec_2021.nc'

 #-----------------------------------------------------------------------------------------
  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'datadir=', 'flnm='])
  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--datadir'):
      datadir = a
    elif o in ('--flnm'):
      flnm = a
    else:
      assert False, 'unhandled option'

  filename='%s/%s' %(datadir, flnm)
 #-----------------------------------------------------------------------------------------
  pv = PlotVariable(debug=debug)
  imgname = flnm.replace('.nc', '')
  pv.process(flnm=filename, imgname=imgname)

