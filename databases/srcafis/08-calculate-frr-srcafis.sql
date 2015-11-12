-- calculate FRR (False Rejection Rate)

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

-- FRR_n (considering a single subject [n])

-- i. number of genuine attempts against [n]
SELECT count(*) AS total_genuine_attempts_against_n
FROM (
  SELECT a.id, a.pid, a.fid
  FROM srcafis a
    JOIN srcafis b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
  WHERE a.id != b.id
    AND b.id = 925
) x;

-- ii. number of invalid rejections against [n]
-- iii. False Rejection Rate over [n]
SELECT y.id,
  z.total_genuine_attempts_against_n, y.total_genuine_acceptances_over_n,
  z.total_genuine_attempts_against_n - y.total_genuine_acceptances_over_n AS total_invalid_rejections_against_n,
  (z.total_genuine_attempts_against_n - y.total_genuine_acceptances_over_n)::numeric /
    z.total_genuine_attempts_against_n * 100 AS false_rejection_rate_over_n
FROM (
  SELECT x.id, sum(total) AS total_genuine_acceptances_over_n
  FROM (
    SELECT b.id, count(1) AS total
    --SELECT a.id, a.pid, a.fid, p.*
    FROM srcafis a
      JOIN srcafis b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
      JOIN srcafis_d p ON (p.sample = b.id AND p.probe = a.id AND p.score <= 1000)
    WHERE a.id != b.id
      AND b.id = 925
      --AND a.ds = 'Neurotech/CM' AND b.ds = 'Neurotech/CM'
    GROUP BY b.id
    UNION
    SELECT b.id, count(1) AS total
    --SELECT a.id, a.pid, a.fid, p.*
    FROM srcafis a
      JOIN srcafis b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
      JOIN srcafis_d p ON (p.probe = b.id AND p.sample = a.id AND p.score <= 1000)
    WHERE a.id != b.id
      AND b.id = 925
      --AND a.ds = 'Neurotech/CM' AND b.ds = 'Neurotech/CM'
    GROUP BY b.id
  ) x
  GROUP BY x.id
) y, (
  SELECT w.id, count(*) AS total_genuine_attempts_against_n
  FROM (
    SELECT b.id
    FROM srcafis a
      JOIN srcafis b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
    WHERE a.id != b.id
      AND b.id = 925
      --AND a.ds = 'Neurotech/CM' AND b.ds = 'Neurotech/CM'
  ) w
  GROUP BY w.id
) z
WHERE z.id = y.id;

-- ====================================================================================================

-- FRR (considering the whole dataset will all N subjects)

SELECT sum(coalesce(k.false_rejection_rate_over_n, 1.0)) / (
  SELECT count(1) FROM srcafis
  WHERE ds = 'Neurotech/CM'
  ) * 100 AS false_rejection_rate
--SELECT l.id, l.pid, l.fid, k.*
FROM srcafis l
  LEFT JOIN (
    SELECT y.id,
      z.total_genuine_attempts_against_n, y.total_genuine_acceptances_over_n,
      z.total_genuine_attempts_against_n - y.total_genuine_acceptances_over_n
        AS total_invalid_rejections_against_n,
      (z.total_genuine_attempts_against_n - y.total_genuine_acceptances_over_n)::numeric /
        z.total_genuine_attempts_against_n AS false_rejection_rate_over_n
    FROM (
      SELECT x.id, sum(total) AS total_genuine_acceptances_over_n
      FROM (
        SELECT b.id, count(1) AS total
        FROM srcafis a
          JOIN srcafis b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
          JOIN srcafis_d p ON (p.sample = b.id AND p.probe = a.id)
        WHERE a.id != b.id
          AND a.ds = 'Neurotech/CM'
          AND p.score >= 40 -- decision threshold
        GROUP BY b.id
        UNION
        SELECT b.id, count(1) AS total
        FROM srcafis a
          JOIN srcafis b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
          JOIN srcafis_d p ON (p.probe = b.id AND p.sample = a.id)
        WHERE a.id != b.id
          AND a.ds = 'Neurotech/CM'
          AND p.score >= 40 -- decision threshold
        GROUP BY b.id
      ) x
      GROUP BY x.id
    ) y, (
      SELECT w.id, count(*) AS total_genuine_attempts_against_n
      FROM (
        SELECT b.id
        FROM srcafis a
          JOIN srcafis b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
        WHERE a.id != b.id
          AND a.ds = 'Neurotech/CM'
      ) w
      GROUP BY w.id
    ) z
    WHERE z.id = y.id
  ) k ON (l.id = k.id)
WHERE l.ds = 'Neurotech/CM';

-- ====================================================================================================

/*
Results

DT: score >= 40
  false_rejection_rate  
------------------------
 3.15126050420168067200

DT: score >= 45
  false_rejection_rate  
------------------------
 3.36134453781512605000

DT: score >= 50
  false_rejection_rate  
------------------------
 4.13165266106442577000

DT: score >= 60
  false_rejection_rate  
------------------------
 6.51260504201680672300

DT: score >= 80
  false_rejection_rate   
-------------------------
 12.04481792717086834700
*/

