#!/bin/bash

# workaround 1: resize images to at least 256x256
echo "Resizing TIFF images..."
for a in TestDatabase/FVC2000/DB4_B/*.tif
do
  b="${a/.tif/}"
  cp $a $b.bkp
  convert $a -resize 256 $a
done

# workaround 2: convert images to PGM and then back to TIFF
echo "Converting TIFF images to grayscale..."
for d in CrossMatch_Sample_DB UareU_sample_DB
do
  for a in TestDatabase/Neurotech/$d/*.tif
  do
    b="${a/.tif/}"
    convert $a $b.pgm
    mv $a $b.bkp
    convert $b.pgm $a
  done
done

