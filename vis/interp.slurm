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

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/era5/vis

#time python interp2height.py --debug=0 \
#	--datadir=/work2/noaa/gsienkf/weihuang/era5/data \
#       --upfile=dec2021.nc \
#       --uvfile=dec2021_uvq.nc \
#       --sfcfile=dec2021_surfvar.nc

 time python interp2height.py --debug=0 \
	--datadir=/work2/noaa/gsienkf/weihuang/era5/daily-data \
	--upfile=2022dec15-00.nc \
	--uvfile=2022dec15-00.nc \
	--sfcfile=2022dec15-00_sfcdata.nc

