#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 01:45:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=mean
#SBATCH --output=log.mean

 datadir=/work2/noaa/gsienkf/weihuang/era5/data

 module load cdo/1.9.10

 cd ${datadir}

 ifile=dec2021_surface.nc
 ofile=monthly_mean_dec2021_surface.nc
#cdo monmean $ifile $ofile
 cdo timavg $ifile $ofile
 

