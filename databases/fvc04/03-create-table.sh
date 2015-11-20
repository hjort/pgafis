#!/bin/bash

dbase="afis"
table="fvc04"

tmpdir="/tmp/pgafis/fvc04"

PSQL="/usr/local/pgsql/bin/psql $dbase"

if [ "$PGHOST" != "" ]; then echo "Considering host: $PGHOST"; fi
if [ "$PGUSER" != "" ]; then echo "Considering user: $PGUSER"; fi

rm -rf $tmpdir

# recriação das estruturas
echo "Recreating fingerprints table..."
echo "DROP TABLE IF EXISTS $table;
CREATE TABLE $table (
  id serial NOT NULL PRIMARY KEY,
  db int2 NOT NULL,
  fp char(5) NOT NULL,
  pid int2,
  tif bytea NOT NULL,
  wsq bytea,
  mdt bytea,
  xyt text,
  mins int2,
  nfiq int2
);" | $PSQL -q

# TIF
echo "Importing TIFF images to database..."
for i in `seq 1 4`
do
	echo "DB_$i ========================================================"
	dbd="$tmpdir/db${i}"
	mkdir -p $dbd/tif/ $dbd/hex/
	cp -R images/db${i}/*.tif $dbd/tif/
	for a in $dbd/tif/*.tif
	do
		b="`basename $a`"
		c="${b/.tif/}"
		d="$dbd/hex/$c.hex"
		echo "$c"
		xxd -p $a | tr -d "\n" > $d
		(echo -ne "$i\t$c\t\\\\\x"; cat $d) | $PSQL -c "COPY $table (db, fp, tif) FROM STDIN"
	done
done

# complementar campos adicionais
echo "Filling additional identifier fields..."
echo | $PSQL -q << EOF
UPDATE $table
SET pid = split_part(fp, '_', 1)::int2
EOF

# criar chave única
echo "Creating unique key..."
$PSQL -c "ALTER TABLE $table ADD UNIQUE (db, fp)"
$PSQL -c "CREATE INDEX ON $table (db, pid)"

# WSQ
echo "Converting TIFF images to WSQ format..."
echo | $PSQL -q << EOF
UPDATE $table SET wsq = cwsq(tif, 2.25, 640, 480, 8, null) WHERE db = 1;
UPDATE $table SET wsq = cwsq(tif, 2.25, 328, 364, 8, null) WHERE db = 2;
UPDATE $table SET wsq = cwsq(tif, 2.25, 300, 480, 8, null) WHERE db = 3;
UPDATE $table SET wsq = cwsq(tif, 2.25, 288, 384, 8, null) WHERE db = 4;
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

