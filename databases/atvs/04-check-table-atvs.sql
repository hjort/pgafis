-- check table structure
\d atvs

/*
                                Table "public.atvs"
 Column |         Type          |                     Modifiers                     
--------+-----------------------+---------------------------------------------------
 id     | integer               | not null default nextval('atvs_id_seq'::regclass)
 fp     | character(18)         | not null
 ds     | smallint              | 
 pid    | smallint              | 
 of     | character(1)          | 
 sn     | character(2)          | 
 fid    | character(2)          | 
 whz    | character varying(12) | 
 bmp    | bytea                 | not null
 wsq    | bytea                 | 
 mdt    | bytea                 | 
 xyt    | text                  | 
 mins   | smallint              | 
 nfiq   | smallint              | 
Indexes:
    "atvs_pkey" PRIMARY KEY, btree (id)
    "atvs_fp_key" UNIQUE CONSTRAINT, btree (fp)
*/

-- =========================================================

-- verificação geral dos valores
SELECT id, fp, ds, pid, fid,
  pg_size_pretty(length(bmp)::numeric) AS bmp,
  pg_size_pretty(length(wsq)::numeric) AS wsq,
  pg_size_pretty(length(mdt)::numeric) AS mdt,
  pg_size_pretty(length(xyt)::numeric) AS xyt,
  mins,
  nfiq
FROM atvs
ORDER BY id
LIMIT 10;

/*
 id |         fp         | ds | pid | fid |  bmp  |  wsq  |    mdt    |    xyt     | mins | nfiq 
----+--------------------+----+-----+-----+-------+-------+-----------+------------+------+------
  1 | ds1_u01_f_fc_li_01 |  1 |   1 | li  | 89 kB | 24 kB | 506 bytes | 850 bytes  |   63 |    5
  2 | ds1_u01_f_fc_li_02 |  1 |   1 | li  | 89 kB | 22 kB | 314 bytes | 503 bytes  |   39 |    5
  3 | ds1_u01_f_fc_li_03 |  1 |   1 | li  | 89 kB | 23 kB | 482 bytes | 821 bytes  |   60 |    5
  4 | ds1_u01_f_fc_li_04 |  1 |   1 | li  | 89 kB | 23 kB | 602 bytes | 1021 bytes |   75 |    5
  5 | ds1_u01_f_fc_lm_01 |  1 |   1 | lm  | 89 kB | 24 kB | 530 bytes | 887 bytes  |   66 |    5
  6 | ds1_u01_f_fc_lm_02 |  1 |   1 | lm  | 89 kB | 23 kB | 602 bytes | 1024 bytes |   75 |    5
  7 | ds1_u01_f_fc_lm_03 |  1 |   1 | lm  | 89 kB | 24 kB | 594 bytes | 998 bytes  |   74 |    5
  8 | ds1_u01_f_fc_lm_04 |  1 |   1 | lm  | 89 kB | 24 kB | 498 bytes | 841 bytes  |   62 |    5
  9 | ds1_u01_f_fc_ri_01 |  1 |   1 | ri  | 89 kB | 24 kB | 506 bytes | 841 bytes  |   63 |    5
 10 | ds1_u01_f_fc_ri_02 |  1 |   1 | ri  | 89 kB | 23 kB | 482 bytes | 786 bytes  |   60 |    5
(10 rows)
*/

-- =========================================================

-- verificação de algumas digitais aleatórias
SELECT id, fp, ds, pid, fid,
  length(bmp) AS bmp_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes,
  length(xyt) AS xyt_chars,
  mins,
  nfiq
FROM atvs
ORDER BY random()
LIMIT 15;

/*
  id  |         fp         | ds | pid | fid | bmp_bytes | wsq_bytes | mdt_bytes | xyt_chars | mins | nfiq 
------+--------------------+----+-----+-----+-----------+-----------+-----------+-----------+------+------
  244 | ds1_u03_o_fc_li_04 |  1 |   3 | li  |     91078 |     22098 |       346 |       571 |   43 |    5
 1969 | ds2_u04_o_fc_li_01 |  2 |   4 | li  |     91078 |     20617 |       274 |       447 |   34 |    5
 3062 | ds2_u16_o_ft_lm_02 |  2 |  16 | lm  |    201078 |     35817 |      1010 |      1677 |  126 |    5
  129 | ds1_u02_f_ft_li_01 |  1 |   2 | li  |    201078 |     30509 |       578 |       992 |   72 |    5
  368 | ds1_u04_o_fo_rm_04 |  1 |   4 | rm  |    225078 |     41949 |       682 |      1198 |   85 |    3
 2844 | ds2_u13_o_fc_ri_04 |  2 |  13 | ri  |     91078 |     24308 |       394 |       663 |   49 |    5
 1350 | ds1_u15_f_fc_lm_02 |  1 |  15 | lm  |     91078 |     24125 |       458 |       773 |   57 |    5
 2606 | ds2_u11_f_fc_rm_02 |  2 |  11 | rm  |     91078 |     24095 |       666 |      1127 |   83 |    5
  553 | ds1_u06_o_fo_ri_01 |  1 |   6 | ri  |    225078 |     45384 |       866 |      1511 |  108 |    3
 1760 | ds2_u02_f_fo_rm_04 |  2 |   2 | rm  |    166838 |     39400 |       922 |      1596 |  115 |    4
 2665 | ds2_u11_o_fo_ri_01 |  2 |  11 | ri  |    166838 |     40723 |       658 |      1129 |   82 |    3
 1288 | ds1_u14_f_ft_lm_04 |  1 |  14 | lm  |    201078 |     22335 |       522 |       886 |   65 |    5
 2551 | ds2_u10_o_fc_lm_03 |  2 |  10 | lm  |     91078 |     22789 |       522 |       859 |   65 |    5
  445 | ds1_u05_o_fc_rm_01 |  1 |   5 | rm  |     91078 |     23099 |       394 |       671 |   49 |    5
 2621 | ds2_u11_f_fo_rm_01 |  2 |  11 | rm  |    166838 |     38395 |       434 |       752 |   54 |    4
(15 rows)
*/

-- =========================================================

-- verificação da amostra por tipo de sensor
SELECT ds, sn,
  pg_size_pretty(avg(length(bmp))) AS bmp,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins), 2) AS mins,
  trunc(avg(nfiq), 2) AS nfiq
FROM atvs
GROUP BY ds, sn
ORDER BY ds, sn;

/*
 ds | sn |  bmp   |  wsq  |    mdt    |    xyt     |  mins  | nfiq 
----+----+--------+-------+-----------+------------+--------+------
  1 | fc | 89 kB  | 23 kB | 480 bytes | 812 bytes  |  59.85 | 4.97
  1 | fo | 220 kB | 47 kB | 820 bytes | 1419 bytes | 102.25 | 3.39
  1 | ft | 196 kB | 29 kB | 532 bytes | 908 bytes  |  66.30 | 4.23
  2 | fc | 89 kB  | 22 kB | 499 bytes | 840 bytes  |  62.24 | 4.92
  2 | fo | 179 kB | 39 kB | 665 bytes | 1152 bytes |  82.93 | 3.37
  2 | ft | 196 kB | 24 kB | 553 bytes | 949 bytes  |  68.99 | 4.46
(6 rows)
*/

-- verificação da amostra por dedo
SELECT ds, fid,
  pg_size_pretty(avg(length(bmp))) AS bmp,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins), 2) AS mins,
  trunc(avg(nfiq), 2) AS nfiq
FROM atvs
GROUP BY ds, fid
ORDER BY ds, fid;

/*
 ds | fid |  bmp   |  wsq  |    mdt    |    xyt     | mins  | nfiq 
----+-----+--------+-------+-----------+------------+-------+------
  1 | li  | 168 kB | 33 kB | 610 bytes | 1045 bytes | 76.11 | 4.25
  1 | lm  | 168 kB | 33 kB | 643 bytes | 1102 bytes | 80.21 | 4.28
  1 | ri  | 168 kB | 33 kB | 576 bytes | 987 bytes  | 71.82 | 4.10
  1 | rm  | 168 kB | 33 kB | 613 bytes | 1051 bytes | 76.40 | 4.15
  2 | li  | 155 kB | 28 kB | 563 bytes | 965 bytes  | 70.24 | 4.27
  2 | lm  | 155 kB | 28 kB | 608 bytes | 1041 bytes | 75.77 | 4.25
  2 | ri  | 155 kB | 28 kB | 533 bytes | 911 bytes  | 66.45 | 4.28
  2 | rm  | 155 kB | 28 kB | 586 bytes | 1005 bytes | 73.09 | 4.21
(8 rows)
*/


-- verificação da amostra por imagem original/falsa e sensor
SELECT ds, of, sn,
  pg_size_pretty(avg(length(bmp))) AS bmp,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins), 2) AS mins,
  trunc(avg(nfiq), 2) AS nfiq
FROM atvs
GROUP BY ds, of, sn
ORDER BY ds, of, sn;

/*
 ds | of | sn |  bmp   |  wsq  |    mdt    |    xyt     |  mins  | nfiq 
----+----+----+--------+-------+-----------+------------+--------+------
  1 | f  | fc | 89 kB  | 24 kB | 576 bytes | 979 bytes  |  71.84 | 4.99
  1 | f  | fo | 220 kB | 47 kB | 766 bytes | 1319 bytes |  95.59 | 4.01
  1 | f  | ft | 196 kB | 28 kB | 540 bytes | 918 bytes  |  67.27 | 4.81
  1 | o  | fc | 89 kB  | 22 kB | 384 bytes | 644 bytes  |  47.86 | 4.94
  1 | o  | fo | 220 kB | 47 kB | 873 bytes | 1519 bytes | 108.91 | 2.77
  1 | o  | ft | 196 kB | 31 kB | 524 bytes | 897 bytes  |  65.33 | 3.66
  2 | f  | fc | 89 kB  | 23 kB | 643 bytes | 1084 bytes |  80.17 | 5.00
  2 | f  | fo | 163 kB | 37 kB | 636 bytes | 1097 bytes |  79.37 | 3.75
  2 | f  | ft | 196 kB | 19 kB | 651 bytes | 1115 bytes |  81.13 | 4.73
  2 | o  | fc | 89 kB  | 21 kB | 356 bytes | 597 bytes  |  44.32 | 4.85
  2 | o  | fo | 195 kB | 42 kB | 694 bytes | 1207 bytes |  86.50 | 3.00
  2 | o  | ft | 196 kB | 28 kB | 456 bytes | 784 bytes  |  56.85 | 4.19
(12 rows)
*/

