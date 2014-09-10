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
*/

#include <lfs.h>
#include <imgtype.h>
#include <imgboost.h>

//int extract_minutiae_xytq(unsigned char**, int*, int, unsigned char*);
//int mdt_encode_minutiae(unsigned char**, int*, MINUTIAE*);
/*
int decode_grayscale_image(int *oimg_type,
	unsigned char **odata, int *olen,
	int *ow, int *oh, int *od, int *oppi);
//, int *ointrlvflag, int *hor_sampfctr, int *vrt_sampfctr, int *on_cmpnts);
*/

// CREATE FUNCTION mindt(wsq bytea, boost boolean) RETURNS bytea
PG_FUNCTION_INFO_V1(pg_min_detect);
Datum
pg_min_detect(PG_FUNCTION_ARGS)
{
	bytea *wsq;
	bool boost;
	bytea *res;
	unsigned isize, osize = 0;
	unsigned char *idata, *odata = NULL;
	int ret;

	// read WSQ parameter
	wsq = PG_GETARG_BYTEA_P(0);
	isize = VARSIZE(wsq) - VARHDRSZ;
	idata = (unsigned char *) VARDATA(wsq);

	if (debug > 0)
		elog(NOTICE, "wsq: %x, isize: %d, idata: %x",
			(unsigned) wsq, isize, (unsigned) idata);

	// read boost parameter
	boost = PG_ARGISNULL(1) ? FALSE : PG_GETARG_BOOL(1);
	if (debug > 0)
		elog(NOTICE, "boost: %d", boost);

	if (debug > 0)
		elog(NOTICE, "Extracting minutiae...");

	if ((ret = extract_minutiae_xytq(&odata, (int *) &osize,
			boost, idata))) {
		PG_RETURN_NULL();
	}

	if (debug > 0)
		elog(NOTICE, "Minutiae data created, byte length = %d", osize);

	// initialize result buffer
	res = (bytea *) palloc(osize + VARHDRSZ);
	SET_VARSIZE(res, osize + VARHDRSZ);

	// copy data to output buffer
	//memset(VARDATA(res), 0, osize);
	memcpy(VARDATA(res), odata, osize);

	PG_RETURN_BYTEA_P(res);
}

int extract_minutiae_xytq(unsigned char **odata, int *osize, int boost, unsigned char *idata) {

	unsigned char *bdata;
	int img_type;
	int ilen, iw, ih, id, ippi, bw, bh, bd;
	double ippmm;
	//int img_idc, img_imp;
	int *direction_map, *low_contrast_map, *low_flow_map;
	int *high_curve_map, *quality_map;
	int map_w, map_h;
	int ret;
	MINUTIAE *minutiae;
	//ANSI_NIST *ansi_nist;
	//RECORD *imgrecord;
	//int imgrecord_i;

	// FIXME: remover isso
/*
	*odata = NULL;
	*osize = 0;
	exit(0);
*/

	// 1. READ FINGERPRINT WSQ IMAGE FROM FILE INTO MEMORY

	// Decode the image data from memory
	if ((ret = decode_grayscale_image(
			&img_type, &idata, &ilen, &iw, &ih, &id, &ippi))) {
		exit(ret);
	}

	// If image ppi not defined, then assume 500
	if (ippi == UNDEFINED)
		ippmm = DEFAULT_PPI / (double) MM_PER_INCH;
	else 
		ippmm = ippi / (double) MM_PER_INCH;

	// 2. ENHANCE IMAGE CONTRAST IF REQUESTED
	if (boost)
		trim_histtails_contrast_boost(idata, iw, ih); 

	// 3. GET MINUTIAE & BINARIZED IMAGE
	if ((ret = get_minutiae(&minutiae, &quality_map, &direction_map,
			&low_contrast_map, &low_flow_map, &high_curve_map,
			&map_w, &map_h, &bdata, &bw, &bh, &bd,
			idata, iw, ih, id, ippmm, &lfsparms_V2))) {
		free(idata);
		exit(ret);
	}

	// Done with input image data
	free(idata);

	// 4. WRITE MINUTIAE TO OUTPUT VARIABLE
	if ((ret = mdt_encode_minutiae(&odata, &osize, minutiae))) {
		free_minutiae(minutiae);
		free(quality_map);
		free(direction_map);
		free(low_contrast_map);
		free(low_flow_map);
		free(high_curve_map);
		free(bdata);
		exit(ret);
	}

	// Done with minutiae detection maps
	free(quality_map);
	free(direction_map);
	free(low_contrast_map);
	free(low_flow_map);
	free(high_curve_map);

	// Done with minutiae and binary image results
	free_minutiae(minutiae);
	free(bdata);

	// Exit normally
	exit(0);
}

int decode_grayscale_image(int *oimg_type,
	unsigned char **odata, int *olen,
	int *ow, int *oh, int *od, int *oppi)
//, int *ointrlvflag, int *hor_sampfctr, int *vrt_sampfctr, int *on_cmpnts)
{
	int ret;
	unsigned char *idata, *ndata;
	int img_type, ilen, nlen;
	int w, h, d, ppi, lossyflag, intrlvflag = 0, n_cmpnts;
	//IMG_DAT *img_dat;

/*
	if ((ret = image_type(&img_type, idata, ilen))) {
		free(idata);
		return(ret);
	}

	if (img_type != WSQ_IMG) {
		free(idata);
		fprintf(stderr, "ERROR : decode_image : ");
		fprintf(stderr, "illegal image type (not WSQ) = %d\n", img_type);
		return(-3);
	}

	if ((ret = wsq_decode_mem(&ndata, &w, &h, &d, &ppi, &lossyflag, idata, ilen))){
		free(idata);
		return(ret);
	}

	nlen = w * h;
	// Pix depth always 8 for WSQ ...
	n_cmpnts = 1;
//	hor_sampfctr[0] = 1;
//	vrt_sampfctr[0] = 1;

	free(idata);

	*oimg_type = img_type;
	*odata = ndata;
	*olen = nlen;
	*ow = w;
	*oh = h;
	*od = d;
	*oppi = ppi;
//	*ointrlvflag = intrlvflag;
//	*on_cmpnts = n_cmpnts;

	// Only desire grayscale images ...
	if(d != 8){
		free(idata);
		fprintf(stderr, "ERROR : read_and_decode_grayscale_image : ");
		fprintf(stderr, "image depth : %d != 8\n", d);
		return(-4);
	}
*/
	return(0);
}

// Grava as minúcias em formato binário próprio (MDT).
int mdt_encode_minutiae(unsigned char **odata, int *osize, const MINUTIAE *minutiae)
{
	unsigned i, qty, ox, oy, ot, oq;
	MINUTIA *minutia;
	ushort *mdt, *pmdt, len;

	qty = minutiae->num;

	if (debug > 0)
		elog(NOTICE, "minutiae->num = %d", qty);
/*
	len = 1 + qty * 4;
	mdt = palloc(sizeof(ushort) * len);
	pmdt = mdt;
	//memset(mdt, 0, sizeof(ushort) * siz);
	*pmdt++ = qty;
	for (i = 0; i < qty; i++) {
		minutia = minutiae->list[i];
		lfs2m1_minutia_XYT(&ox, &oy, &ot, minutia);
		oq = sround(minutia->reliability * 100.0);
		*pmdt++ = ox;
		*pmdt++ = oy;
		*pmdt++ = ot;
		*pmdt++ = oq;
	}
	//fwrite(mdt, sizeof(ushort), len, file);
	//free(mdt);

	odata = mdt;
	osize = sizeof(ushort) * len;
*/
	return(0);
}
