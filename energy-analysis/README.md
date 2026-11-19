# Rwanda energy progress analysis

End-to-end analysis of five World Bank energy indicators for Rwanda (1990–2020): electricity access, renewable energy consumption, renewable electricity output, CO2 emissions and energy intensity.

- **Cleaning:** files are loaded with automatic encoding detection, then the series are cleaned and aligned by year.
- **Trends:** rolling averages and year-over-year growth rates.
- **Forecasting:** electricity access and renewable consumption are forecast five years ahead with ARIMA, exponential smoothing and Prophet, and the three are compared.
- **Regression:** renewable energy consumption explains only 11.5% of the variation in CO2 emissions (R² = 0.115). The relationship is negative but weak.
- **Dashboard:** an interactive Dash and Plotly app compares indicators side by side.

Open `RwandaEnergyProject.ipynb`. The CSV files it reads are in this folder.

Write-up: [Rwanda Energy Progress: Trends and Forecasts](https://alhafizabaka.wixsite.com/my-site-1/post/rwanda-energy-progress-a-comprehensive-analysis).
