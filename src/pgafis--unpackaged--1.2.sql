/* pgafis/pgafis--unpackaged--1.2.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pgafis" to load this file. \quit

ALTER EXTENSION pgafis ADD FUNCTION cwsq(bytea, real, int, int, int, int);

ALTER EXTENSION pgafis ADD FUNCTION nfiq(bytea);

ALTER EXTENSION pgafis ADD FUNCTION mindt(bytea);
ALTER EXTENSION pgafis ADD FUNCTION mindt(bytea, boolean);

ALTER EXTENSION pgafis ADD FUNCTION mdt2text(bytea);
ALTER EXTENSION pgafis ADD FUNCTION mdt_mins(bytea);

ALTER EXTENSION pgafis ADD FUNCTION bz_match(text, text);
ALTER EXTENSION pgafis ADD FUNCTION bz_match(bytea, bytea);

