#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=interp
#SBATCH --output=log.interp

 module load ncl

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

#ncl compute_grad_catalog.ncl \
#   'diri="/work2/noaa/gsienkf/weihuang/gfs/data/annual/"' \
#   'fili="hl_annual_mean_gfs_4_2022.nc"' \
#   'filo="annual_grad_cate.nc"'

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
       ifile=hl_monthly_mean_gfs_4_${ym}.nc
       ofile=grad_cate_${ym}.nc
       echo "datadir: $datadir"
       ncl compute_grad_catalog.ncl \
          "diri=\"${datadir}\"" \
          "fili=\"${ifile}\"" \
          "filo=\"${ofile}\""
     fi
   done
 done

