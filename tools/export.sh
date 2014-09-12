#!/bin/bash

tabela="fingerprints"
tempdir="/tmp/pgafis"

PSQL='/usr/local/pgsql/bin/psql afis'

# recriação do diretório
rm -rf $tempdir
mkdir -p $tempdir/pgm $tempdir/wsq

# PGM
for a in ../samples/pgm/*.pgm
do
	b="`basename $a`"
	c="${b/.pgm/}"
	d="$tempdir/pgm/$c.hex"
	e="$tempdir/pgm/$c.pgm"
	echo "$c"
	$PSQL -c "SELECT encode(pgm, 'hex') FROM $tabela WHERE id = '$c'" -At | tr -d '\n' > $d
	xxd -p -r $d > $e
done
ls -la "$tempdir/pgm"

# WSQ
for a in ../samples/wsq/*.wsq
do
	b="`basename $a`"
	c="${b/.wsq/}"
	d="$tempdir/wsq/$c.hex"
	e="$tempdir/wsq/$c.wsq"
	echo "$c"
	$PSQL -c "SELECT encode(wsq, 'hex') FROM $tabela WHERE id = '$c'" -At | tr -d '\n' > $d
	xxd -p -r $d > $e
done
ls -la "$tempdir/wsq"

#hd /tmp/pgafis/wsq/101_1.wsq | head -15; echo; hd ../samples/wsq/101_1.wsq | head -15
#diff /tmp/pgafis/wsq/101_1.wsq ../samples/wsq/101_1.wsq

exit 0

# MDT
$PSQL -c "SELECT id, mdt2text(mdt) FROM $tabela ORDER BY id"

# verificação dos valores
#$PSQL -c "select id, length(pgm) as pgm_bytes, length(wsq) as wsq_bytes, length(mdt) as mdt_bytes from fingerprints limit 5"

exit 0
