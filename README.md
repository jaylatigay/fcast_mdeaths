##📈 Comparative Analysis of Forecasting Models on Mortality Data

Author: Jaymart G. Latigay
Date: September 12, 2025
Course: DS 238: Time Series and Forecasting
Exercise #1

## 📌 Project Overview

This project compares five time series forecasting models using monthly death data (mdeaths) from 1974–1978 (60 months) as training data. The goal is to generate a 12-month forecast for 1979 (months 61–72) and evaluate each model's one-step in-sample accuracy.

Models implemented:

Simple Moving Average (SMA)

Weighted Moving Average (WMA)

Simple Exponential Smoothing (SES)

Simple Linear Regression (SLR / Trend Line Equation)

Trend + Seasonal Decomposition (Additive)

The models are compared using MAD, MAPE, and RMSE accuracy metrics.

## ⚙️ Methodology

Data Preparation

Extracted monthly death counts from 1974–1978.

Created a training dataset with month (1–60) and monthly_deaths.

Helper Function

Defined a custom acc() function to compute:

Mean Absolute Deviation (MAD)

Mean Absolute Percentage Error (MAPE)

Root Mean Squared Error (RMSE)

Forecasting Models

SMA: Forecast based on average of last 4 months.

WMA: Similar to SMA, but recent months weighted more heavily.

SES: Used HoltWinters() without trend or seasonality.

SLR: Linear regression on time index vs. monthly deaths.

Decomposition: Removed seasonality, modeled trend with regression, then re-added seasonal component.

Evaluation

Computed in-sample one-step forecasts for training period.

Generated 12-month out-of-sample forecasts (Jan–Dec 1979).
