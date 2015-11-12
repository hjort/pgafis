#!/bin/bash

dbase="afis"
table="casia"

tmpdir="/tmp/pgafis"

PSQL="/usr/local/pgsql/bin/psql $dbase"

if [ "$PGHOST" != "" ]; then echo "Considering host: $PGHOST"; fi
if [ "$PGUSER" != "" ]; then echo "Considering user: $PGUSER"; fi

rm -rf $tmpdir

# recriação das estruturas
echo "Recreating fingerprints table..."
echo "DROP TABLE IF EXISTS $table;
CREATE TABLE $table (
  id serial NOT NULL PRIMARY KEY,
  fp char(8) NOT NULL,
  pid int2,
  fid char(2),
  bmp bytea NOT NULL,
  wsq bytea,
  mdt bytea,
  xyt text,
  mins int2,
  nfiq int2
);" | $PSQL -q

# BMP
echo "Importing BMP images to database..."
dbd="$tmpdir/casia"
mkdir -p $dbd/bmp/ $dbd/hex/
find images/ -type f -name "*.bmp" -exec cp {} $dbd/bmp/ \;
for a in $dbd/bmp/*.bmp
do
  b="`basename $a`"
  c="${b/.bmp/}"
  d="$dbd/hex/$c.hex"
  echo "$c"
  xxd -p $a | tr -d "\n" > $d
  (echo -ne "$c\t\\\\\x"; cat $d) | $PSQL -c "COPY $table (fp, bmp) FROM STDIN"
done

# criar chave única
echo "Creating unique key..."
$PSQL -c "ALTER TABLE $table ADD UNIQUE (fp)"
$PSQL -c "CREATE INDEX ON $table (pid, fid)"

# complementar campos adicionais
echo "Filling additional identifier fields..."
echo | $PSQL -q << EOF
UPDATE $table
SET
  pid = split_part(fp, '_', 1)::int2,
  fid = split_part(fp, '_', 2)::char(2);
EOF

# WSQ
echo "Converting BMP images to WSQ format..."
echo | $PSQL -q << EOF
UPDATE $table SET wsq = cwsq(bmp, 2.25, 328, 356, 8, null);
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

