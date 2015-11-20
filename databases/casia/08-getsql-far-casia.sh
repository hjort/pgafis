#!/bin/bash

dt="$1"

echo "SELECT trunc(coalesce(sum(w.false_acceptance_rate_over_n) / 20000, 0.0), 5) AS false_acceptance_rate
FROM (
  SELECT z.id, z.pid, z.fid, z.total_fraud_attempts_against_n, z.total_successful_frauds_against_n,
    z.total_successful_frauds_against_n::numeric / z.total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
  FROM (
    SELECT n.id, n.pid, n.fid, 19995 AS total_fraud_attempts_against_n, y.total_successful_frauds_against_n
    FROM casia n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM casia a
          JOIN casia_d b ON (b.probe = a.id)
          JOIN casia c ON (c.id = b.sample)
        WHERE b.score >= $dt
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM casia a
          JOIN casia_d b ON (b.sample = a.id)
          JOIN casia c ON (c.id = b.probe)
        WHERE b.score >= $dt
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE y.id = n.id
  ) z
) w"

