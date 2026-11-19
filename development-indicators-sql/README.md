# Rwanda development indicators warehouse (PostgreSQL)

[![sql-warehouse](https://github.com/quizdany/dataAnalysisPortifolio/actions/workflows/sql.yml/badge.svg)](https://github.com/quizdany/dataAnalysisPortifolio/actions/workflows/sql.yml)

Twenty-four years (2000–2023) of World Bank indicators for Rwanda, modeled in PostgreSQL so that analysts query one clean, trusted source instead of redoing calculations in each report.

## What it does

| Step | File | Details |
| --- | --- | --- |
| Schema | `sql/01_schema.sql` | Four tables (economic, demographic, education, health), one row per year. Primary keys enforce the grain; `CHECK` constraints reject impossible values (for example a negative population, or an urban share above 100%). |
| Load | `sql/02_load.sql` | Loads the CSV extracts with explicit column mapping. This fixes the source's `Time` header, its own column order and a typo (`infat_mortality_rate`). |
| Quality checks | `sql/03_quality_checks.sql` | Blocking checks: gap-free years, the same years in every table, complete GDP and inflation series, no implausible population jumps. Completeness of optional series is reported. Results go to `rwanda.dq_report`, and the build stops on any failure. |
| Views | `sql/04_views.sql` | `economic_overview` (with 5-year averages of growth and inflation), `population_trends`, `education_health_summary` and `development_dashboard`. Metrics are defined once and reused by Tableau. |
| Analysis | `sql/05_analysis.sql` | Above-average growth years (CTE), year-over-year changes (window functions), years with large shifts, and growth by inflation band. |
| Tests | `tests/constraint_tests.sql` | Proves the schema rejects duplicates, missing values and out-of-range data. |

## Run it

```bash
DATABASE_URL=postgresql://user:pass@localhost:5432/db ./build.sh
psql "$DATABASE_URL" -f tests/constraint_tests.sql
```

CI builds the warehouse in a fresh PostgreSQL container and runs the tests on every push.

## Findings

- GDP grew by **7.45% a year** on average over 2000–2023, with inflation averaging 7.2%.
- The only contraction-level swing was 2020 (COVID), followed by the strongest rebound in 2021.
- The data has real gaps, and the quality report makes them visible instead of hiding them: literacy is only 21% complete (it is surveyed every few years), and hospital beds are 67% complete.

## Data

World Bank World Development Indicators for Rwanda: GDP growth, GDP per capita, inflation, population, urbanisation, life expectancy, school enrollment, literacy, infant mortality, health spending and hospital beds.

Dashboard: [Tableau Public](https://public.tableau.com/app/profile/daniel.kwizera/viz/RwandaDevelopmentIndicatorsfromSQL/rwandaDevelopment).
