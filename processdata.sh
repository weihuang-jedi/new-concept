#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 04:45:00
#SBATCH -A gsienkf
##SBATCH --partition=orion
#SBATCH --partition=bigmem
#SBATCH --job-name=interp
#SBATCH --output=log.interp

#set -x

 year=2022
 
#----------------------------------------------------------------------------------------------------
 module load cdo/1.9.10
 module load ncl

 ulimit -S unlimited
 ulimit -c unlimited

#monthlist=(01  02  03  04  05  06  07  08  09  10  11  12)
#name_list=(jan feb mar apr may jun jul aug sep oct nov dec)

 monthlist=(02  03  05  06  08  09  11)
 name_list=(feb mar may jun aug sep nov)

 for j in ${!monthlist[@]}
 do
   month=${monthlist[$j]}
   mname=${name_list[$j]}

   dirname=${mname}${year}
   datadir=/work2/noaa/gsienkf/weihuang/gfs/data/${dirname}
  #mkdir -p ${datadir}
   cd ${datadir}

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
       dataname=gfs_4_${ymd}_${hour}00_000
      #rm -f ${dataname}.nc
      #cdo -f nc4 copy ${dataname}.grb2 ${dataname}.nc
       ncl_convert2nc ${dataname}.grb2
       rm -f ${dataname}.grb2
     done
   done

   for hour in 00 06 12 18
   do
     ifiles=`ls gfs_4_*_${hour}00_000.nc`
     ofile=monthly_mean_gfs_4_${ym}_${hour}00_000.nc
     cdo ensmean $ifiles $ofile
   done

   ifiles=`ls monthly_mean*.nc`
   ofile=monthly_mean_gfs_4_${ym}.nc
   cdo ensmean $ifiles $ofile

   time python /work2/noaa/gsienkf/weihuang/gfs/genheightvar.py --debug=0 \
          --datadir=${datadir} \
          --infile=monthly_mean_gfs_4_${ym}_000.nc
 done

 mkdir -p /work2/noaa/gsienkf/weihuang/gfs/data/annual
 cd /work2/noaa/gsienkf/weihuang/gfs/data

 ifiles=`ls */monthly_mean_gfs_4_202[12][01][1234567890]_000.nc`
 ofile=annual_mean_gfs_4_${year}.nc
 cdo ensmean $ifiles $ofile

