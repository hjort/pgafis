\timing on

-- matching threshold set to: 40

-- =========================================================

-- Verification (1:1)

-- single logical answer for matching
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM srcafis a, srcafis b
WHERE a.ds = 'FVC2000/DB2_B' AND a.fp = '109_1'
  AND b.ds = 'FVC2000/DB2_B' AND b.fp = '109_2';

/*
 match 
-------
 t
(1 row)
*/

-- matching along with score value
SELECT score, (score >= 40) AS match
FROM (
  SELECT bz_match(a.mdt, b.mdt) AS score
  FROM srcafis a, srcafis b
  WHERE a.id = 6 AND b.id = 19
) a;

/*
 score | match 
-------+-------
   151 | t
(1 row)
*/

-- =========================================================

-- Identification (1:N)

-- all matching occurrences scored
SELECT a.fp AS probe, b.fp AS sample,
  bz_match(a.mdt, b.mdt) AS score
FROM srcafis a, srcafis b
WHERE a.ds = 'FVC2000/DB2_B' AND a.fp = '109_1'
  and a.id != b.id
  AND bz_match(a.mdt, b.mdt) >= 40
  --AND a.pid = b.pid
ORDER BY score DESC;

/*
  probe   |  sample  | score 
----------+----------+-------
 109_1    | 109_3    |   172
 109_1    | 109_2    |   151
 109_1    | 109_8    |   131
 109_1    | 109_4    |   130
 109_1    | 109_1    |    91
 109_1    | 109_3    |    74
 109_1    | 109_5    |    71
 109_1    | 109_4    |    67
 109_1    | 109_7    |    58
 109_1    | 109_6    |    57
(10 rows)
*/

-- faster: returns a single matching!
SELECT b.fp AS first_match
FROM srcafis a, srcafis b
WHERE a.ds = 'FVC2000/DB2_B' AND a.fp = '109_1'
  and a.id != b.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

/*
 first_match 
-------------
 109_1   
(1 row)
*/

