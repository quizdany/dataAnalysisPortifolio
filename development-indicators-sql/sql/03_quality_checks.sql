-- Data quality checks -> rwanda.dq_report. Fails if a blocking check fails.
-- Completeness is reported only (some series have real gaps).

SET search_path TO rwanda;

CREATE TABLE dq_report (
    check_name  text PRIMARY KEY,
    observed    numeric,
    expected    text,
    blocking    boolean,
    passed      boolean
);

-- years: no gaps, same in every table
INSERT INTO dq_report
SELECT 'years_contiguous_' || t, gaps, '= 0', true, gaps = 0
FROM (
    SELECT 'economic' AS t, (max(year) - min(year) + 1) - count(*) AS gaps FROM economic_indicators
    UNION ALL SELECT 'demographic', (max(year) - min(year) + 1) - count(*) FROM demographic_indicators
    UNION ALL SELECT 'education', (max(year) - min(year) + 1) - count(*) FROM education_indicators
    UNION ALL SELECT 'health', (max(year) - min(year) + 1) - count(*) FROM health_indicators
) g;

INSERT INTO dq_report
SELECT 'tables_share_same_years', count(*), '= 0', true, count(*) = 0
FROM (
    SELECT year, count(*) AS tables_with_year
    FROM (
        SELECT year FROM economic_indicators
        UNION ALL SELECT year FROM demographic_indicators
        UNION ALL SELECT year FROM education_indicators
        UNION ALL SELECT year FROM health_indicators
    ) all_years
    GROUP BY year
    HAVING count(*) <> 4
) missing;

-- key series complete
INSERT INTO dq_report
SELECT 'gdp_growth_complete', count(*) FILTER (WHERE gdp_growth IS NULL), '= 0', true,
       count(*) FILTER (WHERE gdp_growth IS NULL) = 0
FROM economic_indicators;

INSERT INTO dq_report
SELECT 'inflation_complete', count(*) FILTER (WHERE inflation_rate IS NULL), '= 0', true,
       count(*) FILTER (WHERE inflation_rate IS NULL) = 0
FROM economic_indicators;

-- population: no >5% jump in a year
INSERT INTO dq_report
SELECT 'population_yoy_jump_over_5pct', count(*), '= 0', true, count(*) = 0
FROM (
    SELECT total_population::numeric / lag(total_population) OVER (ORDER BY year) - 1 AS growth
    FROM demographic_indicators
) p
WHERE abs(growth) > 0.05;

-- completeness (info only)
INSERT INTO dq_report
SELECT 'completeness_pct_' || col, round(100.0 * filled / total, 1), 'reported', false, true
FROM (
    SELECT 'life_expectancy' AS col, count(life_expectancy) AS filled, count(*) AS total FROM demographic_indicators
    UNION ALL SELECT 'primary_enrollment_rate', count(primary_enrollment_rate), count(*) FROM education_indicators
    UNION ALL SELECT 'literacy_rate', count(literacy_rate), count(*) FROM education_indicators
    UNION ALL SELECT 'infant_mortality_rate', count(infant_mortality_rate), count(*) FROM health_indicators
    UNION ALL SELECT 'hospital_beds_per_1000', count(hospital_beds_per_1000), count(*) FROM health_indicators
) c;

SELECT check_name, observed, expected, blocking, passed FROM dq_report ORDER BY blocking DESC, check_name;

DO $$
DECLARE failures text;
BEGIN
    SELECT string_agg(check_name, ', ') INTO failures FROM rwanda.dq_report WHERE blocking AND NOT passed;
    IF failures IS NOT NULL THEN
        RAISE EXCEPTION 'Data quality checks failed: %', failures;
    END IF;
END $$;
