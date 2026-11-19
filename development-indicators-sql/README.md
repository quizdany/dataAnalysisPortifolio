# Rwanda development indicators – PostgreSQL

[![sql-warehouse](https://github.com/quizdany/dataAnalysisPortifolio/actions/workflows/sql.yml/badge.svg)](https://github.com/quizdany/dataAnalysisPortifolio/actions/workflows/sql.yml)

World Bank indicators for Rwanda (2000–2023) loaded into PostgreSQL: economy, population, education and health.

| File | What it does |
| --- | --- |
| `sql/01_schema.sql` | 4 tables, one row per year. Primary keys + CHECK constraints (no negative population, urban share ≤ 100%, etc.) |
| `sql/02_load.sql` | Loads the CSVs. Maps the `Time` column to `year` and fixes a typo in the source (`infat_mortality_rate`) |
| `sql/03_quality_checks.sql` | No missing years, same years in every table, GDP/inflation complete, no big population jumps. Results in `rwanda.dq_report`; the build stops if a check fails |
| `sql/04_views.sql` | Views for the dashboard (5-year averages, population growth, etc.) |
| `sql/05_analysis.sql` | CTEs and window functions: above-average growth years, year-over-year changes, growth by inflation band |
| `tests/constraint_tests.sql` | Checks that bad rows get rejected |

## Run

```bash
DATABASE_URL=postgresql://user:pass@localhost:5432/db ./build.sh
psql "$DATABASE_URL" -f tests/constraint_tests.sql
```

## Findings

- Average GDP growth 2000–2023: **7.45%**, average inflation 7.2%
- Biggest swing: the 2020 drop (COVID) and the 2021 rebound
- Gaps in the data: literacy is only 21% complete, hospital beds 67%

Dashboard: [Tableau Public](https://public.tableau.com/app/profile/daniel.kwizera/viz/RwandaDevelopmentIndicatorsfromSQL/rwandaDevelopment)
