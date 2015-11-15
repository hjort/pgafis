#!/bin/bash

tabela="errors"

PSQL='/usr/local/pgsql/bin/psql afis'

for a in 110_4 110_8
do
  c="$a-db"
  d="$c.hex"

# TIF
echo "Extracting TIF..."
e="$c.tif"
$PSQL -c "SELECT encode(tif, 'hex') FROM $tabela WHERE fp = '$a'" -At | tr -d '\n' > $d
xxd -p -r $d > $e

# WSQ
echo "Extracting WSQ..."
e="$c.wsq"
$PSQL -c "SELECT encode(wsq, 'hex') FROM $tabela WHERE fp = '$a'" -At | tr -d '\n' > $d
xxd -p -r $d > $e

# MDT
echo "Extracting MDT..."
e="$c.mdt"
$PSQL -c "SELECT encode(mdt, 'hex') FROM $tabela WHERE fp = '$a'" -At | tr -d '\n' > $d
xxd -p -r $d > $e

# XYT
echo "Extracting XYT..."
e="$c.xyt"
$PSQL -c "SELECT xyt FROM $tabela WHERE fp = '$a'" -At > $e

rm -f *.hex

ls -la $c*

done

exit 0

