/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

/*
SET client_min_messages TO debug1;
SELECT id, mdt2text(mdt) FROM fingerprints;
*/

int convert_xyt_binary_text(uchar**, unsigned*, uchar*, unsigned);

// CREATE FUNCTION mdt2text(mdt bytea) RETURNS text
PG_FUNCTION_INFO_V1(pg_mdt_text);
Datum
pg_mdt_text(PG_FUNCTION_ARGS)
{
	bytea *mdt;
	text *res;
	unsigned isize, osize = 0;
	uchar *idata, *odata = NULL;
	int ret;

	// read MDT parameter
	mdt = PG_GETARG_BYTEA_P(0);
	isize = VARSIZE(mdt) - VARHDRSZ;
	idata = (uchar *) VARDATA(mdt);

	if (debug > 0)
		elog(NOTICE, "mdt: %x, isize: %d, idata: %x",
			(unsigned) mdt, isize, (unsigned) idata);

	// check data validity
	if (!is_minutiae_data(idata, isize)) {
		elog(ERROR, "Argument does not contain minutiae data");
		PG_RETURN_NULL();
	}

	// convert data from bytea to text
	if ((ret = convert_xyt_binary_text(&odata, &osize, idata, isize))) {
		elog(ERROR, "First argument does not contain minutiae data");
		PG_RETURN_NULL();
	}

	// initialize result buffer
	res = (text *) palloc(osize + VARHDRSZ);
	SET_VARSIZE(res, osize + VARHDRSZ);

	// copy data to output buffer
	memcpy(VARDATA(res), odata, osize);

	free(odata);

	PG_RETURN_TEXT_P(res);
}

int convert_xyt_binary_text(uchar **odata, unsigned *osize, uchar *idata, unsigned isize)
{
	struct xyt_struct * xyt_s;
	int total_minutiae, expected_size, i;
	char xyt_line[MAX_LINE_LENGTH];

	xyt_s = load_xyt_binary(idata, isize);
	if (xyt_s == XYT_NULL)
	{
		elog(ERROR, "Error reading minutiae data in binary format");
		return(1);
	}

	total_minutiae = xyt_s->nrows;
	expected_size = total_minutiae * (MAX_LINE_LENGTH + 2);

	odata = malloc(expected_size);
	memset(odata, 0, expected_size);
	osize = 0;

	if (debug > 0) {
		elog(NOTICE, "Total de minúcias: %d", total_minutiae);
		elog(DEBUG1, "No =>  X   Y   T   Q?");
	}

	for (i = 0; i < total_minutiae; i++)
	{
		if (!osize)
			strcat(odata, "\n");
		sprintf(xyt_line, "%d %d %d",
			xyt_s->xcol[i], xyt_s->ycol[i], xyt_s->thetacol[i]);
		strcat(odata, xyt_line);
		osize += strlen(xyt_line) + 1;
		if (debug > 0)
			elog(DEBUG1, "%s", xyt_line);
	}

	if (xyt_s != XYT_NULL)
		free((char *) xyt_s);

	return(0);
}

