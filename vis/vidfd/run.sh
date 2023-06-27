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

 time_start=$(date +%s)

 cd /work2/noaa/gsienkf/weihuang/gfs/vis/vidfd

#rm -f *.png

 for hour in 00Z 06Z 12Z 18Z
 do
cat > datainfo_${hour}.txt << EOF
png
/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/
monthly_mean_gfs_4_202112_${hour}00_000.nc
monthly_mean_gfs_vidfd_${hour}Z_dec_2021.nc
monthly_mean_gfs_vidfd_${hour}Z_dec_2021
monthly mean GFS VIDFD ${hour}Z Dec 2021
EOF
   sed -e "s/DATAINFO/datainfo_${hour}.txt/g" \
       plot-vidfd.template > plot-vidfd-${hour}.ncl
   ncl plot-vidfd-${hour}.ncl &
 done

 sed -e "s/DATAINFO/datainfo.txt/g" \
     plot-vidfd.template > plot-vidfd.ncl
 ncl plot-vidfd.ncl &

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

