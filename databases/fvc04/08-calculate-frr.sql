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

-- [n]: a given fingerprint image => i.e., a record in "fvc04" table

-- FRR_n (considering a single subject [n])

-- i. number of genuine attempts against [n]
SELECT count(*) AS total_genuine_attempts_against_n
FROM (
  SELECT a.id, a.db, a.pid
  FROM fvc04 a JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
  WHERE a.id != b.id
    AND b.id = 49
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
    --SELECT a.id, a.pid, p.*
    FROM fvc04 a JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
      JOIN fvc04_d p ON (p.sample = b.id AND p.probe = a.id)
    WHERE a.id != b.id
      AND b.id = 49
      AND p.score >= 40
    GROUP BY b.id
    UNION
    SELECT b.id, count(1) AS total
    --SELECT a.id, a.pid, a.fid, p.*
    FROM fvc04 a JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
      JOIN fvc04_d p ON (p.probe = b.id AND p.sample = a.id)
    WHERE a.id != b.id
      AND b.id = 49
      AND p.score >= 40
    GROUP BY b.id
  ) x
  GROUP BY x.id
) y, (
  SELECT w.id, count(*) AS total_genuine_attempts_against_n
  FROM (
    SELECT b.id --, a.id, a.pid, a.fid
    FROM fvc04 a JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
    WHERE a.id != b.id
      AND b.id = 49
  ) w
  GROUP BY w.id
) z
WHERE z.id = y.id;

-- ====================================================================================================

-- FRR (considering the whole dataset will all N subjects)

SELECT sum(coalesce(k.false_rejection_rate_over_n, 1.0)) /
  (SELECT count(1) FROM fvc04 WHERE db = 1) * 100 AS false_rejection_rate
--SELECT l.id, coalesce(k.false_rejection_rate_over_n, 1.0)
--SELECT sum(coalesce(k.false_rejection_rate_over_n, 1.0))
FROM fvc04 l
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
        FROM fvc04 a JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
          JOIN fvc04_d p ON (p.sample = b.id AND p.probe = a.id)
        WHERE a.id != b.id
          AND p.score >= 40
          AND a.db = 1
        GROUP BY b.id
        UNION
        SELECT b.id, count(1) AS total
        FROM fvc04 a JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
          JOIN fvc04_d p ON (p.probe = b.id AND p.sample = a.id)
        WHERE a.id != b.id
          AND p.score >= 40
          AND a.db = 1
        GROUP BY b.id
      ) x
      GROUP BY x.id
    ) y, (
      SELECT w.id, count(*) AS total_genuine_attempts_against_n
      FROM (
        SELECT b.id
        FROM fvc04 a JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
        WHERE a.id != b.id
          AND a.db = 1
      ) w
      GROUP BY w.id
    ) z
    WHERE z.id = y.id
  ) k ON (l.id = k.id)
WHERE l.db = 1;

-- ====================================================================================================

-- FRR (faster)

SELECT sum(coalesce(k.false_rejection_rate_over_n, 1.0)) / 80 * 100 AS false_rejection_rate
FROM fvc04 l
  LEFT JOIN (
    SELECT y.id,
      7 AS total_genuine_attempts_against_n, y.total_genuine_acceptances_over_n,
      7 - y.total_genuine_acceptances_over_n AS total_invalid_rejections_against_n,
      (7 - y.total_genuine_acceptances_over_n)::numeric / 7 AS false_rejection_rate_over_n
    FROM (
      SELECT x.id, sum(total) AS total_genuine_acceptances_over_n
      FROM (
        SELECT b.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
          JOIN fvc04_d p ON (p.sample = b.id AND p.probe = a.id)
        WHERE a.id != b.id
          AND p.score >= 80
          AND a.db = 1
        GROUP BY b.id
        UNION
        SELECT b.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
          JOIN fvc04_d p ON (p.probe = b.id AND p.sample = a.id)
        WHERE a.id != b.id
          AND p.score >= 80
          AND a.db = 1
        GROUP BY b.id
      ) x
      GROUP BY x.id
    ) y
  ) k ON (l.id = k.id)
WHERE l.db = 1;

-- ====================================================================================================

/*
Results

DT = 40

  false_rejection_rate   
-------------------------
 46.07142857142857142900

DT = 80

  false_rejection_rate   
-------------------------
 79.46428571428571428600

*/

