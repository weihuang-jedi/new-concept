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

 cd /work2/noaa/gsienkf/weihuang/gfs

#rm -f data/hl_*.nc

 time python genheightvar.py --debug=0 \
	--datadir=/work2/noaa/gsienkf/weihuang/gfs/data/jan2022 \
        --infile=gfs_4_20220116_1200_000.nc

