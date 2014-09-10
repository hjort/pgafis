/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

struct xyt_struct * load_xyt(char*);
struct xyt_struct * load_xyt_binary(unsigned char *, unsigned);

// load_xyt
struct xyt_struct * load_xyt(char *str)
{
	int nminutiae; // número da linha da minúcia
	int m;
	int i;
	int nargs_expected; // qtde esperada de colunas

	struct xyt_struct * xyt_s;
	struct xytq_struct * xytq_s;
	int xvals_lng[MAX_FILE_MINUTIAE], // temporary lists to store all the minutiae from a finger
		yvals_lng[MAX_FILE_MINUTIAE],
		tvals_lng[MAX_FILE_MINUTIAE],
		qvals_lng[MAX_FILE_MINUTIAE];
	char xyt_line[MAX_LINE_LENGTH];

	nminutiae = 0;
	nargs_expected = 0;

	memset(xyt_line, 0, MAX_LINE_LENGTH);

	do {

		if (*str != '\n' && *str != '\0') {
			strncat(xyt_line, str++, 1);
			continue;
		}

		m = sscanf(xyt_line, "%d %d %d %d",
			&xvals_lng[nminutiae],
			&yvals_lng[nminutiae],
			&tvals_lng[nminutiae],
			&qvals_lng[nminutiae]);

//		elog(NOTICE, "%2d = <%s>", nminutiae + 1, xyt_line);

//		if (nminutiae == 0)
//			elog(NOTICE, "Line 1: %s", xyt_line);
//		if (nminutiae > 0 && m != nargs_expected)
//			elog(ERROR, "Inconsistent argument count on line %u of minutiae data (%u, %u): [%s]",
//				nminutiae + 1, m, nargs_expected, xyt_line);

		memset(xyt_line, 0, MAX_LINE_LENGTH);

		if (nminutiae == 0)
		{
			if (m != 3 && m != 4) 
			{
				elog(ERROR, "Invalid format of minutiae data on line %u", nminutiae + 1);
				return XYT_NULL;
			}
			nargs_expected = m;
		} 
		else 
		{
			if (m != nargs_expected)
			{
				elog(ERROR, "Inconsistent argument count on line %u of minutiae data", nminutiae + 1);
				return XYT_NULL;
			}
		}

		if (m == 3)
			qvals_lng[nminutiae] = 1;

		if (!*str)
			break;
		str++;

		++nminutiae;
		if (nminutiae == MAX_FILE_MINUTIAE)
			break;

	} while (1);

	xytq_s = (struct xytq_struct *) malloc(sizeof(struct xytq_struct));
	if (xytq_s == XYTQ_NULL)
	{
		elog(ERROR, "Allocation failure while loading minutiae buffer");
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

	xyt_s = bz_prune(xytq_s, 0);

	// workaround temporário...
	/*
	xyt_s = (struct xyt_struct *) malloc(sizeof(struct xyt_struct));
	xyt_s->nrows = nminutiae;
	for (i = 0; i < nminutiae; i++) 
	{
		xyt_s->xcol[i]     = xytq_s->xcol[i];
		xyt_s->ycol[i]     = xytq_s->ycol[i];
		xyt_s->thetacol[i] = xytq_s->thetacol[i];
	}
	*/

	if (xytq_s != XYTQ_NULL)
		free((char *) xytq_s);

	//elog(NOTICE, "Loaded minutiae data with %d lines", nminutiae + 1);

	return xyt_s;
}

// load_xyt_binary
struct xyt_struct * load_xyt_binary(unsigned char *data, unsigned size)
{
	struct xyt_struct * xyt_s;
	//struct xytq_struct * xytq_s;

	xyt_s = XYT_NULL;

	return xyt_s;
}

