/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

/*
SELECT nfiq(mdt) FROM fingers;
*/

// CREATE FUNCTION nfiq(bytea) RETURNS int
PG_FUNCTION_INFO_V1(pg_nfiq);
Datum
pg_nfiq(PG_FUNCTION_ARGS)
{
	bytea *image;
	unsigned size;
	unsigned char *data;
	int ret = 0;
	int img_type, ilen, iw, ih, id, ippi, verbose;
	int nfiq = 0;
	float conf = 0.0;
	int32 result = 0;

	elog(DEBUG1, "pg_nfiq()");

	image = PG_GETARG_BYTEA_P(0);
	size = VARSIZE(image) - VARHDRSZ;
	data = (unsigned char *) VARDATA(image);

	/*if (!is_minutiae_data(data, size)) {
		elog(ERROR, "First argument does not contain minutiae data");
		PG_RETURN_NULL();
	}*/	

/*
	ps = load_xyt_binary(data, size);

	if (ps != XYT_NULL)
		score = bozorth_main(ps, gs);

	if (ps != XYT_NULL)
		free((char *) ps);
*/

	/* Compute the NFIQ value */
	ret = comp_nfiq(&nfiq, &conf, data, iw, ih, id, ippi, &verbose); // &flags.verbose);
	/* If system error ... */
	if (ret < 0) {
		free(data);
		PG_RETURN_NULL();
	}

	if (debug > 0)
		elog(DEBUG1, "nfiq: %d, conf: %4.2f", nfiq, conf);

	result = nfiq;
	PG_RETURN_INT32(result);
}
