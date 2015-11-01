#include <stdio.h>
#include <nfiq.h>

char *program;
int debug = 0;    /* required by wsq_decode_mem() in libwsq.a(decoder.o) */

//FILE * errorfp        = FPNULL;

int main(int argc, char *argv[]) {

	int ret = 0;
	char *imgfile = NULL;
	unsigned char *idata;
	int img_type, ilen, iw, ih, id, ippi, verbose;
	//OPT_FLAGS flags = { 0, 0, 0 };
	int nfiq = 0;
	float conf = 0.0;

	//set_progname(0, "nq", 0); // definir nome do programa
	//errorfp = stderr; // saída de erro padrão

	// read image file
	imgfile = argv[1];

	/* This routine will automatically detect and load:         */
	/* ANSI/NIST, WSQ, JPEGB, JPEGL, and IHead image formats   */
	if((ret = read_and_decode_grayscale_image(imgfile, &img_type,
		&idata, &ilen, &iw, &ih, &id, &ippi))) {
	if(ret == -3) /* UNKNOWN_IMG */
		fprintf(stderr, "Hint: Use -raw for raw images\n");
		exit(ret);
	}

	/* Compute the NFIQ value */
	ret = comp_nfiq(&nfiq, &conf, idata, iw, ih, id, ippi, &verbose); // &flags.verbose);
	/* If system error ... */
	if (ret < 0) {
		free(idata);
		exit(ret);
	}

	/* Report results to stdout */
	printf("nfiq: %d\t%4.2f\n", nfiq, conf);

	/* Deallocate image data */
	free(idata);

	exit(EXIT_SUCCESS);
}
