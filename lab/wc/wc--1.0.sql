/* contrib/wc/wc--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION wc" to load this file. \quit

CREATE FUNCTION wc_lines(text)
	RETURNS int
	AS 'MODULE_PATHNAME', 'wc_lines'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION wc_chars(text)
	RETURNS int
	AS 'MODULE_PATHNAME', 'wc_chars'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION wc_words(text)
	RETURNS int
	AS 'MODULE_PATHNAME', 'wc_words'
	LANGUAGE C STRICT IMMUTABLE;

/*
--
--	Input and output functions and the type itself:
--

CREATE FUNCTION wc_in(cstring)
	RETURNS wc
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT;

CREATE FUNCTION wc_out(wc)
	RETURNS cstring
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT;

CREATE TYPE wc (
	internallength = 16,
	input = wc_in,
	output = wc_out
);

CREATE FUNCTION raw(wc)
	RETURNS text
	AS 'MODULE_PATHNAME', 'wc_rout'
	LANGUAGE C STRICT;

--
--	The various boolean tests:
--

CREATE FUNCTION eq(wc, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'wc_eq'
	LANGUAGE C STRICT;

CREATE FUNCTION ne(wc, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'wc_ne'
	LANGUAGE C STRICT;

--
--	Now the operators.
--

CREATE OPERATOR = (
	leftarg = wc,
	rightarg = text,
	negator = <>,
	procedure = eq
);

CREATE OPERATOR <> (
	leftarg = wc,
	rightarg = text,
	negator = =,
	procedure = ne
);

COMMENT ON TYPE wc IS 'password type with checks';
*/

--
--	eof
--
