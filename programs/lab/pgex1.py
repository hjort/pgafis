#!/usr/bin/python

# https://wiki.postgresql.org/wiki/Psycopg2_Tutorial

import psycopg2

try:
    conn = psycopg2.connect("dbname='template1' user='rodrigo' host='localhost' password='dbpass'")
except:
    print "I am unable to connect to the database"

cur = conn.cursor()

cur.execute("""SELECT datname from pg_database""")

rows = cur.fetchall()

print "\nShow me the databases:\n"
for row in rows:
    print "   ", row[0]

cur.close()
conn.close()
