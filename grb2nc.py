import os, sys
import glob
import getopt
import xarray as xr
import numpy as np

#-------------------------------------------------------------------------------------------
class Grb2NC():
  def __init__(self, debug=0, outfilename='my.nc'):
    self.debug = debug
    self.outfilename = outfilename

    if(self.debug):
      print('debug = ', debug)
      print('outfilename = ', outfilename)

  def process_file(self, infilename=None):
    if(not os.path.isfile(infilename)):
      print('input file %s does not exist. Stop' %infilename)
      sys.exit(-1)
      
    print('Processing file: ', infilename)

    ds_in=xr.open_dataset(infilename)

    if(self.outfilename is None):
      path, flnm = os.path.split(infilename)
      self.outfilename ='%s/my.nc' %(flnm)

   #output grid
    lon1d=np.arange(0,360,1.0)
    lat1d=np.arange(-90,91,1.0)
    lons,lats=np.meshgrid(lon1d,lat1d)

    da_out_lons=xr.DataArray(lons,dims=['nx','ny'])
    da_out_lats=xr.DataArray(lats,dims=['nx','ny'])
    ds_out_lons=da_out_lons.to_dataset(name='lon')
    ds_out_lats=da_out_lats.to_dataset(name='lat')

    grid_out=xr.merge([ds_out_lons,ds_out_lats])

    ds_in=xr.open_dataset(infilename)
    ds_out=[]
    print('ds_in.keys(): ', ds_in.keys())
    for i in list(ds_in.keys()):
      print('\tWorking on: ', i)
      print('\t\tds_in[i].coords = ', ds_in[i].coords)
      if len(ds_in[i].coords) > 2:
        coords=ds_in[i].coords.to_index()
        print('\tcoords.names = ', coords.names)
        pos='T'
       #print('\t\tcoords.names[:] = ', coords.names[:])

        if coords.names[1] == 'Layer':  # 3-dimensional data
            interp_out= ds_in[i].values
            da_out=xr.DataArray(interp_out,dims=['time','lay','lat','lon'])                    
            da_out.attrs['long_name']=ds_in[i].long_name
            da_out.attrs['units']=ds_in[i].units
            ds_out.append(da_out.to_dataset(name=i))

    ds_out=xr.merge(ds_out)
    ds_out=ds_out.assign_coords(lon=('lon',lon1d))
    ds_out=ds_out.assign_coords(lat=('lat',lat1d))
    ds_out=ds_out.assign_coords(lay=('lay',ds_in.Layer.values))
    ds_out=ds_out.assign_coords(time=('time',ds_in.Time.values))
    ds_out['lon'].attrs['units']='degrees_east'
    ds_out['lon'].attrs['axis']='X'
    ds_out['lon'].attrs['standard_name']='longitude'
    ds_out['lat'].attrs['units']='degrees_north'
    ds_out['lat'].attrs['axis']='Y'
    ds_out['lat'].attrs['standard_name']='latitude'
    ds_out['lay'].attrs['units']='meters'
    ds_out['lay'].attrs['positive']='down'
    ds_out['lay'].attrs['axis']='Z'

    ds_out.to_netcdf(outfilename)
    ds_out.close()

    ds_in.close()

#------------------------------------------------------------------------------------------------------------------------
if __name__ == '__main__':
  debug = 1
  datadir = '/work2/noaa/gsienkf/weihuang/gfs/data/'
  outfilename = 'my.nc'

  opts, args = getopt.getopt(sys.argv[1:], '', ['debug=', 'datadir=', 'outfilename='])

  for o, a in opts:
    if o in ('--debug'):
      debug = int(a)
    elif o in ('--datadir'):
      datadir = a
    elif o in ('--outfilename'):
      outfilename = a
   #else:
   #  assert False, 'unhandled option'

  print('debug = ', debug)
  print('datadir = ', datadir)
  print('outfilename = ', outfilename)

 #open input file to get input grid
 #files=glob.glob('ocn_????_??_??.nc')
  files=glob.glob(datadir + 'gfs_4_????????_??00_000.grb2')
  files.sort()

  print('files = ', files)

  g2n = Grb2NC(debug=debug, outfilename=outfilename)

  for infile in files:
    print('Processing:', infile)

   #g2n.process_file(infilename=infile)
    sys.exit(-1)
