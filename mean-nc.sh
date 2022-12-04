#!/bin/bash

 datadir=/work2/noaa/gsienkf/weihuang/gfs/data

 module load cdo/1.9.10

 cd ${datadir}

 year=2022
#month=10
 month=01
#month=04
#month=07

 ym=$year$month

 ifiles=`ls gfs_4_*_000.nc`
 ofile=monthly_mean_gfs_4_${ym}_000.nc
 cdo ensmean $ifiles $ofile

 for hour in 00 06 12 18
 do
   ifiles=`ls gfs_4_*_${hour}00_000.nc`
   ofile=monthly_mean_gfs_4_${ym}_${hour}00_000.nc
   cdo ensmean $ifiles $ofile
 done

