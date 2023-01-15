#!/bin/bash
#SBATCH --ntasks-per-node=40
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -t 06:00:00
#SBATCH -A gsienkf
#SBATCH --partition=bigmem
#SBATCH --job-name=gradcate
#SBATCH --output=log.gradcate

 module load ncl

 ulimit -S unlimited
 ulimit -c unlimited

 cd /work2/noaa/gsienkf/weihuang/gfs/vis

 cat > datainfo.txt << EOFA
png
/work2/noaa/gsienkf/weihuang/gfs/data/annual/
annual_grad_cate.nc
annual_2022_grad_cate
Annual 2022
EOFA

 ncl plotgradcate-direct.ncl
 ncl plotgradcate-direct-polar.ncl

 mkdir -p images/annual

 for fl in `ls gfs*.png`
 do
   convert -trim -geometry 1200x900 +repage -border 8 -bordercolor white \
        -background white -flatten $fl trim_$fl
   rm -f $fl
 done

 mv trim_*.png images/annual/.

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
       ofile=grad_cate_${ym}.nc
       if [ -f ${datadir}/${ofile} ]
       then
         mkdir -p images/${mname}${year}
 cat > datainfo.txt << EOFB
png
${datadir}/
${ofile}
${mname}_${year}_grad_cate
${mname} ${year}
EOFB
         ncl plotgradcate-direct.ncl
         ncl plotgradcate-direct-polar.ncl

         mkdir -p images/${mname}${year}

         for fl in `ls gfs*.png`
         do
           convert -trim -geometry 1200x900 +repage -border 8 -bordercolor white \
                -background white -flatten $fl trim_$fl
           rm -f $fl
         done

         mv trim_*.png images/${mname}${year}/.
       fi
     fi
   done
 done

