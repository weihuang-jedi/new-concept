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

 datadir=/work2/noaa/gsienkf/weihuang/gfs/data

#module load cdo/1.9.10
 module load ncl

 year=2022
#month=01
#month=04
 month=07
#month=10

 cd ${datadir}/jul2022

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
     echo "Processing ${dataname}"
     rm -f ${dataname}.nc
    #cdo -f nc4 copy ${dataname}.grb2 ${dataname}.nc
     ncl_convert2nc ${dataname}.grb2
     rm -f ${dataname}.grb2
   done
 done

