#include <stdio.h>
#include <string.h>
#include <wsq.h>

/*
#include <sys/param.h>
#include <ihead.h>
#include <img_io.h>
#include <dataio.h>
#include <parsargs.h>
#include <version.h>
*/

#define MAXPATHLEN 255

int debug = 1;

int main(int argc, char *argv[]) {
   int ret;
   int rawflag;             /* input image flag: 0 == Raw, 1 == IHead */
   float r_bitrate;         /* target bit compression rate */
   char ifile[MAXPATHLEN], ofile[MAXPATHLEN]; /* Input/Output filenames */
   IHEAD *ihead;            /* Ihead pointer */
   unsigned char *idata;    /* Input data */
   int width, height;       /* image characteristic parameters */
   int depth, ppi;
   unsigned char *odata;    /* Output data */
   int olen;                /* Number of bytes in output data. */

   if (argc > 1)
      strcpy(ifile, argv[1]);
   else
      strcpy(ifile, "sample1.pgm");

   r_bitrate = 0.75;
   rawflag = 1;
   width = 300;
   height = 300;
   depth = 8;
   ppi = -1;

   if(debug > 0)
      fprintf(stdout, "Reading file %s...\n", ifile);

   /* Read the image into memory (IHead or raw pixmap). */
   if((ret = read_raw_or_ihead_wsq(!rawflag, ifile,
                              &ihead, &idata, &width, &height, &depth)))
      exit(ret);

   if(debug > 0)
      fprintf(stdout, "File %s read\n", ifile);

   /* Encode/compress the image pixmap. */
   if((ret = wsq_encode_mem(&odata, &olen, r_bitrate,
                           idata, width, height, depth, ppi, NULL))){
      free(idata);
      exit(ret);
   }

   free(idata);

   if(debug > 0)
      fprintf(stdout, "Image data encoded, compressed byte length = %d\n", olen);

   /* Generate the output filename. */
   fileroot(ifile);
   sprintf(ofile, "%s.%s", ifile, "wsq");

   if((ret = write_raw_from_memsize(ofile, odata, olen))){
      free(odata);
      exit(ret);
   }

   if(debug > 0)
      fprintf(stdout, "Image data written to file %s\n", ofile);

   free(odata);

   /* Exit normally. */
   exit(0);
}
