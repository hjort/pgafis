#!/bin/bash

ds="$1"
dt="$2"

if [ $ds -eq 1 ]
then
  subjects=1632
  attempts=23
else
  subjects=1536
  attempts=23
fi

echo "SELECT trunc(sum(coalesce(k.false_rejection_rate_over_n, 1.0)) / $subjects * 100, 5) AS false_rejection_rate
FROM atvs l
  LEFT JOIN (
    SELECT y.id,
      $attempts AS total_genuine_attempts_against_n, y.total_genuine_acceptances_over_n,
      $attempts - y.total_genuine_acceptances_over_n AS total_invalid_rejections_against_n,
      ($attempts - y.total_genuine_acceptances_over_n)::numeric / $attempts AS false_rejection_rate_over_n
    FROM (
      SELECT x.id, sum(total) AS total_genuine_acceptances_over_n
      FROM (
        SELECT b.id, count(1) AS total
        FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
          JOIN atvs_d p ON (p.sample = b.id AND p.probe = a.id)
        WHERE a.id != b.id
          AND p.score >= $dt
          AND a.ds = $ds
        GROUP BY b.id
        UNION
        SELECT b.id, count(1) AS total
        FROM atvs a JOIN atvs b ON (b.ds = a.ds AND b.pid = a.pid AND b.fid = a.fid)
          JOIN atvs_d p ON (p.probe = b.id AND p.sample = a.id)
        WHERE a.id != b.id
          AND p.score >= $dt
          AND a.ds = $ds
        GROUP BY b.id
      ) x
      GROUP BY x.id
    ) y
  ) k ON (l.id = k.id)
WHERE l.ds = $ds"

