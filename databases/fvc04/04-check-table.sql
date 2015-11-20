-- check table structure
\d fvc04

/*
                            Table "public.fvc04"
 Column |     Type     |                     Modifiers                      
--------+--------------+----------------------------------------------------
 id     | integer      | not null default nextval('fvc04_id_seq'::regclass)
 db     | smallint     | not null
 fp     | character(5) | not null
 tif    | bytea        | not null
 wsq    | bytea        | 
 mdt    | bytea        | 
 xyt    | text         | 
 mins   | smallint     | 
 nfiq   | smallint     | 
Indexes:
    "fvc04_pkey" PRIMARY KEY, btree (id)
    "fvc04_db_fp_key" UNIQUE CONSTRAINT, btree (db, fp)
*/

-- =========================================================

-- verificação geral dos valores
SELECT id, db, fp,
  pg_size_pretty(length(tif)::numeric) AS tif,
  pg_size_pretty(length(wsq)::numeric) AS wsq,
  pg_size_pretty(length(mdt)::numeric) AS mdt,
  pg_size_pretty(length(xyt)::numeric) AS xyt,
  mins,
  nfiq
FROM fvc04
ORDER BY id
LIMIT 10;

/*
 id | db |  fp   |  tif   |  wsq  |    mdt    |    xyt    | mins | nfiq 
----+----+-------+--------+-------+-----------+-----------+------+------
  1 |  1 | 101_1 | 301 kB | 25 kB | 266 bytes | 436 bytes |   33 |    5
  2 |  1 | 101_2 | 301 kB | 35 kB | 514 bytes | 882 bytes |   64 |    2
  3 |  1 | 101_3 | 301 kB | 28 kB | 330 bytes | 562 bytes |   41 |    2
  4 |  1 | 101_4 | 301 kB | 28 kB | 418 bytes | 711 bytes |   52 |    2
  5 |  1 | 101_5 | 301 kB | 28 kB | 498 bytes | 853 bytes |   62 |    2
  6 |  1 | 101_6 | 301 kB | 33 kB | 394 bytes | 657 bytes |   49 |    3
  7 |  1 | 101_7 | 301 kB | 28 kB | 506 bytes | 861 bytes |   63 |    2
  8 |  1 | 101_8 | 301 kB | 28 kB | 514 bytes | 882 bytes |   64 |    5
  9 |  1 | 102_1 | 301 kB | 20 kB | 274 bytes | 474 bytes |   34 |    3
 10 |  1 | 102_2 | 301 kB | 38 kB | 538 bytes | 937 bytes |   67 |    3
(10 rows)
*/

-- =========================================================

-- verificação de algumas digitais aleatórias
SELECT id, db, fp,
  length(tif) AS tif_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes,
  length(xyt) AS xyt_chars,
  mins,
  nfiq
FROM fvc04
ORDER BY random()
LIMIT 15;

/*
 id  | db |  fp   | tif_bytes | wsq_bytes | mdt_bytes | xyt_chars | mins | nfiq 
-----+----+-------+-----------+-----------+-----------+-----------+------+------
  67 |  1 | 109_3 |    307712 |     35374 |       442 |       760 |   55 |    2
 174 |  3 | 102_6 |    144512 |     19529 |       618 |      1080 |   77 |    4
  97 |  2 | 103_1 |    119904 |     32579 |       378 |       653 |   47 |    2
 117 |  2 | 105_5 |    119904 |     32828 |       570 |       993 |   71 |    2
 300 |  4 | 108_4 |    111104 |     27327 |       378 |       636 |   47 |    3
 289 |  4 | 107_1 |    111104 |     28344 |       354 |       605 |   44 |    2
 182 |  3 | 103_6 |    144512 |     23674 |       570 |       957 |   71 |    5
 170 |  3 | 102_2 |    144512 |     27763 |       890 |      1531 |  111 |    3
 307 |  4 | 109_3 |    111104 |     28682 |       426 |       724 |   53 |    3
  26 |  1 | 104_2 |    307712 |     22513 |       322 |       572 |   40 |    3
 228 |  3 | 109_4 |    144512 |     32423 |       818 |      1421 |  102 |    3
 275 |  4 | 105_3 |    111104 |     24978 |       554 |       953 |   69 |    5
  37 |  1 | 105_5 |    307712 |     40169 |       498 |       855 |   62 |    3
 135 |  2 | 107_7 |    119904 |     31717 |       554 |       929 |   69 |    5
 114 |  2 | 105_2 |    119904 |     29068 |       434 |       739 |   54 |    5
(15 rows)
*/

-- =========================================================

-- verificação sumária da amostra
SELECT db,
  pg_size_pretty(avg(length(tif))) AS tif,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins))::int AS mins,
  trunc(avg(nfiq))::int AS nfiq,
  count(1)
FROM fvc04
GROUP BY db
ORDER BY db;

/*
 db |  tif   |  wsq  |    mdt    |    xyt     | mins | nfiq | count 
----+--------+-------+-----------+------------+------+------+-------
  1 | 301 kB | 32 kB | 436 bytes | 757 bytes  |   54 |    3 |    80
  2 | 117 kB | 31 kB | 410 bytes | 699 bytes  |   51 |    4 |    80
  3 | 141 kB | 30 kB | 732 bytes | 1258 bytes |   91 |    3 |    80
  4 | 109 kB | 26 kB | 473 bytes | 803 bytes  |   58 |    5 |    80
(4 rows)
*/

