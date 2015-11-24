#!/bin/bash

dbase="afis"
table="srcafis"

PSQL="/usr/local/pgsql/bin/psql $dbase"

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

if [ "$PGHOST" != "" ]; then echo "Considering host: $PGHOST"; fi
if [ "$PGUSER" != "" ]; then echo "Considering user: $PGUSER"; fi

echo "Running script with $procs process(es)"
inicio=`date`

# decision threshold
DT=20

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
let maxid+=chunks

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
  FROM srcafis_m a, srcafis_m b
  WHERE a.id BETWEEN $sid AND $eid
    AND a.id % $procs = ${resto}
    AND b.id > a.id
) c
WHERE score >= $DT;
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

