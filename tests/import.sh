#!/bin/bash

tabela="errors"

PSQL='/usr/local/pgsql/bin/psql afis'

# recriação das estruturas
$PSQL -c "
DROP TABLE IF EXISTS $tabela;
CREATE TABLE $tabela (
  id serial not null primary key,
  tif bytea, wsq bytea, mdt bytea, xyt text,
  mins int2, nfiq int2
)"

# TIF
a="110_4.tif"
d="${a/.tif/.hex}"
xxd -p $a | tr -d "\n" > $d
(echo -ne "\\\\\x"; cat $d) | $PSQL -c "COPY $tabela (tif) FROM STDIN"

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
$PSQL -c "SELECT id,
  length(tif) AS tif_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes,
  length(xyt) AS xyt_chars,
  mins, nfiq
FROM $tabela
LIMIT 5"

rm -f *.hex

exit 0

