/**
 * pgAFIS - Automated Fingerprint Identification System Support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

#define get_progname pg_get_progname
#include <postgres.h>
#undef get_progname
#define bz_match nbis_bz_match
#include <bozorth.h>
#undef bz_match

#include "fmgr.h"
#include "utils/builtins.h"
#include <stdio.h>
#include <unistd.h>

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

int m1_xyt                  = 1; // M1 default {x,y,t} representation
int max_minutiae            = DEFAULT_BOZORTH_MINUTIAE;
int min_computable_minutiae = MIN_COMPUTABLE_BOZORTH_MINUTIAE;

int verbose_main      = 0;
int verbose_load      = 0;
int verbose_bozorth   = 0;
int verbose_threshold = 0;

FILE * errorfp        = FPNULL;

Datum bz_match(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(bz_match);
Datum
bz_match(PG_FUNCTION_ARGS)
{
	text *txt1 = PG_GETARG_TEXT_PP(0);
	text *txt2 = PG_GETARG_TEXT_PP(1);
	//int32 size = VARSIZE(txt) - VARHDRSZ;
	int32 score = 0;
	char *str1 = VARDATA_ANY(txt1);
	char *str2 = VARDATA_ANY(txt2);
	//size_t nbytes = VARSIZE_ANY_EXHDR(txt);

//        int np = 5;
        struct xyt_struct *ps = XYT_NULL; // probe structure
        struct xyt_struct *gs = XYT_NULL; // gallery structure

//        set_progname(0, "pgafis", 0); // definir nome do programa
//        errorfp = stderr; // saída de erro padrão

	// FIXME: não está funcionando...
	//if (!str)
	//if (txt == NULL)
	//	PG_RETURN_INT32(0);

	// TODO: carregar tabelas XYT a partir dos argumentos "text"

	score += 1;
	while (*str1) {
		if (*str1 == '\n')
			score++;
		str1++;
	}
	score += 1;
	while (*str2) {
		if (*str2 == '\n')
			score++;
		str2++;
	}

        if (ps != XYT_NULL)
                free((char *) ps);
        if (gs != XYT_NULL)
                free((char *) gs);

	PG_RETURN_INT32(score);
}

