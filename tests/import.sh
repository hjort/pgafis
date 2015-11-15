#!/bin/bash

tabela="errors"

PSQL='/usr/local/pgsql/bin/psql afis'

# recriação das estruturas
$PSQL -c "
DROP TABLE IF EXISTS $tabela;
CREATE TABLE $tabela (
  id serial not null primary key,
  fp varchar(10),
  tif bytea, wsq bytea, mdt bytea, xyt text,
  mins int2, nfiq int2
)"

for a in 110_4 110_8
do
  c="$a.tif"
  d="${c/.tif/.hex}"

  # TIF
  xxd -p $c | tr -d "\n" > $d
  (echo -ne "$a\t\\\\\x"; cat $d) | $PSQL -c "COPY $tabela (fp, tif) FROM STDIN"
done

# WSQ
$PSQL -c "UPDATE $tabela SET wsq = cwsq(tif, 2.25, 448, 478, 8, null)"

# MDT
$PSQL -c "UPDATE $tabela SET mdt = mindt(wsq, true)"

# XYT
$PSQL -c "UPDATE $tabela SET xyt = mdt2text(mdt)"

# 
$PSQL -c "UPDATE $tabela SET mins = mdt_mins(mdt)"

# NFIQ
$PSQL -c "UPDATE $tabela SET nfiq = nfiq(mdt)"

# verificação dos valores
$PSQL -c "SELECT id, fp,
  length(tif) AS tif_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes,
  length(xyt) AS xyt_chars,
  mins, nfiq
FROM $tabela
LIMIT 5"

rm -f *.hex

exit 0

