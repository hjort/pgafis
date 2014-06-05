CFLAGS=-I/opt/nbis-4.2.0/include -L/opt/nbis-4.2.0/lib -lbozorth3 -lm -g

all: bz

bz: bz.c
	gcc bz.c ${CFLAGS} -o bz

ct: ct.c
	gcc -O2 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -fpic -I. -I/usr/src/postgresql-9.3/src/include -I/opt/nbis-4.2.0/include -L/opt/nbis-4.2.0/lib -lbozorth3 -lm ct.c -o ct

test: all
	#./bz
	./bz ../../samples/xyt/101_1.xyt ../../samples/xyt/101_2.xyt

clean:
	rm -rf bz
