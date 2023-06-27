#!/bin/sh
#SBATCH -t 05:55:00
#SBATCH -A gsienkf
#SBATCH -N 1
#SBATCH --ntasks-per-node=40
##SBATCH -p bigmem
#SBATCH -p orion
#SBATCH -J plotvidfd
#SBATCH -e log.%J.err
#SBATCH -o log.%J.out

 module load slurm

 source ~/visenv

#rm -f *.png

 time_start=$(date +%s)

 cd /work2/noaa/gsienkf/weihuang/era5/vis/vidfd

 baselist=(00 06 12 18)
 hourlist=(06 12 18 00)
 #get length of an array
 hourlength=${#hourlist[@]}

 #use for loop to read all values and indexes
 for (( i=0; i<${hourlength}; i++ ))
 do
   base=${baselist[$i]}
   hour=${hourlist[$i]}

   python plotpvar.py \
     --datadir=/work2/noaa/gsienkf/weihuang/era5/vis/vidfd/data \
     --flnm=monthly_mean_ERA5_VIDFD_${hour}Z_Dec_2021.nc &

   python plotdiff.py \
     --datadir=/work2/noaa/gsienkf/weihuang/era5/vis/vidfd/data \
     --base=monthly_mean_ERA5_VIDFD_${base}Z_Dec_2021.nc \
     --flnm=monthly_mean_ERA5_VIDFD_${hour}Z_Dec_2021.nc \
     --imgname=monthly_mean_ERA5_VIDFD_${hour}Z-${base}Z_Dec_2021 &
 done

 wait

 time_end=$(date +%s)
 echo "python elapsed Time: $(($time_end-$time_start)) seconds"

