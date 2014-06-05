SELECT b.arq, bz_match(a.xyt, b.xyt) AS match
FROM dedos a, dedos b
WHERE a.id = 1
ORDER BY match DESC;

/*
afis=# SELECT b.arq, bz_match(a.xyt, b.xyt) AS match FROM dedos a, dedos b WHERE a.id = 1 ORDER BY match DESC LIMIT 5;
    arq    | match 
-----------+-------
 107_5.xyt |   100
 106_8.xyt |    97
 102_8.xyt |    97
 102_6.xyt |    95
 102_2.xyt |    95
(5 rows)
*/

