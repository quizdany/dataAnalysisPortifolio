-- Rwanda development indicators warehouse: schema.
-- One row per year in each table. Constraints enforce the grain and plausible
-- values, so bad data is rejected at load time instead of reaching a dashboard.

DROP SCHEMA IF EXISTS rwanda CASCADE;
CREATE SCHEMA rwanda;
SET search_path TO rwanda;

CREATE TABLE economic_indicators (
    year            integer PRIMARY KEY CHECK (year BETWEEN 1960 AND 2100),
    gdp_growth      numeric(8, 3) CHECK (gdp_growth BETWEEN -50 AND 50),      -- annual %
    gdp_per_capita  numeric(12, 2) CHECK (gdp_per_capita > 0),             -- current US$
    inflation_rate  numeric(8, 3) CHECK (inflation_rate BETWEEN -50 AND 500) -- consumer prices, annual %
);

CREATE TABLE demographic_indicators (
    year                      integer PRIMARY KEY CHECK (year BETWEEN 1960 AND 2100),
    total_population          bigint NOT NULL CHECK (total_population > 0),
    urban_population_percent  numeric(6, 3) CHECK (urban_population_percent BETWEEN 0 AND 100),
    life_expectancy           numeric(6, 3) CHECK (life_expectancy BETWEEN 20 AND 100)
);

CREATE TABLE education_indicators (
    year                       integer PRIMARY KEY CHECK (year BETWEEN 1960 AND 2100),
    -- Gross enrollment can exceed 100% because over-age pupils are counted.
    primary_enrollment_rate    numeric(7, 3) CHECK (primary_enrollment_rate BETWEEN 0 AND 200),
    secondary_enrollment_rate  numeric(7, 3) CHECK (secondary_enrollment_rate BETWEEN 0 AND 200),
    literacy_rate              numeric(6, 3) CHECK (literacy_rate BETWEEN 0 AND 100)
);

CREATE TABLE health_indicators (
    year                             integer PRIMARY KEY CHECK (year BETWEEN 1960 AND 2100),
    infant_mortality_rate            numeric(7, 2) CHECK (infant_mortality_rate BETWEEN 0 AND 300), -- per 1,000 live births
    health_expenditure_percent_gdp   numeric(6, 3) CHECK (health_expenditure_percent_gdp BETWEEN 0 AND 100),
    hospital_beds_per_1000           numeric(6, 3) CHECK (hospital_beds_per_1000 >= 0)
);

COMMENT ON SCHEMA rwanda IS 'World Bank development indicators for Rwanda, 2000-2023. One row per year per table.';
COMMENT ON COLUMN economic_indicators.gdp_growth IS 'GDP growth, annual %';
COMMENT ON COLUMN economic_indicators.gdp_per_capita IS 'GDP per capita, current US$';
COMMENT ON COLUMN economic_indicators.inflation_rate IS 'Inflation, consumer prices, annual %';
COMMENT ON COLUMN demographic_indicators.urban_population_percent IS 'Urban population, % of total';
COMMENT ON COLUMN education_indicators.primary_enrollment_rate IS 'School enrollment, primary, % gross';
COMMENT ON COLUMN education_indicators.secondary_enrollment_rate IS 'School enrollment, secondary, % gross';
COMMENT ON COLUMN health_indicators.infant_mortality_rate IS 'Infant deaths per 1,000 live births';
