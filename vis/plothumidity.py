# =========================================================================

import os
import sys
import yaml
import types
import getopt
import pygrib

import numpy as np
import matplotlib
import matplotlib.pyplot

#from matplotlib import cm
from mpl_toolkits.basemap import Basemap

class PlotOnMap():
  def __init__(self, debug=0, datafile=None, output=0):
    self.debug = debug
    self.datafile = datafile
    self.output = output

    if(self.debug):
      print('debug = ', debug)
      print('output = ', output)
      print('datafile = ', datafile)
 
  def build_basemap(self):
    basemap_dict = {'resolution': 'c', 'projection': 'cyl',
                    'llcrnrlat': -90.0, 'llcrnrlon': 0.0,
                    'urcrnrlat':  90.0, 'urcrnrlon': 360.0}
    basemap_dict['lat_0'] = 0.0
    basemap_dict['lon_0'] = 180.0

    basemap = Basemap(**basemap_dict)

    return basemap

  def create_image(self, plt_obj, savename):
    dirname = os.path.dirname(savename)
    if dirname != '' and not os.path.isdir(dirname):
      msg = ('Path %s does not exist; an attempt will be made to '
           'create it.' % dirname)
      os.mkdir(dirname)
    msg = ('Saving image as %s.' % savename)
    print(msg)
    kwargs = {'transparent': True, 'dpi': 500}
    plt_obj.savefig(savename, **kwargs)

  def display(self, output=False, image_name='unknown'):
    if(output):
      self.plt.tight_layout()
      kwargs = {'plt_obj': self.plt, 'savename': image_name}
      self.create_image(**kwargs)
    else:
      self.plt.show()

  def plots(self, pvar, title=''):
    self.basemap = self.build_basemap()

    self.plt = matplotlib.pyplot
    try:
      self.plt.close('all')
      self.plt.clf()
    except Exception:
      pass

    self.fig = self.plt.figure()
    self.ax = self.plt.subplot()

   #for this dataset, longitude is 0 through 360, so you need to subtract 180 to properly display on map
   #lons, lats= np.meshgrid(self.lons, self.lats)

   #(x, y) = self.basemap(self.lons, self.lats)

    x1d = self.lons.flatten()
    y1d = self.lats.flatten()
    v1d = pvar.flatten()

    extend = 'both'
    alpha = 0.5

    contfill = self.basemap.contourf(x1d, y1d, v1d, tri=True,
                                     levels=self.clevs, extend=extend,
                                     cmap=self.cmapname)

    pad = 0.1
    orientation = 'horizontal'
    cb = self.fig.colorbar(contfill, orientation=orientation, pad=pad, ticks=self.clevs)

    size = 'large'
    label = 'SLP (hPa)'
    weight = 'bold'
    cb.set_label(label=label, size=size, weight=weight)

    labelsize = 'medium'
    cb.ax.tick_params(labelsize=labelsize)
    cb.ax.set_xticklabels(self.clevs, minor=False)

    self.ax.set_title(title)

    self.plot_coast_lat_lon_line()

  def plot_coast_lat_lon_line(self):
    color = 'green'
    linewidth = 0.2
    self.basemap.drawcoastlines(color=color, linewidth=linewidth)

   #draw parallels
    color = 'black'
    linewidth = 0.1
    fontsize = 8
    dashes = [10, 10]
    labels = [1,1,0,1]
    circles = np.arange(-90,90,30)
    self.basemap.drawparallels(circles,labels=labels,
                               color=color, linewidth=linewidth,
                               dashes=dashes, fontsize=fontsize)

   #draw meridians
    meridians = np.arange(0,360,30)
    self.basemap.drawmeridians(meridians,labels=labels,
                               color=color, linewidth=linewidth,
                               dashes=dashes, fontsize=fontsize)

  def get_q(self, RH, T, p):
    es = 611.2*np.exp(17.67*(T-273.15)/(T-29.65))
    rvs = 0.622*es/(p - es)
    rv = RH/100. * rvs
    qv = rv/(1 + rv)
    return qv

  def get_pdfq(self, temp, qv, p):
   #r = 286.9
   #rho = p/(r*temp)
   #rho_ref = rho * (1 + 1.609 * qv) / (1 + qv)
    pq = 0.609 * p * qv / (1.0 + qv)

    return pq

  def run(self):
    grbs=pygrib.open(self.datafile)

   #print('grbs:', grbs)
   #for grb in grbs:
   #  print('grb:', grb)

   #varname = 'Specific humidity'
   #grb = grbs.select(name=varname)[0]
   #data=grb.values
   #lat,lon = grb.latlons()

    varname = 'Relative humidity'

   #grb = grbs.select(name=varname, typeOfLevel='isobaricInhPa', level='1000')
   #grb = grbs.select(name=varname, level=lambda l: l < 500 and l >= 300)
    grb = grbs.select(name=varname, level=1000)[0]
   #print('grb:', grb)
    rh = grb.values
    self.lats, self.lons = grb.latlons()

   #print('self.lats = ', self.lats)
   #print('self.lons = ', self.lons)

    varname = 'Temperature'
    grb = grbs.select(name=varname, level=1000)[0]
    temp = grb.values
    pres = 100000.0
    qv = self.get_q(rh, temp, pres)

    #msg = grb.tostring()
    #print('msg:', msg)

    grbs.close()

    if(self.debug):
      msg = ('range for qv: (%s, %s).' % (qv.min(), qv.max()))
      print(msg)

   #coolwarm, bwr, rainbow, jet, seismic
    self.cmapname = 'jet'
    self.clevs = [0.0, 0.001, 0.002, 0.005, 0.0075, 0.01, 0.012, 0.014, 0.016, 0.018, 0.02]

    image_name = 'specific_humidity'
    self.plots(qv, title='Specific Humidity at 1000 hPa')
    self.display(output=self.output, image_name=image_name)

    pq = 0.01 * self.get_pdfq(temp, qv, pres)
   #self.clevs = [0.0, 1.0, 2.0, 5.0, 7.5, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 18.0, 20.0]
   #self.clevs = np.arange(0.0, 15.5, 0.5)
    self.clevs = np.arange(0.0, 10.5, 0.5)

    image_name = 'humidity_pressure'
    self.plots(pq, title='Humidity Pressure at 1000 hPa')
    self.display(output=self.output, image_name=image_name)

# ----
if __name__ == '__main__':
  debug = 11
  output = 0
  datafile = 'data/gfs_4_20211001_0000_000.grb2'

  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'output=', 'datafile='])

  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--output'):
      output = int(a)
    elif o in ('--datafile'):
      datafile = a
   #else:
   #  assert False, 'unhandled option'

 #print('opts = ', opts)
 #print('args = ', args)
  print('debug = ', debug)
  print('output = ', output)
  print('datafile = ', datafile)

  pom = PlotOnMap(debug=debug, output=output, datafile=datafile)
  pom.run()

