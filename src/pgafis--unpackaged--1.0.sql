/* contrib/pgafis/pgafis--unpackaged--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pgafis" to load this file. \quit

ALTER EXTENSION pgafis ADD function bz_match(text, text);

