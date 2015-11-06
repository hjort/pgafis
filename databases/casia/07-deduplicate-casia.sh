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
  probe int2,
  sample int2,
  score int2
);
" | $PSQL -q
echo

# retrieve maximum id
maxid=`$PSQL -tA -c "SELECT max(id) FROM ${table}"`

let chunks=procs*2
sid=1
eid=$chunks

# loop for each process
while [ $eid -le $maxid ]
do
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
  WHERE a.id BETWEEN $sid AND $eid
    AND a.id % $procs = ${resto}
    AND b.id > a.id
--limit 5000
) c
WHERE score >= 40;
"
    echo "=> Process $nproc [$sid->$eid]: $sql"
    $PSQL -q -c "$sql" &
  done
  echo -e "[`date`]\n"
  wait
  let sid+=chunks
  let eid+=chunks
done

# create primary key
echo "Creating primary key..."
$PSQL -c "ALTER TABLE ${table}_d ADD PRIMARY KEY (probe, sample)"

echo "Finished!"
termino=`date`

echo
echo "Started at:  $inicio"
echo "Finished at: $termino"

