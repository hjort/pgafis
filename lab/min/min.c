#include <stdio.h>
#include <string.h>
#include <lfs.h>

/*
#include <imgdecod.h>
#include <sys/param.h>
#include <an2k.h>
#include <imgboost.h>
#include <img_io.h>
#include <version.h>
#include <sunrast.h>
*/

#define MAXPATHLEN 255
#define ushort unsigned short

int debug = 1;

int main(int argc, char *argv[]) {

	int boostflag, m1flag;
	char ifile[MAXPATHLEN], ofile[MAXPATHLEN], minfile[MAXPATHLEN];
	unsigned char *idata, *bdata;
	int img_type;
	int ilen, iw, ih, id, ippi, bw, bh, bd;
	double ippmm;
	int img_idc, img_imp;
	int *direction_map, *low_contrast_map, *low_flow_map;
	int *high_curve_map, *quality_map;
	int map_w, map_h;
	int ret;
	MINUTIAE *minutiae;
	ANSI_NIST *ansi_nist;
	RECORD *imgrecord;
	int imgrecord_i;

	boostflag = TRUE;
	m1flag = TRUE;

	if (argc > 1)
		strcpy(ifile, argv[1]);
	else
		strcpy(ifile, "sample1.wsq");

	if(debug > 0)
		fprintf(stdout, "Reading file %s...\n", ifile);

	/* 1. READ FINGERPRINT IMAGE FROM FILE INTO MEMORY. */

	/* Read the image data from file into memory */
	if((ret = read_and_decode_grayscale_image(ifile,
			&img_type, &idata, &ilen, &iw, &ih, &id, &ippi))){
		exit(ret);
	}
	/* If image ppi not defined, then assume 500 */
	if(ippi == UNDEFINED)
		ippmm = DEFAULT_PPI / (double)MM_PER_INCH;
	else 
		ippmm = ippi / (double)MM_PER_INCH;

	/* 2. ENHANCE IMAGE CONTRAST IF REQUESTED */
	if(boostflag)
		trim_histtails_contrast_boost(idata, iw, ih); 

	/* 3. GET MINUTIAE & BINARIZED IMAGE. */
	if((ret = get_minutiae(&minutiae, &quality_map, &direction_map,
			&low_contrast_map, &low_flow_map, &high_curve_map,
			&map_w, &map_h, &bdata, &bw, &bh, &bd,
			idata, iw, ih, id, ippmm, &lfsparms_V2))){
		free(idata);
		exit(ret);
	}

	/* Done with input image data */
	free(idata);

	/* Generate the output filename. */
	fileroot(ifile);
	sprintf(ofile, "%s.%s", ifile, "xyt");

	/* 4. WRITE MINUTIAE & MAP RESULTS TO TEXT FILES */
	if((ret = write_minutiae_XYTQ(ofile, M1_XYT_REP, minutiae, iw, ih))){
		free_minutiae(minutiae);
		free(quality_map);
		free(direction_map);
		free(low_contrast_map);
		free(low_flow_map);
		free(high_curve_map);
		free(bdata);
		exit(ret);
	}
	/*if((ret = write_text_results(oroot, m1flag, bw, bh,
		   minutiae, quality_map,
		   direction_map, low_contrast_map,
		   low_flow_map, high_curve_map, map_w, map_h)))*/

	// imprimir minúcias
//	print_minutiae(minutiae);

	// gravar minúcias
	sprintf(minfile, "%s.%s", ifile, "mdt");
	write_minutiae(minutiae, minfile);

	/* Done with minutiae detection maps. */
	free(quality_map);
	free(direction_map);
	free(low_contrast_map);
	free(low_flow_map);
	free(high_curve_map);

	/* Done with minutiae and binary image results */
	free_minutiae(minutiae);
	free(bdata);

	/* Exit normally. */
	exit(0);
}

/**
 * Imprime as minúcias.
 */
int print_minutiae(const MINUTIAE *minutiae)
{
	FILE *fp = stdout;
	int i, ox, oy, ot, oq;
	MINUTIA *minutia;

	fprintf(fp, "BEGIN MINUTIAE;\n");
	for(i = 0; i < minutiae->num; i++){
		minutia = minutiae->list[i];
		lfs2m1_minutia_XYT(&ox, &oy, &ot, minutia);
		oq = sround(minutia->reliability * 100.0);
		fprintf(fp, "%d %d %d %d\n", ox, oy, ot, oq);
	}
	fprintf(fp, "END MINUTIAE;\n");

	return(0);
}

/**
 * Grava as minúcias em arquivo binário.
 */
int write_minutiae(const MINUTIAE *minutiae, char *filename)
{
	FILE *file;
	size_t ret;
	unsigned i, qty, ox, oy, ot, oq;
	MINUTIA *minutia;
	ushort *mdt, *pmdt, len;

	file = fopen(filename, "wb");
	fprintf(stdout, "Writing minutiae to file %s\n", filename);
	qty = minutiae->num;

	// 1. grava byte a byte
	/*
	fputc(qty, file);
	for (i = 0; i < qty; i++) {
		minutia = minutiae->list[i];
		lfs2m1_minutia_XYT(&ox, &oy, &ot, minutia);
		oq = sround(minutia->reliability * 100.0);
		fputc(ox, file);
		fputc(oy, file);
		fputc(ot, file);
		fputc(oq, file);
	}
	*/
	// ...

	// 2. grava de uma só vez
	len = 1 + qty * 4;
	mdt = malloc(sizeof(ushort) * len);
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
	fwrite(mdt, sizeof(ushort), len, file);
	free(mdt);
	// ...

	fclose(file);
	return(0);
}

