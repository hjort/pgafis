#!/bin/bash

dbase="afis"

PSQL="/usr/local/pgsql/bin/psql $dbase"

if [ "$PGHOST" != "" ]; then echo "Considering host: $PGHOST"; fi
if [ "$PGUSER" != "" ]; then echo "Considering user: $PGUSER"; fi

echo
for ds in `seq 1 4`
do
  echo "============= DATASET $ds ============="
  for dt in `seq 20 30`
  #for dt in `seq 40 10 80`
  #for dt in 40
  do
    far=`bash 08-getsql-far.sh $ds $dt | $PSQL -tA`
    frr=`bash 08-getsql-frr.sh $ds $dt | $PSQL -tA`
    echo "DT: $dt -> FAR: $far, FRR: $frr"
  done
  echo
done

