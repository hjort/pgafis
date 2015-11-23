#!/bin/bash

ds="$1"
dt="$2"

echo "SELECT trunc(sum(coalesce(k.false_rejection_rate_over_n, 1.0)) / 80 * 100, 5) AS false_rejection_rate
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
          AND p.score >= $dt
          AND a.db = $ds
        GROUP BY b.id
        UNION
        SELECT b.id, count(1) AS total
        FROM fvc04 a
          JOIN fvc04 b ON (b.db = a.db AND b.pid = a.pid)
          JOIN fvc04_d p ON (p.probe = b.id AND p.sample = a.id)
        WHERE a.id != b.id
          AND p.score >= $dt
          AND a.db = $ds
        GROUP BY b.id
      ) x
      GROUP BY x.id
    ) y
  ) k ON (l.id = k.id)
WHERE l.db = $ds"

