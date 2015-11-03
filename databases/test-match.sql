-- Verification (1:1)

SELECT (bz_match(a.mdt, b.mdt) >= 20) AS match
FROM fvc04 a, fvc04 b
WHERE a.dbid = 1 AND a.fpid = '101_1'
  AND b.dbid = 1 AND b.fpid = '101_6';

/*
 match 
-------
 t
(1 row)
*/

SELECT score, (score >= 40) AS match
FROM (
  SELECT bz_match(a.mdt, b.mdt) AS score
  FROM fvc04m a, fvc04m b
  WHERE a.id = '3:101_1' AND b.id = '3:101_2'
) a;

/*
 score | match 
-------+-------
   103 | t
(1 row)
*/

-- faster 1:1
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM fvc04m a, fvc04m b
WHERE a.id = '3:101_1' AND b.id = '3:101_2';

-- =========================================================

-- Identification (1:N)

SELECT a.fpid AS probe, b.fpid AS sample,
  bz_match(a.mdt, b.mdt) AS match
FROM fvc04 a, fvc04 b
WHERE a.dbid = 1 AND a.fpid = '101_1'
  AND NOT (b.dbid = a.dbid AND b.fpid = a.fpid)
  AND bz_match(a.mdt, b.mdt) >= 40
ORDER BY match DESC
LIMIT 5;

/*
 probe | sample | match 
-------+--------+-------
 101_1 | 101_2  |   103
 101_1 | 101_4  |    80
 101_1 | 101_7  |    49
 101_1 | 101_6  |    48
 101_1 | 101_5  |    41
(5 rows)
*/

SELECT a.id AS probe, b.id AS sample,
  bz_match(a.mdt, b.mdt) AS match
FROM fvc04m a, fvc04m b
WHERE a.id = '3:101_1'
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
ORDER BY match DESC
LIMIT 5;

/*
  probe  | sample  | match 
---------+---------+-------
 3:101_1 | 3:101_5 |   105
 3:101_1 | 3:101_2 |   103
 3:101_1 | 3:101_3 |    93
 3:101_1 | 3:101_4 |    71
 3:101_1 | 3:101_7 |    46
(5 rows)
*/

-- faster 1:N
SELECT b.id AS matched_sample
FROM fvc04m a, fvc04m b
WHERE a.id = '3:101_1'
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 3;

SELECT array_agg(b.id) AS matched_samples
FROM fvc04m a, fvc04m b
WHERE a.id = '3:109_1'
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40;

-- =========================================================

SELECT dbid,
  pg_size_pretty(avg(length(tif))) AS tif,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins))::int AS mins
FROM fvc04
GROUP BY dbid
ORDER BY dbid;

/*
 dbid |  tif   |  wsq  |    mdt    |    xyt     | mins 
------+--------+-------+-----------+------------+------
    1 | 301 kB | 32 kB | 436 bytes | 757 bytes  |   54
    2 | 117 kB | 31 kB | 411 bytes | 700 bytes  |   51
    3 | 141 kB | 30 kB | 732 bytes | 1258 bytes |   91
    4 | 109 kB | 26 kB | 473 bytes | 803 bytes  |   58
(4 rows)
*/

