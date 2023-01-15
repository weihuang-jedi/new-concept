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

 cd /work2/noaa/gsienkf/weihuang/gfs/data/dec2022

#time python /work2/noaa/gsienkf/weihuang/gfs/genheightvar.py --debug=0 \
#	--datadir=/work2/noaa/gsienkf/weihuang/gfs/data/dec2022 \
#       --infile=monthly_mean_gfs_4_202212.nc

 time python /work2/noaa/gsienkf/weihuang/gfs/genheightvar.py --debug=0 \
	--datadir=/work2/noaa/gsienkf/weihuang/gfs/data/dec2022 \
        --infile=gfs_4_20221216_0000_000.nc

