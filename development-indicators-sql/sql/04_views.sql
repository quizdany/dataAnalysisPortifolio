-- Views used by Tableau.

SET search_path TO rwanda;

CREATE VIEW economic_overview AS
SELECT e.year, e.gdp_growth, e.gdp_per_capita, e.inflation_rate, d.total_population,
       round(avg(e.gdp_growth) OVER (ORDER BY e.year ROWS BETWEEN 4 PRECEDING AND CURRENT ROW), 2)
           AS gdp_growth_5yr_avg,
       round(avg(e.inflation_rate) OVER (ORDER BY e.year ROWS BETWEEN 4 PRECEDING AND CURRENT ROW), 2)
           AS inflation_5yr_avg
FROM economic_indicators e
JOIN demographic_indicators d USING (year);

CREATE VIEW population_trends AS
SELECT year, total_population, urban_population_percent,
       round(100.0 * (total_population::numeric / lag(total_population) OVER (ORDER BY year) - 1), 2)
           AS population_growth_pct
FROM demographic_indicators;

CREATE VIEW education_health_summary AS
SELECT ed.year, ed.primary_enrollment_rate, ed.secondary_enrollment_rate,
       h.infant_mortality_rate, h.health_expenditure_percent_gdp
FROM education_indicators ed
JOIN health_indicators h USING (year);

CREATE VIEW development_dashboard AS
SELECT e.year, e.gdp_growth, e.inflation_rate, d.urban_population_percent,
       ed.primary_enrollment_rate, h.infant_mortality_rate
FROM economic_indicators e
JOIN demographic_indicators d USING (year)
JOIN education_indicators ed USING (year)
JOIN health_indicators h USING (year);
