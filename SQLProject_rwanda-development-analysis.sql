-- Rwanda Development Analysis Project
-- Author: Daniel Kwizera
-- Date: 22/07/2024

-- Project Aim: To analyze and visualize Rwanda's development progress over the past two decades (2000-2023) 
-- across key economic, demographic, educational, and health indicators, identifying trends, 
-- correlations, and potential areas for future development focus.

-- This script performs the following tasks:
-- 1. Creates a database and necessary tables
-- 2. Imports data from CSV files
-- 3. Conducts basic and advanced data analysis
-- 4. Creates views for dashboard preparation
-- 5. Prepares queries for visualization and further analysis


-- ----------------------
-- Database Creation
-- ----------------------

CREATE DATABASE rwanda_development;


-- ----------------------
-- Table Creation
-- ----------------------

-- Economic Indicators Table
CREATE TABLE economic_indicators (
    year INT,
    gdp_growth FLOAT,
    gdp_per_capita FLOAT,
    inflation_rate FLOAT
);

-- Demographic Indicators Table
CREATE TABLE demographic_indicators (
    year INT,
    total_population INT,
    urban_population_percent FLOAT,
    life_expectancy FLOAT
);

-- Education Indicators Table
CREATE TABLE education_indicators (
    year INT,
    primary_enrollment_rate FLOAT,
    secondary_enrollment_rate FLOAT,
    literacy_rate FLOAT
);

-- Health Indicators Table
CREATE TABLE health_indicators (
    year INT,
    infant_mortality_rate FLOAT,
    health_expenditure_percent_gdp FLOAT,
    hospital_beds_per_1000 FLOAT
);

-- ----------------------
-- Data Import
-- ----------------------

-- Used pgAdmin to manually move files to the database


-- ----------------------
-- Basic Data Exploration
-- ----------------------

-- 1. Economic growth over time
-- This query shows the trend of GDP growth and per capita GDP over the years
SELECT year, gdp_growth, gdp_per_capita
FROM economic_indicators
ORDER BY year;

-- 2. Population growth and urbanization
-- This query illustrates the change in total population and urban population percentage
SELECT year, total_population, urban_population_percent
FROM demographic_indicators
ORDER BY year;

-- 3. Education progress
-- This query shows the trends in primary and secondary school enrollment rates, and literacy rate
SELECT year, primary_enrollment_rate, secondary_enrollment_rate, literacy_rate
FROM education_indicators
ORDER BY year;

-- 4. Health improvements
-- This query demonstrates changes in infant mortality rate and health expenditure over time
SELECT year, infant_mortality_rate, health_expenditure_percent_gdp
FROM health_indicators
ORDER BY year;

-- 5. Correlation between GDP growth and education enrollment
-- This query helps visualize any potential relationship between economic growth and education
SELECT e.year, e.gdp_growth, ed.primary_enrollment_rate, ed.secondary_enrollment_rate
FROM economic_indicators e
JOIN education_indicators ed ON e.year = ed.year
ORDER BY e.year;

-- ----------------------
-- Advanced SQL Techniques
-- ----------------------

-- 1.Calculating 5-year moving averages for key indicators
-- This query provides a smoothed trend line for various indicators, reducing short-term fluctuations
SELECT 
    year,
    AVG(gdp_growth) OVER (ORDER BY year ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS gdp_growth_5yr_avg,
    AVG(urban_population_percent) OVER (ORDER BY year ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS urban_pop_5yr_avg,
    AVG(primary_enrollment_rate) OVER (ORDER BY year ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS primary_enrollment_5yr_avg,
    AVG(infant_mortality_rate) OVER (ORDER BY year ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS infant_mortality_5yr_avg
FROM economic_indicators e
JOIN demographic_indicators d ON e.year = d.year
JOIN education_indicators ed ON e.year = ed.year
JOIN health_indicators h ON e.year = h.year
ORDER BY year;

-- 2.Identifying years with significant changes across multiple indicators
-- This query helps pinpoint years where Rwanda experienced notable shifts in development indicators
WITH yearly_changes AS (
    SELECT 
        e.year,
        e.gdp_growth - LAG(e.gdp_growth) OVER (ORDER BY e.year) AS gdp_growth_change,
        d.urban_population_percent - LAG(d.urban_population_percent) OVER (ORDER BY e.year) AS urban_pop_change,
        ed.primary_enrollment_rate - LAG(ed.primary_enrollment_rate) OVER (ORDER BY e.year) AS enrollment_change,
        h.infant_mortality_rate - LAG(h.infant_mortality_rate) OVER (ORDER BY e.year) AS mortality_change
    FROM economic_indicators e
    JOIN demographic_indicators d ON e.year = d.year
    JOIN education_indicators ed ON e.year = ed.year
    JOIN health_indicators h ON e.year = h.year
)
SELECT year, gdp_growth_change, urban_pop_change, enrollment_change, mortality_change
FROM yearly_changes
WHERE ABS(gdp_growth_change) > 2 -- GDP growth changed by more than 2 percentage points
   OR ABS(urban_pop_change) > 1 -- Urban population changed by more than 1 percentage point
   OR ABS(enrollment_change) > 5 -- Primary enrollment changed by more than 5 percentage points
   OR ABS(mortality_change) > 5 -- Infant mortality changed by more than 5 per 1000 births
ORDER BY year;


-- 1. Window function to calculate year-over-year GDP growth change
-- This query uses a window function to compute the change in GDP growth from the previous year
SELECT year, 
       gdp_growth,
       gdp_growth - LAG(gdp_growth) OVER (ORDER BY year) AS gdp_growth_change
FROM economic_indicators
ORDER BY year;

-- 2. Common Table Expression (CTE) to find years with above-average GDP growth
-- This query uses a CTE to calculate the average GDP growth and then finds years exceeding this average
WITH avg_gdp AS (
    SELECT AVG(gdp_growth) AS avg_gdp_growth
    FROM economic_indicators
)
SELECT ei.year, ei.gdp_growth
FROM economic_indicators ei, avg_gdp
WHERE ei.gdp_growth > avg_gdp.avg_gdp_growth
ORDER BY ei.year;

-- 3. Pivot table to show education indicators side by side
-- This query uses conditional aggregation to create a pivot-like view of education indicators
SELECT year,
       MAX(CASE WHEN indicator = 'primary_enrollment_rate' THEN value END) AS primary_enrollment,
       MAX(CASE WHEN indicator = 'secondary_enrollment_rate' THEN value END) AS secondary_enrollment,
       MAX(CASE WHEN indicator = 'literacy_rate' THEN value END) AS literacy_rate
FROM (
    SELECT year, 'primary_enrollment_rate' AS indicator, primary_enrollment_rate AS value
    FROM education_indicators
    UNION ALL
    SELECT year, 'secondary_enrollment_rate', secondary_enrollment_rate
    FROM education_indicators
    UNION ALL
    SELECT year, 'literacy_rate', literacy_rate
    FROM education_indicators
) AS unpivoted
GROUP BY year
ORDER BY year;

-- ----------------------
-- Creating Views for Dashboard
-- ----------------------

-- Economic Overview View
-- This view combines key economic and demographic indicators for easy querying
CREATE VIEW economic_overview AS
SELECT e.year, e.gdp_growth, e.gdp_per_capita, e.inflation_rate, d.total_population
FROM economic_indicators e
JOIN demographic_indicators d ON e.year = d.year;

-- Education and Health Summary View
-- This view brings together education and health indicators for comparative analysis
CREATE VIEW education_health_summary AS
SELECT e.year, e.primary_enrollment_rate, e.secondary_enrollment_rate, 
       h.infant_mortality_rate, h.health_expenditure_percent_gdp
FROM education_indicators e
JOIN health_indicators h ON e.year = h.year;

--Population trends View
--This view tracks the trend of the total population in general and of urban population if particular
CREATE VIEW population_trends AS 
SELECT year, total_population, urban_population_percent 
FROM demographic_indicators;


-- ----------------------
-- Queries for Dashboard Visualizations
-- ----------------------

-- 1. GDP Growth Trend
-- This query to create a line chart of GDP growth over time
SELECT year, gdp_growth FROM economic_indicators ORDER BY year;

-- 2. Population vs. Urbanization
-- This query to create a dual-axis chart showing population growth and urbanization rate
SELECT year, total_population, urban_population_percent 
FROM demographic_indicators ORDER BY year;

-- 3. Education Enrollment Rates
-- This query to create a stacked bar chart of primary and secondary enrollment rates
SELECT year, primary_enrollment_rate, secondary_enrollment_rate 
FROM education_indicators ORDER BY year;

-- 4. Health Indicators Over Time
-- This query to create a multi-line chart of health indicators
SELECT year, infant_mortality_rate, health_expenditure_percent_gdp 
FROM health_indicators ORDER BY year;

-- 5. Combined Economic and Social Indicators
-- This query to create a dashboard summary showing key indicators across all sectors
SELECT e.year, e.gdp_growth, d.urban_population_percent, 
       ed.primary_enrollment_rate, h.infant_mortality_rate
FROM economic_indicators e
JOIN demographic_indicators d ON e.year = d.year
JOIN education_indicators ed ON e.year = ed.year
JOIN health_indicators h ON e.year = h.year
ORDER BY e.year;



