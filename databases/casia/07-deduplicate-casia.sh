#!/bin/bash

dbase="afis"
table="casia"

tmpdir="/tmp/pgafis"

PSQL="/usr/local/pgsql/bin/psql $dbase -h 10.11.70.147 -U afis"
#PSQL="/usr/local/pgsql/bin/psql $dbase"

# check if several arguments were passed
if [ $# -gt 1 ]
then
  echo "Synthax: $0 [nproc]"
  echo "Example: $0 8"
  exit 1
fi

# get number of processes to be spawned
if [ $# -eq 1 ]
then
  procs=$1
else
  procs=1
fi

echo "Running script with $procs process(es)"
inicio=`date`

# create deduplication table
echo "Recreating deduplication results table..."
echo "DROP TABLE IF EXISTS ${table}_d;
CREATE TABLE ${table}_d (
  probe int,
  sample int,
  score int
);
" | $PSQL -q

# loop for each process
for nproc in `seq 1 $procs`
do
  let resto=nproc-1
  #sql="SELECT count(1) FROM ${table} WHERE id % $procs = ${resto}"
  sql="
INSERT INTO ${table}_d
SELECT c.*
FROM (
  SELECT a.id AS probe, b.id AS sample,
    bz_match(a.mdt, b.mdt) AS score
  FROM casia a, casia b
  WHERE a.id % $procs = ${resto} AND a.id != b.id
) c
WHERE score >= 40;
"
  echo "Process $nproc: $sql"
  $PSQL -q -c "$sql" &
done
wait

# create primary key
echo "Creating primary key..."
$PSQL -c "ALTER TABLE ${table}_d ADD PRIMARY KEY (probe, sample)"

echo "Finished!"
termino=`date`

echo
echo "Started at:  $inicio"
echo "Finished at: $termino"

