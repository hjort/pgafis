#CFLAGS += -lfprint

all: enroll

enroll: enroll.c
	gcc enroll.c -lfprint -o enroll

clean:
	rm -f enroll

test: enroll
	./enroll 2
