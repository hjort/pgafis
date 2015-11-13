#include <stdio.h>

#define uint unsigned int

int main(void) {

	uint a, b, c;

	a = 22000;
	b = 28400000;
	c = 29300000000;

	printf("sizeof(uint): %d\n", sizeof(uint));
	printf("a: %d, b: %d, c: %d\n", a, b, c);

	return 0;
}
