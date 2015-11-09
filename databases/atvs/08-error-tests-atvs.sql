\timing on

\d casia_d

/*
*/

-- =========================================================

DROP TABLE IF EXISTS casia_s;

SELECT a.id, a.db, a.fp,
  a.db || ':' || a.fp AS dbfp,
  a.mins, a.nfiq,
  array_length(samples40, 1) AS m40,
  array_length(samples60, 1) AS m60,
  array_length(samples80, 1) AS m80,
  array_length(samples100, 1) AS m100,
  samples40, samples60, samples80, samples100
INTO casia_s
FROM casia a
LEFT JOIN (
  SELECT probe AS id, array_agg(sample) AS samples40
  FROM casia_d
  WHERE score >= 40
  GROUP BY id
) b ON (b.id = a.id)
LEFT JOIN (
  SELECT probe AS id, array_agg(sample) AS samples60
  FROM casia_d
  WHERE score >= 60
  GROUP BY id
) c ON (c.id = a.id)
LEFT JOIN (
  SELECT probe AS id, array_agg(sample) AS samples80
  FROM casia_d
  WHERE score >= 80
  GROUP BY id
) d ON (d.id = a.id)
LEFT JOIN (
  SELECT probe AS id, array_agg(sample) AS samples100
  FROM casia_d
  WHERE score >= 100
  GROUP BY id
) e ON (e.id = a.id)
ORDER BY a.id;

ALTER TABLE casia_s ADD PRIMARY KEY (id);

\d casia_s

SELECT id, dbfp, mins, nfiq, m40, m60, m80, m100,
  samples40, samples100
FROM casia_s
ORDER BY id;

SELECT db,
  trunc(avg(m40),2) AS m40, trunc(avg(m60),2) AS m60,
  trunc(avg(m80),2) AS m80, trunc(avg(m100),2) AS m100
FROM casia_s
GROUP BY db
ORDER BY db;

-- =========================================================

