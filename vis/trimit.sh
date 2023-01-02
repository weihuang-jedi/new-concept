#!/bin/bash

 set -x

 for fl in `ls gfs_grad*.png`
 do
   convert -trim -geometry 2500x2500 +repage -border 8 -bordercolor white \
	-background white -flatten $fl trimed_$fl
   rm -f $fl
 done

