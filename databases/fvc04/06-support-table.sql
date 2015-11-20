-- create table containing only ids and minutiae
DROP TABLE IF EXISTS fvc04_m;
SELECT id, mdt INTO fvc04_m FROM fvc04;
ALTER TABLE fvc04_m ADD PRIMARY KEY (id);

-- check table structure
\d fvc04_m

/*
    Table "public.fvc04_m"
 Column |  Type   | Modifiers 
--------+---------+-----------
 id     | integer | not null
 mdt    | bytea   | 
Indexes:
    "fvc04_m_pkey" PRIMARY KEY, btree (id)
*/

-- compare size in disk for the tables
\dt+

/*
 Schema |      Name      |   Type   |  Owner   |    Size    | Description 
--------+----------------+----------+----------+------------+-------------
 public | fvc04          | table    | rodrigo  | 43 MB      | 
 public | fvc04_m        | table    | rodrigo  | 192 kB     | 
*/

\timing on

-- =========================================================

-- Verification (1:1)

SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM fvc04_m a, fvc04_m b
WHERE a.id = (SELECT id FROM fvc04 WHERE db = 3 AND fp = '101_1')
  AND b.id = (SELECT id FROM fvc04 WHERE db = 3 AND fp = '101_4');

-- faster!
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM fvc04_m a, fvc04_m b
WHERE a.id = 161
  AND b.id = 164;

/*
 match 
-------
 t
(1 row)
*/

SELECT bz_match(a.mdt, b.mdt) AS score
FROM fvc04_m a, fvc04_m b
WHERE a.id = 161
  AND b.id = 164;

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
FROM fvc04_m a, fvc04_m b
WHERE a.id = (SELECT id FROM fvc04 WHERE db = 3 AND fp = '101_1')
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

-- faster!
SELECT b.id AS first_matching_sample
FROM fvc04_m a, fvc04_m b
WHERE a.id = 161
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

-- returns all matches
SELECT array_agg(b.id) AS matching_samples
FROM fvc04_m a, fvc04_m b
WHERE a.id = 161
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40;

