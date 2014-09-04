#define get_progname pg_get_progname
#include <postgres.h>
#undef get_progname
#include <bozorth.h>

// see: http://stackoverflow.com/questions/9847952/error-conflicting-types-for-whatever

int main(void) {
	printf("ct\n");
	return 123;
}
