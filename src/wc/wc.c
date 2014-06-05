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
	int count = 0;

	// FIXME: não está funcionando...
	if (txt == NULL)
		PG_RETURN_INT32(0);

	// TODO: implementar isso!
	//while (*txt) count++;
	//PG_RETURN_INT32(count);

	PG_RETURN_INT32(42);

	/*
	chkpass    *a1 = (chkpass *) PG_GETARG_POINTER(0);
	text	   *txt = PG_GETARG_TEXT_PP(0);
	char		str[9];
	char	   *crypt_output;

	text_to_cstring_buffer(a2, str, sizeof(str));
	crypt_output = crypt(str, a1->password);
	if (crypt_output == NULL)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("crypt() failed")));

	PG_RETURN_BOOL(strcmp(a1->password, crypt_output) == 0);
	*/
}

PG_FUNCTION_INFO_V1(wc_words);
Datum
wc_words(PG_FUNCTION_ARGS)
{
	PG_RETURN_INT32(53);
}


