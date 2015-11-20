#!/bin/bash

ds="$1"
dt="$2"

if [ $ds -eq 1 ]
then
  subjects=1632
  attempts=1608
else
  subjects=1536
  attempts=1512
fi

echo "SELECT trunc(coalesce(
  sum(w.false_acceptance_rate_over_n) / $subjects, 0.0), 5) AS false_acceptance_rate
FROM (
  SELECT z.id, z.pid, z.fid,
    z.total_fraud_attempts_against_n, z.total_successful_frauds_against_n,
    z.total_successful_frauds_against_n::numeric / z.total_fraud_attempts_against_n * 100 AS false_acceptance_rate_over_n
  FROM (
    SELECT n.id, n.pid, n.fid, $attempts AS total_fraud_attempts_against_n, y.total_successful_frauds_against_n
    FROM atvs n, (
      SELECT x.id, sum(x.total) AS total_successful_frauds_against_n
      FROM (
        SELECT a.id, count(1) AS total
        FROM atvs a
          JOIN atvs_d b ON (b.probe = a.id)
          JOIN atvs c ON (c.id = b.sample)
        WHERE b.score >= $dt
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
          AND c.ds = $ds
        GROUP BY a.id
        UNION
        SELECT a.id, count(1) AS total
        FROM atvs a
          JOIN atvs_d b ON (b.sample = a.id)
          JOIN atvs c ON (c.id = b.probe)
        WHERE b.score >= $dt
          AND NOT (c.pid = a.pid AND c.fid = a.fid)
          AND c.ds = $ds
        GROUP BY a.id
      ) x
      GROUP BY x.id
    ) y
    WHERE y.id = n.id
  ) z
) w"

