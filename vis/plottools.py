#=========================================================================
import os
import sys
import types
import getopt

import numpy as np
import matplotlib
import matplotlib.pyplot

from matplotlib import cm
from mpl_toolkits.basemap import Basemap
from matplotlib.ticker import MultipleLocator

from modelVerticalpressure import ModelVerticalPressure

#=========================================================================
class PlotTools():
  def __init__(self, debug=0, output=0, lat=[], lon=[]):
    self.debug = debug
    self.output = output
    self.lat = lat
    self.lon = lon

    self.set_default()
    self.set_grid(lat, lon)

   #------------------------------------------------------------------------------
    filename = '/work/noaa/gsienkf/weihuang/jedi/case_study/sondes/Data/bkg/fv_core.res.nc'
    self.mvp = ModelVerticalPressure(debug=debug, filename=filename)
   #prs = self.mvp.get_pressure()
   #print('len(prs) = ', len(prs))
   #for n in range(len(prs)):
   #  print('Level %d pressure %f' %(n, prs[n]))
    self.logp = self.mvp.get_logp()
    self.markpres = self.mvp.get_markpres()
    self.marklogp = self.mvp.get_marklogp()

    self.precision = 1
    self.hemisphere = 'N'
    self.projection = 'cyl'

  def set_precision(self, precision=1):
    self.precision = precision

  def get_markpres(self):
    return self.markpres

  def set_markpres(self, markpres=[]):
    self.markpres = markpres
    self.mvp.set_markpres(markpres = markpres)
    self.marklogp = self.mvp.get_marklogp()

  def set_default(self):
    self.image_name = 'sample.png'

   #cmapname = coolwarm, bwr, rainbow, jet, seismic
    self.cmapname = 'bwr'

    self.clevs = np.arange(-2.0, 2.05, 0.05)
    self.cblevs = np.arange(-2.0, 2.5, 0.5)

    self.obslat = []
    self.obslon = []

    self.extend = 'both'
    self.alpha = 0.5
    self.pad = 0.1
    self.orientation = 'horizontal'
    self.size = 'large'
    self.weight = 'bold'
    self.labelsize = 'medium'

    self.label = 'Distance (km)'
    self.title = 'Distance to Patch/Tile Center'

    self.scale=100
    self.scale_units='inches'

    self.hemisphere = 'N'

  def set_hemisphere(self, hemisphere='N'):
    self.hemisphere = hemisphere

  def set_scale(self, scale=100):
    self.scale = scale

  def set_scale_units(self, scale_units='inches'):
    self.scale_units = scale_units

  def set_clevs(self, clevs=[]):
    self.clevs = clevs

  def set_cblevs(self, cblevs=[]):
    self.cblevs = cblevs

  def set_obs_latlon(self, obslat=[], obslon=[]):
    self.obslat = obslat
    self.obslon = obslon

  def set_imagename(self, imagename):
    self.image_name = imagename

  def set_cmapname(self, cmapname):
    self.cmapname = cmapname

  def set_label(self, label):
    self.label = label

  def set_title(self, title):
    self.title = title

  def set_grid(self, lat, lon):
    self.nlat = len(lat)
    self.nlon = len(lon)

   #print('self.nlat = ', self.nlat)
   #print('self.nlon = ', self.nlon)

    lon2d = np.zeros((self.nlat, self.nlon), dtype=float)
    lat2d = np.zeros((self.nlat, self.nlon), dtype=float)

    for n in range(self.nlat):
      lon2d[n, :] = lon[:]
    for n in range(self.nlon):
      lat2d[:, n] = lat[:]

    self.lon1d = np.reshape(lon2d, (lon2d.size, ))
    self.lat1d = np.reshape(lat2d, (lat2d.size, ))

  def set_vector_grid(self, u, v, intv=5):
    nblat = int(intv/2)
    nblon = int(intv/2)
    nvlat = int(self.nlat/intv)
    nvlon = int(self.nlon/intv)

    print('self.nlat = %d, nvlat = %d' %(self.nlat, nvlat))
    print('self.nlon = %d, nvlon = %d' %(self.nlon, nvlon))

    lon = np.zeros((nvlat, nvlon), dtype=float)
    lat = np.zeros((nvlat, nvlon), dtype=float)
    u2d = np.zeros((nvlat, nvlon), dtype=float)
    v2d = np.zeros((nvlat, nvlon), dtype=float)

    for i in range(nvlat):
      for n in range(nvlon):
        lat[i, n] = self.lat[nblat+i*intv]
    for n in range(nvlat):
      for i in range(nvlon):
        lon[n, i] = self.lon[nblon+i*intv]
        u2d[n, i] = u[nblat+n*intv, nblon+i*intv]
        v2d[n, i] = v[nblat+n*intv, nblon+i*intv]

    lon1d = np.reshape(lon, (lon.size, ))
    lat1d = np.reshape(lat, (lat.size, ))

    u1d = np.reshape(u2d, (u2d.size, ))
    v1d = np.reshape(v2d, (v2d.size, ))

    return lat1d, lon1d, u1d, v1d

  def set_stream_grid(self):
    lon2d = np.zeros((self.nlat, self.nlon), dtype=float)
    lat2d = np.zeros((self.nlat, self.nlon), dtype=float)

    for n in range(self.nlat):
      lon2d[n, :] = self.lon[:]
    for n in range(self.nlon):
      lat2d[:, n] = self.lat[:]

    return lat2d, lon2d

  def build_basemap(self):
    basemap_dict = {'resolution': 'c', 'projection': 'cyl',
                    'llcrnrlat': -90.0, 'llcrnrlon': 0.0,
                    'urcrnrlat':  90.0, 'urcrnrlon': 360.0}
    basemap_dict['lat_0'] = 0.0
    basemap_dict['lon_0'] = 180.0

    basemap = Basemap(**basemap_dict)

    return basemap

  def build_basemap4stereo_projection(self, hemisphere='N', projection='ortho'):
    self.hemisphere = hemisphere
    self.projection = projection

    if('ortho' == projection):
      if('N' == hemisphere):
        basemap = Basemap(projection='ortho', lon_0=-105,lat_0=75, resolution='c')
      else:
        basemap = Basemap(projection='ortho', lon_0=-105,lat_0=-75, resolution='c')
    else:
      if('N' == hemisphere):
        basemap = Basemap(projection='npstere', boundinglat=0, round=True,
                          lon_0=-90, lat_0=90, lat_1=60, lat_2=30, resolution='c')
      else:
        basemap = Basemap(projection='spstere', boundinglat=0, round=True,
                          lon_0=90, lat_0=-90, lat_1=-60, lat_2=-30, resolution='c')

    return basemap

  def create_image(self, plt_obj, savename):
    msg = ('Saving image as %s.' % savename)
    print(msg)
    kwargs = {'transparent': True, 'dpi': 500}
    plt_obj.savefig(savename, **kwargs)

  def display(self, output=False, image_name=None):
    if(output):
      if(image_name is None):
        image_name=self.image_name
      self.plt.tight_layout()
      kwargs = {'plt_obj': self.plt, 'savename': image_name}
      self.create_image(**kwargs)
    else:
      self.plt.show()

  def plot(self, pvar, addmark=0, marker='x', size=3, color='green'):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('plot variable min: %s, max: %s' % (pvar.min(), pvar.max()))
    print(msg)

    (self.x, self.y) = self.basemap(self.lon1d, self.lat1d)
   #(self.x, self.y) = np.meshgrid(lon1d, lat1d)
    v1d = np.reshape(pvar, (pvar.size, ))

    contfill = self.basemap.contourf(self.x, self.y, v1d, tri=True,
                                     levels=self.clevs, extend=self.extend,
                                     alpha=self.alpha, cmap=self.cmapname)

    cb = self.fig.colorbar(contfill, orientation=self.orientation,
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line()

    if(addmark):
      self.add_obs_marker(marker=marker, size=size, color=color)

    self.display(output=self.output, image_name=self.image_name)

  def plot_without_marker(self, pvar):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('plot variable min: %s, max: %s' % (pvar.min(), pvar.max()))
    print(msg)

    (self.x, self.y) = self.basemap(self.lon1d, self.lat1d)
   #(self.x, self.y) = np.meshgrid(lon1d, lat1d)
    v1d = np.reshape(pvar, (pvar.size, ))

    contfill = self.basemap.contourf(self.x, self.y, v1d, tri=True,
                                     levels=self.clevs, extend=self.extend,
                                     alpha=self.alpha, cmap=self.cmapname)

    cb = self.fig.colorbar(contfill, orientation=self.orientation,
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line()

    self.display(output=self.output, image_name=self.image_name)

  def simple_plot(self, pvar):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('plot variable min: %s, max: %s' % (pvar.min(), pvar.max()))
    print(msg)

    (self.x, self.y) = self.basemap(self.lon1d, self.lat1d)
    v1d = np.reshape(pvar, (pvar.size, ))

    contfill = self.basemap.contourf(self.x, self.y, v1d, tri=True,
                                     extend=self.extend,
                                     alpha=self.alpha, cmap=self.cmapname)

    cb = self.fig.colorbar(contfill, orientation=self.orientation,
                           pad=self.pad)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line()

    self.display(output=self.output, image_name=self.image_name)

  def simple_vector(self, u, v, intv=5):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('vector u min: %s, max: %s' % (u.min(), u.max()))
    print(msg)
    msg = ('vector v min: %s, max: %s' % (v.min(), v.max()))
    print(msg)

    lat1d, lon1d, u1d, v1d = self.set_vector_grid(u, v, intv=intv)

    clevs = np.arange(-100, 105, 5)
    blevs = np.arange(-100, 120, 20)

    (x, y) = self.basemap(lon1d, lat1d)
#   vector = self.plt.arrow(x, y, u1d, v1d)
#   vector = self.plt.quiver(x, y, u1d, v1d)
    vector = self.basemap.quiver(x, y, u1d, v1d, width=0.002,
 				 scale=self.scale, scale_units=self.scale_units,
                                 alpha=self.alpha, cmap=self.cmapname)
#                                levels=clevs, extend=self.extend,
#                                alpha=self.alpha, cmap=self.cmapname)
    vectorkey = self.plt.quiverkey(vector, 0.95, 1.02, 20, '20m/s', labelpos='N')

    cb = self.fig.colorbar(vector, orientation=self.orientation,
                           pad=self.pad, ticks=blevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line()

    self.display(output=self.output, image_name=self.image_name)

 #https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.streamplot.html#matplotlib.pyplot.streamplot
 #matplotlib.pyplot.streamplot(x, y, u, v, density=1, linewidth=None,
 #    color=None, cmap=None, norm=None, arrowsize=1, arrowstyle='-|>',
 #    minlength=0.1, transform=None, zorder=None, start_points=None,
 #    maxlength=4.0, integration_direction='both', *, data=None)
  def simple_stream(self, u, v, intv=5):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('vector u min: %s, max: %s' % (u.min(), u.max()))
    print(msg)
    msg = ('vector v min: %s, max: %s' % (v.min(), v.max()))
    print(msg)

    lat, lon = self.set_stream_grid()

    clevs = np.arange(-100, 105, 5)
    blevs = np.arange(-100, 120, 20)

   #(x, y) = self.basemap(lon, lat)
   #stream = self.basemap.streamplot(lon, lat, u, v, density=1, linewidth=0.2)
    stream = self.basemap.streamplot(lon, lat, u, v, density=10, linewidth=0.2,
 				     arrowsize=1, arrowstyle='-|>',
                                     cmap=self.cmapname)

   #cb = self.fig.colorbar(stream, orientation=self.orientation,
   #                       pad=self.pad, ticks=blevs)
   #cb.set_label(label=self.label, size=self.size, weight=self.weight)
   #cb.ax.tick_params(labelsize=self.labelsize)

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line()

    self.display(output=self.output, image_name=self.image_name)

 #https://www.geeksforgeeks.org/matplotlib-pyplot-barbs-in-python/
 #https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.barbs.html#matplotlib.pyplot.barbs
 #https://matplotlib.org/stable/gallery/images_contours_and_fields/barb_demo.html
  def simple_barbs(self, u, v, intv=10):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('vector u min: %s, max: %s' % (u.min(), u.max()))
    print(msg)
    msg = ('vector v min: %s, max: %s' % (v.min(), v.max()))
    print(msg)

    lat, lon = self.set_stream_grid()

    clevs = np.arange(-100, 105, 5)
    blevs = np.arange(-100, 120, 20)

    ib = int(intv/2)
    spd = np.sqrt(u**2 + v**2)

    barbs = self.basemap.barbs(lon[ib::intv, ib::intv], lat[ib::intv, ib::intv],
                               u[ib::intv, ib::intv], v[ib::intv, ib::intv],
                               spd[ib::intv, ib::intv], fill_empty=False, rounding=False,
                               flagcolor='r', barbcolor=['b', 'g'], flip_barb=True,
                               barb_increments=dict(half=5, full=10, flag=50),
                               sizes=dict(emptybarb=0.25, spacing=0.2, height=0.3))

# Arbitrary set of vectors, make them longer and change the pivot point
# (point around which they're rotated) to be the middle
#axs1[0, 1].barbs(
#    data['x'], data['y'], data['u'], data['v'], length=8, pivot='middle')

# Showing colormapping with uniform grid.  Fill the circle for an empty barb,
# don't round the values, and change some of the size parameters
#axs1[1, 0].barbs(
#    X, Y, U, V, np.sqrt(U ** 2 + V ** 2), fill_empty=True, rounding=False,
#    sizes=dict(emptybarb=0.25, spacing=0.2, height=0.3))

# Change colors as well as the increments for parts of the barbs
#axs1[1, 1].barbs(data['x'], data['y'], data['u'], data['v'], flagcolor='r',
#                 barbcolor=['b', 'g'], flip_barb=True,
#                 barb_increments=dict(half=10, full=20, flag=100))

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line()

    self.display(output=self.output, image_name=self.image_name)

  def obsonly(self, obslat, obslon, obsvar, inbound=False):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('plot variable min: %s, max: %s' % (np.min(obsvar), np.max(obsvar)))
    print(msg)

   #print('len(obslon) = ', len(obslon))
   #print('len(obslat) = ', len(obslat))
   #print('len(obsvar) = ', len(obsvar))

    x, y = self.basemap(obslon, obslat)
   #norm = self.plt.Normalize(np.min(obsvar), np.max(obsvar))
   #obsplot = self.basemap.scatter(x, y, c=obsvar, cmap='viridis', alpha=self.alpha)

    vm = abs(np.min(obsvar))
    bm = abs(np.max(obsvar))
    if(bm > vm):
      vm = bm
  
    if(vm < 1.0e-6):
      vm = 1.0
    size = np.zeros((len(obsvar)), dtype=float)
    for n in range(len(size)):
      size[n] = 1.0 + 100.0*abs(obsvar[n])/vm

    if(inbound):
      midvar = np.where(obsvar > self.cblevs[0], obsvar, self.cblevs[0])
      var = np.where(midvar < self.cblevs[-1], midvar, self.cblevs[-1])
    else:
      var = obsvar

    print('self.cmapname = ', self.cmapname)
    obsplot = self.basemap.scatter(x, y, s=size, c=var, cmap=self.cmapname, 
                                   alpha=self.alpha)

    cb = self.plt.colorbar(orientation=self.orientation, extend='both',
                           pad=self.pad, ticks=self.cblevs, shrink=0.8)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line()

    self.display(output=self.output, image_name=self.image_name)

  def set_format(self, cb):
    if(self.precision == 0):
      cb.ax.set_xticklabels(['{:.0f}'.format(x) for x in self.cblevs], minor=False)
    elif(self.precision == 1):
      cb.ax.set_xticklabels(['{:.1f}'.format(x) for x in self.cblevs], minor=False)
    elif(self.precision == 2):
      cb.ax.set_xticklabels(['{:.2f}'.format(x) for x in self.cblevs], minor=False)
    else:
      cb.ax.set_xticklabels(['{:.3f}'.format(x) for x in self.cblevs], minor=False)

  def obsonly2(self, obslat, obslon, obsvar, inbound=False, vm=5.0):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('plot variable min: %s, max: %s' % (np.min(obsvar), np.max(obsvar)))
    print(msg)

    x, y = self.basemap(obslon, obslat)

    if(inbound):
      midvar = np.where(obsvar > self.cblevs[0], obsvar, self.cblevs[0])
      var = np.where(midvar < self.cblevs[-1], midvar, self.cblevs[-1])
    else:
      var = obsvar

    size = np.zeros((len(obsvar)), dtype=float)
    for n in range(len(size)):
      size[n] = 1.0 + 100.0*abs(obsvar[n])/vm
      if(size[n] > 150.0):
        size[n] = 150.0

    print('self.cmapname = ', self.cmapname)
    obsplot = self.basemap.scatter(x, y, s=size, c=var, cmap=self.cmapname, 
                                   alpha=self.alpha)

    cb = self.plt.colorbar(orientation=self.orientation, extend='both',
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line()

    self.display(output=self.output, image_name=self.image_name)

  def add_obs_marker(self, marker='x', size=3, color='green'):
    if(len(self.obslon) > 0):
      x, y = self.basemap(self.obslon, self.obslat)
     #adding dotes:
     #dotes = self.basemap.plot(x, y, 'bo', markersize=12)
     #dotes = self.basemap.plot(x, y, 'bo', markersize=6)
      dotes = self.basemap.scatter(x, y, marker=marker, s=size, color=color)

  def plot_meridional_section(self, pvar):
    nlev, nlat = pvar.shape

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    lev = np.arange(0.0, float(nlev), 1.0)
    dlat = 180.0/(nlat-1)
    lat = np.arange(-90.0, 90.0+dlat, dlat)

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

   #contfill = self.ax.contourf(lat, lev, pvar, tri=True,
    contfill = self.ax.contourf(lat, -lev[::-1], pvar[::-1,:], tri=True,
                                levels=self.clevs, extend=self.extend,
                                alpha=self.alpha, cmap=self.cmapname)

    cb = self.fig.colorbar(contfill, orientation=self.orientation,
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    major_ticks_top=np.linspace(-90,90,7)
    self.ax.set_xticks(major_ticks_top)

    intv = int(1+nlev/10)
   #major_ticks_top=np.linspace(0,nlev,intv)
   #major_ticks_top=np.linspace(0,60,7)
    major_ticks_top=np.linspace(-60,0,7)
    self.ax.set_yticks(major_ticks_top)

    minor_ticks_top=np.linspace(-90,90,19)
    self.ax.set_xticks(minor_ticks_top,minor=True)

   #minor_ticks_top=np.linspace(0,60,13)
    minor_ticks_top=np.linspace(-60,0,13)
    self.ax.set_yticks(minor_ticks_top,minor=True)

    self.ax.grid(b=True, which='major', color='green', linestyle='-', alpha=0.5)
    self.ax.grid(b=True, which='minor', color='green', linestyle='dotted', alpha=0.2)

    self.display(output=self.output, image_name=self.image_name)

  def plot_meridional_section_logp(self, pvar):
    nlev, nlat = pvar.shape

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    lev = np.arange(0.0, float(nlev), 1.0)
    dlat = 180.0/(nlat-1)
    lat = np.arange(-90.0, 90.0+dlat, dlat)

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    contfill = self.ax.contourf(lat, self.logp[::-1], pvar[::-1,:], tri=True,
                                levels=self.clevs, extend=self.extend,
                                alpha=self.alpha, cmap=self.cmapname)

    cb = self.fig.colorbar(contfill, orientation=self.orientation,
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    major_ticks_top=np.linspace(-90,90,7)
    self.ax.set_xticks(major_ticks_top)

    minor_ticks_top=np.linspace(-90,90,19)
    self.ax.set_xticks(minor_ticks_top,minor=True)
    self.ax.set_xlabel('Latitude')

    self.ax.set_yticks(self.marklogp)
    self.ax.set_ylabel('Unit: hPa')

    yticklabels = []
    for p in self.markpres:
      lbl = '%d' %(int(p+0.1))
      yticklabels.append(lbl)
    self.ax.set_yticklabels(yticklabels)

    self.ax.grid(b=True, which='major', color='green', linestyle='-', alpha=0.5)
    self.ax.grid(b=True, axis='x', which='minor', color='green', linestyle='dotted', alpha=0.2)

    self.display(output=self.output, image_name=self.image_name)

  def plot_zonal_section(self, pvar):
    nlev, nlon = pvar.shape

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    lev = np.arange(0.0, float(nlev), 1.0)
   #lev = -lev[::-1]
    dlon = 360.0/nlon
    lon = np.arange(0.0, 360, dlon)

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

   #contfill = self.ax.contourf(lon, lev, pvar, tri=True,
    contfill = self.ax.contourf(lon, -lev[::-1], pvar[::-1,:], tri=True,
                                levels=self.clevs, extend=self.extend,
                                alpha=self.alpha, cmap=self.cmapname)

    cb = self.fig.colorbar(contfill, orientation=self.orientation,
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    major_ticks_top=np.linspace(0,360,13)
    self.ax.set_xticks(major_ticks_top)

    intv = int(1+nlev/10)
   #major_ticks_top=np.linspace(0,nlev,intv)
   #major_ticks_top=np.linspace(0,60,7)
    major_ticks_top=np.linspace(-60,0,7)
    self.ax.set_yticks(major_ticks_top)

    self.ax.grid(b=True, which='major', color='green', linestyle='-', alpha=0.5)

    minor_ticks_top=np.linspace(0,360,37)
    self.ax.set_xticks(minor_ticks_top,minor=True)

    intv = int(1+nlev/5)
   #minor_ticks_top=np.linspace(0,nlev,intv)
   #minor_ticks_top=np.linspace(0,60,13)
    minor_ticks_top=np.linspace(-60,0,13)
    self.ax.set_yticks(minor_ticks_top,minor=True)

    self.ax.grid(b=True, which='minor', color='green', linestyle='dotted', alpha=0.2)

    self.display(output=self.output, image_name=self.image_name)

  def plot_zonal_section_logp(self, pvar):
    nlev, nlon = pvar.shape

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    lev = np.arange(0.0, float(nlev), 1.0)
    dlon = 360.0/nlon
    lon = np.linspace(0.5*dlon, 360.0-0.5*dlon, nlon, endpoint=True)

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    contfill = self.ax.contourf(lon, self.logp[::-1], pvar[::-1,:], tri=True,
                                levels=self.clevs, extend=self.extend,
                                alpha=self.alpha, cmap=self.cmapname)

    cb = self.fig.colorbar(contfill, orientation=self.orientation,
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    major_ticks_top=np.linspace(0,360,13,endpoint=True)
    self.ax.set_xticks(major_ticks_top)

    minor_ticks_top=np.linspace(0,360,37,endpoint=True)
    self.ax.set_xticks(minor_ticks_top,minor=True)
    self.ax.set_xlabel('Longitude')

    self.ax.set_yticks(self.marklogp)
    self.ax.set_ylabel('Unit: hPa')

    yticklabels = []
    for p in self.markpres:
      lbl = '%d' %(int(p+0.1))
      yticklabels.append(lbl)
    self.ax.set_yticklabels(yticklabels)

    self.ax.grid(b=True, which='major', color='green', linestyle='-', alpha=0.5)
    self.ax.grid(b=True, axis='x', which='minor', color='green', linestyle='dotted', alpha=0.2)

    self.display(output=self.output, image_name=self.image_name)

  def plot_coast_lat_lon_line(self):
   #https://matplotlib.org/basemap/users/geography.html
   #map.drawmapboundary(fill_color='aqua')
   #map.fillcontinents(color='#cc9955', lake_color='aqua')
   #map.drawcounties()
   #map.drawstates(color='0.5')

   #draw coastlines
    color = 'black'
    linewidth = 0.5
    self.basemap.drawcoastlines(color=color, linewidth=linewidth)

   #draw parallels
    color = 'green'
    linewidth = 0.5
    fontsize = 8
    dashes = [10, 10]
    circles = np.arange(-90,90,30)
    self.basemap.drawparallels(np.arange(-90,90,30),labels=[1,1,0,1],
                               color=color, linewidth=linewidth,
                               dashes=dashes, fontsize=fontsize)

   #draw meridians
    color = 'green'
    linewidth = 0.5
    fontsize = 8
    dashes = [10, 10]
    meridians = np.arange(0,360,30)
    self.basemap.drawmeridians(np.arange(0,360,30),labels=[1,1,0,1],
                               color=color, linewidth=linewidth,
                               dashes=dashes, fontsize=fontsize)

  def plot_coast_lat_lon_line4hemisphere(self, basemap):
   #https://matplotlib.org/basemap/users/geography.html
   #map.drawmapboundary(fill_color='aqua')
   #map.fillcontinents(color='#cc9955', lake_color='aqua')
   #map.drawcounties()
   #map.drawstates(color='0.5')

   #draw coastlines
    color = 'black'
    linewidth = 0.5
    basemap.drawcoastlines(color=color, linewidth=linewidth)

   #draw parallels
    color = 'green'
    linewidth = 0.5
    fontsize = 8
    dashes = [10, 10]

    if('N' == self.hemisphere):
      circles = np.arange(30,90,15)
    else:
      circles = np.arange(-75,0,15)

    basemap.drawparallels(circles, labels=[1,1,1,1],
                          color=color, linewidth=linewidth,
                          dashes=dashes, fontsize=fontsize)

   #draw meridians
    color = 'green'
    linewidth = 0.5
    fontsize = 8
    dashes = [10, 10]
    meridians = np.arange(0,360,15)
    basemap.drawmeridians(meridians, labels=[1,1,1,1],
                          color=color, linewidth=linewidth,
                          dashes=dashes, fontsize=fontsize)

  def scatter_plot(self, x, y, var, varname, inbound=False):
    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('plot variable min: %s, max: %s' % (np.min(var), np.max(var)))
    print(msg)

   #print('len(var) = ', len(var))

    vm = abs(np.min(var))
    bm = abs(np.max(var))
    if(bm > vm):
      vm = bm
  
    if(vm < 1.0e-6):
      vm = 1.0
    size = np.zeros((len(var)), dtype=float)
    for n in range(len(size)):
      size[n] = 1.0 + 100.0*abs(var[n])/vm

    if(inbound):
      midvar = np.where(var > self.cblevs[0], var, self.cblevs[0])
      sclvar = np.where(midvar < self.cblevs[-1], midvar, self.cblevs[-1])
    else:
      sclvar = var

    print('self.cmapname = ', self.cmapname)
    scatterplot = self.plt.scatter(x, y, s=size, c=sclvar, cmap=self.cmapname, 
                               alpha=self.alpha)

    cb = self.plt.colorbar(orientation=self.orientation, extend='both',
                           pad=self.pad, ticks=self.cblevs, shrink=0.8)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    if(varname == 'surface_pressure'):
      self.plt.xlim((-7, 7))
      self.plt.ylim((-7, 7))
    elif(varname == 'air_temperature'):
      self.plt.xlim((-7, 7))
      self.plt.ylim((-7, 7))
    elif(varname == 'eastward_wind' or varname == 'northward_wind'):
      self.plt.xlim((-10, 10))
      self.plt.ylim((-10, 10))
    elif(varname == 'specific_humidity'):
      self.plt.xlim((-5, 5))
      self.plt.ylim((-5, 5))

    self.plt.xlabel('JEDI_omb', fontsize=14)
    self.plt.ylabel('GSI_omb', fontsize=14)
    self.plt.grid(True)

    ax = self.plt.gca()
    ax.xaxis.set_ticks_position('bottom')
    ax.yaxis.set_ticks_position('left')

    self.display(output=self.output, image_name=self.image_name)

  def scatter_plot2(self, x, y, var, inbound=False, vm=5.0):
    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('plot variable min: %s, max: %s' % (np.min(var), np.max(var)))
    print(msg)

    size = np.zeros((len(var)), dtype=float)
    for n in range(len(size)):
      size[n] = 1.0 + 100.0*abs(var[n])/vm
      if(size[n] > 150.0):
        size[n] = 150.0

    if(inbound):
      midvar = np.where(var > self.cblevs[0], var, self.cblevs[0])
      sclvar = np.where(midvar < self.cblevs[-1], midvar, self.cblevs[-1])
    else:
      sclvar = var

    print('self.cmapname = ', self.cmapname)
    scatterplot = self.plt.scatter(x, y, s=size, c=sclvar, cmap=self.cmapname, 
                               alpha=self.alpha)

    cb = self.plt.colorbar(orientation=self.orientation, extend='both',
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    self.plt.xlim((850.0, 1050))
    self.plt.ylim((850.0, 1050))

    self.plt.xlabel('GSI_HofX', fontsize=14)
    self.plt.ylabel('JEDI_HofX', fontsize=14)
    self.plt.grid(True)

    ax = self.plt.gca()
    ax.xaxis.set_ticks_position('bottom')
    ax.yaxis.set_ticks_position('left')

    self.display(output=self.output, image_name=self.image_name)

  def plot4hemisphere(self, pvar, hemisphere='N'):
    self.basemap = self.build_basemap4stereo_projection(hemisphere=hemisphere)

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('plot variable min: %s, max: %s' % (pvar.min(), pvar.max()))
    print(msg)

    (self.x, self.y) = self.basemap(self.lon1d, self.lat1d)
    v1d = np.reshape(pvar, (pvar.size, ))

    contfill = self.basemap.contourf(self.x, self.y, v1d, tri=True,
                                     levels=self.clevs, extend=self.extend,
                                     alpha=self.alpha, cmap=self.cmapname)

    cb = self.fig.colorbar(contfill, orientation=self.orientation,
                           pad=self.pad, ticks=self.cblevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.ax.set_title(self.title)

    self.plot_coast_lat_lon_line4hemisphere(self.basemap)

    self.display(output=self.output, image_name=self.image_name)

 #https://matplotlib.org/stable/gallery/subplots_axes_and_figures/subplots_demo.html
 #	fig, (ax1, ax2) = plt.subplots(1, 2)
 #	fig.suptitle('Horizontally stacked subplots')
 #	ax1.plot(x, y)
 #	ax2.plot(x, -y)

  def panel2hemispheres(self, pvar):
    msg = ('plot variable min: %s, max: %s' % (pvar.min(), pvar.max()))
    print(msg)

    self.hemisphere = 'N'
    self.projection = 'ortho'

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig, ax = self.plt.subplots(nrows=1, ncols=2)
    self.fig.suptitle(self.title)

    north_map = Basemap(ax=ax[0], projection='ortho', lon_0=-105, lat_0=90, resolution='c')
    south_map = Basemap(ax=ax[1], projection='ortho', lon_0=75, lat_0=-90, resolution='c')

   #north_map = Basemap(ax=ax[0], projection='npstere', boundinglat=0, round=True,
   #                    lon_0=-90, lat_0=90, lat_1=60, lat_2=30, resolution='c')
   #south_map = Basemap(ax=ax[1], projection='spstere', boundinglat=0, round=True,
   #                    lon_0=90, lat_0=-90, lat_1=-60, lat_2=-30, resolution='c')

    v1d = np.reshape(pvar, (pvar.size, ))

    small_val = 1.0e-6
   #mask = np.ma.masked_where(v1d < small_val, v1d)
   #var = v1d.copy()
   #var[mask < small_val] = np.nan
   #var = v1d
    var = np.ma.array(v1d, mask = v1d < small_val)

    (nx, ny) = north_map(self.lon1d, self.lat1d)
    f_n = north_map.contourf(nx, ny, var, tri=True,
                             levels=self.clevs, extend=self.extend,
                             alpha=self.alpha, cmap=self.cmapname)
    self.hemisphere = 'N'
    self.plot_coast_lat_lon_line4hemisphere(north_map)

    (sx, sy) = south_map(self.lon1d, self.lat1d)
    f_s = south_map.contourf(sx, sy, var, tri=True,
                             levels=self.clevs, extend=self.extend,
                             alpha=self.alpha, cmap=self.cmapname)
    self.hemisphere = 'S'
    self.plot_coast_lat_lon_line4hemisphere(south_map)

    cb = self.fig.colorbar(f_s, ax=ax, orientation=self.orientation,
                           pad=self.pad, ticks=self.cblevs, shrink=0.6)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)
    self.set_format(cb)

    self.display(output=self.output, image_name=self.image_name)

  def set_meridional_vector_grid(self, v, w, hor, ver, intv=5):
    nver, nhor = v.shape
    nhb = int(intv/2)
    nvb = int(intv/2)
    mhor = int(nhor/intv)
    mver = int(nver/intv)

    hax = np.zeros((mver, mhor), dtype=float)
    vax = np.zeros((mver, mhor), dtype=float)
    v2d = np.zeros((mver, mhor), dtype=float)
    w2d = np.zeros((mver, mhor), dtype=float)

    for i in range(mver):
      for n in range(mhor):
        vax[i, n] = ver[nvb+i*intv]
    for n in range(mver):
      for i in range(mhor):
        hax[n, i] = hor[nhb+i*intv]
        v2d[n, i] = v[nvb+n*intv, nhb+i*intv]
        w2d[n, i] = 100.0*w[nvb+n*intv, nhb+i*intv]

    hax1d = np.reshape(hax, (hax.size, ))
    vax1d = np.reshape(vax, (vax.size, ))

    v1d = np.reshape(v2d, (v2d.size, ))
    w1d = np.reshape(w2d, (w2d.size, ))

    return hax1d, vax1d, v1d, w1d

  def plot_section_vector(self, v, w, hor, ver, intv=5):
    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('vector v min: %s, max: %s' % (v.min(), v.max()))
    print(msg)
    msg = ('vector w min: %s, max: %s' % (w.min(), w.max()))
    print(msg)

    ver = np.linspace(0.0, float(nver-1), nver)

    hax1d, vax1d, v1d, w1d = self.set_meridional_vector_grid(v, w, hor, ver, intv=intv)

    clevs = np.arange(-100, 105, 5)
    blevs = np.arange(-100, 120, 20)

   #(x, y) = self.basemap(lon1d, lat1d)
    vector = self.plt.quiver(hax1d, vax1d, v1d, w1d, width=0.002,
                             scale=self.scale, scale_units=self.scale_units,
                             alpha=self.alpha, cmap=self.cmapname)
    vectorkey = self.plt.quiverkey(vector, 0.95, 1.02, 20, '20m/s', labelpos='N')

    cb = self.fig.colorbar(vector, orientation=self.orientation,
                           pad=self.pad, ticks=blevs)

    cb.set_label(label=self.label, size=self.size, weight=self.weight)

    cb.ax.tick_params(labelsize=self.labelsize)

    self.ax.set_title(self.title)

    self.display(output=self.output, image_name=self.image_name)

 #----------------------------------------------------------------------------------------------
  def set_section_stream_grid(self, hor, ver):
    mver = len(ver)
    mhor = len(hor)

    h2d = np.zeros((mver, mhor), dtype=float)
    v2d = np.zeros((mver, mhor), dtype=float)

    for k in range(mver):
      for i in range(mhor):
        v2d[k, i] = ver[k]
        h2d[k, i] = hor[i]

    return h2d, v2d

 #----------------------------------------------------------------------------------------------
  def plot_section_stream(self, v, w, hor, ver):
    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

    msg = ('vector v min: %s, max: %s' % (v.min(), v.max()))
    print(msg)
    msg = ('vector w min: %s, max: %s' % (w.min(), w.max()))
    print(msg)

    hor, ver = self.set_section_stream_grid(hor, ver)
    w = 500.0*w

    clevs = np.arange(-100, 105, 5)
    blevs = np.arange(-100, 120, 20)

   #(x, y) = self.basemap(lon, lat)
    stream = self.plt.streamplot(hor, ver, v, w, density=10, linewidth=0.2,
				 arrowsize=1, arrowstyle='-|>',
                                 cmap=self.cmapname)

   #cb = self.fig.colorbar(stream, orientation=self.orientation,
   #                       pad=self.pad, ticks=blevs)
   #cb.set_label(label=self.label, size=self.size, weight=self.weight)
   #cb.ax.tick_params(labelsize=self.labelsize)

    self.ax.set_title(self.title)

    self.display(output=self.output, image_name=self.image_name)

# ----
if __name__ == '__main__':
  debug = 1
  output = 0

  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'output='])

  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--output'):
      output = int(a)
   #else:
   #  assert False, 'unhandled option'

  print('debug = ', debug)
  print('output = ', output)

 #pt = PlotTools(debug=debug, output=output, lat=lat, lon=lon)
 #pt.plot(pvar)

