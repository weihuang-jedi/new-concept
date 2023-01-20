#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=calmfc
#SBATCH --output=log.calmfc

 module load ncl

 set -x

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 year=2022
 month=01
 mname=jan

 datadir=/work2/noaa/gsienkf/weihuang/gfs/data/${mname}${year}

 day=0
 while [ $day -lt 31 ]
 do
   if [ $day -lt 10 ]
   then
     dstr=0${day}
   else
     dstr=${day}
   fi

   for hour in 00 06 12 18
   do
     ifile=gfs_4_${year}${month}${dstr}_${hour}00_000.nc
     ofile=mfc_${year}${month}${dstr}_${hour}.nc

     if [ -f ${datadir}/$ifile ]
     then
 cat > datainfo.txt << EOFB
${datadir}/
${ifile}
${ofile}
EOFB
       ncl cal_mfc_div.ncl
     fi
   done
   day=$(( $day + 1 ))
 done

