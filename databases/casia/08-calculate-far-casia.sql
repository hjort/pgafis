-- calculate FAR (False Acceptance Rate)

\timing on

/*
FAR (False Acceptance Rate)
FRR (False Rejection Rate)
EER (Equal Error Rate)
 - Valor para o qual FAR = FRR
 - Boa medida de qualidade
 - FBI: classificação boa se FAR = 1% e FAR = 20%
Ex: SourceAFIS FAR = 0.01%, FRR = 10.9%
*/

-- ====================================================================================================

-- [n]: a given fingerprint image => i.e., a record in "casia" table

-- FAR_n (considering a single subject [n])

-- i. number of fraud attempts against [n]
SELECT count(*) AS total_fraud_attempts_against_n
FROM (
  SELECT a.id, a.pid, a.fid
  FROM casia a, casia b
  WHERE b.id = 1720
    AND a.id NOT IN (SELECT c.id FROM casia c WHERE c.pid = b.pid AND c.fid = b.fid)
) x;

/*SELECT a.id, a.pid, a.fid
FROM casia a, casia b
WHERE b.id = 61
  AND a.id NOT IN (SELECT c.id FROM casia c WHERE c.pid = b.pid AND c.fid = b.fid);*/
/*SELECT count(*) AS total_fraud_attempts_against_n
FROM casia a
WHERE NOT (a.pid = 1 AND a.fid = 'R0');*/

-- ii. number of successful frauds against [n]
SELECT count(*) AS total_successful_frauds_against_n
FROM (
  SELECT a.pid, a.fid, b.*, 'P'::char AS ps, c.pid, c.fid
  FROM casia a
    JOIN casia_d b ON (b.probe = a.id)
    JOIN casia c ON (c.id = b.sample)
  WHERE a.id = 1720
    AND b.score >= 40
    AND NOT (c.pid = a.pid AND c.fid = a.fid)
  UNION
  SELECT a.pid, a.fid, b.*, 'S', c.pid, c.fid
  FROM casia a
    JOIN casia_d b ON (b.sample = a.id)
    JOIN casia c ON (c.id = b.probe)
  WHERE a.id = 1720
    AND b.score >= 40
    AND NOT (c.pid = a.pid AND c.fid = a.fid)
) x;

/*SELECT b.*
FROM casia a
  JOIN casia_d b ON (b.probe = a.id OR b.sample = a.id)
WHERE (a.pid = 1 AND a.fid = 'R0');*/
/*select count(*), a.probe as id
from casia_d a join casia_d b on (b.sample = a.probe)
group by id order by 1 desc limit 100;*/

-- iii. False Acceptance Rate over [n]
SELECT total_successful_frauds_against_n, total_fraud_attempts_against_n,
  total_successful_frauds_against_n::numeric /
    total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
FROM (
  SELECT sum(total) AS total_successful_frauds_against_n, (
    SELECT count(*)
    FROM casia a, casia b
    WHERE b.id = 1720
      AND a.id NOT IN (
        SELECT c.id
        FROM casia c
        WHERE c.pid = b.pid AND c.fid = b.fid
      )
    ) AS total_fraud_attempts_against_n
  FROM (
    SELECT count(1) AS total
    FROM casia a
      JOIN casia_d b ON (b.probe = a.id)
      JOIN casia c ON (c.id = b.sample)
    WHERE a.id = 1720
      AND b.score >= 40
      AND NOT (c.pid = a.pid AND c.fid = a.fid)
    UNION
    SELECT count(1) AS total
    FROM casia a
      JOIN casia_d b ON (b.sample = a.id)
      JOIN casia c ON (c.id = b.probe)
    WHERE a.id = 1720
      AND b.score >= 40
      AND NOT (c.pid = a.pid AND c.fid = a.fid)
  ) x
) y;

-- ====================================================================================================

-- FAR (considering the whole dataset will all N subjects)

SELECT coalesce(
  sum(w.false_acceptance_rate_over_n) / (
    SELECT count(1) FROM casia
    WHERE id <= 100 -- for debugging purposes
  ), 0.0) AS false_acceptance_rate
FROM (
  SELECT z.id, z.pid, z.fid,
    z.total_fraud_attempts_against_n, z.total_successful_frauds_against_n,
    z.total_successful_frauds_against_n::numeric /
      z.total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
  FROM (
    SELECT n.id, n.pid, n.fid,
      count(*) AS total_fraud_attempts_against_n,
      max(y.total_successful_frauds_against_n) AS total_successful_frauds_against_n
    FROM casia a, casia b, casia n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM casia a
          JOIN casia_d b ON (b.probe = a.id)
          JOIN casia c ON (c.id = b.sample)
        WHERE b.score >= 40
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM casia a
          JOIN casia_d b ON (b.sample = a.id)
          JOIN casia c ON (c.id = b.probe)
        WHERE b.score >= 40
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE b.id = n.id
      AND y.id = n.id
      AND a.id NOT IN (
        SELECT c.id
        FROM casia c
        WHERE c.pid = b.pid AND c.fid = b.fid
      )
      --AND n.id <= 100 -- for debugging purposes
      --AND n.id IN (1720, 1464, 492)
    GROUP BY n.id, n.pid, n.fid
  ) z
) w;


-- FAR (optimized)

SELECT coalesce(
  sum(w.false_acceptance_rate_over_n) /
  20000 -- N: total number of subjects = 20000
  , 0.0) AS false_acceptance_rate
FROM (
  SELECT z.id, z.pid, z.fid,
    z.total_fraud_attempts_against_n, z.total_successful_frauds_against_n,
    z.total_successful_frauds_against_n::numeric /
      z.total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
  FROM (
    SELECT n.id, n.pid, n.fid,
      19995 AS total_fraud_attempts_against_n, -- fixed: 20000-5=19995
      y.total_successful_frauds_against_n
    FROM casia n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM casia a
          JOIN casia_d b ON (b.probe = a.id)
          JOIN casia c ON (c.id = b.sample)
        WHERE b.score >= 40 -- decision threshold
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM casia a
          JOIN casia_d b ON (b.sample = a.id)
          JOIN casia c ON (c.id = b.probe)
        WHERE b.score >= 40 -- decision threshold
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE y.id = n.id
      --AND n.id <= 100 -- for debugging purposes
  ) z
) w;

-- ====================================================================================================

/*
Results

DT: score >= 40
   false_acceptance_rate    
----------------------------
 0.002706926731682920735391

DT: score >= 45
   false_acceptance_rate    
----------------------------
 0.000838709677419354840284

DT: score >= 50
   false_acceptance_rate    
----------------------------
 0.000291822955738934734499

DT: score >= 60
   false_acceptance_rate    
----------------------------
 0.000049012253063265816582

DT: score >= 80
   false_acceptance_rate    
----------------------------
 0.000002000500125031257814
*/

