pgafis
======

pgAFIS - Automated Fingerprint Identification System Support for PostgreSQL

![fingers](./samples/fingers.jpg "Sample Fingerprints")

# Sample fingerprints data

```sql
afis=#
SELECT id, arq, xyt FROM dedos;

 id |    arq    |      xyt       
----+-----------+----------------
  1 | 101_1.xyt | 45 62 5 72    +
    |           | 56 280 118 17 +
    |           | 73 71 95 78 ...
  2 | 101_2.xyt | 18 39 5 15    +
    |           | 32 257 118 82 +
    |           | 44 47 95 67 ...
(...)
```
- "xyt" column holds fingerprint templates in XYT format


# Verification (1:1)

```sql
afis=#
SELECT (bz_match(a.xyt, b.xyt) >= 30) AS match
FROM dedos a, dedos b
WHERE a.id = 1 AND b.id = 6;

 match 
-------
 t
(1 row)
```
- given two fingerprints, they can be considered the same according to a stated threshold value (e.g., 30)


# Identification (1:N)

```sql
afis=#
SELECT a.arq AS arq1, b.arq AS arq2,
  bz_match(a.xyt, b.xyt) AS match
FROM dedos a, dedos b
WHERE a.id = 1
  AND bz_match(a.xyt, b.xyt) > 20
ORDER BY match DESC;

   arq1    |   arq2    | match 
-----------+-----------+-------
 101_1.xyt | 101_1.xyt |   144
 101_1.xyt | 101_6.xyt |    40
 101_1.xyt | 101_8.xyt |    37
 101_1.xyt | 101_2.xyt |    24
(4 rows)
```
- entire table is read (sequential scan is made)

```sql
afis=#
SELECT id, arq, score
FROM match_dedos((SELECT xyt FROM dedos WHERE id = 1), 30, 3)
ORDER BY score DESC;

 id |    arq    | score 
----+-----------+-------
  1 | 101_1.xyt |   144
  6 | 101_6.xyt |    38
  3 | 101_3.xyt |    32
(3 rows)
```
- loop is made so far as reached a given number of templates (e.g, 3) above the defined threshold (e.g, 30)
