\timing on

/*
FAR (False Acceptance Rate)
FRR (False Rejection Rate)
EER (Equal Error Rate)
 - Valor para o qual FAR = FRR
 - Boa medida de qualidade
 - FBI: classificação boa se FAR = 1% e FAR = 20%
Ex: SourceAFIS FAR = 0.01% FRR = 10.9%
*/

-- =========================================================

-- calculate FAR (False Acceptance Rate)

SELECT total_falsely_accepted, total_matches_performed,
  total_falsely_accepted::numeric / total_matches_performed * 100 AS false_acceptance_rate
FROM (
  SELECT count(x.*) AS total_falsely_accepted, (
    SELECT count(*) FROM casia a, casia b WHERE b.id > a.id) AS total_matches_performed
  FROM (
    SELECT a.id, a.pid, a.fid, b.score, c.id, c.pid, c.fid, 'P'::char AS ps
    FROM casia a
      JOIN casia_d b ON (b.probe = a.id) -- probe
      JOIN casia c ON (c.id = b.sample)
    WHERE b.score >= 40 -- threshold for matching
      AND NOT (a.pid = c.pid AND a.fid = c.fid) -- falsely accepted
      --AND a.pid = 1 AND a.fid = 'R0' -- for debugging
    UNION
    SELECT a.id, a.pid, a.fid, b.score, c.id, c.pid, c.fid, 'S'
    FROM casia a
      JOIN casia_d b ON (b.sample = a.id) -- sample
      JOIN casia c ON (c.id = b.probe)
    WHERE b.score >= 40 -- threshold for matching
      AND NOT (a.pid = c.pid AND a.fid = c.fid) -- falsely accepted
      --AND a.pid = 1 AND a.fid = 'R0' -- for debugging
  ) x
) y;

/*
score >= 40
 total_falsely_accepted | total_matches_performed |   false_acceptance_rate    
------------------------+-------------------------+----------------------------
                  11218 |               199990000 | 0.005609280464023201160100

score >= 60
 total_falsely_accepted | total_matches_performed |   false_acceptance_rate    
------------------------+-------------------------+----------------------------
                    208 |               199990000 | 0.000104005200260013000700

score >= 80
 total_falsely_accepted | total_matches_performed |   false_acceptance_rate    
------------------------+-------------------------+----------------------------
                      8 |               199990000 | 0.000004000200010000500000
*/

-- =========================================================

-- FRR (False Rejection Rate)

SELECT total_correctly_accepted, total_correctly_expected, total_matches_performed,
  (1 - total_correctly_accepted::numeric / total_correctly_expected) * 100 AS false_rejection_rate
FROM (
  SELECT count(x.*) AS total_correctly_accepted, (
    SELECT count(*) FROM casia a, casia b WHERE b.id > a.id
      --AND a.pid = 1 AND a.fid = 'R0' AND b.pid = 1 AND b.fid = 'R0' -- for debugging
      --AND a.pid = 1 AND a.fid IN ('R0', 'L0') AND b.pid = 1 AND b.fid IN ('R0', 'L0') -- for debugging
    ) AS total_matches_performed, (
    SELECT count(*) FROM casia a, casia b WHERE b.id > a.id AND a.pid = b.pid AND a.fid = b.fid
      --AND a.pid = 1 AND a.fid = 'R0' AND b.pid = 1 AND b.fid = 'R0' -- for debugging
      --AND a.pid = 1 AND a.fid IN ('R0', 'L0') AND b.pid = 1 AND b.fid IN ('R0', 'L0') -- for debugging
    ) AS total_correctly_expected
  FROM (
    SELECT a.id, a.pid, a.fid, /*b.probe,*/ b.score, /*b.sample,*/ c.id, c.pid, c.fid
    FROM casia a
      JOIN casia_d b ON (b.probe = a.id)
      JOIN casia c ON (c.id = b.sample OR c.id = b.probe)
    WHERE b.score >= 40 -- threshold for matching
      AND a.pid = c.pid AND a.fid = c.fid -- correctly accepted
      --AND a.pid = 1 AND a.fid = 'R0' -- for debugging
      --AND a.pid = 1 AND a.fid IN ('R0', 'L0') -- for debugging
      AND a.id != c.id
  ) x
) y;

/*
score >= 40

score >= 60

score >= 80
*/


/*
SELECT a.id, b.id
FROM casia a, casia b
WHERE b.id > a.id
  AND a.pid = 1 AND a.fid = 'R0'
  AND b.pid = 1 AND b.fid = 'R0'
ORDER BY 1, 2;

SELECT count(*)
FROM casia a, casia b
WHERE b.id > a.id
  AND a.pid = 1 AND a.fid = 'R0'
  AND b.pid = 1 AND b.fid = 'R0';

SELECT a.id, a.pid, a.fid
FROM casia a
WHERE a.pid = 1 AND a.fid IN ('R0', 'L0')
ORDER BY 1, 2;

SELECT a.id, b.id
FROM casia a, casia b
WHERE b.id > a.id
  AND a.pid = 1 AND a.fid IN ('R0', 'L0')
  AND b.pid = 1 AND b.fid IN ('R0', 'L0')
ORDER BY 1, 2;
*/

-- =========================================================


