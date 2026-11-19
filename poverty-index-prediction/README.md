# Predicting poverty in Rwanda from nightlight data

Tests whether satellite nightlight data and population density can predict the Multidimensional Poverty Index (MPI) for each sector in Rwanda.

- 2015 nightlight data is clipped to sector boundaries in ArcGIS Pro.
- Two features are engineered: nightlight per capita and population density. Both are significant predictors (p < 0.05).
- Lasso, Ridge and Elastic Net models are compared. Lasso explains 69% of the variance in MPI (R² = 0.69), and predicted values correlate with actual values at 0.83.
- The overall model did not pass the significance test (p > 0.05). It is a useful signal, not a replacement for survey data.
- Maps of actual and predicted MPI line up closely, especially around Kigali.

The notebook expects `MPIAssignment.xlsx` and `rw_nightlight_2015_07.xls` (course data, not redistributed here).

Write-up: [Predicting Poverty in Rwanda from Nightlight Data](https://alhafizabaka.wixsite.com/my-site-1/post/analyzing-socio-economic-indicators-and-nightlight-data-to-predict-the-multidimensional-poverty-inde).
