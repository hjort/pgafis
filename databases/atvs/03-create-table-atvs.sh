#!/bin/bash

dbase="afis"
table="atvs"

tmpdir="/tmp/pgafis/atvs"

PSQL="/usr/local/pgsql/bin/psql $dbase"

if [ "$PGHOST" != "" ]; then echo "Considering host: $PGHOST"; fi
if [ "$PGUSER" != "" ]; then echo "Considering user: $PGUSER"; fi

rm -rf $tmpdir

# recriação das estruturas
echo "Recreating fingerprints table..."
echo "DROP TABLE IF EXISTS $table;
CREATE TABLE $table (
  id serial NOT NULL PRIMARY KEY,
  fp char(18) NOT NULL, -- fingerprint id: uXX_A_BB_CD_YY (eg: 'ds1_u10_f_fo_rm_04')
  ds int2, -- dataset (1: WithCooperation, 2: WithoutCooperation)
  pid int2, -- number of the user [01 02 03 ... 17]
  of char(1), -- original / fake
  sn char(2), -- capacitive / optical / thermal
  fid char(2), -- right / left hand, middle / index finger
  whz varchar(12), -- image dimensions (widht x height x depth)
  bmp bytea NOT NULL,
  wsq bytea,
  mdt bytea,
  xyt text,
  mins int2,
  nfiq int2
);" | $PSQL -q

# BMP
echo "Importing BMP images to database..."
dbd="$tmpdir"
mkdir -p $dbd/bmp1/ $dbd/bmp2/ $dbd/hex/
find images/DS_WithCooperation/ -type f -name "*.bmp" -exec cp {} $dbd/bmp1/ \;
find images/DS_WithoutCooperation/ -type f -name "*.bmp" -exec cp {} $dbd/bmp2/ \;
> errors.log
for i in 1 2
do
  for a in $dbd/bmp$i/*.bmp
  do
    b="`basename $a`"
    c="${b/.bmp/}"
    c="${c/_fake_/_f_}" # necessary due to erroneus filenames... :P
    c="ds${i}_${c}" # insert DS index (1: WithCooperation, 2: WithoutCooperation)
    d="$dbd/hex/$c.hex"
    whz="$(identify -format '%wx%hx%z' $a)" # retrieve image dimensions
    echo "$c"
    xxd -p $a | tr -d "\n" > $d
    (echo -ne "$c\t$whz\t\\\\\x"; cat $d) | $PSQL -c "COPY $table (fp, whz, bmp) FROM STDIN" 2>> errors.log
  done
done

# check whether errors were found
if [ -s errors.log ]
then
  echo "Errors occurred when importing BMP images!"
  less errors.log
  exit 2
fi

# criar chave única
echo "Creating unique key..."
$PSQL -c "ALTER TABLE $table ADD UNIQUE (fp)"
$PSQL -c "CREATE INDEX ON $table (ds, pid, fid)"

# complementar campos adicionais
echo "Filling additional identifier fields..."
echo | $PSQL -q << EOF
UPDATE $table
SET
  ds = replace(split_part(fp, '_', 1), 'ds', '')::int2,
  pid = replace(split_part(fp, '_', 2), 'u', '')::int2,
  of = split_part(fp, '_', 3)::char,
  sn = split_part(fp, '_', 4)::char(2),
  fid = split_part(fp, '_', 5)::char(2)
EOF

# WSQ
echo "Converting BMP images to WSQ format..."
echo | $PSQL -q << EOF
UPDATE $table
SET wsq = cwsq(bmp, 2.25,
  split_part(whz, 'x', 1)::int,
  split_part(whz, 'x', 2)::int,
  split_part(whz, 'x', 3)::int,
  null);
EOF

# MDT
echo "Extracting features from fingerprints through MINDTCT..."
$PSQL -c "UPDATE $table SET mdt = mindt(wsq, true)"

# XYT
echo "Extracting features in XYT format..."
$PSQL -c "UPDATE $table SET xyt = mdt2text(mdt)"

# minúcias
echo "Counting number of minutiae extracted..."
$PSQL -c "UPDATE $table SET mins = mdt_mins(mdt)"

# NFIQ
echo "Checking quality of WSQ images through NFIQ..."
$PSQL -c "UPDATE $table SET nfiq = nfiq(wsq)"

exit 0

