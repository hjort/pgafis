#
# Makefile for example programs
#

subdir = src/test/examples
top_builddir = /usr/src/postgresql-9.3
#top_builddir = ../../..
include $(top_builddir)/src/Makefile.global

ifeq ($(PORTNAME), win32)
LDLIBS += -lws2_32
endif

CFLAGS += -g
override CPPFLAGS := -I$(libpq_srcdir) $(CPPFLAGS)
override LDLIBS := $(libpq_pgport) $(LDLIBS)

PROGS = testlibpq testbytea
#PROGS = testlibpq testlibpq2 testlibpq3 testlibpq4 testlo testlo64 testbytea

all: $(PROGS)

test: all
	./testbytea dbname=afis

clean:
	rm -f $(PROGS) *.o
