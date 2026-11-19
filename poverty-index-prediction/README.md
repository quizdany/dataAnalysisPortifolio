# Poverty prediction from nightlight data

Can nightlight satellite data and population density predict the Multidimensional Poverty Index (MPI) by sector in Rwanda?

- nightlight data (2015) clipped to sector boundaries in ArcGIS Pro
- features: nightlight per capita, population density (both p < 0.05)
- Lasso: R² = 0.69, predicted vs actual correlation 0.83
- overall model not significant (p > 0.05), so it's a signal, not a replacement for surveys
- actual vs predicted maps match closely, especially around Kigali

Needs `MPIAssignment.xlsx` and `rw_nightlight_2015_07.xls` (course data, not included).
