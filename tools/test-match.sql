-- Verification (1:1)

SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM fingerprints a, fingerprints b
WHERE a.id = '101_1' AND b.id = '101_6';

/*
 match 
-------
 t
(1 row)
*/


-- Identification (1:N)

SELECT a.id AS probe, b.id AS sample,
  bz_match(a.mdt, b.mdt) AS match
FROM fingerprints a, fingerprints b
WHERE a.id = '101_1' AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) > 40
LIMIT 3;

/*
 probe | sample | match 
-------+--------+-------
 101_1 | 101_3  |    45
 101_1 | 101_4  |    57
 101_1 | 101_6  |    47
(3 rows)
*/

