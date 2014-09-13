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

// 1 byte (0..255)
#define uchar unsigned char

// 2 bytes (0..65535)
#define ushort unsigned short

#endif   /* PGAFIS_H */
