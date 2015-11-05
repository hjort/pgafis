\timing on

-- matching threshold set to: 40

-- =========================================================

-- Verification (1:1)

-- single logical answer for matching
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM casia a, casia b
WHERE a.fp = '000_L0_0'
  AND b.fp = '000_L0_2';

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
  FROM casia a, casia b
  WHERE a.id = 1 AND b.id = 3
) a;

/*
 score | match 
-------+-------
    93 | t
(1 row)
*/

-- =========================================================

-- Identification (1:N)

-- all matching occurrences scored
SELECT a.fp AS probe, b.fp AS sample,
  bz_match(a.mdt, b.mdt) AS score
FROM casia a, casia b
WHERE a.fp = '000_L0_0'
  AND b.fp != a.fp
  AND bz_match(a.mdt, b.mdt) >= 40
  --AND a.pid = b.pid
ORDER BY score DESC;

/*
  probe   |  sample  | score 
----------+----------+-------
 000_L0_0 | 000_L0_2 |    93
 000_L0_0 | 175_L0_0 |    40
(2 rows)
*/

-- faster: returns a single matching!
SELECT b.fp AS first_match
FROM casia a, casia b
WHERE a.fp = '000_L0_0'
  AND b.fp != a.fp
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

/*
 first_match 
-------------
 175_L0_0
(1 row)
*/

