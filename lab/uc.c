#include <stdio.h>

#define uchar unsigned char

int main(void) {

	uchar a, b, c;

	a = 22;
	b = 284;
	c = 2930;

	printf("sizeof(uchar): %d\n", sizeof(uchar));
	printf("a: %d, b: %d, c: %d\n", a, b, c);

	return 0;
}
