#!/bin/sh
#SBATCH -t 05:55:00
#SBATCH -A gsienkf
#SBATCH -N 1
#SBATCH --ntasks-per-node=40
#SBATCH -p bigmem
##SBATCH -p orion
#SBATCH -J dmfc
#SBATCH -e dmfc.%J.err
#SBATCH -o dmfc.%J.out

 module load slurm ncl

 rm -f *.png

 time_start=$(date +%s)

 cd /work2/noaa/gsienkf/weihuang/era5/vis/vidfd

 ncl plot-vidfd.ncl

 time_end=$(date +%s)
 echo "ncl elapsed Time: $(($time_end-$time_start)) seconds"

 echo "ncl end:"
 date

 for fl in `ls *.png`
 do
   convert -trim -geometry 1200x900 +repage -border 8 -bordercolor white \
        -background white -flatten $fl trim_$fl
   rm -f $fl
 done

