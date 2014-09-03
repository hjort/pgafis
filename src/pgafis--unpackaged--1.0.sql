/* contrib/pgafis/pgafis--unpackaged--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pgafis" to load this file. \quit

ALTER EXTENSION pgafis ADD FUNCTION bz_match(text, text);

ALTER EXTENSION pgafis ADD FUNCTION cwsq(bytea, real, int, int, int, int);

