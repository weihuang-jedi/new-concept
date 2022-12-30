#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=interp
#SBATCH --output=log.interp

 module load ncl

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 ncl compute_state_catalog_my.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"' \
	'fili="hl_gfs_4_20220116_0000_000.nc"' \
	'filo="my_state_cate_20220116_00.nc"'

