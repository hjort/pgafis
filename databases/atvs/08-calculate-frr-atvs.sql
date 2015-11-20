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

-- [n]: a given fingerprint image => i.e., a record in "atvs" table

-- FRR_n (considering a single subject [n])

-- i. number of genuine attempts against [n]
SELECT count(*) AS total_genuine_attempts_against_n
FROM (
  SELECT a.id, a.pid, a.fid
  FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
  WHERE a.id != b.id
    AND b.id = 85
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
    FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
      JOIN atvs_d p ON (p.sample = b.id AND p.probe = a.id AND p.score <= 50)
    WHERE a.id != b.id
      AND b.id = 85
      --AND b.id IN (1720, 1464, 492) --= 1720
    GROUP BY b.id
    UNION
    SELECT b.id, count(1) AS total
    --SELECT a.id, a.pid, a.fid, p.*
    FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
      JOIN atvs_d p ON (p.probe = b.id AND p.sample = a.id AND p.score <= 50)
    WHERE a.id != b.id
      AND b.id = 85
      --AND b.id IN (1720, 1464, 492) --= 1720
    GROUP BY b.id
  ) x
  GROUP BY x.id
) y, (
  SELECT w.id, count(*) AS total_genuine_attempts_against_n
  FROM (
    SELECT b.id --, a.id, a.pid, a.fid
    FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
    WHERE a.id != b.id
      AND b.id = 85
      --AND b.id IN (1720, 1464, 492) --= 1720
  ) w
  GROUP BY w.id
) z
WHERE z.id = y.id;

-- ====================================================================================================

-- FRR (considering the whole dataset will all N subjects)

SELECT sum(coalesce(k.false_rejection_rate_over_n, 1.0)) /
  (SELECT count(1) FROM atvs WHERE ds = 1) * 100 AS false_rejection_rate
--SELECT l.id, coalesce(k.false_rejection_rate_over_n, 1.0)
--SELECT sum(coalesce(k.false_rejection_rate_over_n, 1.0))
FROM atvs l
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
        FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
          JOIN atvs_d p ON (p.sample = b.id AND p.probe = a.id)
        WHERE a.id != b.id
          AND p.score >= 40
          AND a.ds = 1
        GROUP BY b.id
        UNION
        SELECT b.id, count(1) AS total
        FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
          JOIN atvs_d p ON (p.probe = b.id AND p.sample = a.id)
        WHERE a.id != b.id
          AND p.score >= 40
          AND a.ds = 1
        GROUP BY b.id
      ) x
      GROUP BY x.id
    ) y, (
      SELECT w.id, count(*) AS total_genuine_attempts_against_n
      FROM (
        SELECT b.id
        FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
        WHERE a.id != b.id
          AND a.ds = 1
      ) w
      GROUP BY w.id
    ) z
    WHERE z.id = y.id
  ) k ON (l.id = k.id)
WHERE l.ds = 1;

-- ====================================================================================================

-- FRR (faster)

SELECT sum(coalesce(k.false_rejection_rate_over_n, 1.0)) / 1632 * 100 AS false_rejection_rate
FROM atvs l
  LEFT JOIN (
    SELECT y.id,
      23 AS total_genuine_attempts_against_n, y.total_genuine_acceptances_over_n,
      23 - y.total_genuine_acceptances_over_n AS total_invalid_rejections_against_n,
      (23 - y.total_genuine_acceptances_over_n)::numeric / 23 AS false_rejection_rate_over_n
    FROM (
      SELECT x.id, sum(total) AS total_genuine_acceptances_over_n
      FROM (
        SELECT b.id, count(1) AS total
        FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
          JOIN atvs_d p ON (p.sample = b.id AND p.probe = a.id)
        WHERE a.id != b.id
          AND p.score >= 40
          AND a.ds = 1
        GROUP BY b.id
        UNION
        SELECT b.id, count(1) AS total
        FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
          JOIN atvs_d p ON (p.probe = b.id AND p.sample = a.id)
        WHERE a.id != b.id
          AND p.score >= 40
          AND a.ds = 1
        GROUP BY b.id
      ) x
      GROUP BY x.id
    ) y
  ) k ON (l.id = k.id)
WHERE l.ds = 1;

-- ====================================================================================================

/*
Results

DT = 40

  false_rejection_rate   
-------------------------
 93.36903239556692242100

DT = 80

  false_rejection_rate   
-------------------------
 97.51172208013640238700

*/

