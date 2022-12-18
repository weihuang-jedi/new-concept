import getopt
import os, sys
import numpy as np

import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
from mpl_toolkits.axes_grid1 import make_axes_locatable

import cartopy.crs as ccrs
from cartopy import config
from cartopy.util import add_cyclic_point
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter

import cartopy.feature as cfeature
import cartopy.mpl.ticker as cticker

import netCDF4 as nc4

import tkinter
import matplotlib
matplotlib.use('TkAgg')
#=========================================================================
class CrossSectionPlot():
  def __init__(self, debug=0, output=0):
    self.debug = debug
    self.output = output

    self.set_default()

 #------------------------------------------------------------------------
  def set_default(self):
    self.imagename = 'annual_grad_catalog.png'

    self.runname = 'CATALOG'

   #cmapname = coolwarm, bwr, rainbow, jet, seismic
   #self.cmapname = 'bwr'
   #self.cmapname = 'coolwarm'
   #self.cmapname = 'rainbow'
    self.cmapname = 'jet'

    self.clevs = np.arange(-0.2, 0.21, 0.01)
    self.cblevs = np.arange(-0.2, 0.3, 0.1)

    self.extend = 'both'
    self.alpha = 0.5
    self.pad = 0.1
    self.orientation = 'horizontal'
    self.size = 'large'
    self.weight = 'bold'
    self.labelsize = 'medium'

    self.label = 'Unit None'
    self.title = 'Atmospheric Catelog Cross Section'

 #------------------------------------------------------------------------
  def plot(self, lats, alts, pvar, ymax=10000.0):
    fig, ax = plt.subplots(constrained_layout=True, figsize=(11,8.5))
    levels = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
    colors = ('magenta', 'navy', 'orange', 'cyan', 'red', 'blue', 'brown')
    X, Y = np.meshgrid(lats, alts)
    cs = ax.contourf(X, Y, pvar, levels,
                     colors=colors,
                     origin='lower', extend='neither')
    cs.cmap.set_under('magenta')
    cs.cmap.set_over('blue')

    ax.set_title('Zonal Averaged Atmospheric Catalog')

   #Axis customization
    xticklabels = ['90S', '75S', '60S', '45S', '30S', '15S', '0',
                   '15N', '30N', '45N', '60N', '75N', '90N']
    ax.set_xticklabels(xticklabels)
    plt.xticks(lats[::30], xticklabels)
    ax.set_ylabel('Height (meter)')

    ytickpos = np.arange(0, ymax+1000, 1000)
    yticklabels = []
    for tick in ytickpos:
      lbl = str(tick)
      yticklabels.append(lbl)
    ax.set_yticklabels(yticklabels)
    plt.yticks(ytickpos, yticklabels)

   #Notice that the colorbar gets all the information it
   #needs from the ContourSet object, cs.
   #fig.colorbar(cs, location='bottom')
   #fig.colorbar(cs, orientation='horizontal', ticklocation='auto',
   #             extend='neither', ticks=ticks)
    cb = fig.colorbar(cs, orientation='horizontal', extend='neither')
    cblabel =    '1. Thermal High           2. Thermal Low           3. Warm High             '
    cblabel = '%s 4. Cold Low               5. Warm Low              6. Cold High        ' %(cblabel)
    cb.set_label(label=cblabel, weight='bold')

    plt.ylim(0, ymax)
    plt.grid(True)

    if(self.output):
      if(self.imagename is None):
        imagename = 't_aspect.png'
      else:
        imagename = self.imagename
      plt.savefig(imagename)
      plt.close()
    else:
      plt.show()

  def set_label(self, label='Unit (C)'):
    self.label = label

  def set_title(self, title='Temperature Increment'):
    self.title = title

  def set_clevs(self, clevs=[]):
    self.clevs = clevs

  def set_cblevs(self, cblevs=[]):
    self.cblevs = cblevs

  def set_imagename(self, imagename):
    self.imagename = imagename

  def set_cmapname(self, cmapname):
    self.cmapname = cmapname


#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 1
  output = 0
  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/annual'
  datafile = '%s/annual_grad_cate.nc' %(datadir)

  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'output=', 'datafile='])
  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--output'):
      output = int(a)
    elif o in ('--datafile'):
      datafile = a
    else:
      assert False, 'unhandled option'

#-----------------------------------------------------------------------------------------
  ncf = nc4.Dataset(datafile, 'r')

  alts = ncf.variables['alt'][:]
  lats = ncf.variables['lat'][:]
  lons = ncf.variables['lon'][:]
  cate = ncf.variables['cate'][:,:,:]

#-----------------------------------------------------------------------------------------
  csp = CrossSectionPlot(debug=debug, output=output)

  clevs = [1, 2, 3, 4, 5, 6, 7]
  cblevs = [1, 2, 3, 4, 5, 6, 7]

  csp.set_clevs(clevs=clevs)
  csp.set_cblevs(cblevs=cblevs)

  csp.set_title('Averaged Atmospheric Catalog')
  csp.set_imagename('gradCate.png')

  cscate = np.average(cate, axis=2)

  csp.plot(lats, alts[0:200], cscate[0:200, :])

