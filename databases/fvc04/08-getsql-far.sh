#!/bin/bash

ds="$1"
dt="$2"

echo "SELECT trunc(
  coalesce(sum(w.false_acceptance_rate_over_n) / 80, 0.0), 5) AS false_acceptance_rate
FROM (
  SELECT z.id, z.pid,
    z.total_fraud_attempts_against_n, z.total_successful_frauds_against_n,
    z.total_successful_frauds_against_n::numeric /
      z.total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
  FROM (
    SELECT n.id, n.pid,
      72 AS total_fraud_attempts_against_n,
      y.total_successful_frauds_against_n
    FROM fvc04 n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04_d b ON (b.probe = a.id)
          JOIN fvc04 c ON (c.id = b.sample)
        WHERE b.score >= $dt
          AND NOT (c.db = a.db AND c.pid = a.pid)
          AND c.db = $ds
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04_d b ON (b.sample = a.id)
          JOIN fvc04 c ON (c.id = b.probe)
        WHERE b.score >= $dt
          AND NOT (c.db = a.db AND c.pid = a.pid)
          AND c.db = $ds
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE y.id = n.id
      AND n.db = $ds
  ) z
) w"

