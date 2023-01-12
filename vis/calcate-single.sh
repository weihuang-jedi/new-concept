#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=gradcate
#SBATCH --output=log.gradcate

 module load ncl

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

#ncl compute_grad_catalog.ncl \
#   'diri="/work2/noaa/gsienkf/weihuang/gfs/data/dec2022/"' \
#   'fili="hl_monthly_mean_gfs_4_202212.nc"' \
#   'filo="monthly_mean_grad_cate.nc"'

 ncl compute_grad_catalog.ncl \
    'diri="/work2/noaa/gsienkf/weihuang/gfs/data/dec2022/"' \
    'fili="hl_gfs_4_20221216_0000_000.nc"' \
    'filo="grad_gfs_4_20221216_0000_000.nc"'

