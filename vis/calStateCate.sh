#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
#SBATCH --partition=orion
#SBATCH --job-name=statecate
#SBATCH --output=log.statecate

 module load ncl

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/era5/vis

#ncl compute_state_catalog.ncl \
#	'diri="/work2/noaa/gsienkf/weihuang/era5/data/"' \
#	'fili="hl_monthly_mean_uvtp.nc"' \
#	'filo="state_cate_202112.nc"'

 ncl compute_state_daily_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/era5/data/"' \
	'fili="hl_uvtp.nc"' \
	'filo="daily_cate.nc"'

