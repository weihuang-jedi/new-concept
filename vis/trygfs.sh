#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 04:45:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=era5cate
#SBATCH --output=log.era5cate

 source ~/visenv

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 rm -f trim*.png

 datadir=/work2/noaa/gsienkf/weihuang/gfs/data/dec2021
 infile=gfs_grad_cate_202112-fortran.nc
 level=20

 for level in 80 120 160 200 240 280 320 360 400
 do
   time python tst-plot-gfs-cate.py --debug=0 \
      --datadir=${datadir} \
      --infile=${infile} \
      --level=${level} &
 done

 wait

 exit 0

 for fl in `ls *.png`
 do
   convert -trim -geometry 1200x900 +repage -border 8 -bordercolor white \
	-background white -flatten $fl trim_$fl
   rm -f $fl
 done

 tar cvf ~/era5.tar *.png

