CFLAGS=-I/opt/nbis-4.2.0/include -L/opt/nbis-4.2.0/lib -g
MIN_LIBS=-limage -lmindtct -lwsq -lfet -ljpegl \
	-lioutil -lihead -lan2k -lpng -lz -lopenjpeg -ljpegb

all: min

min: min.c
	gcc min.c -m32 -fPIC ${CFLAGS} ${MIN_LIBS} -o min -lm -lutil -limage

test: all
	./min sample2.wsq

clean:
	rm -f min *.min *.qm *.hcm *.brw *.lfm *.lcm *.dm *.xyt

