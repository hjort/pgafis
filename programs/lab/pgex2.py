#!/usr/bin/python

# https://wiki.postgresql.org/wiki/Psycopg2_Tutorial

# load the adapter
import psycopg2

# load the psycopg extras module
import psycopg2.extras

try:
    conn = psycopg2.connect("dbname='template1' user='rodrigo' host='localhost' password='dbpass'")
except:
    print "I am unable to connect to the database"

# If we are accessing the rows via column name instead of position we 
# need to add the arguments to conn.cursor.
cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
#cur = conn.cursor()

cur.execute("""SELECT datname from pg_database""")

# Note that below we are accessing the row via the column name.
print "\nShow me the databases:\n"
rows = cur.fetchall()
for row in rows:
    print "   ", row['datname']

cur.close()
conn.close()
