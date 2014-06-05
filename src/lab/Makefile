CFLAGS=-I/opt/nbis-4.2.0/include -L/opt/nbis-4.2.0/lib -lbozorth3 -lm -g

all: bz

bz: bz.c
	gcc bz.c ${CFLAGS} -o bz

test: all
	#./bz
	./bz ../../samples/xyt/101_1.xyt ../../samples/xyt/101_2.xyt

clean:
	rm -rf bz
