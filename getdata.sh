#!/bin/bash

#set -x

#website="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-004-0.5-degree/forecast"
 website="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-004-0.5-degree/analysis"
#website="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-003-1.0-degree/analysis"
#website="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-003-1.0-degree/analysis/202008/20200801/gfs_3_20200801_0000_000.grb2

 year=2021
#month=10
#month=01
#month=04
 month=07

 ym=$year$month

 d=0
 while [ $d -lt 31 ]
 do
   d=$((d + 1))
   if [ $d -lt 10 ]
   then
     day=0$d
   else
     day=$d
   fi

   ymd=$ym$day

   for hour in 00 06 12 18
   do
     datadir=$website/$ym/$ymd

    #dataname=$datadir/gfs_3_${ymd}_${hour}00_000.grb2
     dataname=$datadir/gfs_4_${ymd}_${hour}00_000.grb2

     echo "wget $dataname"
     wget $dataname
   done
 done

