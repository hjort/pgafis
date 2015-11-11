-- FIXME!

set client_min_messages to debug1;
set client_min_messages to default;

UPDATE srcafis SET mins=null, xyt=null, nfiq=null, wsq=null, mdt=null WHERE ds ~ '^FVC2000/DB3';

UPDATE srcafis SET wsq = cwsq(tif, 2.25, 448, 478, 8, null) WHERE ds ~ '^FVC2000/DB3';

UPDATE srcafis SET mdt = mindt(wsq, true) WHERE ds ~ '^FVC2000/DB3';
UPDATE srcafis SET mins = mdt_mins(mdt) WHERE ds ~ '^FVC2000/DB3';
UPDATE srcafis SET xyt = mdt2text(mdt) WHERE ds ~ '^FVC2000/DB3';
UPDATE srcafis SET nfiq = nfiq(wsq) WHERE ds ~ '^FVC2000/DB3';

/*UPDATE srcafis SET mins = mdt_mins(mdt) WHERE ds !~ '^FVC2000/DB3';
UPDATE srcafis SET xyt = mdt2text(mdt) WHERE ds !~ '^FVC2000/DB3';
UPDATE srcafis SET nfiq = nfiq(wsq) WHERE ds !~ '^FVC2000/DB3';*/

select ds, whz, count(1), min(mins) as mins_min, max(mins) as mins_max, trunc(avg(mins),2) as mins_avg, min(nfiq) as nfiq_min, max(nfiq) as nfiq_max, trunc(avg(nfiq),2) as nfiq_avg, round(avg(length(tif))) as tif, round(avg(length(wsq))) as wsq, round(avg(length(mdt))) as mdt, round(avg(length(xyt))) as xyt from srcafis group by ds, whz order by ds, whz;

select min(id), max(id) from srcafis where ds ~ '^FVC2000/DB3';
/*
 min | max 
-----+-----
 241 | 320
*/

select id, mdt_mins(mdt) from srcafis where id = 241; -- ok
select id, mdt_mins(mdt) from srcafis where id = 298; -- erro
select id, mdt_mins(mdt) from srcafis where id between 241 and 320 and id != 298 order by id; -- erro

DO $$DECLARE r record;
BEGIN
    FOR r IN select id from srcafis where ds ~ '^FVC2000/DB3' and id>298 order by id
    LOOP
        raise notice '=> %', r.id;
        EXECUTE 'select id, mdt_mins(mdt) from srcafis where id = ' || r.id;
    END LOOP;
END$$;

select id, fp, nfiq, length(tif) as tif, length(wsq) as wsq, length(mdt) as mdt from srcafis where id between 241 and 320 order by id;

select fp, pid, fid from srcafis where id = 298;

select ds, whz, count(1), min(mins) as mins_min, max(mins) as mins_max, trunc(avg(mins),2) as mins_avg, min(nfiq) as nfiq_min, max(nfiq) as nfiq_max, trunc(avg(nfiq),2) as nfiq_avg, round(avg(length(tif))) as tif, round(avg(length(wsq))) as wsq, round(avg(length(mdt))) as mdt, round(avg(length(xyt))) as xyt from srcafis where id != 298 group by ds, whz order by ds, whz;

