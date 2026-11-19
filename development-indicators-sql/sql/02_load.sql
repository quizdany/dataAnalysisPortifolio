-- Load CSVs (run from development-indicators-sql/).
-- Columns are listed explicitly: the CSVs use "Time" for year and have their own column order.

SET search_path TO rwanda;

\copy economic_indicators (year, gdp_growth, gdp_per_capita, inflation_rate) FROM 'data/economic_indicators.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy demographic_indicators (year, total_population, urban_population_percent, life_expectancy) FROM 'data/demographic_indicators.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy education_indicators (year, secondary_enrollment_rate, primary_enrollment_rate, literacy_rate) FROM 'data/education_indicators.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy health_indicators (year, infant_mortality_rate, health_expenditure_percent_gdp, hospital_beds_per_1000) FROM 'data/health_indicators.csv' WITH (FORMAT csv, HEADER true, NULL '')
