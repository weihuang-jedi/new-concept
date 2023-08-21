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

 source ~/visenv

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/era5/vis

#time python interp2height.py --debug=0 \
#	--datadir=/work2/noaa/gsienkf/weihuang/era5/data \
#	--upfile=era5_monthly_atm_2022.nc \
#	--sfcfile=era5_monthly_surf_2022.nc \
#	--outfile=era5_monthly_surf_2022.nc

#time python interp2height.py --debug=0 \
#	--datadir=/work2/noaa/gsienkf/weihuang/era5/data \
#	--upfile=monthly-mean-pressure-level.nc \
#	--sfcfile=monthly-mean-surface.nc \
#	--outfile=monthly-mean-height-level.nc

#time python interp2height_uvq+zt.py --debug=0

 time python mm-interp2height.py  --debug=0

