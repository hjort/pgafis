\timing on

DROP TABLE IF EXISTS fvc04d;
CREATE TABLE fvc04d (
  probe int,
  sample int,
  score int
);

-- deduplicação de toda a base biométrica (~40 min)
INSERT INTO fvc04d
SELECT c.*
FROM (
  SELECT a.id AS probe, b.id AS sample,
    bz_match(a.mdt, b.mdt) AS score
  FROM fvc04 a, fvc04 b
  WHERE a.id != b.id
  --LIMIT 1280
) c
WHERE score >= 40;

ALTER TABLE fvc04d ADD PRIMARY KEY (probe, sample);

\d fvc04d

-- =========================================================

DROP TABLE IF EXISTS fvc04s;

SELECT a.id, a.db, a.fp,
  a.db || ':' || a.fp AS dbfp,
  a.mins, a.nfiq,
  array_length(samples40, 1) AS m40,
  array_length(samples60, 1) AS m60,
  array_length(samples80, 1) AS m80,
  array_length(samples100, 1) AS m100,
  samples40, samples60, samples80, samples100
INTO fvc04s
FROM fvc04 a
LEFT JOIN (
  SELECT probe AS id, array_agg(sample) AS samples40
  FROM fvc04d
  WHERE score >= 40
  GROUP BY id
) b ON (b.id = a.id)
LEFT JOIN (
  SELECT probe AS id, array_agg(sample) AS samples60
  FROM fvc04d
  WHERE score >= 60
  GROUP BY id
) c ON (c.id = a.id)
LEFT JOIN (
  SELECT probe AS id, array_agg(sample) AS samples80
  FROM fvc04d
  WHERE score >= 80
  GROUP BY id
) d ON (d.id = a.id)
LEFT JOIN (
  SELECT probe AS id, array_agg(sample) AS samples100
  FROM fvc04d
  WHERE score >= 100
  GROUP BY id
) e ON (e.id = a.id)
ORDER BY a.id;

ALTER TABLE fvc04s ADD PRIMARY KEY (id);

\d fvc04s

SELECT id, dbfp, mins, nfiq, m40, m60, m80, m100,
  samples40, samples100
FROM fvc04s
ORDER BY id;

SELECT db,
  trunc(avg(m40),2) AS m40, trunc(avg(m60),2) AS m60,
  trunc(avg(m80),2) AS m80, trunc(avg(m100),2) AS m100
FROM fvc04s
GROUP BY db
ORDER BY db;

-- =========================================================

