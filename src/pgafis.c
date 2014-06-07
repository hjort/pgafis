/**
 * pgAFIS - Automated Fingerprint Identification System Support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

#include <stdio.h>
#include <unistd.h>

#define get_progname pg_get_progname
#include <postgres.h>
#undef get_progname
#define bz_match nbis_bz_match
#include <bozorth.h>
#undef bz_match

#include "fmgr.h"
#include "utils/builtins.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

int m1_xyt                  = 1; // -m1: M1 default {x,y,t} representation
int max_minutiae            = DEFAULT_BOZORTH_MINUTIAE; // -n max-minutiae
int min_computable_minutiae = MIN_COMPUTABLE_BOZORTH_MINUTIAE; // -A minminutiae=#

int verbose_main      = 0; // -v
int verbose_load      = 0;
int verbose_bozorth   = 0;
int verbose_threshold = 0;

FILE * errorfp = FPNULL;

struct xyt_struct * load_xyt(char *str);

Datum pg_bz_match(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(pg_bz_match);
Datum
pg_bz_match(PG_FUNCTION_ARGS)
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

	PG_RETURN_INT32(score);
}

struct xyt_struct * load_xyt(char *str)
{
	int nminutiae; // número da linha da minúcia
	int m;
	int i;
	int nargs_expected; // qtde esperada de colunas

	struct xyt_struct * xyt_s;
	struct xytq_struct * xytq_s;
	int xvals_lng[MAX_FILE_MINUTIAE], // temporary lists to store all the minutiae from a finger
		yvals_lng[MAX_FILE_MINUTIAE],
		tvals_lng[MAX_FILE_MINUTIAE],
		qvals_lng[MAX_FILE_MINUTIAE];
	char xyt_line[MAX_LINE_LENGTH];

	nminutiae = 0;
	nargs_expected = 0;

	memset(xyt_line, 0, MAX_LINE_LENGTH);

	do {

		if (*str != '\n' && *str != '\0') {
			strncat(xyt_line, str++, 1);
			continue;
		}

		m = sscanf(xyt_line, "%d %d %d %d",
			&xvals_lng[nminutiae],
			&yvals_lng[nminutiae],
			&tvals_lng[nminutiae],
			&qvals_lng[nminutiae]);

		//elog(NOTICE, "%2d = <%s>", nminutiae + 1, xyt_line);

		memset(xyt_line, 0, MAX_LINE_LENGTH);

		if (nminutiae == 0)
		{
			if (m != 3 && m != 4) 
			{
				elog(ERROR, "Invalid format of minutiae data on line %u", nminutiae + 1);
				return XYT_NULL;
			}
			nargs_expected = m;
		} 
		else 
		{
			if (m != nargs_expected)
			{
				elog(ERROR, "Inconsistent argument count on line %u of minutiae data", nminutiae + 1);
				return XYT_NULL;
			}
		}

		if (m == 3)
			qvals_lng[nminutiae] = 1;

		if (!*str)
			break;
		str++;

		++nminutiae;
		if (nminutiae == MAX_FILE_MINUTIAE)
			break;

	} while (1);

	xytq_s = (struct xytq_struct *) malloc(sizeof(struct xytq_struct));
	if (xytq_s == XYTQ_NULL)
	{
		elog(ERROR, "Allocation failure while loading minutiae buffer");
		return XYT_NULL;
	}

	xytq_s->nrows = nminutiae;
	for (i = 0; i < nminutiae; i++)
	{
		xytq_s->xcol[i] = xvals_lng[i];
		xytq_s->ycol[i] = yvals_lng[i];
		xytq_s->thetacol[i] = tvals_lng[i];
		xytq_s->qualitycol[i] = qvals_lng[i];
	}

	xyt_s = bz_prune(xytq_s, 0);

	// workaround temporário...
	/*
	xyt_s = (struct xyt_struct *) malloc(sizeof(struct xyt_struct));
	xyt_s->nrows = nminutiae;
	for (i = 0; i < nminutiae; i++) 
	{
		xyt_s->xcol[i]     = xytq_s->xcol[i];
		xyt_s->ycol[i]     = xytq_s->ycol[i];
		xyt_s->thetacol[i] = xytq_s->thetacol[i];
	}
	*/

	if (xytq_s != XYTQ_NULL)
		free(xytq_s);

	//elog(NOTICE, "Loaded minutiae data with %d lines", nminutiae + 1);

	return xyt_s;
}

