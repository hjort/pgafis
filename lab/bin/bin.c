#include <stdio.h>

#define ushort unsigned short

int main(void) {

	FILE *file;
	size_t ret;

	int i;
	char x[10] = "ABCDEFGHIJ";
	unsigned y[5] = {1, 11, 21, 31, 41};
	ushort z[7] = {3, 5, 7, 9, 13, 15, 17};
	ushort *zz, *pzz;

	zz = malloc(sizeof(ushort) * 2);
	pzz = zz;
	*pzz = 3;
	printf("pzz = %d\n", *pzz);
	pzz++;
	//*zz++ = 3; *zz++ = 5; *zz++ = 7;

	//printf("Storage size for ushort: %d bytes\n", sizeof(ushort));


	// 1. escrita

	// FILE *fopen(const char *filename, const char *mode);
	file = fopen("test.bin", "wb");

	// size_t fwrite(const void *ptr, size_t size_of_elements, size_t number_of_elements, FILE *a_file);

	ret = fwrite(z, sizeof(z[0]), sizeof(z) / sizeof(z[0]), file);
	/*
	ret = fwrite(x, sizeof(x[0]), sizeof(x) / sizeof(x[0]), file);
	printf("ret = %d\n", ret);
	ret = fwrite(y, sizeof(y[0]), 5, file);
	printf("ret = %d\n", ret);
	*/

	// int fclose(FILE *a_file);
	fclose(file);


	// 2. leitura

	*x = 0;
	*y = 0;

	file = fopen("test.bin", "rb");

	// size_t fread(void *ptr, size_t size_of_elements, size_t number_of_elements, FILE *a_file);

	/*
	ret = fread(&x, sizeof(char), 10, file);
	printf("ret = %d\n", ret);
	ret = fread(&y, sizeof(unsigned), 5, file);
	printf("ret = %d\n", ret);

	printf("x = %s\n", x);
	for (i = 0; i < 5; i++)
		printf("y[%d] = %d\n", i, y[i]);
	*/
	for (i = 0; i < sizeof(z) / sizeof(z[0]); i++)
		printf("z[%d] = %d\n", i, z[i]);

	fclose(file);

	free(zz);

	return 0;
}
