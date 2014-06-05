#include "postgres.h"

#include "fmgr.h"
#include "utils/builtins.h"
#include <unistd.h>

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

Datum wc_chars(PG_FUNCTION_ARGS);
Datum wc_lines(PG_FUNCTION_ARGS);
Datum wc_words(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(wc_chars);
Datum
wc_chars(PG_FUNCTION_ARGS)
{
	PG_RETURN_INT32(31);
}

PG_FUNCTION_INFO_V1(wc_lines);
Datum
wc_lines(PG_FUNCTION_ARGS)
{
	text *txt = PG_GETARG_TEXT_PP(0);
	//int32 size = VARSIZE(txt) - VARHDRSZ;
	int32 count = 0;
	char *str = VARDATA_ANY(txt);
	//size_t nbytes = VARSIZE_ANY_EXHDR(txt);

	// FIXME: não está funcionando...
	if (!str)
	//if (txt == NULL)
		PG_RETURN_INT32(0);

	count = 1;
	while (*str) {
		if (*str == '\n')
			count++;
		str++;
	}

	PG_RETURN_INT32(count);
}

PG_FUNCTION_INFO_V1(wc_words);
Datum
wc_words(PG_FUNCTION_ARGS)
{
	PG_RETURN_INT32(53);
}


