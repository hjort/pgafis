\timing on

-- matching threshold set to: 40

-- =========================================================

-- Verification (1:1)

-- single logical answer for matching
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM atvs a, atvs b
WHERE a.fp = 'ds2_u05_f_fo_ri_01'
  AND b.fp = 'ds2_u05_f_fo_ri_03';

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
  FROM atvs a, atvs b
  WHERE a.id = 2041 AND b.id = 2042
) a;

/*
 score | match 
-------+-------
    58 | t
(1 row)
*/

-- =========================================================

-- Identification (1:N)

-- all matching occurrences scored
SELECT a.fp AS probe, b.fp AS sample,
  bz_match(a.mdt, b.mdt) AS score
FROM atvs a, atvs b
WHERE a.fp = 'ds2_u05_f_fo_ri_01'
  AND b.fp != a.fp
  AND bz_match(a.mdt, b.mdt) >= 40
  --AND a.pid = b.pid
ORDER BY score DESC;

/*
       probe        |       sample       | score 
--------------------+--------------------+-------
 ds2_u05_f_fo_ri_01 | ds2_u05_f_fo_ri_02 |    58
 ds2_u05_f_fo_ri_01 | ds2_u05_f_fo_ri_03 |    56
 ds2_u05_f_fo_ri_01 | ds1_u05_f_fc_ri_03 |    49
(3 rows)
*/

-- faster: returns a single matching!
SELECT b.fp AS first_match
FROM atvs a, atvs b
WHERE a.fp = 'ds2_u05_f_fo_ri_01'
  AND b.fp != a.fp
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

/*
    first_match     
--------------------
 ds1_u05_f_fc_ri_03
(1 row)
*/

