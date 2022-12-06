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
class GeneratePlot():
  def __init__(self, debug=0, output=0):
    self.debug = debug
    self.output = output

    self.set_default()

  def plot(self, lons, lats, pvar):
   #ax.coastlines(resolution='110m')
   #ax.gridlines()

    nrows = 1
    ncols = 1

   #set up the plot
    proj = ccrs.PlateCarree()

    fig, ax = plt.subplots(nrows=nrows,ncols=ncols,
                           subplot_kw=dict(projection=proj),
                           figsize=(11,8.5))
 
   #axs is a 2 dimensional array of `GeoAxes`. Flatten it into a 1-D array
   #axs=axs.flatten()

    print('\tpvar.shape = ', pvar.shape)

    vmin = np.min(pvar)
    vmax = np.max(pvar)

    print('\tpvar min: %f, max: %f' %(vmin, vmax))

    nan_array = np.argwhere(np.isnan(pvar))

    print('nan_array: ', nan_array)

   #if((vmax - vmin) > 1.0e-5):
   #  self.clevs, self.cblevs = get_plot_levels(pvar)

   #cyclic_data, cyclic_lons = add_cyclic_point(pvar, coord=lons)

   #cs=ax.contourf(cyclic_lons, lats, cyclic_data, transform=proj,
   #cs=ax.contourf(lons, lats, pvar, transform=proj,
   #               levels=self.clevs, extend=self.extend,
   #               alpha=self.alpha, cmap=self.cmapname)
    maxLevels = 101
    cs=ax.contourf(lons, lats, pvar, maxLevels, transform=proj,
                   extend=self.extend,
                   alpha=self.alpha, cmap=self.cmapname)

    ax.set_extent([-180, 180, -90, 90], crs=proj)
    ax.coastlines(resolution='auto', color='k')
    ax.gridlines(color='lightgrey', linestyle='-', draw_labels=True)

    ax.set_title(self.title)

   #Adjust the location of the subplots on the page to make room for the colorbar
    fig.subplots_adjust(bottom=0.1, top=0.8, left=0.05, right=0.95,
                        wspace=0.02, hspace=0.02)

   #Add a colorbar axis at the bottom of the graph
    cbar_ax = fig.add_axes([0.1, 0.1, 0.80, 0.05])

   #Draw the colorbar
   #cbar=fig.colorbar(cs, cax=cbar_ax, pad=self.pad, ticks=self.cblevs,
   #                  orientation='horizontal')
    cbar=fig.colorbar(cs, cax=cbar_ax, pad=self.pad,
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

  def set_default(self):
    self.imagename = 'sample.png'

    self.runname = 'SLP'

   #cmapname = coolwarm, bwr, rainbow, jet, seismic
   #self.cmapname = 'bwr'
   #self.cmapname = 'coolwarm'
    self.cmapname = 'rainbow'
   #self.cmapname = 'jet'

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
  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data'
 #datafile = '%s/monthly_mean_gfs_4_202201_000.nc' %(datadir)
  datafile = '%s/hl_monthly_mean_gfs_4_202201_000.nc' %(datadir)

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

  lats = ncf.variables['lat'][:]
  lons = ncf.variables['lon'][:]

#-----------------------------------------------------------------------------------------
  hgt = ncf.variables['alt'][:]

  varname = 'T'
  var = ncf.variables[varname][:, :, :]

  clevs = np.arange(220.0, 310.0, 1.0)
  cblevs = np.arange(220.0, 310.0, 10.0)

 #gp.set_clevs(clevs=clevs)
 #gp.set_cblevs(cblevs=cblevs)

  gp.set_label(varname)

#-----------------------------------------------------------------------------------------

  print('\tvar.max: %f, var.min: %f' %(np.max(var), np.min(var)))

  imagename = 'slp.png'
  gp.set_imagename(imagename)

  nalt, nlat, nlon = var.shape
  print('nlat = %d, nlat = %d, nlon = %d' %(nalt, nlat, nlon))
  for n in range(0, nalt, 100):
    print('Level %d var.min: %f, var.max: %f' %(n, np.min(var[n,:,:]), np.max(var[n,:,:])))
    title = '%s at %f meter' %(varname, hgt[n])
    gp.set_title(title)
    gp.plot(lons, lats, var[n,:,:])

#-----------------------------------------------------------------------------------------
  ncf.close()

