#!/bin/bash
#SBATCH --ntasks-per-node=1
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 04:45:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=dfc_div
#SBATCH --output=log.dfc_div

#source ~/intelenv

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 module load ncl

 ncl mfc_div.ncl
 ncl dfc_div.ncl

