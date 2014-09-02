/* contrib/pgafis/pgafis--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pgafis" to load this file. \quit

CREATE FUNCTION bz_match(text, text)
	RETURNS int
	AS 'MODULE_PATHNAME', 'pg_bz_match'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION cwsq(bytea, float, int, int, int, int)
	RETURNS bytea
	AS 'MODULE_PATHNAME', 'pg_cwsq'
        LANGUAGE C STRICT IMMUTABLE;

--
--	eof
--
