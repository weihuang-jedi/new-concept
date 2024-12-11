#!/bin/sh
#SBATCH -t 05:55:00
#SBATCH -A gsienkf
#SBATCH -N 1
#SBATCH --ntasks-per-node=40
#SBATCH -p bigmem
##SBATCH -p orion
#SBATCH -J gfsdmfc
#SBATCH -e gfsdmfc.%J.err
#SBATCH -o gfsdmfc.%J.out

 module load slurm ncl

 rm -f *.png

 time_start=$(date +%s)

#ncl mfc_div.ncl > log.mfc.out &
#ncl dfc_div.ncl > log.dfc.out &

#wait

 ncl dfc_div.ncl 

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

