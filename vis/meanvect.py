#=========================================================================
import os
import sys
import types
import getopt
import netCDF4
import matplotlib

import numpy as np
import matplotlib.pyplot

from matplotlib import cm
from mpl_toolkits.basemap import Basemap

sys.path.append('../plot-utils')
from plottools import PlotTools

#=========================================================================
class PlotFV3Model():
  def __init__(self, debug=0, output=0, filename=None):
    self.debug = debug
    self.output = output
    self.filename = filename

    if(self.debug):
      print('self.filename = ', self.filename)

  def get_var(self, varname, ndim=3, time=0):
    ncfile = netCDF4.Dataset(self.filename, 'r')
    lat = ncfile.variables['lat'][:]
    lon = ncfile.variables['lon'][:]
    if(ndim == 3):
      var = ncfile.variables[varname][time, :, :, :]
    else:
      var = ncfile.variables[varname][time, :, :]
    ncfile.close()

    if(self.debug):
      msg = ('analy range for variable %s: (%s, %s).' % (varname, var.min(), var.max()))
      print(msg)

    return lat, lon, var

#------------------------------------------------------------------------------
if __name__ == '__main__':
  debug = 1
  output = 0
  addobs = 0
  filename = 'grid_fv3.nc'

  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'output=', 'addobs=', 'filename='])

  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--output'):
      output = int(a)
    elif o in ('--addobs'):
      addobs = int(a)
    elif o in ('--filename'):
      filename = a
   #else:
   #  assert False, 'unhandled option'

  print('debug = ', debug)
  print('output = ', output)
  print('addobs = ', addobs)
  print('filename = ', filename)

#------------------------------------------------------------------------------
  pom = PlotFV3Model(debug=debug, output=output, filename=filename)

  lat, lon, u3d = pom.get_var('ua')
  lat, lon, v3d = pom.get_var('va')
  lat, lon, w3d = pom.get_var('W')

 #print('lon = ', lon)
 #print('lat = ', lat)
 #print('u3d = ', u3d)
 #print('v3d = ', v3d)

#------------------------------------------------------------------------------
  pt = PlotTools(debug=debug, output=output, lat=lat, lon=lon)
 #if(addobs):
 #  filename = 'jeff-runs/PSonly/diag_conv_ps_ges.2021010900_ensmean.nc4'
 #  rgo = ReadGSIobs(debug=debug, filename=filename)
 #  obslat, obslon = rgo.get_latlon()

 #  pt.set_obs_latlon(obslat=obslat, obslon=obslon)

#------------------------------------------------------------------------------
  pt.set_label('Vector')

  imageprefix = 'fv3_vector'
  titleprefix = 'FV3 vector at'

#------------------------------------------------------------------------------
  pt.set_cmapname('rainbow')

  nlev, nlat, nlon = v3d.shape

  print('v3d.shape = ', v3d.shape)

  """
  for lev in range(5, nlev, 5):
    u = u3d[lev,:,:]
    v = v3d[lev,:,:]
    imgname = '%s_lev_%d.png' %(imageprefix, lev)
    title = '%s level %d' %(titleprefix, lev)
    pt.set_imagename(imgname)
    pt.set_title(title)
   #pt.simple_vector(u, v, intv=10)
   #pt.simple_stream(u, v, intv=5)
    pt.simple_barbs(u, v, intv=10)

  sys.exit(-1)
  """

#------------------------------------------------------------------------------
  clevs = np.arange(-0.5, 0.51, 0.01)
  cblevs = np.arange(-0.5, 0.6, 0.1)
  pt.set_clevs(clevs=clevs)
  pt.set_cblevs(cblevs=cblevs)

  ver = np.arange(0.0, float(nlev), 1.0)
  ver = -ver[::-1]

  print('u3d.shape = ', u3d.shape)

  vmean = np.mean(v3d[:,:,150:210], axis=2)
  wmean = np.mean(w3d[:,:,150:210], axis=2)

  print('vmean.shape = ', vmean.shape)

  v = vmean[::-1,:]
  w = wmean[::-1,:]
  title = '%s zonal mean between 150-210' %(titleprefix)
  pt.set_title(title)

  imgname = '%s_zonal_mean_150-210.png' %(imageprefix)
  pt.set_imagename(imgname)
 #pt.plot_section_vector(v, w, lat, ver, intv=5)
  pt.plot_section_stream(v, w, lat, ver)

