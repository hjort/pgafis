# pgafis/Makefile

MODULE_big = pgafis
OBJS = pgafis.o

EXTENSION = pgafis
DATA = pgafis--1.0.sql pgafis--unpackaged--1.0.sql

NBIS_HOME = /opt/nbis-4.2.0

BOZORTH_LIBS = -lbozorth3 -lm
IMGTOOLS_LIBS = -limage -lihead -lwsq -ljpegl -lpng -lfet -lioutil -lutil -lm
NBIS_LIB = ${NBIS_HOME}/lib/lib

SHLIB_LINK = ${NBIS_LIB}bozorth3.a \
	${NBIS_LIB}mindtct.a \
	${NBIS_LIB}wsq.a ${NBIS_LIB}ioutil.a ${NBIS_LIB}fet.a \
	${NBIS_LIB}jpegl.a \
	${NBIS_LIB}png.a \
	${NBIS_LIB}util.a ${NBIS_LIB}image.a

override CPPFLAGS := -I${NBIS_HOME}/include -L${NBIS_HOME}/lib ${BOZORTH_LIBS} ${IMGTOOLS_LIBS}
override LDFLAGS := -m32 -fPIC

#-O2 -w -ansi -D_POSIX_SOURCE -D__NBISLE__ -D__NBIS_OPENJPEG__ -D__NBIS_PNG__ -m32 -fPIC

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

pgafis.o: pgafis.c pgafis.h cwsq.h mindt.h match.h xyt.h

