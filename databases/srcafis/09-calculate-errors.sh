#!/bin/bash

dbase="afis"
table="srcafis"

PSQL="/usr/local/pgsql/bin/psql $dbase"

if [ "$PGHOST" != "" ]; then echo "Considering host: $PGHOST"; fi
if [ "$PGUSER" != "" ]; then echo "Considering user: $PGUSER"; fi

# retrieve maximum id
#maxid=`$PSQL -tA -c "SELECT max(id) FROM ${table}"`

DBS="Donated1 FVC2000/DB1_B FVC2000/DB2_B FVC2000/DB3_B FVC2000/DB4_B FVC2002/DB1_B FVC2002/DB2_B FVC2002/DB3_B FVC2002/DB4_B FVC2004/DB1_B FVC2004/DB2_B FVC2004/DB3_B FVC2004/DB4_B Neurotech/CM Neurotech/UrU"

echo
for db in $DBS
#for db in Neurotech/CM
do
  echo "=========== $db ==========="
  for dt in `seq 40 50`
  #for dt in `seq 40 10 80`
  #for dt in 40
  do
    far=`./09-getsql-far.sh $db $dt | $PSQL -tA`
    frr=`./09-getsql-frr.sh $db $dt | $PSQL -tA`
    echo "DT: $dt -> FAR: $far, FRR: $frr"
  done
  echo
done

