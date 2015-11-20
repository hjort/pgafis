#!/bin/bash

db="$1"
dt="$2"

echo "SELECT trunc(coalesce(
  sum(w.false_acceptance_rate_over_n) / (
    SELECT count(1) FROM srcafis
    WHERE ds = '$db'
  ), 0.0), 5) AS false_acceptance_rate
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
          AND a.ds = '$db' AND c.ds = '$db'
          AND b.score >= $dt
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM srcafis a
          JOIN srcafis_d b ON (b.sample = a.id)
          JOIN srcafis c ON (c.id = b.probe)
        WHERE NOT (c.ds = a.ds AND c.pid = a.pid AND c.fid = a.fid)
          AND a.ds = '$db' AND c.ds = '$db'
          AND b.score >= $dt
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
      AND a.ds = '$db'
      AND n.ds = '$db'
    GROUP BY n.id, n.pid, n.fid
  ) z
) w"

