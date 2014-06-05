/* contrib/wc/wc--unpackaged--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION wc" to load this file. \quit

ALTER EXTENSION wc ADD function wc_chars(text);
ALTER EXTENSION wc ADD function wc_lines(text);
ALTER EXTENSION wc ADD function wc_words(text);

/*
ALTER EXTENSION wc ADD type wc;
ALTER EXTENSION wc ADD function wc_in(cstring);
ALTER EXTENSION wc ADD function wc_out(wc);
ALTER EXTENSION wc ADD function raw(wc);
ALTER EXTENSION wc ADD function eq(wc,text);
ALTER EXTENSION wc ADD function ne(wc,text);
ALTER EXTENSION wc ADD operator <>(wc,text);
ALTER EXTENSION wc ADD operator =(wc,text);
*/
