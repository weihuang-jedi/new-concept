#!/bin/bash

 set -x

 for fl in `ls state*.png`
 do
   convert -trim -geometry 1200x900 +repage -border 8 -bordercolor white \
	-background white -flatten $fl trim_$fl
   rm -f $fl
 done

