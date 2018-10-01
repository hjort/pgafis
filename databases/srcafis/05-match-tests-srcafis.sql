\timing on

-- matching threshold set to: 40

-- =========================================================

-- Verification (1:1)

-- single logical answer for matching
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM srcafis a, srcafis b
WHERE a.ds = 'FVC2002/DB4_B' AND a.fp = '101_1'
  AND b.ds = 'FVC2002/DB4_B' AND b.fp = '101_2';

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
  WHERE a.id = 1648 AND b.id = 1685
) a;

/*
 score | match 
-------+-------
    67 | t
(1 row)
*/

-- =========================================================

-- Identification (1:N)

-- all matching occurrences scored
SELECT a.fp AS probe, b.fp AS sample,
  bz_match(a.mdt, b.mdt) AS score
FROM srcafis a, srcafis b
WHERE a.ds = 'FVC2002/DB4_B' AND a.fp = '101_1'
  and a.id != b.id
  AND bz_match(a.mdt, b.mdt) >= 40
  --AND a.pid = b.pid
ORDER BY score DESC;

/*
  probe   |  sample  | score 
----------+----------+-------
 101_1    | 101_7    |   144
 101_1    | 101_8    |    78
 101_1    | 101_2    |    67
 101_1    | 101_4    |    48
(4 rows)
*/

-- faster: returns a single matching!
SELECT b.fp AS first_match
FROM srcafis a, srcafis b
WHERE a.ds = 'FVC2002/DB4_B' AND a.fp = '101_1'
  and a.id != b.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

/*
 first_match 
-------------
 101_8   
(1 row)
*/

