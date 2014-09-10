/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

/*
SELECT (bz_match(a.xyt, b.xyt) >= 30) AS match
FROM dedos a, dedos b
WHERE a.id = 1 AND b.id = 6;

SELECT bz_match(wsq, wsq) from fingers;
*/

#define bz_match nbis_bz_match
#include <bozorth.h>
#undef bz_match

#include "xyt.h"

int m1_xyt                  = 1; // -m1: M1 default {x,y,t} representation
int max_minutiae            = DEFAULT_BOZORTH_MINUTIAE; // -n max-minutiae
int min_computable_minutiae = MIN_COMPUTABLE_BOZORTH_MINUTIAE; // -A minminutiae=#

int verbose_main      = 0; // -v
int verbose_load      = 0;
int verbose_bozorth   = 0;
int verbose_threshold = 0;

FILE * errorfp = FPNULL;

// CREATE FUNCTION bz_match(text, text) RETURNS int;
PG_FUNCTION_INFO_V1(pg_bz_match_text);
Datum
pg_bz_match_text(PG_FUNCTION_ARGS)
{
	text *txt1 = PG_GETARG_TEXT_PP(0);
	text *txt2 = PG_GETARG_TEXT_PP(1);
	char *str1 = VARDATA_ANY(txt1);
	char *str2 = VARDATA_ANY(txt2);
	//int32 size = VARSIZE(txt1) - VARHDRSZ;
	//size_t nbytes = VARSIZE_ANY_EXHDR(txt1);
	int32 score = 0;

	//int np = 5;
	struct xyt_struct *ps = XYT_NULL; // probe structure
	struct xyt_struct *gs = XYT_NULL; // gallery structure

	//set_progname(0, "pgafis", 0); // definir nome do programa
	//errorfp = stderr; // saída de erro padrão

	//elog(NOTICE, "size: %d", size);

	ps = load_xyt(str1);
	if (ps != XYT_NULL)
		gs = load_xyt(str2);

	if (ps != XYT_NULL && gs != XYT_NULL)
		score = bozorth_main(ps, gs);

	if (ps != XYT_NULL)
		free((char *) ps);
	if (gs != XYT_NULL)
		free((char *) gs);

//	elog(NOTICE, "score: %d", score);

	PG_RETURN_INT32(score);
}

// CREATE FUNCTION bz_match(bytea, bytea) RETURNS int;
PG_FUNCTION_INFO_V1(pg_bz_match_bytea);
Datum
pg_bz_match_bytea(PG_FUNCTION_ARGS)
{
	bytea *wsq1, *wsq2;
	unsigned size1, size2;
	unsigned char *data1, *data2;
	int32 score = 0;

	struct xyt_struct *ps = XYT_NULL; // probe structure
	struct xyt_struct *gs = XYT_NULL; // gallery structure

	wsq1 = PG_GETARG_BYTEA_P(0);
	size1 = VARSIZE(wsq1) - VARHDRSZ;
	data1 = (unsigned char *) VARDATA(wsq1);

	wsq2 = PG_GETARG_BYTEA_P(1);
	size2 = VARSIZE(wsq2) - VARHDRSZ;
	data2 = (unsigned char *) VARDATA(wsq2);

	ps = load_xyt_binary(data1, size1);
	if (ps != XYT_NULL)
		gs = load_xyt_binary(data2, size2);

	if (ps != XYT_NULL && gs != XYT_NULL)
		score = bozorth_main(ps, gs);

	if (ps != XYT_NULL)
		free((char *) ps);
	if (gs != XYT_NULL)
		free((char *) gs);

	if (debug > 0)
		elog(NOTICE, "score: %d", score);

	PG_RETURN_INT32(score);
}

