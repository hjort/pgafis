#!/bin/bash

tabela="fvc04"
tempdir="/tmp/pgafis"

PSQL='/usr/local/pgsql/bin/psql afis'

# recriação das estruturas
echo "DROP TABLE IF EXISTS $tabela;
CREATE TABLE $tabela (
  dbid int2,
  fpid char(5),
  tif bytea,
  wsq bytea,
  mdt bytea,
  xyt text,
  mins int2,
  nfiq int2,
  PRIMARY KEY (dbid, fpid)
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
		(echo -ne "$i\t$c\t\\\\\x"; cat $d) | $PSQL -c "COPY $tabela (dbid, fpid, tif) FROM STDIN"
	done
done

# WSQ
echo | $PSQL -q << EOF
UPDATE $tabela SET wsq = cwsq(tif, 2.25, 640, 480, 8, null) WHERE dbid = 1;
UPDATE $tabela SET wsq = cwsq(tif, 2.25, 328, 364, 8, null) WHERE dbid = 2;
UPDATE $tabela SET wsq = cwsq(tif, 2.25, 300, 480, 8, null) WHERE dbid = 3;
UPDATE $tabela SET wsq = cwsq(tif, 2.25, 288, 384, 8, null) WHERE dbid = 4;
EOF

# MDT
$PSQL -c "UPDATE $tabela SET mdt = mindt(wsq, true) WHERE mdt IS NULL"

# XYT
$PSQL -c "UPDATE $tabela SET xyt = mdt2text(mdt) WHERE xyt IS NULL"

# minúcias
$PSQL -c "UPDATE $tabela SET mins = array_length(string_to_array(xyt, E'\n'), 1) WHERE mins IS NULL"

# verificação dos valores
echo "SELECT dbid, fpid,
  length(tif) AS tif_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes,
  length(xyt) AS xyt_chars,
  mins
FROM $tabela
ORDER BY random()
LIMIT 15" | $PSQL -q

# verificação dos valores
echo "SELECT dbid,
  pg_size_pretty(avg(length(tif))) AS tif,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins))::int AS mins
FROM $tabela
GROUP BY dbid
ORDER BY dbid" | $PSQL -q

echo "
drop table if exists fvc04m;
select (dbid || ':' || fpid)::char(7) as id, mdt into fvc04m from fvc04;
alter table fvc04m add primary key (id);
" | $PSQL -q

#afis=# \d+
# Schema |      Name      |   Type   |  Owner   |    Size    | Description 
#--------+----------------+----------+----------+------------+-------------
# public | fvc04          | table    | rodrigo  | 43 MB      | 
# public | fvc04m         | table    | rodrigo  | 192 kB     | 

exit 0
