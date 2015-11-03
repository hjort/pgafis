#!/bin/bash

tabela="fvc04"
tempdir="/tmp/pgafis"

PSQL='/usr/local/pgsql/bin/psql afis'

# recriação das estruturas
echo "DROP TABLE IF EXISTS $tabela;
CREATE TABLE $tabela (
  id serial NOT NULL PRIMARY KEY,
  db int2 NOT NULL,
  fp char(5) NOT NULL,
  tif bytea NOT NULL,
  wsq bytea,
  mdt bytea,
  xyt text,
  mins int2,
  nfiq int2
);" | $PSQL -q
rm -rf $tempdir

# TIF
for i in `seq 1 4`
do
	echo "DB_$i ========================================================"
	dbd="$tempdir/db${i}"
	mkdir -p $dbd/tif/ $dbd/hex/
	cp -R db${i}/*.tif $dbd/tif/
	for a in $dbd/tif/*.tif
	do
		b="`basename $a`"
		c="${b/.tif/}"
		d="$dbd/hex/$c.hex"
		echo "$c"
		xxd -p $a | tr -d "\n" > $d
		(echo -ne "$i\t$c\t\\\\\x"; cat $d) | $PSQL -c "COPY $tabela (db, fp, tif) FROM STDIN"
	done
done

# criar chave única
$PSQL -c "ALTER TABLE $tabela ADD UNIQUE (db, fp)"

# WSQ
echo | $PSQL -q << EOF
UPDATE $tabela SET wsq = cwsq(tif, 2.25, 640, 480, 8, null) WHERE db = 1;
UPDATE $tabela SET wsq = cwsq(tif, 2.25, 328, 364, 8, null) WHERE db = 2;
UPDATE $tabela SET wsq = cwsq(tif, 2.25, 300, 480, 8, null) WHERE db = 3;
UPDATE $tabela SET wsq = cwsq(tif, 2.25, 288, 384, 8, null) WHERE db = 4;
EOF

# MDT
$PSQL -c "UPDATE $tabela SET mdt = mindt(wsq, true)"

# XYT
$PSQL -c "UPDATE $tabela SET xyt = mdt2text(mdt)"

# minúcias
$PSQL -c "UPDATE $tabela SET mins = mdt_mins(mdt)"
#$PSQL -c "UPDATE $tabela SET mins = array_length(string_to_array(xyt, E'\n'), 1) WHERE mins IS NULL"

# NFIQ
$PSQL -c "UPDATE $tabela SET nfiq = nfiq(wsq)"

# verificação dos valores
echo "SELECT id, db, fp,
  length(tif) AS tif_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes,
  length(xyt) AS xyt_chars,
  mins,
  nfiq
FROM $tabela
ORDER BY random()
LIMIT 15" | $PSQL -q

# verificação dos valores
echo "SELECT db,
  pg_size_pretty(avg(length(tif))) AS tif,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins))::int AS mins,
  trunc(avg(nfiq))::int AS nfiq
FROM $tabela
GROUP BY db
ORDER BY db" | $PSQL -q

# criar tabela apenas com ids e minúcias
echo "
DROP TABLE IF EXISTS fvc04m;
SELECT id, mdt INTO fvc04m FROM fvc04;
ALTER TABLE fvc04m ADD PRIMARY KEY (id);
" | $PSQL -q

#afis=# \d+
# Schema |      Name      |   Type   |  Owner   |    Size    | Description 
#--------+----------------+----------+----------+------------+-------------
# public | fvc04          | table    | rodrigo  | 43 MB      | 
# public | fvc04m         | table    | rodrigo  | 192 kB     | 

# efetuar deduplicação de toda a base biométrica
echo "
DROP TABLE IF EXISTS fvc04d;
CREATE TABLE fvc04d (
  id int,
  matches int[]
);
" | $PSQL -q

# limiar->tempo: 40->35 min, 60->xx min
time echo "
INSERT INTO fvc04d
SELECT a.id, array_agg(b.id) AS matched_samples
FROM fvc04m a, fvc04m b
WHERE b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 60
GROUP BY a.id;
" | $PSQL -q
$PSQL -c "ALTER TABLE fvc04d ADD PRIMARY KEY (id)"
$PSQL -c "ALTER TABLE fvc04d RENAME TO fvc04d60"

# verificação da eficácia do algoritmo em cada limiar
echo "
SELECT id, db || ':' || fp AS dbfp, mins, nfiq,
  b.matches AS matches_40, array_length(b.matches, 1) AS nmatch_40,
  c.matches AS matches_60, array_length(c.matches, 1) AS nmatch_60
FROM fvc04 a
  NATURAL JOIN fvc04d40 b
  NATURAL JOIN fvc04d60 c
ORDER BY id
LIMIT 25;
" | $PSQL -q

exit 0

