SELECT b.arq, bz_match(a.xyt, b.xyt) AS match
FROM dedos a, dedos b
WHERE a.id = 1
ORDER BY match DESC;

/*
afis=# SELECT b.arq, bz_match(a.xyt, b.xyt) AS match
FROM dedos a, dedos b
WHERE a.id = 1
ORDER BY match DESC
LIMIT 5;
    arq    | match 
-----------+-------
 101_1.xyt |   144
 101_6.xyt |    40
 101_8.xyt |    37
 101_2.xyt |    24
 101_5.xyt |    19
(5 rows)
*/

SELECT b.arq, bz_match((SELECT a.xyt FROM dedos a WHERE a.id = 1), b.xyt) AS match
FROM dedos b         
ORDER BY match DESC
LIMIT 5;

/*
afis=# SELECT b.arq, bz_match((SELECT a.xyt FROM dedos a WHERE a.id = 1), b.xyt) AS match FROM dedos b ORDER BY match DESC LIMIT 5;
    arq    | match 
-----------+-------
 101_1.xyt |   144
 101_6.xyt |    40
 101_8.xyt |    37
 101_2.xyt |    24
 101_5.xyt |    19
(5 rows)
*/
