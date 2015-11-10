FIXME!

UPDATE srcafis SET mins = mdt_mins(mdt) WHERE ds !~ '^FVC2000/DB3';
UPDATE srcafis SET xyt = mdt2text(mdt) WHERE ds !~ '^FVC2000/DB3';
UPDATE srcafis SET nfiq = nfiq(wsq) WHERE ds !~ '^FVC2000/DB3';

select ds, whz, count(1), avg(mins) as mins, avg(nfiq) as nfiq, avg(length(wsq)) as wsq, avg(length(mdt)) as mdt, avg(length(xyt)) as xyt from srcafis group by ds, whz order by ds, whz;

