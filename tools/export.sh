#!/bin/bash

tabela="fingerprints"
tempdir="/tmp/pgafis"

PSQL='/usr/local/pgsql/bin/psql afis'

# recriação do diretório
rm -rf $tempdir
mkdir -p $tempdir/pgm $tempdir/wsq $tempdir/xyt

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

diff $tempdir/pgm/101_1.pgm ../samples/pgm/101_1.pgm
hd $tempdir/pgm/101_1.pgm | head -15; echo; hd ../samples/pgm/101_1.pgm | head -15

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

diff $tempdir/wsq/101_1.wsq ../samples/wsq/101_1.wsq
hd $tempdir/wsq/101_1.wsq | head -15; echo; hd ../samples/wsq/101_1.wsq | head -15

# 12/09: testes de efetividade do gerador de WSQ/XYT
dpyimage $tempdir/wsq/101_1.wsq &
dpyimage ../samples/wsq/101_1.wsq &
mindtct -b -m1 $tempdir/wsq/101_1.wsq /tmp/pgafis/a
mindtct -b -m1 ../samples/wsq/101_1.wsq /tmp/pgafis/b
ls -la /tmp/pgafis/
for i in brw dm hcm lcm lfm min qm xyt; do echo "[$i]"; diff /tmp/pgafis/a.$i /tmp/pgafis/b.$i; done | less

# MDT
#$PSQL -c "SELECT id, mdt2text(mdt) FROM $tabela ORDER BY id"

# XYT
for a in ../samples/xyt/*.xyt
do
	b="`basename $a`"
	c="${b/.xyt/}"
	d="$tempdir/xyt/$c.xyt"
	echo "$c"
	$PSQL -c "SELECT xyt FROM $tabela WHERE id = '$c'" -At > $d
done
ls -la "$tempdir/xyt"

diff $tempdir/xyt/101_1.xyt ../samples/xyt/101_1.xyt
hd $tempdir/xyt/101_1.xyt | head -15; echo; hd ../samples/xyt/101_1.xyt | head -15

# verificação dos valores
#$PSQL -c "select id, length(pgm) as pgm_bytes, length(wsq) as wsq_bytes, length(mdt) as mdt_bytes from fingerprints limit 5"

exit 0
