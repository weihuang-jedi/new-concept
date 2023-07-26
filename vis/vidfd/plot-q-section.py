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
    self.cmapname = 'brg'

    self.clevs = np.arange(0.0, 20.2, 0.2)
    self.cblevs = np.arange(0.0, 22.0, 2.0)

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
  def get_index(self, year=2021, month=12, hour=0, timeseries=[]):
    idx = []
    atmos_epoch = datetime(1900, 1, 1, 0, 0, tzinfo=timezone.utc)
   #print('atmos_epoch = ', atmos_epoch)

    for n in range(len(timeseries)):
      dt = timedelta(hours=float(timeseries[n])) + atmos_epoch
     #print(dt)
      if(dt.year == year):
        if(dt.month == month):
          if(dt.hour == hour):
            idx.append(n)
    return idx

 #-----------------------------------------------------------------------------------------
  def get_mean(self, nc4var, year=2021, month=12, ndim=2, nlon=720):
    monthdays = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if((year % 400 == 0) or  
      ( year % 100 != 0) and  
      ( year % 4 == 0)):   
     #print("Given Year is a leap Year");  
      monthdays[2] = 29
   #Else it is not a leap year  
   #else:  
     #print ("Given Year is not a leap Year")  

    start_idx = 0
    for n in range(1, month):
      start_idx += monthdays[n]
    start_idx *= 4
    end_idx = start_idx + 4*monthdays[month]

    if(ndim == 2):
      wholeval = nc4var[start_idx:end_idx, :, nlon]
    else:
      wholeval = nc4var[start_idx:end_idx, :, :, nlon]

    print('wholeval = ', wholeval)

    mean_00 = np.mean(wholeval[0::4, :, :], axis=0)
    mean_06 = np.mean(wholeval[1::4, :, :], axis=0)
    mean_12 = np.mean(wholeval[2::4, :, :], axis=0)
    mean_18 = np.mean(wholeval[3::4, :, :], axis=0)
    meanval = 0.25*(mean_00 + mean_06 + mean_12 + mean_18)

    return meanval, mean_00, mean_06, mean_12, mean_18

 #-----------------------------------------------------------------------------------------
  def process(self, flnm=None, it=0):
    if(os.path.exists(flnm)):
      print('Processing %s' %(flnm))
      ncf = nc4.Dataset(flnm, 'r')
    else:
      print('file: %s does not exist. Stop' %(flnm))
      sys.exit(-1)

    self.lat = ncf.variables['lat_0'][:]
    self.lon = ncf.variables['lon_0'][:]
    self.prs = ncf.variables['lv_ISBL0'][:]

    z = []
    ftop = np.log2(10.0)
    for n in range(len(self.prs)):
      fact = 20.0*(np.log2(100000.0/self.prs[n])/ftop)
      print('Level %d prs = %f, z = %f' %(n, self.prs[n], fact))
      z.append(fact)

    nlon = int(len(self.lon)/2)
    length = 60
    varname = 'SPFH_P0_L100_GLL0'
    var = ncf.variables[varname]
    longname = var.getncattr('long_name')
    val = var[:, :, nlon-length:nlon+length]
   #meanval = var[:, :, nlon]
   #meanval = np.mean(val, axis=2)
    meanval = np.mean(val, axis=2)
    pvar = 1000.0*meanval

    print('pvar = ', pvar)

    nz = 23
    zp = z[nz:]
    vp = pvar[nz:, :]
    title = longname
    imgname = title.replace(' ', '_')
    print('%s min: %f, max: %f' %(longname, np.min(pvar), np.max(pvar)))
    self.gp.plot_cross_section(self.lat, zp[::-1], vp[::-1,:], title, imgname)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/dec2021'
  flnm = 'monthly_mean_gfs_4_202112.nc'

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
  pv.process(flnm=filename)

