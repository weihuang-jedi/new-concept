#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 04:45:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=gfscate
#SBATCH --output=log.gfscate

 source ~/visenv

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 rm -f trim*.png

 time python tst-plot-gfs-cate.py --debug=0

 exit 0

 for fl in `ls *.png`
 do
   convert -trim -geometry 1200x900 +repage -border 8 -bordercolor white \
	-background white -flatten $fl trim_$fl
   rm -f $fl
 done

 tar cvf ~/era5.tar *.png

