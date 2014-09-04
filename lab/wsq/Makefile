CFLAGS=-I/opt/nbis-4.2.0/include -L/opt/nbis-4.2.0/lib -g -limage -lihead -lwsq -ljpegl -lfet -lioutil -lutil -lm

all: wsq

wsq: wsq.c
	gcc wsq.c -m32 -fPIC ${CFLAGS} -o wsq

test: all
	./wsq sample2.pgm

clean:
	rm -rf wsq
