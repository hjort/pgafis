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
WHERE wsq IS NULL
ORDER BY id
LIMIT 10;

/*
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
*/

-- =========================================================

-- verificação da amostra por base de dados
SELECT ds,
  pg_size_pretty(avg(length(bmp))) AS bmp,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins), 2) AS mins,
  trunc(avg(nfiq), 2) AS nfiq
FROM srcafis
GROUP BY ds
ORDER BY ds;

-- verificação da amostra por base de dados e dedo
SELECT ds, fid,
  pg_size_pretty(avg(length(bmp))) AS bmp,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins), 2) AS mins,
  trunc(avg(nfiq), 2) AS nfiq
FROM srcafis
GROUP BY ds, fid
ORDER BY ds, fid;

