/**
 * pgAFIS - Automated Fingerprint Identification System support for PostgreSQL
 * Project Home: https://github.com/hjort/pgafis
 *
 * Authors:
 * Rodrigo Hjort <rodrigo.hjort@gmail.com>
 */

#ifndef PGAFIS_H
#define PGAFIS_H

#include <stdio.h>
#include <unistd.h>

#define get_progname pg_get_progname
#include <postgres.h>
#undef get_progname

#include "fmgr.h"
#include "utils/builtins.h"

#define ushort unsigned short
#define uchar unsigned char

#endif   /* PGAFIS_H */
