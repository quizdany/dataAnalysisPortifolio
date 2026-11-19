-- Analysis queries.

SET search_path TO rwanda;

-- period averages
SELECT min(year) AS first_year, max(year) AS last_year,
       round(avg(gdp_growth), 2) AS avg_gdp_growth_pct,
       round(avg(inflation_rate), 2) AS avg_inflation_pct
FROM economic_indicators;

-- above-average growth years
WITH avg_gdp AS (SELECT avg(gdp_growth) AS avg_growth FROM economic_indicators)
SELECT year, round(gdp_growth, 2) AS gdp_growth
FROM economic_indicators, avg_gdp
WHERE gdp_growth > avg_growth
ORDER BY year;

-- year-over-year change
SELECT year,
       round(gdp_growth - lag(gdp_growth) OVER (ORDER BY year), 2) AS gdp_growth_change,
       round(inflation_rate - lag(inflation_rate) OVER (ORDER BY year), 2) AS inflation_change
FROM economic_indicators
ORDER BY year;

-- years with big shifts
WITH yearly_changes AS (
    SELECT e.year,
           e.gdp_growth - lag(e.gdp_growth) OVER w AS gdp_growth_change,
           d.urban_population_percent - lag(d.urban_population_percent) OVER w AS urban_pop_change,
           ed.primary_enrollment_rate - lag(ed.primary_enrollment_rate) OVER w AS enrollment_change,
           h.infant_mortality_rate - lag(h.infant_mortality_rate) OVER w AS mortality_change
    FROM economic_indicators e
    JOIN demographic_indicators d USING (year)
    JOIN education_indicators ed USING (year)
    JOIN health_indicators h USING (year)
    WINDOW w AS (ORDER BY e.year)
)
SELECT year, round(gdp_growth_change, 2) AS gdp_growth_change,
       round(urban_pop_change, 2) AS urban_pop_change,
       round(enrollment_change, 2) AS enrollment_change,
       round(mortality_change, 2) AS mortality_change
FROM yearly_changes
WHERE abs(gdp_growth_change) > 2 OR abs(urban_pop_change) > 1
   OR abs(enrollment_change) > 5 OR abs(mortality_change) > 5
ORDER BY year;

-- growth by inflation band
SELECT CASE WHEN inflation_rate < 3 THEN 'low (<3%)'
            WHEN inflation_rate < 8 THEN 'moderate (3-8%)'
            ELSE 'high (>=8%)' END AS inflation_band,
       count(*) AS years,
       round(avg(gdp_growth), 2) AS avg_gdp_growth
FROM economic_indicators
GROUP BY 1
ORDER BY min(inflation_rate);
