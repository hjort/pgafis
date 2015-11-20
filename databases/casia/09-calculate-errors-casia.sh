#!/bin/bash

dbase="afis"
table="casia"

PSQL="/usr/local/pgsql/bin/psql $dbase"

if [ "$PGHOST" != "" ]; then echo "Considering host: $PGHOST"; fi
if [ "$PGUSER" != "" ]; then echo "Considering user: $PGUSER"; fi

echo
for dt in `seq 40 50`
#for dt in `seq 40 10 80`
#for dt in 40
do
  far=`./09-getsql-far-casia.sh $dt | $PSQL -tA`
  frr=`./09-getsql-frr-casia.sh $dt | $PSQL -tA`
  echo "DT: $dt -> FAR: $far, FRR: $frr"
done
echo

