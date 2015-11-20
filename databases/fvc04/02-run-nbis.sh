#!/bin/bash

if ! which bozorth3
then
  echo "NBIS programs not in shell path"
  exit 1
fi

# verificar tamanho das imagens
#$ identify db1/101_1.tif
#db1/101_1.tif TIFF 640x480 640x480+0+0 8-bit Grayscale DirectClass 308KB 0.000u 0:00.009
#$ identify db2/101_1.tif
#db2/101_1.tif TIFF 328x364 328x364+0+0 8-bit Grayscale DirectClass 120KB 0.000u 0:00.000
#$ identify db3/101_1.tif
#db3/101_1.tif TIFF 300x480 300x480+0+0 8-bit Grayscale DirectClass 145KB 0.000u 0:00.000
#$ identify db4/101_1.tif
#db4/101_1.tif TIFF 288x384 288x384+0+0 8-bit Grayscale DirectClass 111KB 0.000u 0:00.000

# converter imagens para formato WSQ
echo "Converting TIFF images to WSQ format..."
find images/db1/ -name "*.tif" -exec cwsq .75 wsq {} -r 640,480,8 \;
find images/db2/ -name "*.tif" -exec cwsq .75 wsq {} -r 328,364,8 \;
find images/db3/ -name "*.tif" -exec cwsq .75 wsq {} -r 300,480,8 \;
find images/db4/ -name "*.tif" -exec cwsq .75 wsq {} -r 288,384,8 \;

# verificar qualidade
echo "Checking quality of WSQ images through NFIQ..."
for i in `seq 1 4`
do
  for a in images/db$i/*.wsq
  do
    echo "$a"
    nfiq $a
  done
done

# extrair minúcias
echo "Extracting features from fingerprints through MINDTCT..."
for i in `seq 1 4`
do
  for a in images/db$i/*.wsq
  do
    echo "$a"
    b="${a/.wsq/}"
    mindtct $a $b
  done
done

# executar comparações
echo "Performing fingerprint matches through BOZORTH3..."
for i in `seq 1 4`
do
  for a in images/db$i/*.xyt
  do
    echo "[$a]"
    bozorth3 -m1 -A outfmt=spg -T 40 -p $a db$i/*.xyt
    echo
  done
done

exit 0

