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

#source ~/intelenv

 ulimit -S unlimited
 ulimit -c unlimited

 topdir=/work2/noaa/gsienkf/weihuang/gfs-fcst
 datadir=${topdir}/data/dec2022

 time python ${topdir}/genheightvar.py --debug=0 \
	--datadir=${datadir} \
        --infile=monthly_mean_gfs_4_202212.nc

