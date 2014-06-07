#!/bin/bash

export PGHOME=/usr/local/pgsql/bin
export PGPORT=5432
export PGHOST=localhost

psql afis -c "
DROP TABLE IF EXISTS dedos;
CREATE TABLE dedos (
  id serial not null primary key,
  arq varchar not null,
  xyt text
);"

cd ../samples/xyt
for arq in *.xyt
do
  psql afis -c "INSERT INTO dedos (arq, xyt) VALUES ('$arq', '`cat $arq`')"
done
cd -

