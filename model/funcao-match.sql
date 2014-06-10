CREATE TYPE row_match_dedos AS (id int, arq varchar, xyt text, score int);

CREATE OR REPLACE FUNCTION match_dedos(
  xyt_probe text, threshold int, max_matches int)
RETURNS SETOF row_match_dedos AS $$
DECLARE
  r row_match_dedos;
  c int := 0;
BEGIN
  FOR r IN
    SELECT id, arq, xyt
    FROM dedos
  LOOP
    r.score = bz_match(r.xyt, xyt_probe);
    IF r.score >= threshold THEN
      --RAISE NOTICE 'Found match! id: %', r.id;
      c = c + 1;
      RETURN NEXT r;
      IF c >= max_matches THEN
        EXIT;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END
$$ LANGUAGE plpgsql;

SELECT id, arq, score
FROM match_dedos((SELECT xyt FROM dedos WHERE id = 1), 30, 3)
ORDER BY score DESC;

/*
CREATE OR REPLACE FUNCTION match(xyt_probe text, threshold int, max_matches int) RETURNS SETOF record AS $$
DECLARE
  r record;
  c int := 0;
BEGIN
  FOR r IN
    SELECT *
    FROM dedos
  LOOP
    IF bz_match(r.xyt, xyt_probe) >= threshold THEN
      --RAISE NOTICE 'Found match! id: %', r.id;
      c = c + 1;
      RETURN NEXT r;
      IF c >= max_matches THEN
        EXIT;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END
$$ LANGUAGE plpgsql;

SELECT id, arq FROM match((SELECT xyt FROM dedos WHERE id = 1), 50, 3);
*/
