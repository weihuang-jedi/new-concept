#!/bin/bash

 set -x

#for fl in `ls gfs*.png`
#for fl in `ls era5*.png`
 for fl in `ls *.png`
 do
   convert -trim -geometry 1200x900 +repage -border 8 -bordercolor white \
	-background white -flatten $fl trim_$fl
   rm -f $fl
 done

