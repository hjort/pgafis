#include <stdio.h>

#define ushort unsigned short

int main(void) {

	unsigned char cc[] = {0x01, 0x01, 0xd2, 0x00};
	ushort s1, s2, *ps, s;
	unsigned int i;

	// http://stackoverflow.com/questions/300808/c-how-to-cast-2-bytes-in-an-array-to-an-unsigned-short
	s1 = (((ushort) cc[1]) << 8) | cc[0];
	s2 = (((ushort) cc[3]) << 8) | cc[2];

	i = (cc[0] << 64) | (cc[1] << 32) | (cc[2] << 16) | (cc[3] << 8);

	printf("c[0]: %d, c[1]: %d, c[2]: %d, c[3]: %d\n", cc[0], cc[1], cc[2], cc[3]);
	printf("s1: %d, s2: %d\n", s1, s2);
	printf("i: %d\n", i);

	// mais fácil: usar ponteiro! :D
	ps = cc;
	s = *ps;
	printf("ps: %d, s: %d\n", *ps, s);

	return 0;
}
