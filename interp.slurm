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

 cd /work2/noaa/gsienkf/weihuang/gfs/data/annual

 time python /work2/noaa/gsienkf/weihuang/gfs/genheightvar.py --debug=0 \
	--datadir=/work2/noaa/gsienkf/weihuang/gfs/data/annual \
        --infile=annual_mean_gfs_4_2022.nc

