#include <stdio.h>
#include <bozorth.h>

int m1_xyt                  = 1; // M1 default {x,y,t} representation
int max_minutiae            = DEFAULT_BOZORTH_MINUTIAE;
int min_computable_minutiae = MIN_COMPUTABLE_BOZORTH_MINUTIAE;

int verbose_main      = 0;
int verbose_load      = 1;
int verbose_bozorth   = 0;
int verbose_threshold = 0;

FILE * errorfp        = FPNULL;

int main(int argc, char *argv[]) {

	int np = 5;
	struct xyt_struct *ps = XYT_NULL; // probe structure
	struct xyt_struct *gs = XYT_NULL; // gallery structure
	int score = 0;
	int i;

	set_progname(0, "bz", 0); // definir nome do programa
	errorfp = stderr; // saída de erro padrão

	// estruturas fixadas
	/*
	ps = (struct xyt_struct *) malloc(sizeof(struct xyt_struct));
	gs = (struct xyt_struct *) malloc(sizeof(struct xyt_struct));

	ps->nrows = 2;
	ps->xcol[0] = 45;
	ps->ycol[0] = 62;
	ps->thetacol[0] = 5;
	//ps->qualitycol[0] = 72;
	ps->xcol[1] = 56;
	ps->ycol[1] = 280;
	ps->thetacol[1] = 118;
	//ps->qualitycol[1] = 17;

	gs->nrows = 2;
	gs->xcol[0] = 18;
	gs->ycol[0] = 39;
	gs->thetacol[0] = 5;
	//gs->qualitycol[0] = 15;
	gs->xcol[1] = 32;
	gs->ycol[1] = 257;
	gs->thetacol[1] = 118;
	//gs->qualitycol[1] = 82;
	*/

	// ler arquivos XYT
	ps = bz_load(argv[1]);
	gs = bz_load(argv[2]);

	/*
	printf("Minúcias A:\n");
	for (i = 0; i < ps->nrows; i++)
		printf("%2d = (%3d, %3d, %3d)\n", (i + 1),
			ps->xcol[i], ps->ycol[i], ps->thetacol[i]);
	printf("Minúcias B:\n");
	for (i = 0; i < gs->nrows; i++)
		printf("%2d = (%3d, %3d, %3d)\n", (i + 1),
			gs->xcol[i], gs->ycol[i], gs->thetacol[i]);
	*/

	score = bozorth_main(ps, gs);
	
	if (ps != XYT_NULL)
		free((char *) ps);
	if (gs != XYT_NULL)
		free((char *) gs);

	printf("score: %d\n", score);

	return score;
}
