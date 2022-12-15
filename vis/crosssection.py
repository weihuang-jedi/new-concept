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

    self.label = 'Unit (C)'
    self.title = 'Temperature Increment'

 #------------------------------------------------------------------------
  def plot(self, lats, alts, pvar):
   #Start Figure, set big size for cross section
    fig = plt.figure(figsize=(12, 8))

   #Specify plotting axis (single panel)
    ax = plt.subplot(111)

   #Set y-scale to be log since pressure decreases exponentially with height
   #ax.set_yscale('log')

   #Set limits, tickmarks, and ticklabels for y-axis
    ax.set_ylim([0, 10001])
    ax.set_yticks(range(0, 10001, 1000))
    ax.set_yticklabels(range(0, 10001, 1000))

   #Invert the y-axis since pressure decreases with increasing height
   #ax.invert_yaxis()

   #Plot the sudo elevation on the cross section
   #ax.fill_between(xsect['obs_distance'], xsect['elevation'].m, 1030,
   #            where=xsect['elevation'].m <= 1030, facecolor='lightgrey',
   #            interpolate=True, zorder=10)
   #Don't plot xticks
   #plt.xticks([], [])

   #Plot smoothed potential temperature grid (K)
    cs = ax.contourf(lats, alts, pvar, range(1, 7, 1), cmap = 'jet')
    ax.clabel(cs, fmt='%i')

   #Plot smoothed mixing ratio grid (g/kg)
    cs = ax.contourf(lats, alts, pvar, range(1, 7, 1), colors='tab:black')
    ax.clabel(cs, fmt='%i')

   # Add some informative titles
    plt.title('Cross-Section of Atmospheric Systems Catalog', loc='left')
    plt.title(date, loc='right')

    plt.show()

#--------------------------------------------------------------------------------
if __name__== '__main__':
  debug = 1
  output = 0
  datadir = '/work2/noaa/gsienkf/weihuang/gfs/vis'
  datafile = '%s/stateCate.nc' %(datadir)

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
  gp = GeneratePlot(debug=debug, output=output)

  ncf = nc4.Dataset(datafile, 'r')

  alts = ncf.variables['alt'][:]
  lats = ncf.variables['lat'][:]
  lons = ncf.variables['lon'][:]
  cate = ncf.variables['cate'][:,:,:]

#-----------------------------------------------------------------------------------------
  grav = 9.81
  rgas = 287.05

  csp = CrossSectionPlot(debug=debug, output=output)
  csp.plot(lats, alts[0:200], cate[0:200, :, :])

