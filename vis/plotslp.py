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
def plotfull(x, y, z, title):
  X, Y = np.meshgrid(x, y)

  print('Plotting ', title)
   
  fig = plt.figure(figsize=(10, 5))
  ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
  proj = ccrs.PlateCarree()

  levels = [960.0, 970.0, 980.0, 990.0, 995.0, 997.5,
            1000.0, 1002.0, 1004.0, 1006.0, 1008.0, 1010.0,
            1012.0, 1014.0, 1016.0, 1018.0, 1020.0, 1025.0,
            1030.0, 1040.0]
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

#---------------------------------------------------------
def plotdiff(x, y, z, title):
  X, Y = np.meshgrid(x, y)

  print('Plotting ', title)

  fig = plt.figure(figsize=(10, 5))
  ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
  proj = ccrs.PlateCarree()

 #cs = plt.contourf(X, Y, z, cmap ="jet")
 #cmap='nipy_spectral'
  cmap='jet'
  cs = ax.contourf(X, Y, z,
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
  def process(self, yfile=None, mfile=None, dfile=None):
    if(os.path.exists(yfile)):
      print('Processing %s' %(yfile))
      ncyf = nc4.Dataset(yfile, 'r')
    else:
      print('file: %s does not exist. Stop' %(yfile))
      sys.exit(-1)

    if(os.path.exists(mfile)):
      print('Processing %s' %(mfile))
      ncmf = nc4.Dataset(mfile, 'r')
    else:
      print('file: %s does not exist. Stop' %(mfile))
      sys.exit(-1)

    if(os.path.exists(dfile)):
      print('Processing %s' %(dfile))
      ncdf = nc4.Dataset(dfile, 'r')
    else:
      print('file: %s does not exist. Stop' %(dfile))
      sys.exit(-1)

    lat = ncyf.variables['lat_0'][:]
    lon = ncyf.variables['lon_0'][:]
    ypmsl = 0.01*ncyf.variables['PRMSL_P0_L101_GLL0'][:,:]
    title = 'annual Pressure reduced to MSL Jan 2022 units: hPa'
    plotfull(lon, lat, ypmsl, title)

    mpmsl = 0.01*ncmf.variables['PRMSL_P0_L101_GLL0'][:,:]
    title = 'month Pressure reduced to MSL Jan 2022 units: hPa'
    plotfull(lon, lat, mpmsl, title)

    dpmsl = 0.01*ncdf.variables['PRMSL_P0_L101_GLL0'][:,:]
    title = 'Pressure reduced to MSL Jan 16 00Z 2022 units: hPa'
    plotfull(lon, lat, dpmsl, title)

    mmy_pmsl = mpmsl - ypmsl
    title = 'month-annual Pressure reduced to MSL Jan 2022 units: hPa'
    plotdiff(lon, lat, mmy_pmsl, title)

    dmm_pmsl = dpmsl - mpmsl
    title = 'day-month Pressure reduced to MSL Jan 2022 units: hPa'
    plotdiff(lon, lat, dmm_pmsl, title)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  ydir = '/work2/noaa/gsienkf/weihuang/gfs/data/annual'
  yfile = 'annual_mean_gfs_4_2022.nc'

  mdir = '/work2/noaa/gsienkf/weihuang/gfs/data/jan2022'
  mfile = 'monthly_mean_gfs_4_202201.nc'

  ddir = '/work2/noaa/gsienkf/weihuang/gfs/data/jan2022'
  dfile = 'gfs_4_20220116_0000_000.nc'

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
  yf = '%s/%s' %(ydir, yfile)
  mf = '%s/%s' %(mdir, mfile)
  df = '%s/%s' %(ddir, dfile)
  pv.process(yfile=yf, mfile=mf, dfile=df)

