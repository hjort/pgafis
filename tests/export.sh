#!/bin/bash

tabela="errors"

PSQL='/usr/local/pgsql/bin/psql afis'

# exclusão de arquivos

# TIF
echo "Extracting TIF..."
c="110_8-db"
d="$c.hex"
e="$c.tif"
$PSQL -c "SELECT encode(tif, 'hex') FROM $tabela" -At | tr -d '\n' > $d
xxd -p -r $d > $e

# WSQ
echo "Extracting WSQ..."
e="$c.wsq"
$PSQL -c "SELECT encode(wsq, 'hex') FROM $tabela" -At | tr -d '\n' > $d
xxd -p -r $d > $e

# XYT
echo "Extracting XYT..."
e="$c.xyt"
$PSQL -c "SELECT xyt FROM $tabela" -At > $e

rm -f *.hex

exit 0

