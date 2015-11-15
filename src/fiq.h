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

#include <nfiq.h>

// CREATE FUNCTION nfiq(bytea) RETURNS int
PG_FUNCTION_INFO_V1(pg_nfiq);
Datum
pg_nfiq(PG_FUNCTION_ARGS)
{
	bytea *image;
	unsigned size;
	unsigned char *data;
	int ret = 0;
	uchar *ndata;
	int nsize;
	int iw, ih, id, ippi, verbose = 0;
	int nfiq = 0;
	float conf = 0.0;

	elog(DEBUG1, "pg_nfiq()");

	image = PG_GETARG_BYTEA_P(0);
	size = VARSIZE(image) - VARHDRSZ;
	data = (unsigned char *) VARDATA(image);

	if (debug > 0)
		elog(DEBUG2, "image: %x, size: %d, data: %x",
			(unsigned) image, size, (unsigned) data);

	// Decode the image data from memory
	elog(DEBUG2, "decode_grayscale_image()");
	if ((ret = decode_grayscale_image(&ndata, &nsize,
			&iw, &ih, &id, &ippi, data, size))) {
		elog(ERROR, "Error decoding grayscale image from WSQ content");
		free(ndata);
		PG_RETURN_NULL();
	}

	/* Compute the NFIQ value */
	elog(DEBUG2, "comp_nfiq()");
	ret = comp_nfiq(&nfiq, &conf, data, iw, ih, id, ippi, &verbose);
	if (debug > 0)
		elog(DEBUG2, "ret: %d, w,h,d,ppi: %d,%d,%d,%d", ret, iw, ih, id, ippi);
	// if system error...
	if (ret < 0) {
		elog(ERROR, "A system error occurred when computing the NFIQ value: %d", ret);
		free(ndata);
		PG_RETURN_NULL();
	}

	// Done with input image data
	free(ndata);

	if (debug > 0)
		elog(DEBUG2, "nfiq: %d, conf: %4.2f", nfiq, conf);

	PG_RETURN_INT32((int32) nfiq);
}

