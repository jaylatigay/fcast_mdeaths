# 📈 Comparative Analysis of Forecasting Models on Mortality Data  

**Author:** Jaymart G. Latigay  
**Date:** September 12, 2025  
**Course:** DS 238: Time Series and Forecasting  
**Exercise #1**  

---

## 📌 Project Overview  

This project compares **five time series forecasting models** using monthly death data (`mdeaths`) from **1974–1978 (60 months)** as training data. The goal is to generate a **12-month forecast for 1979 (months 61–72)** and evaluate each model's **one-step in-sample accuracy**.  

Models implemented:  
- **Simple Moving Average (SMA)**  
- **Weighted Moving Average (WMA)**  
- **Simple Exponential Smoothing (SES)**  
- **Simple Linear Regression (SLR / Trend Line Equation)**  
- **Trend + Seasonal Decomposition (Additive)**  

The models are compared using **MAD, MAPE, and RMSE** accuracy metrics.  

---

## ⚙️ Methodology  

1. **Data Preparation**  
   - Extracted monthly death counts from 1974–1978.  
   - Created a training dataset with `month (1–60)` and `monthly_deaths`.  

2. **Helper Function**  
   - Defined a custom `acc()` function to compute:  
     - Mean Absolute Deviation (MAD)  
     - Mean Absolute Percentage Error (MAPE)  
     - Root Mean Squared Error (RMSE)  

3. **Forecasting Models**  
   - **SMA:** Forecast based on average of last 4 months.  
   - **WMA:** Similar to SMA, but recent months weighted more heavily.  
   - **SES:** Used `HoltWinters()` without trend or seasonality.  
   - **SLR:** Linear regression on time index vs. monthly deaths.  
   - **Decomposition:** Removed seasonality, modeled trend with regression, then re-added seasonal component.  

4. **Evaluation**  
   - Computed **in-sample one-step forecasts** for training period.  
   - Generated **12-month out-of-sample forecasts (Jan–Dec 1979)**.  

---

## 📊 Results  

### 🔮 Forecasts (Months 61–72, Jan–Dec 1979)  

| Model              | Forecasts (Jan → Dec 1979) |
|--------------------|-----------------------------|
| **SMA (4-month)**  | 1258 (constant all months)  |
| **WMA (4-month)**  | 1421.818 (constant all months) |
| **SES**            | 1811.954 (constant all months) |
| **SLR (Trend)**    | 1325.972 → 1255.568 (declining) |
| **Decomp (Additive)** | 1960.95 → 1726.29 (seasonal variation) |

---

### 📈 Accuracy (One-step In-sample)  

| Model   |   MAD   |  MAPE  |   RMSE  |
|---------|---------|--------|---------|
| **SMA** | 415.013 | 28.152 | 484.777 |
| **WMA** | 338.250 | 22.707 | 405.347 |
| **SES** | 482.300 | 25.888 | 555.495 |
| **Trend (SLR)** | 356.819 | 24.304 | 417.560 |
| **Decomp (Additive)** | 108.207 |  6.613 | 156.867 |

---

## 🧐 Interpretations  

- The time series data, **mdeaths**, showed a **declining long-term trend**, with **seasonal peaks from January to March**, **lows in mid-year**, and **rebounds during the last three months**. It also contained random monthly noise.  

- **SMA, WMA, and SES** produced **flat forecasts**. These models are not suited for datasets with both **seasonality and trend**, since they cannot keep up with variations in the data.  

- For the **Simple Linear Regression (Trend Model)**, surprisingly, **WMA slightly outperformed it across all three error measures**. Possible reasons:  
  - Since accuracy is **one-step ahead**, WMA reacts faster to recent values, while the regression line adapts more slowly.  
  - The time series is **not perfectly linear** — it has annual dips and rebounds. WMA reflects these fluctuations better, while regression cannot capture them.  
  - **WMA smooths out random monthly noise** through weighted averaging, while regression follows a strict straight-line fit. From observation: the regression model is “too stiff and sticks by the rules,” while WMA “adapts flexibly to recent past information.”  

- **Seasonal Decomposition with Trend** performed **by far the best** across all metrics. This is because it explicitly accounts for three key components of time series data:  
  - **Level (average)** — handled by all models (means, weights, smoothing, intercept).  
  - **Trend (long-term drift)** — explicitly modeled in regression and decomposition.  
  - **Seasonality (annual cycles)** — **only decomposition** captured this repeating yearly pattern, which gave it a clear advantage.  

✅ **Conclusion:** Models that capture **both trend and seasonality** are far superior for time series like `mdeaths`, while simple smoothing methods fall short.  

---

## 📚 References  

- R Documentation: [`mdeaths` dataset](https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/UKLungDeaths.html)  
- [UK Lung Deaths Analysis on RPubs](https://rpubs.com/datadivas/UKlungdeathsanalysis)  

---
