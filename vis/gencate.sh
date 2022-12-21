#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=interp
#SBATCH --output=log.interp

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 output=1
 type=grad
#type=state

#set -x

#python crosssection.py  --output=${output} \
#       --datafile=/work2/noaa/gsienkf/weihuang/gfs/data/annual/annual_${type}_cate.nc \
#       --title="Annual Zonal Mean Atmospheric System Catalog" \
#       --imagename=annual_zonal_mean_cate.png

 monthlist=(01  02  03  04  05  06  07  08  09  10  11  12)
 name_list=(jan feb mar apr may jun jul aug sep oct nov dec)

 for year in 2021 2022
 do
   for j in ${!monthlist[@]}
   do
     month=${monthlist[$j]}
     mname=${name_list[$j]}

     ym=$year$month

     datadir=/work2/noaa/gsienkf/weihuang/gfs/data/${mname}${year}
     if [ -d $datadir ]
     then
       file=${datadir}/${type}_cate_${ym}.nc
       imagename=${mname}_180_cate.png
       mon="$(tr [a-z] [A-Z] <<< "$mname")"
       title=${mon}_Zonal_Mean_Atmospheric_System_Catalog
       python crosssection.py  --output=${output} \
            --datafile=${file} \
            --title=${title} \
            --imagename=${imagename}
     fi
   done
 done

