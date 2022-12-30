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
  Z = z + 0.5

  print('Plotting ', title)
   
  fig = plt.figure(figsize=(10, 5))
  ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
  proj = ccrs.PlateCarree()

 #cs = plt.contourf(X, Y, z, cmap ="jet")
  cs = ax.contourf(X, Y, Z, levels, colors=colors,
                   transform=proj)
  cs.cmap.set_under('magenta')
  cs.cmap.set_over('blue')

 #cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.85)
  cbar = plt.colorbar(cs, ax=ax, orientation='horizontal',
                      pad=.1, fraction=0.06, extend='neither')
  cblabel =    '1. Thermal High           2. Thermal Low           3. Warm High             '
  cblabel = '%s 4. Cold Low               5. Warm Low              6. Cold High        ' %(cblabel)
 #cbar.set_label(label=cblabel, weight='bold')
  cbar.set_label(label=cblabel)
 #cbar.ax.tick_params(labelsize=10)
 #cbar.ax.tick_params(labelsize=5)
  cbar.ax.tick_params(labelsize='xx-small')

  ax.set_extent([-180, 180, -90, 90], crs=proj)
  ax.coastlines(resolution='auto', color='k')
  ax.gridlines(color='lightgrey', linestyle='-', draw_labels=True)
  ax.set_global()
  plt.title(title)
  imagename = '%s.png' %(title.replace(' ', '_'))
  plt.savefig(imagename)
 #plt.show()

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

    varname = 'cate'
    zv = ncf.variables[varname]
    print('zv column:', zv[:,0,0])

    for k in range(0, self.nalt, 40):
      var = zv[k,:,:]
 
     #--------------------------------------------------------------------------------
      z1d = var.flatten()
      for x in [0, 1, 2, 3, 4, 5, 6]:
        print(f"{x} has occurred {op.countOf(z1d, x)} times")

     #title = '%s at hight level: %f' %(varname, self.alt[k])
      title = 'gfs Atmospheric System Catalog at: %d meter' %(int(self.alt[k]+0.5))
      plotit(self.lon, self.lat, var, title)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/dec2021'
 #infile = 'state_cate_202112.nc'
  infile = 'my_state_cate_202112.nc'

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/jan2022'
  infile = 'my_state_cate_20220116_00.nc'

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

