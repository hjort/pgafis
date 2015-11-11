-- create table containing only ids and minutiae
DROP TABLE IF EXISTS srcafis_m;
SELECT id, mdt INTO srcafis_m FROM srcafis;
ALTER TABLE srcafis_m ADD PRIMARY KEY (id);

-- check table structure
\d srcafis_m

/*
   Table "public.srcafis_m"
 Column |  Type   | Modifiers 
--------+---------+-----------
 id     | integer | not null
 mdt    | bytea   | 
Indexes:
    "srcafis_m_pkey" PRIMARY KEY, btree (id)
*/

-- compare size in disk for the tables
\d+

/*
                           List of relations
 Schema |      Name      |   Type   | Owner |    Size    | Description 
--------+----------------+----------+-------+------------+-------------
 public | srcafis        | table    | afis  | 283 MB     | 
 public | srcafis_id_seq | sequence | afis  | 8192 bytes | 
 public | srcafis_m      | table    | afis  | 1144 kB    | 
*/

\timing on

-- =========================================================

-- Verification (1:1)

SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM srcafis_m a, srcafis_m b
WHERE a.id = (SELECT id FROM srcafis WHERE ds = 'FVC2000/DB2_B' AND fp = '109_1')
  AND b.id = (SELECT id FROM srcafis WHERE ds = 'FVC2000/DB2_B' AND fp = '109_2');

-- faster!
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM srcafis_m a, srcafis_m b
WHERE a.id = 6
  AND b.id = 19;

/*
 match 
-------
 t
(1 row)
*/

SELECT bz_match(a.mdt, b.mdt) AS score
FROM srcafis_m a, srcafis_m b
WHERE a.id = 6
  AND b.id = 19;

/*
 score 
-------
   151
(1 row)
*/

-- =========================================================

-- Identification (1:N)

-- returns only first match
SELECT b.id AS first_matching_sample
FROM srcafis_m a, srcafis_m b
WHERE a.id = (SELECT id FROM srcafis WHERE ds = 'FVC2000/DB2_B' AND fp = '109_1')
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

/*
 first_matching_sample 
-----------------------
                   166
(1 row)
*/

-- faster!
SELECT b.id AS first_matching_sample
FROM srcafis_m a, srcafis_m b
WHERE a.id = 6
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

-- returns all matches
SELECT array_agg(b.id) AS matching_samples
FROM srcafis_m a, srcafis_m b
WHERE a.id = 6
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40;

/*
          matching_samples          
------------------------------------
 {166,232,240,19,28,47,69,72,76,80}
(1 row)
*/

