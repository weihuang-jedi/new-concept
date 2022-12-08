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

 #------------------------------------------------------------------------
  def makeone(self, lons, lats, data, ax, name, unit):
    maxLevels = 101
    cs = ax.contourf(lons, lats, data, maxLevels,
                     transform=ccrs.PlateCarree(),
                     extend=self.extend,
                     alpha=self.alpha, cmap=self.cmapname)
    ax.set_global()
    ax.set_title(name)
   #ax.coastlines(resolution='auto', color='k')
    ax.coastlines(resolution='110m', alpha=0.5)
    ax.gridlines(color='lightgrey', linestyle='-', draw_labels=True)
    cbar = plt.colorbar(cs, ax=ax)
    cbar.set_label(unit, rotation=90)


 #------------------------------------------------------------------------
  def plot(self, lons, lats, data, namelist, unitlist):
   #set up the plot
   #proj = ccrs.PlateCarree()
   #proj = ccrs.AzimuthalEquidistant(central_latitude=90, central_longitude=180)
   #proj = ccrs.Orthographic(central_longitude=180.0, central_latitude=90.0, globe=None)
    proj = ccrs.Orthographic(0, 90)
   #proj = ccrs.Orthographic(180, -90)

    fig, ax = plt.subplots(2, 2, figsize=[16, 16], subplot_kw=dict(projection=proj))

    self.makeone(lons, lats, data[0], ax[0,0], namelist[0], unitlist[0])
    self.makeone(lons, lats, data[1], ax[0,1], namelist[1], unitlist[1])
    self.makeone(lons, lats, data[2], ax[1,0], namelist[2], unitlist[2])
    self.makeone(lons, lats, data[3], ax[1,1], namelist[3], unitlist[3])

   #Add a big title at the top
    plt.suptitle(self.title)

    fig.canvas.draw()
   #plt.tight_layout()

    if(self.output):
      if(self.imagename is None):
        imagename = 'sample.png'
      else:
        imagename = self.imagename
      plt.savefig(imagename)
      plt.close()
    else:
      plt.show()

 #------------------------------------------------------------------------
  def set_default(self):
    self.imagename = 'sample.png'
    self.runname = 'SAMPLE'

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
  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/jan2022'
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
  grav = 9.81
  rgas = 287.05
  hgt = ncf.variables['alt'][:]

 #qv = ncf.variables['Qv'][:, :, :]
  temp = ncf.variables['T'][:, :, :]
  pres = ncf.variables['P'][:, :, :]
 #u = ncf.variables['U'][:, :, :]
 #v = ncf.variables['V'][:, :, :]
 #wspd = np.sqrt(u*u + v*v + 0.01)
  rho = pres/(rgas*temp)

  ncf.close()

#-----------------------------------------------------------------------------------------
  nalt, nlat, nlon = temp.shape
  print('nlat = %d, nlat = %d, nlon = %d' %(nalt, nlat, nlon))
  namelist = ['Pressure', 'Density', 'Temperature', 'Specific Humidity']
  unitlist = ['hPa', 'kg/M^3', 'K', 'g/kg']
 #namelist = ['Pressure', 'Density', 'Temperature', 'Wind Speed']
 #unitlist = ['hPa', 'kg/M^3', 'K', 'm/s']
  for n in range(0, nalt, 20):
    p = 0.01*pres[n,:,:]
    r = rho[n,:,:]
    t = temp[n,:,:]
    q = 1000.0*qv[n,:,:]
   #w = wspd[n,:,:]
    data = []
    data.append(p)
    data.append(r)
    data.append(t)
    data.append(q)
   #data.append(w)
    title = 'at %f meter' %(hgt[n])
    gp.set_title(title)
    imagename = 'at_%f_meter.png' %(hgt[n])
    gp.set_imagename(imagename)
    gp.plot(lons, lats, data, namelist, unitlist)

