#!/bin/bash

dbase="afis"
table="srcafis"

tmpdir="/tmp/pgafis/srcafis"

PSQL="/usr/local/pgsql/bin/psql $dbase"

if [ "$PGHOST" != "" ]; then echo "Considering host: $PGHOST"; fi
if [ "$PGUSER" != "" ]; then echo "Considering user: $PGUSER"; fi

rm -rf $tmpdir

# recriação das estruturas
echo "Recreating fingerprints table..."
echo "DROP TABLE IF EXISTS $table;
CREATE TABLE $table (
  id serial NOT NULL PRIMARY KEY,
  ds varchar(13) NOT NULL, -- dataset (eg: 'FVC2000/DB3_B', 'Neurotech/CM', 'Neurotech/UrU')
  fp char(8) NOT NULL, -- fingerprint id (eg: '013_3_1', '103_1', '999_3_1')
  pid int2, -- person identification
  fid int2, -- finger identification
  whz varchar(12), -- image dimensions (widht x height x depth)
  tif bytea NOT NULL,
  wsq bytea,
  mdt bytea,
  xyt text,
  mins int2,
  nfiq int2
);" | $PSQL -q

# TIFF
echo "Importing TIFF images to database..."
dbd="$tmpdir"
mkdir -p $dbd/tif/ $dbd/hex/
cp -R TestDatabase/* $dbd/tif/
> errors.log
cd $dbd/tif/
for a in `find -type f -name "*.tif"`
do
  b="`basename $a`"
  c="${b/.tif/}"
  d="$dbd/hex/$c.hex"
  ds=$(dirname $a | sed -e 's/^.\///' -e 's/CrossMatch_Sample_DB/CM/' -e 's/UareU_sample_DB/UrU/')
  whz="$(identify -format '%wx%hx%z' $a)" # retrieve image dimensions
  echo "$ds # $c"
  xxd -p $a | tr -d "\n" > $d
  (echo -ne "$ds\t$c\t$whz\t\\\\\x"; cat $d) |\
    $PSQL -c "COPY $table (ds, fp, whz, tif) FROM STDIN" 2>> errors.log
done
cd -

# check whether errors were found
if [ -s errors.log ]
then
  echo "Errors occurred when importing TIFF images!"
  less errors.log
  exit 2
fi

# criar chave única
echo "Creating unique key..."
$PSQL -c "ALTER TABLE $table ADD UNIQUE (ds, fp)"
$PSQL -c "CREATE INDEX ON $table (ds, pid, fid)"

# complementar campos adicionais
echo "Filling additional identifier fields..."
echo | $PSQL -q << EOF
UPDATE $table
SET
  pid = split_part(fp, '_', 1)::int2,
  fid = split_part(fp, '_', 2)::int2
WHERE ds !~ '^FVC';

UPDATE $table
SET
  pid = split_part(fp, '_', 1)::int2,
  fid = 1::int2
WHERE ds ~ '^FVC';
EOF

# WSQ
echo "Converting TIFF images to WSQ format..."
echo | $PSQL -q << EOF
UPDATE $table
SET wsq = cwsq(tif, 2.25,
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

