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

cat > datainfo.txt << EOF
/work2/noaa/gsienkf/weihuang/gfs/data/dec2022/
z_gfs_4_20221201_00.nc
grad_cate_20221201_00.nc
EOF

 ncl compute_grad_catalog.ncl

