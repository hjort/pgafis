/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

#ifndef PGAFIS_H
#define PGAFIS_H

#include <stdio.h>
#include <unistd.h>

#define get_progname pg_get_progname
#include <postgres.h>
#undef get_progname

#include "fmgr.h"
#include "utils/builtins.h"

#define ushort unsigned short

extern Datum pg_wsq_encode(PG_FUNCTION_ARGS);
extern Datum pg_min_detect(PG_FUNCTION_ARGS);
extern Datum pg_bz_match(PG_FUNCTION_ARGS);

#include "cwsq.h"
//#include "mindt.h"
#include "match.h"

#endif   /* PGAFIS_H */
