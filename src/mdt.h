/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

/*
SET client_min_messages TO debug1;
SELECT id, mdt2text(mdt), mdt_mins(mdt) FROM fingerprints;
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

	elog(DEBUG1, "pg_mdt_text(): size = %d", isize);
	/*if (debug > 0)
		elog(DEBUG1, "mdt: %x, isize: %d, idata: %x",
			(unsigned) mdt, isize, (unsigned) idata);*/

	// check data validity
	if (!is_minutiae_data(idata, isize)) {
		elog(ERROR, "Argument does not contain minutiae data");
		PG_RETURN_NULL();
	}

	// convert data from bytea to text
	if ((ret = convert_xyt_binary_text(&odata, &osize, idata, isize))) {
		elog(ERROR, "Error converting minutiae data to text");
		PG_RETURN_NULL();
	}

	/*if (debug > 0)
		elog(DEBUG1, "osize: %d, odata: %x",
			osize, (unsigned) odata);*/

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
	struct xytq_struct * xytq_s;
	int total_minutiae, expected_size, i;
	char xyt_line[MAX_LINE_LENGTH];
	char *txt;
	unsigned len = 0;

	elog(DEBUG2, "convert_xyt_binary_text(): size = %d", isize);

	xytq_s = load_xytq_binary(idata, isize);
	if (xytq_s == XYTQ_NULL)
	{
		elog(ERROR, "Error reading minutiae data in binary format");
		return(1);
	}

	total_minutiae = xytq_s->nrows;
	expected_size = total_minutiae * (MAX_LINE_LENGTH + 2);

	txt = malloc(expected_size);
	memset(txt, 0, expected_size);
	len = 0;

	if (debug > 0) {
		elog(DEBUG2, "total_minutiae = %d", total_minutiae);
		//elog(DEBUG2, "No =>  X   Y   T   Q");
	}

	for (i = 0; i < total_minutiae; i++)
	{
		if (len)
			strcat(txt, "\n");
		sprintf(xyt_line, "%d %d %d %d",
			xytq_s->xcol[i], xytq_s->ycol[i],
			xytq_s->thetacol[i], xytq_s->qualitycol[i]);
		strcat(txt, xyt_line);
		len += strlen(xyt_line) + 1;
		/*if (debug > 0)
			elog(DEBUG2, "%s", xyt_line);*/
	}

	if (xytq_s != XYTQ_NULL)
		free((char *) xytq_s);

	*odata = (uchar *) txt;
	*osize = len;

	return(0);
}

// CREATE FUNCTION mdt_mins(mdt bytea) RETURNS int
PG_FUNCTION_INFO_V1(pg_mdt_mincnt);
Datum
pg_mdt_mincnt(PG_FUNCTION_ARGS)
{
	bytea *mdt;
	unsigned isize = 0;
	uchar *idata = NULL;
	ushort count = 0, *pdata = NULL;

	// read MDT parameter
	mdt = PG_GETARG_BYTEA_P(0);
	isize = VARSIZE(mdt) - VARHDRSZ;
	idata = (uchar *) VARDATA(mdt);

	elog(DEBUG1, "pg_mdt_mincnt(): size = %d", isize);
	/*if (debug > 0)
		elog(DEBUG1, "mdt: %x, isize: %d, idata: %x",
			(unsigned) mdt, isize, (unsigned) idata);*/

	// check data validity
	if (!is_minutiae_data(idata, isize)) {
		elog(ERROR, "Argument does not contain minutiae data");
		PG_RETURN_NULL();
	}

	// read first 2 bytes (i.e., number of minutiae)
	pdata = idata;
	count = *pdata;

	PG_RETURN_INT32(count);
}

