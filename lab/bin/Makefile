CFLAGS = -m32 -fPIC -O2 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard

all: bin

bin: bin.c
	gcc bin.c ${CFLAGS} -o bin

test: all
	./bin

clean:
	rm -rf bin

