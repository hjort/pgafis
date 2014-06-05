/**
 * pgAFIS - Automated Fingerprint Identification System Support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

#define get_progname pg_get_progname
#include <postgres.h>
#undef get_progname
#define bz_match nbis_bz_match
#include <bozorth.h>
#undef bz_match

#include "fmgr.h"
#include "utils/builtins.h"
#include <stdio.h>
#include <unistd.h>

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

int m1_xyt                  = 1; // M1 default {x,y,t} representation
int max_minutiae            = DEFAULT_BOZORTH_MINUTIAE;
int min_computable_minutiae = MIN_COMPUTABLE_BOZORTH_MINUTIAE;

int verbose_main      = 0;
int verbose_load      = 0;
int verbose_bozorth   = 0;
int verbose_threshold = 0;

FILE * errorfp        = FPNULL;

struct xyt_struct * load_xyt(char *str);

Datum bz_match(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(bz_match);
Datum
bz_match(PG_FUNCTION_ARGS)
{
	text *txt1 = PG_GETARG_TEXT_PP(0);
	text *txt2 = PG_GETARG_TEXT_PP(1);
	//int32 size = VARSIZE(txt) - VARHDRSZ;
	int32 score = 0;
	char *str1 = VARDATA_ANY(txt1);
	char *str2 = VARDATA_ANY(txt2);
	//size_t nbytes = VARSIZE_ANY_EXHDR(txt);

//        int np = 5;
	struct xyt_struct *ps = XYT_NULL; // probe structure
	struct xyt_struct *gs = XYT_NULL; // gallery structure

//        set_progname(0, "pgafis", 0); // definir nome do programa
//        errorfp = stderr; // saída de erro padrão

	// FIXME: não está funcionando...
	//if (!str)
	//if (txt == NULL)
	//	PG_RETURN_INT32(0);

	// TODO: carregar tabelas XYT a partir dos argumentos "text"
	//ps = load_xyt(str1);
	//gs = load_xyt(str2);

	// FIXME: remover esse código ao final
	score += 1;
	while (*str1) {
		if (*str1 == '\n')
			score++;
		str1++;
	}
	score += 1;
	while (*str2) {
		if (*str2 == '\n')
			score++;
		str2++;
	}
	// ...

	if (ps != XYT_NULL)
		free((char *) ps);
	if (gs != XYT_NULL)
		free((char *) gs);

	PG_RETURN_INT32(score);
}

struct xyt_struct * load_xyt(char *str)
{
	int nminutiae;
	int m;
	int i;
	int nargs_expected;
//	FILE * fp;
	struct xyt_struct * xyt_s;
	struct xytq_struct * xytq_s;
	int xvals_lng[MAX_FILE_MINUTIAE], /* temporary lists to store all the minutaie from a finger */
		yvals_lng[MAX_FILE_MINUTIAE],
		tvals_lng[MAX_FILE_MINUTIAE],
		qvals_lng[MAX_FILE_MINUTIAE];
	char xyt_line[MAX_LINE_LENGTH];

   nminutiae = 0;
   nargs_expected = 0;

	memset(xyt_line, 0, MAX_LINE_LENGTH);

   // FIXME: última linha talvez não esteja sendo lida...
   while (*str) {
	if (*str != '\n') {
		strcat(xyt_line, str);
		str++;
		continue;
	}
	str++;

   /*while ( fgets( xyt_line, sizeof xyt_line, fp ) != CNULL ) 
   {*/
      m = sscanf( xyt_line, "%d %d %d %d",
                   &xvals_lng[nminutiae],
                   &yvals_lng[nminutiae],
                   &tvals_lng[nminutiae],
                   &qvals_lng[nminutiae] );
	memset(xyt_line, 0, MAX_LINE_LENGTH);

      if ( nminutiae == 0 ) 
      {
         if ( m != 3 && m != 4 ) 
         {
		// TODO: usar handler de log do PG
            /*fprintf( errorfp, "%s: ERROR: sscanf() failed on line %u in minutiae file \"%s\"\n",
                     get_progname(), nminutiae+1, xyt_file );*/
            return XYT_NULL;
         }
         nargs_expected = m;
      } 
      else 
      {
         if ( m != nargs_expected ) 
         {
		// TODO: usar handler de log do PG
            /*fprintf( errorfp, "%s: ERROR: inconsistent argument count on line %u of minutiae file \"%s\"\n",
                     get_progname(), nminutiae+1, xyt_file );*/
            return XYT_NULL;
         }
      }
      if ( m == 3 )
         qvals_lng[nminutiae] = 1;

      ++nminutiae;
      if ( nminutiae == MAX_FILE_MINUTIAE )
         break;
   }

   xytq_s = (struct xytq_struct *) malloc(sizeof(struct xytq_struct));
   if (xytq_s == XYTQ_NULL)
   {
	// TODO: usar handler de log do PG
      /*fprintf( errorfp, "%s: ERROR: malloc() failure while loading minutiae buffer failed: %s\n",
                                                     get_progname(),
                                                     strerror(errno)
                                                     );*/
      return XYT_NULL;
   }

   xytq_s->nrows = nminutiae;
   for (i = 0; i < nminutiae; i++)
   {
      xytq_s->xcol[i] = xvals_lng[i];
      xytq_s->ycol[i] = yvals_lng[i];
      xytq_s->thetacol[i] = tvals_lng[i];
      xytq_s->qualitycol[i] = qvals_lng[i];
   }

   // FIXME: precisa ser feita chamada a bz_prune()...
   //xyt_s = bz_prune(xytq_s, 0);
   // workaround...
   xyt_s = (struct xyt_struct *) malloc( sizeof( struct xyt_struct ) );
   for ( i = 0; i < nminutiae; i++ ) 
   {
      xyt_s->xcol[i]     = xytq_s->xcol[i];
      xyt_s->ycol[i]     = xytq_s->ycol[i];
      xyt_s->thetacol[i] = xytq_s->thetacol[i];
   }
   xyt_s->nrows = nminutiae;
   // ...

	// TODO: usar handler de log do PG
   /*if ( verbose_load )
      fprintf( errorfp, "Loaded %s\n", xyt_file );*/

   return xyt_s;
}

