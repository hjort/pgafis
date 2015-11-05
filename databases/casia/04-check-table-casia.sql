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
*/

-- =========================================================

-- verificação sumária da amostra
SELECT fid,
  pg_size_pretty(avg(length(bmp))) AS bmp,
  pg_size_pretty(avg(length(wsq))) AS wsq,
  pg_size_pretty(trunc(avg(length(mdt)))) AS mdt,
  pg_size_pretty(trunc(avg(length(xyt)))) AS xyt,
  trunc(avg(mins))::int AS mins,
  trunc(avg(nfiq))::int AS nfiq
FROM casia
GROUP BY fid
ORDER BY fid;

/*
*/

