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

  def set_cmapname(self, cmapname):
    self.cmapname = cmapname

  def setup_default(self):
   #cmapname = coolwarm, bwr, rainbow, jet, seismic, nipy_spectral
    self.cmapname = 'jet'

    self.clevs = np.arange(-1.0, 1.01, 0.01)
    self.cblevs = np.arange(-1.0, 1.25, 0.25)

   #self.clevs = np.arange(-2.0, 2.02, 0.02)
   #self.cblevs = np.arange(-2.0, 2.5, 0.5)

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
  def get_mean(self, nc4var, year=2021, month=12):
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

    wholeval = nc4var[start_idx:end_idx, :, :]
    mean_00 = np.mean(wholeval[0::4, :, :], axis=0)
    mean_06 = np.mean(wholeval[1::4, :, :], axis=0)
    mean_12 = np.mean(wholeval[2::4, :, :], axis=0)
    mean_18 = np.mean(wholeval[3::4, :, :], axis=0)
    meanval = 0.25*(mean_00 + mean_06 + mean_12 + mean_18)

    return meanval, mean_00, mean_06, mean_12, mean_18

 #-----------------------------------------------------------------------------------------
  def process(self, flnm=None, imgname='ERA5 VIDFD', it=0):
    if(os.path.exists(flnm)):
      print('Processing %s' %(flnm))
      ncf = nc4.Dataset(flnm, 'r')
    else:
      print('file: %s does not exist. Stop' %(flnm))
      sys.exit(-1)

    self.lat = ncf.variables['latitude'][:]
    self.lon = ncf.variables['longitude'][:]

    pvar = ncf.variables['tp']
    fact = 1000.0

    print('pvar:', pvar)

    print('pvar.scale_factor = ', pvar.scale_factor)
    print('pvar.add_offset = ', pvar.add_offset)

    scale_factor = pvar.scale_factor
    add_offset = pvar.add_offset

    meanval, mean_00, mean_06, mean_12, mean_18 = self.get_mean(pvar, year=2021, month=12)
    longname = pvar.getncattr('long_name')

    title = 'ERA5 Dec 2021 %s' %(longname)
    imgname = title.replace(' ', '_')
    pvar = fact*meanval
    print('%s min: %f, max: %f' %(longname, np.min(pvar), np.max(pvar)))
    self.gp.plotit(self.lon, self.lat, pvar, title, imgname)

    varlist = [mean_00, mean_06, mean_12, mean_18]
    hourlist = ['00', '06', '12', '18']

    for n in range(len(varlist)):
      title = '%sZ_%s' %(hourlist[n], longname)
      imgname = title.replace(' ', '_')
      pvar = fact*varlist[n]
      print('%s at %sZ min: %f, max: %f' %(longname, hourlist[n], np.min(pvar), np.max(pvar)))
      self.gp.plotit(self.lon, self.lat, pvar, title, imgname)

    clevs = np.arange(-0.5,  0.52, 0.02)
    cblevs = np.arange(-0.5, 0.6, 0.1)

    self.gp.set_clevs(clevs)
    self.gp.set_cblevs(cblevs)
    self.gp.set_cmapname('bwr')

    for n in range(len(varlist)):
      nm = n - 1
      if(nm < 0):
        nm = len(varlist) - 1
      title = '%sZ-%sZ_%s' %(hourlist[n], hourlist[nm], longname)
      imgname = title.replace(' ', '_')
      pvar = fact*(varlist[n] - varlist[nm])
      print('%s diff at %sZ min: %f, max: %f' %(longname, hourlist[n], np.min(pvar), np.max(pvar)))
      self.gp.plotit(self.lon, self.lat, pvar, title, imgname)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/data'
  flnm = 'monthly-mean-surface.nc'
  imgname = 'tp'

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

