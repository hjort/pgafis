#!/bin/bash

dt="$1"

echo "SELECT trunc(sum(coalesce(k.false_rejection_rate_over_n, 1.0)) /
  (SELECT count(1) FROM casia) * 100, 5) AS false_rejection_rate
FROM casia l
  LEFT JOIN (
    SELECT y.id, z.total_genuine_attempts_against_n, y.total_genuine_acceptances_over_n,
      z.total_genuine_attempts_against_n - y.total_genuine_acceptances_over_n AS total_invalid_rejections_against_n,
      (z.total_genuine_attempts_against_n - y.total_genuine_acceptances_over_n)::numeric / z.total_genuine_attempts_against_n AS false_rejection_rate_over_n
    FROM (
      SELECT x.id, sum(total) AS total_genuine_acceptances_over_n
      FROM (
        SELECT b.id, count(1) AS total
        FROM casia a JOIN casia b ON (b.pid = a.pid AND b.fid = a.fid)
          JOIN casia_d p ON (p.sample = b.id AND p.probe = a.id)
        WHERE a.id != b.id
          AND p.score >= $dt
        GROUP BY b.id
        UNION
        SELECT b.id, count(1) AS total
        FROM casia a JOIN casia b ON (b.pid = a.pid AND b.fid = a.fid)
          JOIN casia_d p ON (p.probe = b.id AND p.sample = a.id)
        WHERE a.id != b.id
          AND p.score >= $dt
        GROUP BY b.id
      ) x
      GROUP BY x.id
    ) y, (
      SELECT w.id, count(*) AS total_genuine_attempts_against_n
      FROM (
        SELECT b.id
        FROM casia a JOIN casia b ON (b.pid = a.pid AND b.fid = a.fid)
        WHERE a.id != b.id
      ) w
      GROUP BY w.id
    ) z
    WHERE z.id = y.id
  ) k ON (l.id = k.id)"

