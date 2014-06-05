# contrib/pgafis/Makefile

MODULE_big = pgafis
OBJS = pgafis.o

EXTENSION = pgafis
DATA = pgafis--1.0.sql pgafis--unpackaged--1.0.sql

#SHLIB_LINK = $(filter -lcrypt, $(LIBS))

override CPPFLAGS := -I/opt/nbis-4.2.0/include -L/opt/nbis-4.2.0/lib -lbozorth3 -lm

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/pgafis
top_builddir = /usr/src/postgresql-9.3
#top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
