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

    self.clevs = np.arange(950.0, 1051.0, 1.0)
    self.cblevs = np.arange(950.0, 1060, 10.0)

    self.orientation = 'horizontal'
    self.pad = 0.1
    self.fraction = 0.06

    self.plotarea = [-180, 180, -90, 90]
   #self.plotarea = [-180, 180, -30, 30]
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

  def set_cmapname(self, cmapname):
    self.cmapname = cmapname

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
    self.monthname = ['NonExist', 'jan', 'feb', 'mar', 'apr', 'may', 'jun',
                      'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

    print('debug: ', debug)

    self.gp = GeneratePlot(debug)

 #-----------------------------------------------------------------------------------------
  def get_mean(self, year=2021, month=12):
    monyear = '%s%d' %(self.monthname[month], year)
    meanlist = []
    for t in ['00', '06', '12', '18']:
      fullname = '%s/%s/%s_%s00_000.nc' %(self.datadir, monyear, self.flnm, t)
      ncf = nc4.Dataset(fullname, 'r')
      val = ncf.variables['PRATE_P0_L1_GLL0'][:,:]
      meanlist.append(val)

      if('00' == t):
        meanval = val
        self.lat = ncf.variables['lat_0'][:]
        self.lon = ncf.variables['lon_0'][:]
      else:
        meanval += val

      ncf.close()

    meanval *= 0.25

    return meanval, meanlist

 #-----------------------------------------------------------------------------------------
  def process(self, datadir=None, flnm=None):
    self.datadir = datadir
    self.flnm = flnm

    meanval, varlist = self.get_mean(year=2021, month=12)
    longname = 'Monthly_Mean_Precipitation_Rate GFS Dec 2021'

    hourlist = ['00', '06', '12', '18']

    clevs = np.arange(-1.0, 1.01, 0.01)
    cblevs = np.arange(-1.0, 1.25, 0.25)

   #clevs = np.arange(-2.0, 2.02, 0.02)
   #cblevs = np.arange(-2.0, 2.5, 0.5)

    self.gp.set_clevs(clevs)
    self.gp.set_cblevs(cblevs)

   #scale = 30.0*24.0*3600.0
    scale = 5000.0

    for n in range(len(varlist)):
      title = '%sZ_%s' %(hourlist[n], longname)
      imgname = title.replace(' ', '_')
      pvar = scale*varlist[n]
      print('%s diff at %sZ min: %f, max: %f' %(longname, hourlist[n], np.min(pvar), np.max(pvar)))
      self.gp.plotit(self.lon, self.lat, pvar, title, imgname)

    clevs = np.arange(-0.5,  0.52, 0.02)
    cblevs = np.arange(-0.5, 0.6, 0.1)

    self.gp.set_clevs(clevs)
    self.gp.set_cblevs(cblevs)
    self.gp.set_cmapname('bwr')

    scale = 2.0*scale
    for n in range(len(varlist)):
      nm = n - 1
      if(nm < 0):
        nm = len(varlist) - 1
      title = '%sZ-%sZ_%s' %(hourlist[n], hourlist[nm], longname)
      imgname = title.replace('_', ' ')
      pvar = scale*(varlist[n] - varlist[nm])
      print('%s diff at %sZ min: %f, max: %f' %(longname, hourlist[n], np.min(pvar), np.max(pvar)))
      self.gp.plotit(self.lon, self.lat, pvar, title, imgname)

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data'
  flnm = 'monthly_mean_gfs_4_202112'

 #-----------------------------------------------------------------------------------------
  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'datadir=', 'flnm='])
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

 #-----------------------------------------------------------------------------------------
  pv = PlotVariable(debug=debug)
  pv.process(datadir=datadir, flnm=flnm)

