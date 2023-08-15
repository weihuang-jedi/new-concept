#=========================================================================
import os, sys
import getopt
import numpy as np
import netCDF4 as nc4

from datetime import datetime, timezone, timedelta
import matplotlib
import matplotlib.pyplot as plt

import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.gridspec as gridspec

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

    self.plotarea = [-180, 180, -30, 30]
    self.resolution = 'auto'

    self.extend = 'both'

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
   #Select ERA5 MSL
    param = 'MSL'

   #Start figure
    fig = plt.figure(figsize=(10, 13))

   #Use gridspec to help size elements of plot; small top plot and big bottom plot
    gs = gridspec.GridSpec(nrows=2, ncols=1, height_ratios=[1, 6], hspace=0.03)

   #Tick labels
    x_tick_labels = [u'0\N{DEGREE SIGN}E', u'90\N{DEGREE SIGN}E',
                     u'180\N{DEGREE SIGN}E', u'90\N{DEGREE SIGN}W',
                     u'0\N{DEGREE SIGN}E']

   #Top plot for geographic reference (makes small map)
    ax1 = fig.add_subplot(gs[0, 0], projection=ccrs.PlateCarree(central_longitude=180))
    ax1.set_extent([0, 357.5, 35, 65], ccrs.PlateCarree(central_longitude=180))
    ax1.set_yticks([-5, 5])
    ax1.set_yticklabels([u'-5\N{DEGREE SIGN}S', u'5\N{DEGREE SIGN}N'])
    ax1.set_xticks([-180, -90, 0, 90, 180])
    ax1.set_xticklabels(x_tick_labels)
    ax1.grid(linestyle='dotted', linewidth=2)

   #Add geopolitical boundaries for map reference
    ax1.add_feature(cfeature.COASTLINE.with_scale('50m'))
    ax1.add_feature(cfeature.LAKES.with_scale('50m'), color='black', linewidths=0.5)

   #Bottom plot for Hovmoller diagram
    ax2 = fig.add_subplot(gs[1, 0])
   #ax2.invert_yaxis()  # Reverse the time order to do oldest first

    cf = ax2.contourf(x, y, z, self.clevs, cmap=plt.cm.bwr, extend='both')
   #cs = ax2.contour(x, y, z, self.clevs, colors='k', linewidths=1)
    cbar = plt.colorbar(cf, orientation='horizontal', pad=0.04, aspect=50, extendrect=True)
    cbar.set_label('hPa')

   #Make some ticks and tick labels
    ax2.set_xticks([0, 90, 180, 270, 357.5])
    ax2.set_xticklabels(x_tick_labels)
    ax2.set_yticks(y[4::8])
    ax2.set_yticklabels(y[4::8])

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
  def get_val(self, nc4var, year=2021, month=12):
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

    self.time = self.timevar[start_idx+1:end_idx]

    return wholeval

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
    self.timevar = ncf.variables['time']
    sincetime = self.timevar.getncattr('units')

    mslvar = ncf.variables['msl']
    wholeval = self.get_val(mslvar, year=2021, month=12)
    longname = mslvar.getncattr('long_name')

    clevs = np.arange(-10.0, 10.5, 0.5)
    cblevs = np.arange(-10.0, 12, 2.0)

    self.gp.set_clevs(clevs)
    self.gp.set_cblevs(cblevs)

    nt, nlat, nlon = wholeval.shape

    ncent = int(nlat/2)

    print('wholeval.shape = ', wholeval.shape)

    meanval = np.mean(wholeval[:,ncent-10:ncent+11,:], axis=1)
    timlonvar = np.empty([nt-1, nlon], dtype=np.float64, order='f')

    for n in range(nt-1):
      timlonvar[n,:] = meanval[n+1,:] - meanval[n,:]

    imgname = 'Time_Longitude_%s' %(longname)
    title = imgname.replace('_', ' ')
    pvar = 0.01*timlonvar
    print('tim/long %s min: %f, max: %f' %(longname, np.min(pvar), np.max(pvar)))
    self.gp.plotit(self.lon, self.time, pvar, title, imgname)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/data'
  flnm = 'monthly-mean-surface.nc'
  imgname = 'MSL'

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

