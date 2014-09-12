#!/bin/bash

tabela="fingerprints"
tempdir="/tmp/pgafis"

PSQL='/usr/local/pgsql/bin/psql afis'

# recriação das estruturas
$PSQL -c "DROP TABLE IF EXISTS $tabela"
$PSQL -c "CREATE TABLE $tabela (id char(5) primary key, pgm bytea, wsq bytea, mdt bytea)"
rm -rf $tempdir
mkdir -p $tempdir/hex

# PGM
cp -R ../samples/pgm/ $tempdir
for a in $tempdir/pgm/*.pgm
do
	b="`basename $a`"
	c="${b/.pgm/}"
	d="$tempdir/hex/$c.hex"
	echo "$c"
	xxd -p $a | tr -d "\n" > $d
	(echo -ne "$c\t\\\\x"; cat $d) | $PSQL -c "COPY $tabela (id, pgm) FROM STDIN"
done

# WSQ
$PSQL -c "UPDATE $tabela SET wsq = cwsq(pgm, 0.75, 300, 300, 8, null)"

# MDT
$PSQL -c "UPDATE $tabela SET mdt = mindt(wsq, true)"

# verificação dos valores
$PSQL -c "select id, length(pgm) as pgm_bytes, length(wsq) as wsq_bytes, length(mdt) as mdt_bytes from fingerprints limit 5"

exit 0
