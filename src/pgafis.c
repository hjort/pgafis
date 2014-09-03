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

#include <wsq.h>

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

/* protótipos */
struct xyt_struct * load_xyt(char *str);
Datum pg_bz_match(PG_FUNCTION_ARGS);
Datum pg_cwsq(PG_FUNCTION_ARGS);

// pg_bz_match
// CREATE FUNCTION bz_match(text, text) RETURNS int;
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

//	elog(NOTICE, "score: %d", score);

	PG_RETURN_INT32(score);
}

// load_xyt
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

//		elog(NOTICE, "%2d = <%s>", nminutiae + 1, xyt_line);

//		if (nminutiae == 0)
//			elog(NOTICE, "Line 1: %s", xyt_line);
//		if (nminutiae > 0 && m != nargs_expected)
//			elog(ERROR, "Inconsistent argument count on line %u of minutiae data (%u, %u): [%s]",
//				nminutiae + 1, m, nargs_expected, xyt_line);

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
		free((char *) xytq_s);

	//elog(NOTICE, "Loaded minutiae data with %d lines", nminutiae + 1);

	return xyt_s;
}

int debug = 1;

// pg_cwsq
// CREATE FUNCTION cwsq(image bytea, bitrate real, width int, height int, depth int, ppi int) RETURNS bytea;
// select cwsq(E'123\\000456', 0.75, 300, 300, 8, 10), E'123\\000456'::bytea;
PG_FUNCTION_INFO_V1(pg_cwsq);
Datum
pg_cwsq(PG_FUNCTION_ARGS)
{
	bytea *image;
	float4 bitrate;
	int32 width, height, depth, ppi;
	bytea *res;
	unsigned isize, osize;
	unsigned char *idata, *odata;
	int ret;

	// read bytea image parameter
	image = PG_GETARG_BYTEA_P(0);
	isize = VARSIZE(image) - VARHDRSZ;
	idata = (unsigned char *) VARDATA(image);

	if (debug > 0)
		elog(NOTICE, "image: %x, isize: %d, idata: %x",
			(unsigned) image, isize, (unsigned) idata);

	// read remaining function parameters
	bitrate = PG_GETARG_FLOAT4(1);
	width = PG_GETARG_INT32(2);
	height = PG_GETARG_INT32(3);
	depth = PG_GETARG_INT32(4);
	ppi = PG_ARGISNULL(5) ? -1 : PG_GETARG_INT32(5);

	if (debug > 0)
		elog(NOTICE, "bitrate: %.2f, width: %d, height: %d, depth: %d, ppi: %d",
			bitrate, width, height, depth, ppi);

	// encode/compress the image pixmap
	if ((ret = wsq_encode_mem(&odata, (int *) &osize, bitrate,
			idata, width, height, depth, ppi, NULL))) {
		PG_RETURN_NULL();
	}

	if (debug > 0)
		elog(NOTICE, "Image data encoded, compressed byte length = %d", osize);

	// initialize result buffer
	res = (bytea *) palloc(osize + VARHDRSZ);
	SET_VARSIZE(res, osize + VARHDRSZ);

	// copy data to output buffer
	//memset(VARDATA(res), 0, osize);
	memcpy(VARDATA(res), odata, osize);

	//pfree(odata);

	PG_RETURN_BYTEA_P(res);
}

