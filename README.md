pgafis
======

pgAFIS - Automated Fingerprint Identification System Support for PostgreSQL

```
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

```
afis=#
SELECT id, arq, xyt FROM dedos WHERE id in (1, 2);

 id |    arq    |      xyt       
----+-----------+----------------
  1 | 101_1.xyt | 45 62 5 72    +
    |           | 56 280 118 17 +
    |           | 73 71 95 78 ...
  2 | 101_2.xyt | 18 39 5 15    +
    |           | 32 257 118 82 +
    |           | 44 47 95 67 ...
(2 rows)
```

