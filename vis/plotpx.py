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
  X, Y = np.meshgrid(x, y)

  print('Plotting ', title)
   
  fig = plt.figure(figsize=(10, 5))
  ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
  proj = ccrs.PlateCarree()

  cmap = 'jet'
  
 #z = 1000.0*z
  z = 10.0e6*z
  levels = np.linspace(-1.0, 1.0, 21)
 #levels = np.linspace(-0.5, 0.5, 21)
 #levels = np.linspace(-0.25, 0.25, 21)
  cs = ax.contourf(X, Y, z, levels,
                   transform=proj, cmap=cmap)
 #cs = plt.contourf(X, Y, z, cmap ="jet")

 #cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.85)
  cbar = plt.colorbar(cs, ax=ax, orientation='horizontal',
                      pad=.1, fraction=0.06, extend='neither')

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
  def process(self, infile=None, varname='Laplas'):
    if(os.path.exists(infile)):
      print('Processing %s' %(infile))
      ncf = nc4.Dataset(infile, 'r')
    else:
      print('input file: %s does not exist. Stop' %(infile))
      sys.exit(-1)

   #dimensions
    for name, dimension in ncf.dimensions.items():
      print('dim name: ', name)

      if(name == 'time'):
        self.ntime = len(dimension)
        self.time = ncf.variables[name][:]
      elif(name == 'alt'):
        self.nalt = len(dimension)
        self.alt = ncf.variables[name][:]
      elif(name == 'lat'):
        self.nlat = len(dimension)
        self.lat = ncf.variables[name][:]
      elif(name == 'lon'):
        self.nlon = len(dimension)
        self.lon = ncf.variables[name][:]

    self.newdims = ('time', 'alt', 'lat', 'lon')

    zv = ncf.variables['cate']
    print('zv column:', zv[:,0,0])

   #for k in range(4):
   #for k in range(0, self.nalt, 40):
   #for k in range(2, self.nalt, 4):
    for k in range(2, 100, 4):
      var = zv[k,:,:]
 
     #--------------------------------------------------------------------------------
     #z1d = var.flatten()
     #for x in [0, 1, 2, 3, 4, 5, 6]:
     #  print(f"{x} has occurred {op.countOf(z1d, x)} times")

      title = 'gfs %s of DEC 2021 %d meter' %(varname, int(self.alt[k]+0.5))
      plotit(self.lon, self.lat, var, title)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/dec2021'
 #varname = 'PY'
  varname = 'D2P'
  infile = '%s.nc' %(varname)

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
  pv.process(infile=infile, varname=varname)

