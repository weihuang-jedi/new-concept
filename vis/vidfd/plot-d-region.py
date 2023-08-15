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

    self.clevs = np.arange(-25.0, 26.0, 1.0)
    self.cblevs = np.arange(-25.0, 30.0, 5.0)

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

#=========================================================================
class PlotVariable():
  def __init__(self, debug=0):
    self.debug = debug

    print('debug: ', debug)

    self.gp = GeneratePlot(debug)

 #-----------------------------------------------------------------------------------------
  def get_data(self, year=2021, month='Dec'):
    hourlist = ['00', '06', '12', '18']

    varlist = []
    for hour in hourlist:
      flnm = '%s/monthly_mean_ERA5_Divergence_%sZ_%s_%d.nc' %(self.datadir, hour, month, year)
      if(os.path.exists(flnm)):
        print('Processing %s' %(flnm))
        ncf = nc4.Dataset(flnm, 'r')
      else:
        print('file: %s does not exist. Stop' %(flnm))
        sys.exit(-1)

      val = ncf.variables['div'][:,:,:]

      if('00' == hour):
        meanval = val
        self.lat = ncf.variables['latitude'][:]
        self.lon = ncf.variables['longitude'][:]
        self.prs = ncf.variables['level'][:]
      else:
        meanval += val

      varlist.append(val)

      ncf.close()

    meanval *= 0.25

    return meanval, varlist

 #-----------------------------------------------------------------------------------------
  def process(self, datadir=None):
    self.datadir = datadir
    scale = 1.0e6
    meanval, varlist = self.get_data(year=2021, month='Dec')
    print('meanval = ', meanval)

    longname = 'Monthly_Mean_Divergence_Dec_2021'
    title = longname
    imgname = title.replace(' ', '_')
    pvar = scale*meanval[-1, :, :]
    print('%s min: %f, max: %f' %(longname, np.min(pvar), np.max(pvar)))
    self.gp.plotit(self.lon, self.lat[240:481], pvar[240:481,:], title, imgname)

    hourlist = ['00', '06', '12', '18']

    for n in range(len(varlist)):
      title = '%sZ %s' %(hourlist[n], longname)
      imgname = title.replace(' ', '_')
      pvar = scale*varlist[n][-1, :, :]
      print('%s at %sZ min: %f, max: %f' %(longname, hourlist[n], np.min(pvar), np.max(pvar)))
      self.gp.plotit(self.lon, self.lat[240:481], pvar[240:481,:], title, imgname)

    clevs = np.arange(-5.0, 5.1, 0.1)
    cblevs = np.arange(-5.0, 6.0, 1.0)

    self.gp.set_clevs(clevs)
    self.gp.set_cblevs(cblevs)

    for n in range(len(varlist)):
      nm = n - 1
      if(nm < 0):
        nm = len(varlist) - 1
      title = '%sZ-%sZ_%s' %(hourlist[n], hourlist[nm], longname)
      imgname = title.replace(' ', '_')
      pvar = scale*(varlist[n][-1, :, :] - varlist[nm][-1, :, :])
      print('%s diff at %sZ min: %f, max: %f' %(longname, hourlist[n], np.min(pvar), np.max(pvar)))
      self.gp.plotit(self.lon, self.lat[240:481], pvar[240:481,:], title, imgname)

    ncf.close()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 0

  datadir = '/work2/noaa/gsienkf/weihuang/era5/vis/vidfd'

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

