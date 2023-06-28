#!/bin/sh
#SBATCH -t 05:55:00
#SBATCH -A gsienkf
#SBATCH -N 1
#SBATCH --ntasks-per-node=40
#SBATCH -p bigmem
##SBATCH -p orion
#SBATCH -J gfsmfd
#SBATCH -e gfsmfd.%J.err
#SBATCH -o gfsmfd.%J.out

 module load slurm ncl

 time_start=$(date +%s)

 cd /work2/noaa/gsienkf/weihuang/gfs/vis/vimfd

#rm -f *.png

 for hour in 00 06 12 18
 do
cat > datainfo_${hour}.txt << EOF
png
/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/
monthly_mean_gfs_4_202112_${hour}00_000.nc
monthly_mean_gfs_vimfd_${hour}Z_dec_2021.nc
monthly_mean_gfs_vimfd_${hour}Z_dec_2021
monthly mean GFS VIMFD ${hour}Z Dec 2021
EOF
   sed -e "s/DATAINFO/datainfo_${hour}.txt/g" \
       plot-vimfd.template > plot-vimfd-${hour}.ncl
   ncl plot-vimfd-${hour}.ncl &
 done

 sed -e "s/DATAINFO/datainfo.txt/g" \
     plot-vimfd.template > plot-vimfd.ncl
 ncl plot-vimfd.ncl &

 wait

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

