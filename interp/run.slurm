#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 04:25:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=getkf
#SBATCH --output=log.tst2

 source ~/gdasenv

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/interp

 make clean
 make
 time interp.exe

