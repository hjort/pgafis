# contrib/wc/Makefile

MODULE_big = wc
OBJS = wc.o

EXTENSION = wc
DATA = wc--1.0.sql wc--unpackaged--1.0.sql

SHLIB_LINK = $(filter -lcrypt, $(LIBS))

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/wc
top_builddir = /usr/src/postgresql-9.3
#top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
