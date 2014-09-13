CFLAGS=-I/opt/nbis-4.2.0/include -L/opt/nbis-4.2.0/lib -g

all: bz ct uc us

bz: bz.c
	gcc bz.c ${CFLAGS} -lbozorth3 -lm -o bz

ct: ct.c
	gcc -O2 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -fpic -I. -I/usr/src/postgresql-9.3/src/include -I/opt/nbis-4.2.0/include -L/opt/nbis-4.2.0/lib -lbozorth3 -lm ct.c -o ct

wsq: wsq.c
	gcc wsq.c -m32 -fPIC ${CFLAGS} -limage -lihead -lwsq -ljpegl -lfet -lioutil -lutil -lm -o wsq

test: all
	#./bz
	./bz ../../samples/xyt/101_1.xyt ../../samples/xyt/101_2.xyt

wsq-test: wsq
	./wsq sample2.pgm

clean:
	rm -rf bz
