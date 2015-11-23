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

-- [n]: a given fingerprint image => i.e., a record in "fvc04" table

-- FAR_n (considering a single subject [n])

-- i. number of fraud attempts against [n]
SELECT count(*) AS total_fraud_attempts_against_n
FROM (
  SELECT a.id, a.db, a.pid
  FROM fvc04 a, fvc04 b
  WHERE b.id = 49
    AND a.id NOT IN (
      SELECT c.id FROM fvc04 c WHERE c.db = b.db AND c.pid = b.pid
    )
    AND a.db = 1
  ORDER BY a.id
) x;

-- ii. number of successful frauds against [n]
SELECT count(*) AS total_successful_frauds_against_n
FROM (
  SELECT a.pid, b.*, 'P'::char AS ps, c.pid
  FROM fvc04 a
    JOIN fvc04_d b ON (b.probe = a.id)
    JOIN fvc04 c ON (c.id = b.sample)
  WHERE a.id = 49
    AND b.score >= 40
    AND NOT (c.db = a.db AND c.pid = a.pid)
    AND c.db = 1
  UNION
  SELECT a.pid, b.*, 'S', c.pid
  FROM fvc04 a
    JOIN fvc04_d b ON (b.sample = a.id)
    JOIN fvc04 c ON (c.id = b.probe)
  WHERE a.id = 49
    AND b.score >= 40
    AND NOT (c.db = a.db AND c.pid = a.pid)
    AND c.db = 1
) x;

/*select count(*), a.probe as id
from fvc04_d a join fvc04_d b on (b.sample = a.probe)
group by id order by 1 desc limit 100;*/

-- iii. False Acceptance Rate over [n]
SELECT total_successful_frauds_against_n, total_fraud_attempts_against_n,
  total_successful_frauds_against_n::numeric /
    total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
FROM (
  SELECT sum(total) AS total_successful_frauds_against_n, (
    SELECT count(*)
    FROM fvc04 a, fvc04 b
    WHERE b.id = 49 --2915
      AND a.id NOT IN (
        SELECT c.id
        FROM fvc04 c
        WHERE c.db = b.db AND c.pid = b.pid
      )
      AND a.db = 1
    ) AS total_fraud_attempts_against_n
  FROM (
    SELECT count(1) AS total
    FROM fvc04 a
      JOIN fvc04_d b ON (b.probe = a.id)
      JOIN fvc04 c ON (c.id = b.sample)
    WHERE a.id = 49
      AND b.score >= 40
      AND NOT (c.db = a.db AND c.pid = a.pid)
      AND c.db = 1
    UNION
    SELECT count(1) AS total
    FROM fvc04 a
      JOIN fvc04_d b ON (b.sample = a.id)
      JOIN fvc04 c ON (c.id = b.probe)
    WHERE a.id = 49
      AND b.score >= 40
      AND NOT (c.db = a.db AND c.pid = a.pid)
      AND c.db = 1
  ) x
) y;

-- ====================================================================================================

-- FAR (considering the whole dataset will all N subjects)

SELECT coalesce(
  sum(w.false_acceptance_rate_over_n) / (
    SELECT count(1) FROM fvc04
    WHERE db = 1
  ), 0.0) AS false_acceptance_rate
FROM (
  SELECT z.id, z.pid,
    z.total_fraud_attempts_against_n, z.total_successful_frauds_against_n,
    z.total_successful_frauds_against_n::numeric /
      z.total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
  FROM (
    SELECT n.id, n.pid,
      count(*) AS total_fraud_attempts_against_n,
      max(y.total_successful_frauds_against_n) AS total_successful_frauds_against_n
    FROM fvc04 a, fvc04 b, fvc04 n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04_d b ON (b.probe = a.id)
          JOIN fvc04 c ON (c.id = b.sample)
        WHERE b.score >= 40
          AND NOT (c.db = a.db AND c.pid = a.pid)
          AND c.db = 1
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04_d b ON (b.sample = a.id)
          JOIN fvc04 c ON (c.id = b.probe)
        WHERE b.score >= 40
          AND NOT (c.db = a.db AND c.pid = a.pid)
          AND c.db = 1
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE b.id = n.id
      AND y.id = n.id
      AND a.id NOT IN (
        SELECT c.id
        FROM fvc04 c
        WHERE c.db = b.db AND c.pid = b.pid
      )
      AND a.db = 1
      AND n.db = 1
    GROUP BY n.id, n.pid
  ) z
) w;


-- FAR (optimized)

SELECT coalesce(
  sum(w.false_acceptance_rate_over_n) /
  80 -- N: total number of subjects
  , 0.0) AS false_acceptance_rate
FROM (
  SELECT z.id, z.pid,
    z.total_fraud_attempts_against_n, z.total_successful_frauds_against_n,
    z.total_successful_frauds_against_n::numeric /
      z.total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
  FROM (
    SELECT n.id, n.pid,
      72 AS total_fraud_attempts_against_n, -- fixed: 80-8=72
      y.total_successful_frauds_against_n
    FROM fvc04 n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04_d b ON (b.probe = a.id)
          JOIN fvc04 c ON (c.id = b.sample)
        WHERE b.score >= 40 -- decision threshold
          AND NOT (c.db = a.db AND c.pid = a.pid)
          AND c.db = 1
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04_d b ON (b.sample = a.id)
          JOIN fvc04 c ON (c.id = b.probe)
        WHERE b.score >= 40 -- decision threshold
          AND NOT (c.db = a.db AND c.pid = a.pid)
          AND c.db = 1
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE y.id = n.id
      AND n.db = 1
  ) z
) w;

-- ====================================================================================================

/*
Results

DT = 40

 false_acceptance_rate  
------------------------
 0.06944444444444444445

*/

