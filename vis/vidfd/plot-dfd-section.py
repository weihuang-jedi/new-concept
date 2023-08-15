#=========================================================================
import os, sys
import getopt
import numpy as np
import netCDF4 as nc4

from datetime import datetime, timezone, timedelta
import matplotlib
import matplotlib.pyplot as plt

import cartopy.crs as ccrs

import tkinter
import matplotlib

#if sys.flags.interactive:
matplotlib.use('TkAgg')

#=========================================================================
class GeneratePlot():
  def __init__(self, debug=0, title='Unknown', imgname='sample'):
    self.debug = debug
    self.title = title
    self.imgname = imgname

    self.setup_default()

  def setup_default(self):
   #cmapname = coolwarm, bwr, rainbow, jet, seismic, nipy_spectral
    self.cmapname = 'jet'

   #self.clevs = np.arange(-10.0, 10.2, 0.2)
   #self.cblevs = np.arange(-10.0, 12.0, 2.0)

    self.clevs = np.arange(-5.0, 5.2, 0.1)
    self.cblevs = np.arange(-5.0, 6.0, 1.0)

   #self.clevs = np.arange(-20.0, 20.2, 0.2)
   #self.cblevs = np.arange(-20.0, 22.0, 2.0)

    self.orientation = 'horizontal'
    self.pad = 0.1
    self.fraction = 0.06

    self.plotarea = [-180, 180, -30, 30]
    self.resolution = 'auto'

    self.extend = 'both'

  def add_coastline(self):
    self.ax.set_extent(self.plotarea, crs=self.proj)
    self.ax.coastlines(resolution=self.resolution, color='k')
    self.ax.gridlines(color='lightgrey', linestyle='-', draw_labels=True)
   #self.ax.set_global()

  def showit(self):
    plt.title(self.title)
    plt.savefig(self.imgname)
   #if sys.flags.interactive:
    plt.show()

  def set_title(self, title):
    self.title = title

  def set_imgname(self, imgname):
    self.imgname = imgname

  def set_clevs(self, clevs):
    self.clevs = clevs

  def set_cblevs(self, cblevs):
    self.cblevs = cblevs

 #---------------------------------------------------------
  def plotit(self, x, y, z, title, imgname):
    self.fig = plt.figure(figsize=(10, 5))
    self.ax = self.fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
    self.proj = ccrs.PlateCarree()

    X, Y = np.meshgrid(x, y)

    print('Plotting ', title)
   
    cs = self.ax.contourf(X, Y, z, levels=self.clevs, extend=self.extend,
                          transform=self.proj,
                          cmap=self.cmapname)
    cbar = plt.colorbar(cs, ax=self.ax, orientation=self.orientation,
                        ticks=self.cblevs,
                        pad=self.pad, fraction=self.fraction)
    self.add_coastline()

    self.set_title(title)
    self.set_imgname(imgname)

    self.showit()

 #---------------------------------------------------------
  def plot_cross_section(self, y, z, data, title, imgname):
    self.fig = plt.figure(figsize=(10, 5))
    self.ax = self.fig.add_subplot(1, 1, 1)

    Y, Z = np.meshgrid(y, z)

    print('Plotting ', title)
   
    cs = self.ax.contourf(Y, Z, data, levels=self.clevs, extend=self.extend,
                          cmap=self.cmapname)
    cbar = plt.colorbar(cs, ax=self.ax, orientation=self.orientation,
                        ticks=self.cblevs,
                        pad=self.pad, fraction=self.fraction)
    plt.grid()

    self.set_title(title)
    self.set_imgname(imgname)

    self.showit()

#=========================================================================
class PlotVariable():
  def __init__(self, debug=0):
    self.debug = debug

    print('debug: ', debug)

    self.gp = GeneratePlot(debug)

 #-----------------------------------------------------------------------------------------
  def process(self, flnm=None, imgname='Density_Flux_Divergence'):
    if(os.path.exists(flnm)):
      print('Processing %s' %(flnm))
      ncf = nc4.Dataset(flnm, 'r')
    else:
      print('file: %s does not exist. Stop' %(flnm))
      sys.exit(-1)

    self.lat = ncf.variables['latitude'][:]
    self.lon = ncf.variables['longitude'][:]
    self.prs = ncf.variables['level'][:]

    z = []
    ftop = np.log2(10.0)
    for n in range(len(self.prs)):
      fact = 20.0*(np.log2(1000.0/self.prs[n])/ftop)
      print('Level %d prs = %f, z = %f' %(n, self.prs[n], fact))
      z.append(fact)

    nlon = int(len(self.lon)/2)
    length = 20
   #varname = 'div'
    varname = 'dfd'
    var = ncf.variables[varname]
    longname = var.getncattr('long_name')
    val = var[:, :, nlon-length:nlon+length]
   #val = var[:, :, :]
    pvar = np.mean(val, axis=2)
   #pvar = val[:, :, nlon]

    ncf.close()

    zp = z[16:]
    vp = pvar[16:, :]
    title = 'Density Flux Divergence ERA5 Dec 2021'
    imgname = title.replace(' ', '_')
    print('%s min: %f, max: %f' %(longname, np.min(pvar), np.max(pvar)))
    self.gp.plot_cross_section(self.lat, zp[::-1], vp[::-1,:], title, imgname)

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = 'data'
  flnm = 'monthly_mean_ERA5_VIDFD_00Z_Dec_2021.nc'
  imgname = 'Density_Flux_Divergence'

 #-----------------------------------------------------------------------------------------
  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'datadir=', 'flnm=', 'imgname='])
  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--datadir'):
      datadir = a
    elif o in ('--flnm'):
      flnm = a
    elif o in ('--imgname'):
      imgname = a
    else:
      assert False, 'unhandled option'

  filename='%s/%s' %(datadir, flnm)
 #-----------------------------------------------------------------------------------------
  pv = PlotVariable(debug=debug)
  pv.process(flnm=filename, imgname=imgname)

