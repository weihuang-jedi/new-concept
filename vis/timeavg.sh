#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
##SBATCH --partition=orion
#SBATCH --partition=bigmem
#SBATCH --job-name=interp
#SBATCH --output=log.interp

 module load cdo

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/era5/vis

 datadir=/work2/noaa/gsienkf/weihuang/era5/data
#inputfile=${datadir}/hl_dec2021.nc
#outputfile=${datadir}/monthly_mean_hl_dec2021.nc

#cdo timavg ${inputfile} ${outputfile}

 for ifile in dec2021.nc dec2021_surfvar.nc  dec2021_uvq.nc
 do
   inputfile=${datadir}/${ifile}
   outputfile=${datadir}/monthly_mean_${ifile}
   cdo timavg ${inputfile} ${outputfile}
 done

