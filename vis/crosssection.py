import getopt
import os, sys
import numpy as np

import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import matplotlib.colors as colors
from mpl_toolkits.axes_grid1 import make_axes_locatable

import cartopy.crs as ccrs
from cartopy import config
from cartopy.util import add_cyclic_point
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter

import cartopy.feature as cfeature
import cartopy.mpl.ticker as cticker

import netCDF4 as nc4

#=========================================================================
class CrossSectionPlot():
  def __init__(self, debug=0, output=0):
    self.debug = debug
    self.output = output

    self.set_default()

 #------------------------------------------------------------------------
  def set_default(self):
    self.imagename = 'sample.png'

    self.runname = 'SLP'

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
  def plot(self, lats, alts, pvar):
   #set up the plot
    fig, ax = plt.subplots(nrows=1,ncols=1,
                           figsize=(12,8))

    print('\tpvar.shape = ', pvar.shape)

    vmin = np.min(pvar)
    vmax = np.max(pvar)

    pvar = pvar + 0.5
    print('\tpvar min: %f, max: %f' %(vmin, vmax))

    cmap = colors.LinearSegmentedColormap.from_list("",
           ["magenta", "navy", "orange", "cyan", "red","blue","brown"])

    cs=ax.contourf(lats, alts, pvar,
                   levels=self.clevs,
                   alpha=self.alpha, cmap=cmap)

    ax.set_title(self.title)

   #Adjust the location of the subplots on the page to make room for the colorbar
    fig.subplots_adjust(bottom=0.1, top=0.8, left=0.05, right=0.95,
                        wspace=0.05, hspace=0.05)

   #Add a colorbar axis at the bottom of the graph
    cbar_ax = fig.add_axes([0.1, 0.1, 0.90, 0.05])

   #Draw the colorbar
    cbar=fig.colorbar(cs, cax=cbar_ax, pad=self.pad, ticks=self.cblevs,
                      orientation='horizontal')

    cbar.set_label(self.label, rotation=0)

   #Add a big title at the top
    plt.suptitle(self.title)

    fig.canvas.draw()
    plt.tight_layout()

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
  datadir = '/work2/noaa/gsienkf/weihuang/gfs/vis'
 #datafile = '%s/stateCate.nc' %(datadir)
  datafile = '%s/gradCate.nc' %(datadir)

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

