/* pgafis/pgafis--1.2.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pgafis" to load this file. \quit

CREATE FUNCTION cwsq(bytea, real, int, int, int, int)
	RETURNS bytea
	AS 'MODULE_PATHNAME', 'pg_wsq_encode'
        LANGUAGE C IMMUTABLE;

CREATE FUNCTION nfiq(bytea)
	RETURNS int
	AS 'MODULE_PATHNAME', 'pg_nfiq'
        LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION mindt(bytea)
	RETURNS bytea
	AS 'MODULE_PATHNAME', 'pg_min_detect'
        LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION mindt(bytea, boolean)
	RETURNS bytea
	AS 'MODULE_PATHNAME', 'pg_min_detect'
        LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION mdt2text(bytea)
	RETURNS text
	AS 'MODULE_PATHNAME', 'pg_mdt_text'
        LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION mdt_mins(bytea)
	RETURNS int
	AS 'MODULE_PATHNAME', 'pg_mdt_mincnt'
        LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION bz_match(text, text)
	RETURNS int
	AS 'MODULE_PATHNAME', 'pg_bz_match_text'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION bz_match(bytea, bytea)
	RETURNS int
	AS 'MODULE_PATHNAME', 'pg_bz_match_bytea'
	LANGUAGE C STRICT IMMUTABLE;

--
--	eof
--
