-- Load the World Bank CSV extracts. Run from the development-indicators-sql folder.
-- The CSVs use "Time" for the year and list columns in their own order, so each
-- \copy names the target columns explicitly (this also maps the source typo
-- "infat_mortality_rate" to infant_mortality_rate). Empty cells load as NULL.

SET search_path TO rwanda;

\copy economic_indicators (year, gdp_growth, gdp_per_capita, inflation_rate) FROM 'data/economic_indicators.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy demographic_indicators (year, total_population, urban_population_percent, life_expectancy) FROM 'data/demographic_indicators.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy education_indicators (year, secondary_enrollment_rate, primary_enrollment_rate, literacy_rate) FROM 'data/education_indicators.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy health_indicators (year, infant_mortality_rate, health_expenditure_percent_gdp, hospital_beds_per_1000) FROM 'data/health_indicators.csv' WITH (FORMAT csv, HEADER true, NULL '')
