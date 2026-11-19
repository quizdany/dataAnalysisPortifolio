-- Bad inserts that should be rejected. Run after build.sh.

SET search_path TO rwanda;

CREATE OR REPLACE FUNCTION pg_temp.expect_rejected(stmt text, label text) RETURNS void AS $$
BEGIN
    BEGIN
        EXECUTE stmt;
    EXCEPTION WHEN integrity_constraint_violation OR check_violation OR not_null_violation
              OR unique_violation THEN
        RAISE NOTICE 'ok: % rejected', label;
        RETURN;
    END;
    RAISE EXCEPTION 'FAILED: % was accepted', label;
END $$ LANGUAGE plpgsql;

BEGIN;
SELECT pg_temp.expect_rejected('INSERT INTO economic_indicators VALUES (2010, 5, 500, 3)', 'duplicate year');
SELECT pg_temp.expect_rejected('INSERT INTO demographic_indicators VALUES (2030, -5, 20, 60)', 'negative population');
SELECT pg_temp.expect_rejected('INSERT INTO demographic_indicators VALUES (2031, NULL, 20, 60)', 'missing population');
SELECT pg_temp.expect_rejected('INSERT INTO demographic_indicators VALUES (2032, 100, 140, 60)', 'urban share over 100%');
SELECT pg_temp.expect_rejected('INSERT INTO education_indicators VALUES (2033, 250, 40, 70)', 'enrollment over 200%');
SELECT pg_temp.expect_rejected('INSERT INTO health_indicators VALUES (1800, 50, 5, 1)', 'year out of range');
ROLLBACK;
