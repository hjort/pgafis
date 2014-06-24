#!/bin/bash

if [ $# -gt 0 ]
then
  qtd=$1
else
  qtd=10
fi
echo "Quantidade: $qtd"

rm -rf pgm wsq xyt
mkdir pgm wsq xyt

echo
echo "=> Captura das imagens (PGM)..."
#i=1; while [ $i -le $qtd ]; do echo "Enroll #$i"; ./enroll-old && test -f enrolled.pgm && mv enrolled.pgm enroll$i.pgm; let i++; done
./enroll $qtd
#gcc enroll.c -lfprint -o enroll

echo
echo "=> Geração de WSQ..."
whd=$(identify -format '%w,%h,8' enroll1.pgm)
for a in *.pgm; do cwsq 2 wsq $a -r $whd; done
mv *.pgm pgm/

echo
echo "=> Extração de minúcias (XYT)..."
for a in *.wsq; do mindtct -b -m1 $a ${a/.wsq/}; done
mv *.wsq wsq/
rm *.{brw,dm,hcm,lcm,lfm,min,qm}
mv *.xyt xyt/

echo
echo "=> Comparação de cada template com os demais..."
echo
cd xyt/
for a in *.xyt
do
  echo "[${a/.xyt/}]"
  bozorth3 -m1 -T 30 -A outfmt=sg -p $a *.xyt | sort -nr
  echo
done
cd -

