#!/bin/bash

#set -x

 website="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-004-0.5-degree/forecast"
#website="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-004-0.5-degree/analysis"
#website="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-003-1.0-degree/analysis"
#website="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-003-1.0-degree/analysis/202008/20200801/gfs_3_20200801_0000_000.grb2

 year=2022
 fcst=24

#monthlist=(01  02  03  04  05  06  07  08  09  10  11  12)
#name_list=(jan feb mar apr may jun jul aug sep oct nov dec)

 monthlist=(12)
 name_list=(dec)

 for j in ${!monthlist[@]}
 do
   month=${monthlist[$j]}
   mname=${name_list[$j]}

   ym=$year$month

   workdir=/work2/noaa/gsienkf/weihuang/gfs-fcst/data/${mname}${year}
   mkdir -p ${workdir}
   cd ${workdir}

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
       srcdir=$website/$ym/$ymd

       srcname=$srcdir/gfs_4_${ymd}_${hour}00_0${fcst}.grb2

       echo "wget $srcname"
       wget $srcname
     done
   done
 done

