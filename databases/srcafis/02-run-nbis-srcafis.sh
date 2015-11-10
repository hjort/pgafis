#!/bin/bash

if ! which bozorth3
then
  echo "NBIS programs not in shell path"
  exit 1
fi

# diretórios das diversas bases
dirs="Donated1 FVC2000/DB1_B FVC2000/DB2_B FVC2000/DB3_B FVC2000/DB4_B FVC2002/DB1_B FVC2002/DB2_B FVC2002/DB3_B FVC2002/DB4_B FVC2004/DB1_B FVC2004/DB2_B FVC2004/DB3_B FVC2004/DB4_B Neurotech/CrossMatch_Sample_DB Neurotech/UareU_sample_DB"

# verificar tamanho das imagens
for d in $dirs
do
  echo "== $d =="
  identify `find TestDatabase/$d/ -type f -name "*.tif" | head -1`
done

# converter imagens para formato WSQ
echo "Converting TIFF images to WSQ format..."
find TestDatabase/Donated1/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 300,300,8 \;
find TestDatabase/FVC2000/DB1_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 300,300,8 \;
find TestDatabase/FVC2000/DB2_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 256,364,8 \;
find TestDatabase/FVC2000/DB3_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 448,478,8 \;
# workaround 1: resize images to at least 256x256
#find TestDatabase/FVC2000/DB4_B/ -name "*.tif" -exec convert {} -resize 256 {} \;
find TestDatabase/FVC2000/DB4_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 256,341,8 \;
find TestDatabase/FVC2002/DB1_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 388,374,8 \;
find TestDatabase/FVC2002/DB2_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 296,560,8 \;
find TestDatabase/FVC2002/DB3_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 300,300,8 \;
find TestDatabase/FVC2002/DB4_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 288,384,8 \;
find TestDatabase/FVC2004/DB1_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 640,480,8 \;
find TestDatabase/FVC2004/DB2_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 328,364,8 \;
find TestDatabase/FVC2004/DB3_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 300,480,8 \;
find TestDatabase/FVC2004/DB4_B/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 288,384,8 \;
# workaround 2: convert images to PGM and then back to TIFF
#find TestDatabase/Neurotech/CrossMatch_Sample_DB/ -name "*.tif" -exec convert {} {}.pgm \;
#find TestDatabase/Neurotech/CrossMatch_Sample_DB/ -name "*.tif" -exec mv {} {}.bkp \;
#find TestDatabase/Neurotech/CrossMatch_Sample_DB/ -name "*.pgm" -exec convert {} {}.tif \;
find TestDatabase/Neurotech/CrossMatch_Sample_DB/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 504,480,8 \;
# workaround 3: convert images to PGM and then back to TIFF
#find TestDatabase/Neurotech/UareU_sample_DB/ -name "*.tif" -exec convert {} {}.pgm \;
#find TestDatabase/Neurotech/UareU_sample_DB/ -name "*.tif" -exec mv {} {}.bkp \;
#find TestDatabase/Neurotech/UareU_sample_DB/ -name "*.pgm" -exec convert {} {}.tif \;
find TestDatabase/Neurotech/UareU_sample_DB/ -name "*.tif" -exec cwsq 2.25 wsq {} -r 326,357,8 \;

# verificar qualidade
echo "Checking quality of WSQ images through NFIQ..."
for d in $dirs
do
  for a in TestDatabase/$d/*.wsq
  do
    echo "$a:"
    nfiq $a
  done
done

# extrair minúcias
echo "Extracting features from fingerprints through MINDTCT..."
for d in $dirs
do
  for a in TestDatabase/$d/*.wsq
  do
    echo "$a"
    b="${a/.wsq/}"
    mindtct $a $b
  done
done

# executar comparações
echo "Performing fingerprint matches through BOZORTH3..."
for d in $dirs
do
  td="TestDatabase/$d"
  for a in $td/*.xyt
  do
    echo "[$a]"
    bozorth3 -m1 -A outfmt=spg -T 40 -p $a $td/*.xyt
    echo
  done
done

exit 0

