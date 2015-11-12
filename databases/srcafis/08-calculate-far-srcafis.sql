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

-- [n]: a given fingerprint image => i.e., a record in "srcafis" table

-- FAR_n (considering a single subject [n])

-- i. number of fraud attempts against [n]
SELECT count(*) AS total_fraud_attempts_against_n
FROM (
  SELECT a.id, a.ds, a.pid, a.fid
  FROM srcafis a, srcafis b
  WHERE b.id = 925
    AND a.id NOT IN (SELECT c.id FROM srcafis c WHERE c.ds = b.ds AND c.pid = b.pid AND c.fid = b.fid)
    AND a.ds = 'Neurotech/CM' --AND b.ds = 'Neurotech/CM'
  ORDER BY a.id
) x;

-- ii. number of successful frauds against [n]
SELECT count(*) AS total_successful_frauds_against_n
FROM (
  SELECT a.pid, a.fid, b.*, 'P'::char AS ps, c.pid, c.fid
  FROM srcafis a
    JOIN srcafis_d b ON (b.probe = a.id)
    JOIN srcafis c ON (c.id = b.sample)
  WHERE a.id = 925
    AND b.score >= 40
    AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
    AND c.ds = 'Neurotech/CM' --AND a.ds = 'Neurotech/CM'
  UNION
  SELECT a.pid, a.fid, b.*, 'S', c.pid, c.fid
  FROM srcafis a
    JOIN srcafis_d b ON (b.sample = a.id)
    JOIN srcafis c ON (c.id = b.probe)
  WHERE a.id = 925
    AND b.score >= 40
    AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
    AND c.ds = 'Neurotech/CM' --AND c.ds = 'Neurotech/CM'
) x;

/*select count(*), a.probe as id
from srcafis_d a join srcafis_d b on (b.sample = a.probe)
group by id order by 1 desc limit 150;*/
/*select count(*), a.id
from srcafis a
  join srcafis_d b on (a.id = b.probe)
  join srcafis_d c on (b.sample = c.probe)
where a.ds = 'Neurotech/CM'
group by id
order by 1 desc
limit 500;*/

-- iii. False Acceptance Rate over [n]
SELECT total_successful_frauds_against_n, total_fraud_attempts_against_n,
  total_successful_frauds_against_n::numeric /
    total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
FROM (
  SELECT sum(total) AS total_successful_frauds_against_n, (
    SELECT count(*)
    FROM srcafis a, srcafis b
    WHERE b.id = 925
      AND a.id NOT IN (
        SELECT c.id
        FROM srcafis c
        WHERE c.ds = b.ds AND c.pid = b.pid AND c.fid = b.fid
      )
      AND a.ds = 'Neurotech/CM' --AND b.ds = 'Neurotech/CM'
    ) AS total_fraud_attempts_against_n
  FROM (
    SELECT count(1) AS total
    FROM srcafis a
      JOIN srcafis_d b ON (b.probe = a.id)
      JOIN srcafis c ON (c.id = b.sample)
    WHERE a.id = 925
      AND b.score >= 40
      AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
      AND c.ds = 'Neurotech/CM' --AND a.ds = 'Neurotech/CM'
    UNION
    SELECT count(1) AS total
    FROM srcafis a
      JOIN srcafis_d b ON (b.sample = a.id)
      JOIN srcafis c ON (c.id = b.probe)
    WHERE a.id = 925
      AND b.score >= 40
      AND NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
      AND c.ds = 'Neurotech/CM' --AND c.ds = 'Neurotech/CM'
  ) x
) y;

-- ====================================================================================================

-- FAR (considering the whole dataset will all N subjects)

SELECT coalesce(
  sum(w.false_acceptance_rate_over_n) / (
    SELECT count(1) FROM srcafis
    WHERE ds = 'Neurotech/CM'
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
    FROM srcafis a, srcafis b, srcafis n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM srcafis a
          JOIN srcafis_d b ON (b.probe = a.id)
          JOIN srcafis c ON (c.id = b.sample)
        WHERE NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
          AND a.ds = 'Neurotech/CM' AND c.ds = 'Neurotech/CM'
          AND b.score >= 40 -- decision threshold
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM srcafis a
          JOIN srcafis_d b ON (b.sample = a.id)
          JOIN srcafis c ON (c.id = b.probe)
        WHERE NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
          AND a.ds = 'Neurotech/CM' AND c.ds = 'Neurotech/CM'
          AND b.score >= 40 -- decision threshold
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE b.id = n.id
      AND y.id = n.id
      AND a.id NOT IN (
        SELECT c.id
        FROM srcafis c
        WHERE c.ds = b.ds AND c.pid = b.pid AND c.fid = b.fid
      )
      AND a.ds = 'Neurotech/CM'
      AND n.ds = 'Neurotech/CM'
    GROUP BY n.id, n.pid, n.fid
  ) z
) w;

-- ====================================================================================================

/*
Results

DT: score >= 40
 false_acceptance_rate  
------------------------
 0.00122549019607843137

DT: score >= 42
 false_acceptance_rate  
------------------------
 0.00122549019607843137

DT: score >= 43
 false_acceptance_rate 
-----------------------
                   0.0
*/

