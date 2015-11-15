/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

/*
SELECT mindt(wsq) FROM fingers;
SELECT mindt(wsq, true) FROM fingers;
UPDATE fingers SET mdt = mindt(wsq, true);
*/

#include <lfs.h>
#include <imgtype.h>
#include <imgboost.h>

int is_wsq_type(uchar*, const int);
int extract_minutiae_xytq(uchar**, int*, uchar*, int, int);
int decode_grayscale_image(uchar**, int*, int*, int*, int*, int*, uchar*, int);
int mdt_encode_minutiae(uchar**, int*, const MINUTIAE*);

// CREATE FUNCTION mindt(wsq bytea, boost boolean) RETURNS bytea
PG_FUNCTION_INFO_V1(pg_min_detect);
Datum
pg_min_detect(PG_FUNCTION_ARGS)
{
	bytea *wsq;
	bool boost;
	bytea *res;
	unsigned isize, osize = 0;
	uchar *idata, *odata = NULL;
	int ret;

	// read WSQ parameter
	wsq = PG_GETARG_BYTEA_P(0);
	isize = VARSIZE(wsq) - VARHDRSZ;
	idata = (uchar *) VARDATA(wsq);

	elog(DEBUG1, "pg_min_detect(): size = %d", isize);

	/*if (debug > 0)
		elog(DEBUG1, "wsq: %x, isize: %d, idata: %x",
			(unsigned) wsq, isize, (unsigned) idata);*/

	// read boost parameter
	boost = PG_ARGISNULL(1) ? FALSE : PG_GETARG_BOOL(1);
	//if (debug > 0)
	elog(DEBUG2, "boost: %d", boost);

	if (!is_wsq_type(idata, isize)) {
		elog(ERROR, "Illegal image type (not in WSQ format)");
		PG_RETURN_NULL();
	}

	if (debug > 0)
		elog(DEBUG2, "Extracting minutiae...");

	if ((ret = extract_minutiae_xytq(&odata, (int *) &osize,
			idata, isize, boost))) {
		PG_RETURN_NULL();
	}

	if (debug > 0)
		elog(DEBUG2, "Minutiae data extracted, byte length = %d", osize);

	// initialize result buffer
	res = (bytea *) palloc(osize + VARHDRSZ);
	SET_VARSIZE(res, osize + VARHDRSZ);

	// copy data to output buffer
	memcpy(VARDATA(res), odata, osize);
	
	free(odata);

	PG_RETURN_BYTEA_P(res);
}

int is_wsq_type(uchar *idata, const int ilen)
{
   int ret;
   ushort marker;
   uchar *cbufptr, *ebufptr;

   cbufptr = idata;
   ebufptr = idata + ilen;

   if ((ret = getc_ushort(&marker, &cbufptr, ebufptr)))
      return(ret);
   
   return(marker == SOI_WSQ);
}

int extract_minutiae_xytq(uchar **odata, int *osize,
	uchar *idata, int isize, int boost)
{
	int ret;

	uchar *ndata;
	int nsize, iw, ih, id, ippi;
	double ippmm;

	MINUTIAE *minutiae;
	int *quality_map, *direction_map;
	int *low_contrast_map, *low_flow_map, *high_curve_map;
	int map_w, map_h;
	uchar *bdata;
	int bw, bh, bd;

	uchar *mdata;
	int msize;

	// 1. READ FINGERPRINT WSQ IMAGE FROM FILE INTO MEMORY
	elog(DEBUG2, "1. READ FINGERPRINT WSQ IMAGE FROM FILE INTO MEMORY");

	// Decode the image data from memory
	if ((ret = decode_grayscale_image(&ndata, &nsize,
			&iw, &ih, &id, &ippi, idata, isize))) {
		return(ret);
	}

	// If image ppi not defined, then assume 500
	if (ippi == UNDEFINED)
		ippmm = DEFAULT_PPI / (double) MM_PER_INCH;
	else 
		ippmm = ippi / (double) MM_PER_INCH;

	// 2. ENHANCE IMAGE CONTRAST IF REQUESTED
	elog(DEBUG2, "2. ENHANCE IMAGE CONTRAST IF REQUESTED");
	if (boost)
		trim_histtails_contrast_boost(ndata, iw, ih); 

	// 3. GET MINUTIAE & BINARIZED IMAGE
	elog(DEBUG2, "3. GET MINUTIAE & BINARIZED IMAGE");
	if ((ret = get_minutiae(&minutiae, &quality_map, &direction_map,
			&low_contrast_map, &low_flow_map, &high_curve_map,
			&map_w, &map_h, &bdata, &bw, &bh, &bd,
			ndata, iw, ih, id, ippmm, &lfsparms_V2))) {
		free(ndata);
		return(ret);
	}

	// Done with input image data
	free(ndata);

	// 4. WRITE MINUTIAE TO OUTPUT VARIABLE
	elog(DEBUG2, "4. WRITE MINUTIAE TO OUTPUT VARIABLE");
	if ((ret = mdt_encode_minutiae(&mdata, &msize, minutiae))) {
		free_minutiae(minutiae);
		free(quality_map);
		free(direction_map);
		free(low_contrast_map);
		free(low_flow_map);
		free(high_curve_map);
		free(bdata);
		return(ret);
	}

	//elog(DEBUG2, "Copying data to output variables...");

	*odata = mdata;
	*osize = msize;

	//elog(DEBUG2, "Freeing memory...");

	// Done with minutiae detection maps
	free(quality_map);
	free(direction_map);
	free(low_contrast_map);
	free(low_flow_map);
	free(high_curve_map);

	// Done with minutiae and binary image results
	free_minutiae(minutiae);
	free(bdata);
//	free(ndata); //FIXME: dá problema...

	// Exit normally
	return(0);
}

int decode_grayscale_image(uchar **odata, int *osize,
	int *ow, int *oh, int *od, int *oppi, uchar *idata, int isize)
{
	int ret;
	uchar *ndata;
	int w, h, d, ppi, lossyflag, nlen;

	if ((ret = wsq_decode_mem(&ndata, &w, &h, &d, &ppi, &lossyflag, idata, isize))) {
		//free(idata);
		return(ret);
	}

	nlen = w * h;

	//free(idata);

	*odata = ndata;
	*osize = nlen;
	*ow = w;
	*oh = h;
	*od = d;
	*oppi = ppi;

	// Only desire grayscale images ...
	if (d != 8) {
		//free(idata);
		//fprintf(stderr, "ERROR : read_and_decode_grayscale_image : ");
		//fprintf(stderr, "image depth : %d != 8\n", d);
		elog(DEBUG2, "image depth : %d != 8", d);
		return(-4);
	}

	return(0);
}

// grava as minúcias em formato binário próprio (MDT)
int mdt_encode_minutiae(uchar **odata, int *osize, const MINUTIAE *minutiae)
{
	unsigned i, qty, ox, oy, ot, oq;
	MINUTIA *minutia;
	ushort *mdt, *pmdt;
	int len, siz;

	qty = minutiae->num;

	elog(DEBUG1, "mdt_encode_minutiae(): qty = %d", qty);
	if (debug > 0)
		elog(DEBUG2, "No =>  X   Y   T   Q");

	len = 1 + qty * 4; // header + 4 valores por minúcia
	siz = sizeof(ushort) * len;
	mdt = malloc(siz);
	pmdt = mdt;
	memset(mdt, 0, siz);

	*pmdt++ = (ushort) qty;

	for (i = 0; i < qty; i++) {
		minutia = minutiae->list[i];
		lfs2m1_minutia_XYT((int*) &ox, (int*) &oy, (int*) &ot, minutia);
		oq = sround(minutia->reliability * 100.0);

		if (debug > 0)
			elog(DEBUG2, "%2d => %3d %3d %3d %2d", i+1, ox, oy, ot, oq);

		*pmdt++ = (ushort) ox;
		*pmdt++ = (ushort) oy;
		*pmdt++ = (ushort) ot;
		*pmdt++ = (ushort) oq;
	}

	*odata = (uchar *) mdt;
	*osize = siz;

	return(0);
}

