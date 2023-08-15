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

   #clevs = np.arange(-100.0, 102.0, 2.0)
   #cblevs = np.arange(-100.0, 110.0, 10.0)

    self.clevs = np.arange(950.0, 1051.0, 1.0)
    self.cblevs = np.arange(950.0, 1060, 10.0)

    self.orientation = 'horizontal'
    self.pad = 0.1
    self.fraction = 0.06

    self.plotarea = [-180, 180, -90, 90]
    self.resolution = 'auto'

    self.extend = 'both'

  def add_coastline(self):
    self.ax.set_extent(self.plotarea, crs=self.proj)
    self.ax.coastlines(resolution=self.resolution, color='k')
    self.ax.gridlines(color='lightgrey', linestyle='-', draw_labels=True)
    self.ax.set_global()

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

#=========================================================================
class PlotVariable():
  def __init__(self, debug=0):
    self.debug = debug

    print('debug: ', debug)

    self.gp = GeneratePlot(debug)

 #-----------------------------------------------------------------------------------------
  def process(self, flnm=None, imgname='ERA5 VIDFD', it=0):
    if(os.path.exists(flnm)):
      print('Processing %s' %(flnm))
      ncf = nc4.Dataset(flnm, 'r')
    else:
      print('file: %s does not exist. Stop' %(flnm))
      sys.exit(-1)

    self.lat = ncf.variables['lat'][:]
    self.lon = ncf.variables['lon'][:]
    self.alt = ncf.variables['alt'][:]
   #timevar = ncf.variables['time']
   #sincetime = timevar.getncattr('units')
    self.time = ncf.variables['time'][:]

    nalt = len(self.alt)
    print('alt = ', self.alt)
    print('nalt = ', nalt)
    prsvar = ncf.variables['p'][0, :, :, :]
    pvar = prsvar[300, :, :]
    pvar = 0.01*pvar

    print('pvar = ', pvar)

    pstart = 750.0
    pinc = 5.0
    pend = 900.0 + pinc
    clevs = np.arange(pstart, pend, pinc)

    pstart = 750.0
    pinc = 20.0
    pend = 800.0 + pinc
    cblevs = np.arange(pstart, pend, pinc)

    self.gp.set_clevs(clevs)
    self.gp.set_cblevs(cblevs)

    longname = 'pressure'
    title = imgname.replace(' ', '_')
    print('%s min: %f, max: %f' %(longname, np.min(pvar), np.max(pvar)))
    self.gp.plotit(self.lon, self.lat, pvar, title, imgname)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/data'
  flnm = 'hl_monthly_mean_uvtp.nc'
  imgname = 'Pressure_at_Zlevel'

 #-----------------------------------------------------------------------------------------
  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'datadir=', 'flnm=', 'imgname='])
  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--datadir'):
      datadir = a
    elif o in ('--flnm'):
      flnm = a
    cblevs = np.arange(-10.0, 12, 2.0)

    self.gp.set_clevs(clevs)
    self.gp.set_cblevs(cblevs)

    longname = 'pressure'
    title = imgname.replace(' ', '_')
    pvar = 0.01*pvar
    print('%s min: %f, max: %f' %(longname, np.min(pvar), np.max(pvar)))
    self.gp.plotit(self.lon, self.lat, pvar, title, imgname)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/data'
  flnm = 'hl_monthly_mean_uvtp.nc'
  imgname = 'Pressure_at_Zlevel'

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

