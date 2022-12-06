#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 04:45:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=interp
#SBATCH --output=log.interp

#source ~/intelenv

 export PYTHONPATH=/work2/noaa/gsienkf/weihuang/gfs/vis/pyspharm/Lib:$PYTHONPATH

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 time python plotlap.py --debug=0

