/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

/*
SELECT cwsq(E'123\\000456', 0.75, 300, 300, 8, 10), E'123\\000456'::bytea;
SELECT length(cwsq(pgm, 0.75, 300, 300, 8, null)) from fingers;
*/

#include <wsq.h>

// pg_cwsq
// CREATE FUNCTION cwsq(image bytea, bitrate real, width int, height int, depth int, ppi int) RETURNS bytea;

PG_FUNCTION_INFO_V1(pg_wsq_encode);
Datum
pg_wsq_encode(PG_FUNCTION_ARGS)
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

