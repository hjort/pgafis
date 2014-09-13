#include <stdio.h>

#define ushort unsigned short

int main(void) {

	ushort a, b, c;

	a = 22;
	b = 284;
	c = 293;

	printf("sizeof(ushort): %d\n", sizeof(ushort));
	printf("a: %d, b: %d, c: %d\n", a, b, c);

	return 0;
}
