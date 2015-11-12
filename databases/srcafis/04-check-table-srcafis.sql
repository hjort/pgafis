-- check table structure
\d srcafis

/*
                                Table "public.srcafis"
 Column |         Type          |                      Modifiers                       
--------+-----------------------+------------------------------------------------------
 id     | integer               | not null default nextval('srcafis_id_seq'::regclass)
 ds     | character varying(13) | not null
 fp     | character(8)          | not null
 pid    | smallint              | 
 fid    | smallint              | 
 whz    | character varying(12) | 
 tif    | bytea                 | not null
 wsq    | bytea                 | 
 mdt    | bytea                 | 
 xyt    | text                  | 
 mins   | smallint              | 
 nfiq   | smallint              | 
Indexes:
    "srcafis_pkey" PRIMARY KEY, btree (id)
    "srcafis_ds_fp_key" UNIQUE CONSTRAINT, btree (ds, fp)
    "srcafis_ds_pid_fid_idx" btree (ds, pid, fid)
*/

-- =========================================================

-- verificação geral dos valores
SELECT id, ds, fp, pid, fid,
  pg_size_pretty(length(tif)::numeric) AS tif,
  pg_size_pretty(length(wsq)::numeric) AS wsq,
  pg_size_pretty(length(mdt)::numeric) AS mdt,
  pg_size_pretty(length(xyt)::numeric) AS xyt,
  mins,
  nfiq
FROM srcafis
ORDER BY id
LIMIT 10;

/*
 id |      ds       |    fp    | pid | fid |  tif  |  wsq  |    mdt    |    xyt     | mins | nfiq 
----+---------------+----------+-----+-----+-------+-------+-----------+------------+------+------
  1 | FVC2000/DB2_B | 104_3    | 104 |   1 | 92 kB | 24 kB | 394 bytes | 668 bytes  |   49 |    2
  2 | FVC2000/DB2_B | 105_6    | 105 |   1 | 92 kB | 19 kB | 218 bytes | 357 bytes  |   27 |    2
  3 | FVC2000/DB2_B | 107_8    | 107 |   1 | 92 kB | 22 kB | 402 bytes | 689 bytes  |   50 |    2
  4 | FVC2000/DB2_B | 105_3    | 105 |   1 | 92 kB | 24 kB | 410 bytes | 694 bytes  |   51 |    2
  5 | FVC2000/DB2_B | 106_4    | 106 |   1 | 92 kB | 23 kB | 578 bytes | 980 bytes  |   72 |    2
  6 | FVC2000/DB2_B | 109_1    | 109 |   1 | 92 kB | 23 kB | 674 bytes | 1135 bytes |   84 |    1
  7 | FVC2000/DB2_B | 110_4    | 110 |   1 | 92 kB | 25 kB | 434 bytes | 736 bytes  |   54 |    3
  8 | FVC2000/DB2_B | 102_5    | 102 |   1 | 92 kB | 23 kB | 554 bytes | 933 bytes  |   69 |    2
  9 | FVC2000/DB2_B | 110_6    | 110 |   1 | 92 kB | 24 kB | 530 bytes | 890 bytes  |   66 |    3
 10 | FVC2000/DB2_B | 104_1    | 104 |   1 | 92 kB | 25 kB | 386 bytes | 645 bytes  |   48 |    2
(10 rows)
*/

-- =========================================================

-- verificação de algumas digitais aleatórias
SELECT id, ds, fp, pid, fid,
  length(tif) AS tif_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes,
  length(xyt) AS xyt_chars,
  mins,
  nfiq
FROM srcafis
ORDER BY random()
LIMIT 15;

/*
  id  |      ds       |    fp    | pid | fid | tif_bytes | wsq_bytes | mdt_bytes | xyt_chars | mins | nfiq 
------+---------------+----------+-----+-----+-----------+-----------+-----------+-----------+------+------
  366 | FVC2004/DB2_B | 108_4    | 108 |   1 |    119904 |     33214 |       458 |       774 |   57 |    5
  164 | FVC2000/DB1_B | 105_3    | 105 |   1 |     90512 |     27764 |       354 |       591 |   44 |    5
 1532 | Neurotech/UrU | 076_9_8  |  76 |   9 |    116788 |     25166 |       506 |       878 |   63 |    5
 1789 | FVC2002/DB4_B | 109_7    | 109 |   1 |    111104 |     20860 |       546 |       939 |   68 |    5
 1122 | Neurotech/UrU | 022_4_7  |  22 |   4 |    116788 |     24788 |       370 |       627 |   46 |    3
 1219 | Neurotech/UrU | 012_7_1  |  12 |   7 |    116788 |     27105 |       386 |       676 |   48 |    5
  582 | FVC2004/DB3_B | 108_3    | 108 |   1 |    144512 |     36868 |       714 |      1227 |   89 |    4
  815 | Neurotech/CM  | 045_5_7  |  45 |   5 |    242450 |     41658 |       762 |      1344 |   95 |    3
 1075 | Neurotech/UrU | 022_3_6  |  22 |   3 |    116788 |     25302 |       410 |       685 |   51 |    5
 1578 | Donated1      | 999_2_3  | 999 |   2 |    220384 |     20097 |       634 |      1062 |   79 |    5
  218 | FVC2000/DB1_B | 110_8    | 110 |   1 |     90512 |     28403 |       378 |       639 |   47 |    5
 1946 | FVC2002/DB3_B | 108_7    | 108 |   1 |     90512 |     21954 |       818 |      1399 |  102 |    5
 1425 | Neurotech/UrU | 013_8_3  |  13 |   8 |    116788 |     30153 |       658 |      1141 |   82 |    5
 1170 | Neurotech/UrU | 017_1_4  |  17 |   1 |    116788 |     24110 |       394 |       677 |   49 |    5
 1765 | FVC2002/DB4_B | 104_6    | 104 |   1 |    111104 |     26314 |       330 |       555 |   41 |    3
(15 rows)
*/

-- =========================================================

-- verificação da amostra por base de dados
SELECT ds,
  pg_size_pretty(avg(length(tif))) AS tif,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins), 2) AS mins,
  trunc(avg(nfiq), 2) AS nfiq,
  count(1)
FROM srcafis
GROUP BY ds
ORDER BY ds;

/*
      ds       |  tif   |  wsq  |    mdt     |    xyt     |  mins  | nfiq | count 
---------------+--------+-------+------------+------------+--------+------+-------
 Donated1      | 212 kB | 19 kB | 589 bytes  | 974 bytes  |  73.43 | 5.00 |    72
 FVC2000/DB1_B | 88 kB  | 27 kB | 422 bytes  | 714 bytes  |  52.50 | 5.00 |    80
 FVC2000/DB2_B | 92 kB  | 23 kB | 462 bytes  | 781 bytes  |  57.50 | 2.63 |    80
 FVC2000/DB3_B | 210 kB | 52 kB | 1283 bytes | 2198 bytes | 160.16 | 4.26 |    80
 FVC2000/DB4_B | 86 kB  | 20 kB | 278 bytes  | 477 bytes  |  34.57 | 4.32 |    80
 FVC2002/DB1_B | 142 kB | 28 kB | 356 bytes  | 617 bytes  |  44.28 | 4.86 |    80
 FVC2002/DB2_B | 162 kB | 36 kB | 518 bytes  | 892 bytes  |  64.53 | 2.76 |    80
 FVC2002/DB3_B | 88 kB  | 22 kB | 615 bytes  | 1033 bytes |  76.63 | 4.92 |    80
 FVC2002/DB4_B | 109 kB | 22 kB | 382 bytes  | 645 bytes  |  47.50 | 4.86 |    80
 FVC2004/DB1_B | 301 kB | 32 kB | 436 bytes  | 757 bytes  |  54.28 | 3.30 |    80
 FVC2004/DB2_B | 117 kB | 31 kB | 410 bytes  | 699 bytes  |  51.11 | 5.00 |    80
 FVC2004/DB3_B | 141 kB | 30 kB | 732 bytes  | 1258 bytes |  91.35 | 3.21 |    80
 FVC2004/DB4_B | 109 kB | 26 kB | 473 bytes  | 803 bytes  |  58.97 | 4.92 |    80
 Neurotech/CM  | 237 kB | 36 kB | 556 bytes  | 980 bytes  |  69.28 | 2.23 |   408
 Neurotech/UrU | 114 kB | 26 kB | 472 bytes  | 811 bytes  |  58.79 | 4.75 |   520
(15 rows)
*/

-- verificação da amostra por base de dados e dedo
SELECT ds, fid,
  pg_size_pretty(avg(length(tif))) AS tif,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins), 2) AS mins,
  trunc(avg(nfiq), 2) AS nfiq
FROM srcafis
GROUP BY ds, fid
ORDER BY ds, fid;

/*
      ds       | fid |  tif   |  wsq  |    mdt     |    xyt     |  mins  | nfiq 
---------------+-----+--------+-------+------------+------------+--------+------
 Donated1      |   1 | 212 kB | 20 kB | 594 bytes  | 978 bytes  |  74.00 | 5.00
 Donated1      |   2 | 212 kB | 19 kB | 703 bytes  | 1163 bytes |  87.62 | 5.00
 Donated1      |   3 | 211 kB | 18 kB | 491 bytes  | 803 bytes  |  61.12 | 5.00
 Donated1      |   4 | 212 kB | 19 kB | 606 bytes  | 1013 bytes |  75.50 | 5.00
 Donated1      |   5 | 212 kB | 19 kB | 614 bytes  | 1026 bytes |  76.50 | 5.00
 Donated1      |   6 | 212 kB | 19 kB | 678 bytes  | 1123 bytes |  84.50 | 5.00
 Donated1      |   7 | 213 kB | 19 kB | 523 bytes  | 856 bytes  |  65.12 | 5.00
 Donated1      |   8 | 211 kB | 20 kB | 561 bytes  | 931 bytes  |  69.87 | 5.00
 Donated1      |  10 | 210 kB | 19 kB | 535 bytes  | 878 bytes  |  66.62 | 5.00
 FVC2000/DB1_B |   1 | 88 kB  | 27 kB | 422 bytes  | 714 bytes  |  52.50 | 5.00
 FVC2000/DB2_B |   1 | 92 kB  | 23 kB | 462 bytes  | 781 bytes  |  57.50 | 2.63
 FVC2000/DB3_B |   1 | 210 kB | 52 kB | 1283 bytes | 2198 bytes | 160.16 | 4.26
 FVC2000/DB4_B |   1 | 86 kB  | 20 kB | 278 bytes  | 477 bytes  |  34.57 | 4.32
 FVC2002/DB1_B |   1 | 142 kB | 28 kB | 356 bytes  | 617 bytes  |  44.28 | 4.86
 FVC2002/DB2_B |   1 | 162 kB | 36 kB | 518 bytes  | 892 bytes  |  64.53 | 2.76
 FVC2002/DB3_B |   1 | 88 kB  | 22 kB | 615 bytes  | 1033 bytes |  76.63 | 4.92
 FVC2002/DB4_B |   1 | 109 kB | 22 kB | 382 bytes  | 645 bytes  |  47.50 | 4.86
 FVC2004/DB1_B |   1 | 301 kB | 32 kB | 436 bytes  | 757 bytes  |  54.28 | 3.30
 FVC2004/DB2_B |   1 | 117 kB | 31 kB | 410 bytes  | 699 bytes  |  51.11 | 5.00
 FVC2004/DB3_B |   1 | 141 kB | 30 kB | 732 bytes  | 1258 bytes |  91.35 | 3.21
 FVC2004/DB4_B |   1 | 109 kB | 26 kB | 473 bytes  | 803 bytes  |  58.97 | 4.92
 Neurotech/CM  |   3 | 237 kB | 35 kB | 527 bytes  | 926 bytes  |  65.65 | 2.09
 Neurotech/CM  |   4 | 237 kB | 34 kB | 529 bytes  | 935 bytes  |  65.88 | 2.31
 Neurotech/CM  |   5 | 237 kB | 40 kB | 597 bytes  | 1051 bytes |  74.45 | 2.05
 Neurotech/CM  |   6 | 237 kB | 40 kB | 610 bytes  | 1078 bytes |  76.10 | 2.14
 Neurotech/CM  |   7 | 237 kB | 34 kB | 505 bytes  | 891 bytes  |  62.98 | 2.25
 Neurotech/CM  |   8 | 237 kB | 34 kB | 568 bytes  | 1004 bytes |  70.84 | 2.56
 Neurotech/UrU |   1 | 114 kB | 25 kB | 443 bytes  | 757 bytes  |  55.17 | 4.78
 Neurotech/UrU |   2 | 114 kB | 26 kB | 472 bytes  | 811 bytes  |  58.83 | 4.75
 Neurotech/UrU |   3 | 114 kB | 26 kB | 447 bytes  | 764 bytes  |  55.73 | 4.71
 Neurotech/UrU |   4 | 114 kB | 26 kB | 497 bytes  | 858 bytes  |  61.94 | 4.89
 Neurotech/UrU |   5 | 114 kB | 28 kB | 537 bytes  | 916 bytes  |  66.98 | 4.62
 Neurotech/UrU |   6 | 114 kB | 28 kB | 537 bytes  | 925 bytes  |  66.91 | 4.83
 Neurotech/UrU |   7 | 114 kB | 26 kB | 435 bytes  | 749 bytes  |  54.20 | 4.77
 Neurotech/UrU |   8 | 114 kB | 26 kB | 474 bytes  | 814 bytes  |  59.08 | 4.64
 Neurotech/UrU |   9 | 114 kB | 26 kB | 457 bytes  | 793 bytes  |  56.87 | 4.83
 Neurotech/UrU |  10 | 114 kB | 25 kB | 413 bytes  | 713 bytes  |  51.43 | 4.70
(37 rows)
*/

