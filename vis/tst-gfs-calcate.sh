#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
##SBATCH --partition=orion
#SBATCH --partition=bigmem
#SBATCH --job-name=calcate
#SBATCH --output=log.calcate

 module load ncl

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 ncl tst-gfs-compute_grad_catalog.ncl \
 	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"' \
 	'fili="monthly_mean_gfs_4_202112-height-level-fortran.nc"' \
 	'filo="gfs_grad_cate_202112-fortran.nc"'

