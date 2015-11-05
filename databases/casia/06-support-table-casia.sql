-- create table containing only ids and minutiae
DROP TABLE IF EXISTS casia_m;
SELECT id, mdt INTO casia_m FROM casia;
ALTER TABLE casia_m ADD PRIMARY KEY (id);

-- check table structure
\d casia_m

/*
    Table "public.casia_m"
 Column |  Type   | Modifiers 
--------+---------+-----------
 id     | integer | not null
 mdt    | bytea   | 
Indexes:
    "casia_m_pkey" PRIMARY KEY, btree (id)
*/

-- compare size in disk for the tables
\d+

/*
                          List of relations
 Schema |     Name     |   Type   | Owner |    Size    | Description 
--------+--------------+----------+-------+------------+-------------
 public | casia        | table    | afis  | 2905 MB    | 
 public | casia_m      | table    | afis  | 9536 kB    | 
*/

\timing on

-- =========================================================

-- Verification (1:1)

SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM casia_m a, casia_m b
WHERE a.id = (SELECT id FROM casia WHERE fp = '000_L0_0')
  AND b.id = (SELECT id FROM casia WHERE fp = '000_L0_2');

-- faster!
SELECT (bz_match(a.mdt, b.mdt) >= 40) AS match
FROM casia_m a, casia_m b
WHERE a.id = 1
  AND b.id = 3;

/*
 match 
-------
 t
(1 row)
*/

SELECT bz_match(a.mdt, b.mdt) AS score
FROM casia_m a, casia_m b
WHERE a.id = 1
  AND b.id = 3;

/*
 score 
-------
    93
(1 row)
*/

-- =========================================================

-- Identification (1:N)

-- returns only first match
SELECT b.id AS first_matching_sample
FROM casia_m a, casia_m b
WHERE a.id = (SELECT id FROM casia WHERE fp = '001_L0_0')
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

/*
 first_matching_sample 
-----------------------
                  1726
(1 row)
*/

-- faster!
SELECT b.id AS first_matching_sample
FROM casia_m a, casia_m b
WHERE a.id = 41
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40
LIMIT 1;

-- returns all matches
SELECT array_agg(b.id) AS matching_samples
FROM casia_m a, casia_m b
WHERE a.id = 41
  AND b.id != a.id
  AND bz_match(a.mdt, b.mdt) >= 40;

/*
 matching_samples  
-------------------
 {1726,1839,45,44}
(1 row)
*/

