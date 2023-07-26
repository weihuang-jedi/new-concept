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
   #self.cmapname = 'brg'
    self.cmapname = 'jet'

    self.clevs = np.arange(-5.0, 5.2, 0.1)
    self.cblevs = np.arange(-5.0, 6.0, 1.0)

   #self.clevs = np.arange(-10.0, 10.2, 0.2)
   #self.cblevs = np.arange(-10.0, 12.0, 2.0)

   #self.clevs = np.arange(-20.0, 20.2, 0.2)
   #self.cblevs = np.arange(-20.0, 22.0, 2.0)

   #self.clevs = np.arange(-200.0, 202.0, 2.0)
   #self.cblevs = np.arange(-200.0, 250.0, 50.0)

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

    self.monthname = ['NonExist', 'jan', 'feb', 'mar', 'apr', 'may', 'jun',
                      'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

    self.gp = GeneratePlot(debug)

 #-----------------------------------------------------------------------------------------
  def get_data(self, year=2021, month=12):
    dirname = '%s/%s%d' %(self.datadir, self.monthname[month], year)
    mon_year = '%s_%d' %(self.monthname[month], year)
    meanlist = []

   #varname = 'div'
    varname = 'dfd'

    for t in ['00', '06', '12', '18']:
      fullname = '%s/monthly_mean_gfs_vidfd_%sZ_%s.nc' %(dirname, t, mon_year)
      print('fullname:', fullname)
      ncf = nc4.Dataset(fullname, 'r')
      var = ncf.variables[varname]
      val = var[:,:,:]
      meanlist.append(val)
      if('00' == t):
        meanval = val
        self.longname = var.long_name
        self._FillValue = var._FillValue
       #self.missing_value = var.missing_value

        self.lat = ncf.variables['lat_0'][:]
        self.lon = ncf.variables['lon_0'][:]
        self.prs = ncf.variables['lv_ISBL0'][:]
      else:
        meanval += val

      ncf.close()

    meanval *= 0.25
    return meanval, meanlist

 #-----------------------------------------------------------------------------------------
  def process(self, datadir=None):
    self.datadir = datadir

    meanval, varlist = self.get_data(year=2021, month=12)
    longname = 'Monthly_Mean_%s' %(self.longname)

    z = []
    ftop = np.log2(10.0)
    for n in range(len(self.prs)):
      fact = 20.0*(np.log2(100000.0/self.prs[n])/ftop)
      print('Level %d prs = %f, z = %f' %(n, self.prs[n], fact))
      z.append(fact)

    nlon = int(len(self.lon)/2)
    length = 10
    val = meanval[:, :, nlon-length:nlon+length]
   #val = meanval[:, :, :]
    pvar = np.mean(val, axis=2)
   #pvar = meanval[:, :, nlon]

   #print('pvar = ', pvar)

    nz = 23
    zp = z[nz:]
    vp = pvar[nz:, :]
    title = 'Density Flux Divergence GFS, Dec 2021'
    imgname = title.replace(' ', '_')
    print('%s min: %f, max: %f' %(longname, np.min(pvar), np.max(pvar)))
    self.gp.plot_cross_section(self.lat, zp[::-1], vp[::-1,:], title, imgname)

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data'

 #-----------------------------------------------------------------------------------------
  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'datadir='])
  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--datadir'):
      datadir = a
    else:
      assert False, 'unhandled option'

 #-----------------------------------------------------------------------------------------
  pv = PlotVariable(debug=debug)
  pv.process(datadir=datadir)

