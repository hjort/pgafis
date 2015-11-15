#!/bin/bash

for a in 110_4 110_8
do
  b="$a-db"

# TIF
echo "Comparing TIF..."
diff $a*.tif
hd $a.tif | head -5; echo; hd $b.tif | head -5
echo

# WSQ
echo "Comparing WSQ..."
diff $a*.wsq
hd $a.wsq | head -5; echo; hd $b.wsq | head -5
echo

#dpyimage $a.wsq &
#dpyimage $b.wsq &

# XYT
echo "Comparing XYT..."
diff $a*.xyt
hd $a.xyt | head -5; echo; hd $b.xyt | head -5
echo

done

exit 0

