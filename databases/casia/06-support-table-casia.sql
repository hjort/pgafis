-- create table containing only ids and minutiae
DROP TABLE IF EXISTS casiam;
SELECT id, mdt INTO casiam FROM casia;
ALTER TABLE casiam ADD PRIMARY KEY (id);

-- check table structure
\d casiam

/*
    Table "public.casiam"
 Column |  Type   | Modifiers 
--------+---------+-----------
 id     | integer | not null
 mdt    | bytea   | 
Indexes:
    "casiam_pkey" PRIMARY KEY, btree (id)
*/

-- compare size in disk for the tables
\d+

/*
 Schema |      Name      |   Type   |  Owner   |    Size    | Description 
--------+----------------+----------+----------+------------+-------------
 public | fvc04          | table    | rodrigo  | 43 MB      | 
 public | fvc04m         | table    | rodrigo  | 192 kB     | 
*/

\timing on

-- =========================================================

-- Verification (1:1)

SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM casiam a, casiam b
WHERE a.id = (SELECT id FROM casia WHERE fp = '001_L0_0')
  AND b.id = (SELECT id FROM casia WHERE fp = '001_L0_1');

-- faster!
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM casiam a, casiam b
WHERE a.id = 1
  AND b.id = 4;

/*
 match 
-------
 t
(1 row)
*/

SELECT bz_match(a.mdt, b.mdt) AS score
FROM casiam a, casiam b
WHERE a.id = 1
  AND b.id = 4;

/*
 score 
-------
    71
(1 row)
*/

-- =========================================================

-- Identification (1:N)

-- returns only first match
SELECT b.id AS first_matching_sample
FROM casiam a, casiam b
WHERE a.id = (SELECT id FROM casia WHERE fp = '001_L0_0')
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

-- faster!
SELECT b.id AS first_matching_sample
FROM casiam a, casiam b
WHERE a.id = 1
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

-- returns all matches
SELECT array_agg(b.id) AS matching_samples
FROM casiam a, casiam b
WHERE a.id = 1
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40;

