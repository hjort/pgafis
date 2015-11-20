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

-- [n]: a given fingerprint image => i.e., a record in "atvs" table

-- FAR_n (considering a single subject [n])

-- i. number of fraud attempts against [n]
SELECT count(*) AS total_fraud_attempts_against_n
FROM (
  SELECT a.id, a.ds, a.pid, a.fid
  FROM atvs a, atvs b
  WHERE b.id = 85
    AND a.id NOT IN (
      SELECT c.id FROM atvs c WHERE c.ds = b.ds AND c.pid = b.pid AND c.fid = b.fid
    )
    AND a.ds = 1
  ORDER BY a.id
) x;

-- ii. number of successful frauds against [n]
SELECT count(*) AS total_successful_frauds_against_n
FROM (
  SELECT a.pid, a.fid, b.*, 'P'::char AS ps, c.pid, c.fid
  FROM atvs a
    JOIN atvs_d b ON (b.probe = a.id)
    JOIN atvs c ON (c.id = b.sample)
  WHERE a.id = 85
    AND b.score >= 40
    AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
    AND c.ds = 1
  UNION
  SELECT a.pid, a.fid, b.*, 'S', c.pid, c.fid
  FROM atvs a
    JOIN atvs_d b ON (b.sample = a.id)
    JOIN atvs c ON (c.id = b.probe)
  WHERE a.id = 85
    AND b.score >= 40
    AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
    AND c.ds = 1
) x;

/*select count(*), a.probe as id
from atvs_d a join atvs_d b on (b.sample = a.probe)
group by id order by 1 desc limit 100;*/

-- iii. False Acceptance Rate over [n]
SELECT total_successful_frauds_against_n, total_fraud_attempts_against_n,
  total_successful_frauds_against_n::numeric /
    total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
FROM (
  SELECT sum(total) AS total_successful_frauds_against_n, (
    SELECT count(*)
    FROM atvs a, atvs b
    WHERE b.id = 85 --2915
      AND a.id NOT IN (
        SELECT c.id
        FROM atvs c
        WHERE c.ds = b.ds AND c.pid = b.pid AND c.fid = b.fid
      )
      AND a.ds = 1
    ) AS total_fraud_attempts_against_n
  FROM (
    SELECT count(1) AS total
    FROM atvs a
      JOIN atvs_d b ON (b.probe = a.id)
      JOIN atvs c ON (c.id = b.sample)
    WHERE a.id = 85
      AND b.score >= 40
      AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
      AND c.ds = 1
    UNION
    SELECT count(1) AS total
    FROM atvs a
      JOIN atvs_d b ON (b.sample = a.id)
      JOIN atvs c ON (c.id = b.probe)
    WHERE a.id = 85
      AND b.score >= 40
      AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
      AND c.ds = 1
  ) x
) y;

-- ====================================================================================================

-- FAR (considering the whole dataset will all N subjects)

SELECT coalesce(
  sum(w.false_acceptance_rate_over_n) / (
    SELECT count(1) FROM atvs
    WHERE ds = 1
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
    FROM atvs a, atvs b, atvs n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM atvs a
          JOIN atvs_d b ON (b.probe = a.id)
          JOIN atvs c ON (c.id = b.sample)
        WHERE b.score >= 40
          AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
          AND c.ds = 1
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM atvs a
          JOIN atvs_d b ON (b.sample = a.id)
          JOIN atvs c ON (c.id = b.probe)
        WHERE b.score >= 40
          AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
          AND c.ds = 1
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE b.id = n.id
      AND y.id = n.id
      AND a.id NOT IN (
        SELECT c.id
        FROM atvs c
        WHERE c.ds = b.ds AND c.pid = b.pid AND c.fid = b.fid
      )
      AND a.ds = 1
      AND n.ds = 1
    GROUP BY n.id, n.pid, n.fid
  ) z
) w;


-- FAR (optimized)

SELECT coalesce(
  sum(w.false_acceptance_rate_over_n) /
  1632 -- N: total number of subjects (ds1: 1632, ds2: 1536)
  , 0.0) AS false_acceptance_rate
FROM (
  SELECT z.id, z.pid, z.fid,
    z.total_fraud_attempts_against_n, z.total_successful_frauds_against_n,
    z.total_successful_frauds_against_n::numeric /
      z.total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
  FROM (
    SELECT n.id, n.pid, n.fid,
      1608 AS total_fraud_attempts_against_n, -- fixed: 1632-24=1608, 1536-24=1512
      y.total_successful_frauds_against_n
    FROM atvs n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM atvs a
          JOIN atvs_d b ON (b.probe = a.id)
          JOIN atvs c ON (c.id = b.sample)
        WHERE b.score >= 40 -- decision threshold
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
          AND c.ds = 1
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM atvs a
          JOIN atvs_d b ON (b.sample = a.id)
          JOIN atvs c ON (c.id = b.probe)
        WHERE b.score >= 40 -- decision threshold
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
          AND c.ds = 1
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE y.id = n.id
  ) z
) w;

-- ====================================================================================================

/*
Results

DT = 40

 false_acceptance_rate  
------------------------
 0.04267876304750756021

*/

