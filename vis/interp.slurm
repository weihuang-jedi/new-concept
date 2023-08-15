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

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 time python gfs-interp2height.py  --debug=0

