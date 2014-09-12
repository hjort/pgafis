#!/bin/bash

alias PSQL='/usr/local/pgsql/bin/psql afis'

PSQL -c "CREATE TABLE fingers (id serial primary key, pgm bytea, wsq bytea)"

# reset values
PSQL -c "TRUNCATE fingers"
rm -f /tmp/101_6*

# PGM
cp ../samples/pgm/101_6.pgm /tmp/
xxd -p /tmp/101_6.pgm | tr -d "\n" > /tmp/101_6p.hex

(echo -n "\\\\x"; cat /tmp/101_6p.hex) | PSQL -c "COPY fingers (pgm) FROM STDIN"

PSQL -c "SELECT encode(pgm, 'hex') FROM fingers LIMIT 1" -At | tr -d '\n' > /tmp/101_6p2.hex
xxd -p -r /tmp/101_6p2.hex > /tmp/101_6p2.pgm

diff /tmp/101_6p.hex /tmp/101_6p2.hex
diff /tmp/101_6.pgm /tmp/101_6p2.pgm

# WSQ
cwsq 0.75 wsq ../samples/pgm/101_6.pgm -r 300,300,8
mv ../samples/pgm/101_6.wsq /tmp/
xxd -p /tmp/101_6.wsq | tr -d "\n" > /tmp/101_6w.hex

PSQL -c "UPDATE fingers SET wsq = cwsq(pgm, 0.75, 300, 300, 8, null)"

PSQL -c "SELECT encode(wsq, 'hex') FROM fingers LIMIT 1" -At | tr -d '\n' > /tmp/101_6w2.hex
xxd -p -r /tmp/101_6w2.hex > /tmp/101_6w2.wsq

diff /tmp/101_6w.hex /tmp/101_6w2.hex
diff /tmp/101_6.wsq /tmp/101_6w2.wsq

# check created output
ll /tmp/101_6*
file /tmp/101*

PSQL -c "SELECT length(pgm) AS pgm_bytes, length(wsq) AS wsq_bytes FROM fingers"

# pgm_bytes | wsq_bytes 
#-----------+-----------
#     90015 |      9189

for a in /tmp/101*.wsq; do echo $a; hd -n 200 $a; done
for a in /tmp/101*.wsq; do echo $a; hd $a | tail; done

qiv /tmp/101*.pgm
dpyimage /tmp/101*.wsq

