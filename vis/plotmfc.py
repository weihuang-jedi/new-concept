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

 #levels = np.linspace(-1.0, 1.0, 21)
 #levels = np.linspace(-0.1, 0.1, 21)
 #cmap='nipy_spectral'
 #cmap='jet'
 #cmap='bwr'
  cmap='seismic'
 #cs = ax.contourf(X, Y, z, levels, transform=proj, cmap=cmap)
  cs = ax.contourf(X, Y, z, transform=proj, cmap=cmap)
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

    self.dimlist = ('prs', 'lat', 'lon')

 #-----------------------------------------------------------------------------------------
  def process(self, flnm=None):
    if(os.path.exists(flnm)):
      print('Processing %s' %(flnm))
      ncf = nc4.Dataset(flnm, 'r')
    else:
      print('file: %s does not exist. Stop' %(flnm))
      sys.exit(-1)

    prs = ncf.variables['lv_ISBL0'][:]
    lat = ncf.variables['lat_0'][:]
    lon = ncf.variables['lon_0'][:]
    mfc = ncf.variables['iduvq'][:,:]
    title = 'Intergrated Moisture Flux 2022010100'
    plotit(lon, lat, mfc, title)

   #print('prs=', prs)
   #print('lat=', lat)

    df = ncf.variables['duvq'][:,:,:]
    n = 0
    while(n < len(prs)):
      var = df[n,:,:]
      title = 'Moisture Flux 2022010100, at %d hPa' %(int(0.01*prs[n]))
      if(prs[n] < 10000.0):
        n += 2
        continue
      print('title: ', title)
      plotit(lon, lat, var, title)
      n += 2

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/jan2022'
  infile = 'monthly_mean_divergence_of_density_flux_202201.nc'

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
 #flnm = '%s/%s' %(datadir, infile)
  flnm = 'mfc_20220101_00.nc'
  pv.process(flnm=flnm)

