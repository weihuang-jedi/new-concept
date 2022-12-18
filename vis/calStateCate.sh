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

#ncl compute_state_catalog.ncl \
#   'diri="/work2/noaa/gsienkf/weihuang/gfs/data/annual/"' \
#   'fili="hl_annual_mean_gfs_4_2022.nc"' \
#   'filo="annual_state_cate.nc"'

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
       ofile=state_cate_${ym}.nc
       echo "datadir: $datadir"
       echo ncl compute_state_catalog.ncl \
          "diri=\"${datadir}\"" \
          "fili=\"${ifile}\"" \
          "filo=\"${ofile}\""
     fi
   done
 done


 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"' \
	'fili="hl_monthly_mean_gfs_4_202112.nc"' \
	'filo="state_cate_202112.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"' \
	'fili="hl_monthly_mean_gfs_4_202201.nc"' \
	'filo="state_cate_202201.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/feb2022/"' \
	'fili="hl_monthly_mean_gfs_4_202202.nc"' \
	'filo="state_cate_202202.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/mar2022/"' \
	'fili="hl_monthly_mean_gfs_4_202203.nc"' \
	'filo="state_cate_202203.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/apr2022/"' \
	'fili="hl_monthly_mean_gfs_4_202204.nc"' \
	'filo="state_cate_202204.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/may2022/"' \
	'fili="hl_monthly_mean_gfs_4_202205.nc"' \
	'filo="state_cate_202205.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/jun2022/"' \
	'fili="hl_monthly_mean_gfs_4_202206.nc"' \
	'filo="state_cate_202206.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/jul2022/"' \
	'fili="hl_monthly_mean_gfs_4_202207.nc"' \
	'filo="state_cate_202207.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/aug2022/"' \
	'fili="hl_monthly_mean_gfs_4_202208.nc"' \
	'filo="state_cate_202208.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/sep2022/"' \
	'fili="hl_monthly_mean_gfs_4_202209.nc"' \
	'filo="state_cate_202209.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/oct2022/"' \
	'fili="hl_monthly_mean_gfs_4_202210.nc"' \
	'filo="state_cate_202210.nc"'

 ncl compute_state_catalog.ncl \
	'diri="/work2/noaa/gsienkf/weihuang/gfs/data/nov2022/"' \
	'fili="hl_monthly_mean_gfs_4_202211.nc"' \
	'filo="state_cate_202211.nc"'

