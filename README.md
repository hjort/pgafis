pgafis
======

pgAFIS - Automated Fingerprint Identification System Support for PostgreSQL

![fingers](./samples/fingers.jpg "Sample Fingerprints")

# Sample fingerprints data

```sql
afis=> \d fingerprints
    Table "public.fingerprints"
 Column |     Type     | Modifiers 
--------+--------------+-----------
 id     | character(5) | not null
 pgm    | bytea        | 
 wsq    | bytea        | 
 mdt    | bytea        | 
Indexes:
    "fingerprints_pkey" PRIMARY KEY, btree (id)
```

```sql
afis=>
SELECT id,
  length(pgm) AS raw_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes
FROM fingerprints
LIMIT 5;

  id   | raw_bytes | wsq_bytes | mdt_bytes 
-------+-----------+-----------+-----------
 101_1 |    180029 |      9002 |       329
 101_2 |    180029 |      8808 |       261
 101_3 |    180029 |      8985 |       313
 101_4 |    180029 |      9503 |       365
 101_5 |    180029 |      8857 |       317
(5 rows)
```
- "pgm" stores original raw fingerprint images (PGM)
- "wsq" stores compressed fingerprint images (WSQ)
- "mdt" stores fingerprint templates in XYT format


# Verification (1:1)

```sql
afis=>
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM fingerprints a, fingerprints b
WHERE a.id = '101_1' AND b.id = '101_6';

 match 
-------
 t
(1 row)
```
- given two fingerprints, they can be considered the same according to a stated threshold value (e.g., 40)


# Identification (1:N)

```sql
afis=>
SELECT a.id AS probe, b.id AS sample,
  bz_match(a.mdt, b.mdt) AS match
FROM fingerprints a, fingerprints b
WHERE a.id = '101_1' AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 3;

 probe | sample | match 
-------+--------+-------
 101_1 | 101_3  |    45
 101_1 | 101_4  |    57
 101_1 | 101_6  |    47
(3 rows)
```
- sequential scan is performed on the table, but so far as a given number of templates (e.g., 3) having a match score above the defined threshold (e.g., 40)

