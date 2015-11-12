-- check table structure
\d casia

/*
                            Table "public.casia"
 Column |     Type     |                     Modifiers                      
--------+--------------+----------------------------------------------------
 id     | integer      | not null default nextval('casia_id_seq'::regclass)
 fp     | character(8) | not null
 pid    | smallint     | 
 fid    | character(2) | 
 bmp    | bytea        | not null
 wsq    | bytea        | 
 mdt    | bytea        | 
 xyt    | text         | 
 mins   | smallint     | 
 nfiq   | smallint     | 
Indexes:
    "casia_pkey" PRIMARY KEY, btree (id)
    "casia_fp_key" UNIQUE CONSTRAINT, btree (fp)
    "casia_pid_fid_idx" btree (pid, fid)
*/

-- =========================================================

-- verificação geral dos valores
SELECT id, fp, pid, fid,
  pg_size_pretty(length(bmp)::numeric) AS bmp,
  pg_size_pretty(length(wsq)::numeric) AS wsq,
  pg_size_pretty(length(mdt)::numeric) AS mdt,
  pg_size_pretty(length(xyt)::numeric) AS xyt,
  mins,
  nfiq
FROM casia
ORDER BY id
LIMIT 10;

/*
 id |    fp    | pid | fid |  bmp   |  wsq  |    mdt    |    xyt     | mins | nfiq 
----+----------+-----+-----+--------+-------+-----------+------------+------+------
  1 | 000_L0_0 |   0 | L0  | 115 kB | 29 kB | 666 bytes | 1137 bytes |   83 |    5
  2 | 000_L0_1 |   0 | L0  | 115 kB | 30 kB | 458 bytes | 772 bytes  |   57 |    5
  3 | 000_L0_2 |   0 | L0  | 115 kB | 29 kB | 802 bytes | 1387 bytes |  100 |    5
  4 | 000_L0_3 |   0 | L0  | 115 kB | 29 kB | 610 bytes | 1053 bytes |   76 |    5
  5 | 000_L0_4 |   0 | L0  | 115 kB | 30 kB | 578 bytes | 989 bytes  |   72 |    5
  6 | 000_L1_0 |   0 | L1  | 115 kB | 26 kB | 538 bytes | 927 bytes  |   67 |    5
  7 | 000_L1_1 |   0 | L1  | 115 kB | 26 kB | 434 bytes | 738 bytes  |   54 |    5
  8 | 000_L1_2 |   0 | L1  | 115 kB | 27 kB | 506 bytes | 862 bytes  |   63 |    5
  9 | 000_L1_3 |   0 | L1  | 115 kB | 29 kB | 602 bytes | 1030 bytes |   75 |    5
 10 | 000_L1_4 |   0 | L1  | 115 kB | 27 kB | 570 bytes | 979 bytes  |   71 |    5
(10 rows)
*/

-- =========================================================

-- verificação de algumas digitais aleatórias
SELECT id, fp, pid, fid,
  length(bmp) AS bmp_bytes,
  length(wsq) AS wsq_bytes,
  length(mdt) AS mdt_bytes,
  length(xyt) AS xyt_chars,
  mins,
  nfiq
FROM casia
ORDER BY random()
LIMIT 15;

/*
  id   |    fp    | pid | fid | bmp_bytes | wsq_bytes | mdt_bytes | xyt_chars | mins | nfiq 
-------+----------+-----+-----+-----------+-----------+-----------+-----------+------+------
  7080 | 176_R3_4 | 176 | R3  |    117846 |     22869 |       410 |       710 |   51 |    5
  4592 | 114_R2_1 | 114 | R2  |    117846 |     25788 |       378 |       629 |   47 |    5
  6606 | 165_L1_0 | 165 | L1  |    117846 |     24166 |       394 |       688 |   49 |    5
   480 | 011_R3_4 |  11 | R3  |    117846 |     27276 |       586 |      1023 |   73 |    5
 14552 | 363_R2_1 | 363 | R2  |    117846 |     21572 |       234 |       406 |   29 |    5
  2736 | 068_L3_0 |  68 | L3  |    117846 |     23105 |       434 |       737 |   54 |    5
  1075 | 026_R2_4 |  26 | R2  |    117846 |     27413 |       418 |       719 |   52 |    5
  8977 | 224_L3_1 | 224 | L3  |    117846 |     24268 |       538 |       926 |   67 |    5
  5746 | 143_R1_0 | 143 | R1  |    117846 |     24166 |       330 |       564 |   41 |    5
  1436 | 035_R3_0 |  35 | R3  |    117846 |     25019 |       354 |       613 |   44 |    5
  7441 | 186_L0_0 | 186 | L0  |    117846 |     29719 |       650 |      1095 |   81 |    5
  1821 | 045_R0_0 |  45 | R0  |    117846 |     28920 |       690 |      1167 |   86 |    5
 19726 | 493_L1_0 | 493 | L1  |    117846 |     28271 |       634 |      1074 |   79 |    5
 19260 | 481_L3_4 | 481 | L3  |    117846 |     26733 |       458 |       774 |   57 |    5
 13402 | 335_L0_1 | 335 | L0  |    117846 |     23721 |       346 |       579 |   43 |    5
(15 rows)
*/

-- =========================================================

-- verificação sumária da amostra
SELECT fid,
  pg_size_pretty(avg(length(bmp))) AS bmp,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins), 2) AS mins,
  trunc(avg(nfiq), 2) AS nfiq
FROM casia
GROUP BY fid
ORDER BY fid;

/*
 fid |  bmp   |  wsq  |    mdt    |    xyt    | mins  | nfiq 
-----+--------+-------+-----------+-----------+-------+------
 L0  | 115 kB | 26 kB | 464 bytes | 792 bytes | 57.75 | 4.95
 L1  | 115 kB | 24 kB | 428 bytes | 735 bytes | 53.33 | 4.96
 L2  | 115 kB | 24 kB | 433 bytes | 745 bytes | 53.99 | 4.96
 L3  | 115 kB | 24 kB | 424 bytes | 729 bytes | 52.84 | 4.96
 R0  | 115 kB | 27 kB | 446 bytes | 758 bytes | 55.56 | 4.95
 R1  | 115 kB | 25 kB | 412 bytes | 704 bytes | 51.26 | 4.96
 R2  | 115 kB | 24 kB | 408 bytes | 699 bytes | 50.82 | 4.96
 R3  | 115 kB | 24 kB | 415 bytes | 713 bytes | 51.74 | 4.95
(8 rows)
*/

