/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

#include "pgafis.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

extern Datum pg_wsq_encode(PG_FUNCTION_ARGS);
extern Datum pg_nfiq(PG_FUNCTION_ARGS);
extern Datum pg_min_detect(PG_FUNCTION_ARGS);
extern Datum pg_mdt_text(PG_FUNCTION_ARGS);
extern Datum pg_mdt_mincnt(PG_FUNCTION_ARGS);
extern Datum pg_bz_match_text(PG_FUNCTION_ARGS);
extern Datum pg_bz_match_bytea(PG_FUNCTION_ARGS);

#include "cwsq.h"
#include "mindt.h"
#include "fiq.h"
#include "match.h"
#include "mdt.h"

int debug = 0;

