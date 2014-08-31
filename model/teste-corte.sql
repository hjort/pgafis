-- teste da funcionalidade de "corte"

DROP TABLE IF EXISTS mytable;

SELECT id, (random() * 100)::int AS val
INTO mytable
FROM generate_series(1, 1e6::int) id;

SELECT * FROM mytable LIMIT 10;

/*
 id | val 
----+-----
  1 |  91
  2 |  26
  3 |   8
  4 |  46
  5 |  17
  6 |  97
  7 |  15
  8 |  19
  9 |  85
 10 |  41
(10 rows)
*/

CREATE OR REPLACE FUNCTION myfunc(int) RETURNS int AS $$
  SELECT $1 % 11;
$$ LANGUAGE sql;

EXPLAIN ANALYZE
SELECT id, myfunc(val)
FROM mytable
WHERE myfunc(val) > 5
--ORDER BY 2 DESC
LIMIT 10;

-- c/ ORDER BY
/*
 Limit  (cost=27461.54..27461.56 rows=10 width=8) (actual time=2219.260..2219.285 rows=10 loops=1)
   ->  Sort  (cost=27461.54..28294.87 rows=333333 width=8) (actual time=2219.254..2219.263 rows=10 loops=1)
         Sort Key: ((val % 11))
         Sort Method: top-N heapsort  Memory: 17kB
         ->  Seq Scan on mytable  (cost=0.00..20258.33 rows=333333 width=8) (actual time=0.054..1593.874 rows=449870 
loops=1)
               Filter: ((val % 11) > 5)
               Rows Removed by Filter: 550130
 Total runtime: 2219.376 ms
(8 rows)
*/

-- s/ ORDER BY
/*
 Limit  (cost=0.00..0.61 rows=10 width=8) (actual time=0.060..0.101 rows=10 loops=1)
   ->  Seq Scan on mytable  (cost=0.00..20258.33 rows=333333 width=8) (actual time=0.054..0.081 rows=10 loops=1)
         Filter: ((val % 11) > 5)
         Rows Removed by Filter: 9
 Total runtime: 0.179 ms
*/

