#Author: Jaymart G. Latigay
#Date: Spetember 12, 2025
#Course: DS 238: Time Series and Forecasting
# Exercise # 1
#Description:
#Comparative analysis of 5 forecasting models (i.e., SMA,WMA,SES,SLR,Trend Decomposition)
# using monthly death data from 1974 to 1978 (months 1-60) for training.
# The goal is to generate a 12-month forecast for 1979 (months 61-72)
# and evaluate each model's one-step in-sample accuracy (i.e., MAD, MAPE, RMSE)



mdeaths_1974_to_1978 <- window(mdeaths, start = c(1974,1), end = c(1978, 12))

dataset <- data.frame(
  month_1974_to_1978 = seq_along(mdeaths_1974_to_1978),   # 1 to 60
  monthly_deaths = as.numeric(mdeaths_1974_to_1978)
)

dataset_len <- nrow(dataset)
n <- 4      #number of periods


#Helper: accuracy metrics
acc <- function(actual, fitted) {
  e <- actual - fitted
  MAD <- mean(abs(e), na.rm = TRUE)
  MAPE <- mean(abs(e / actual), na.rm = TRUE) * 100
  RMSE <- sqrt(mean(e^2, na.rm = TRUE))
  c(MAD = MAD, MAPE = MAPE, RMSE = RMSE)
}

#SIMPLE MOVING AVERAGE
sma_fit <- rep(NA_real_, dataset_len) #vector of same length as the dataset and initially has NA values (type double) for storing fitted values
for(t in (n+1): dataset_len) {  
  sma_fit[t] <- mean(dataset$monthly_deaths[(t-n):(t-1)])  #gets the mean for the past n values, gets their mean, and store fitted value in sma_fit at t index
}

#accuracy measure
sma_acc <- acc(dataset$monthly_deaths[(n+1):dataset_len], sma_fit[(n+1):dataset_len])

#Multi-step forecasts: constant = average of last n actuals
sma_fcast <- rep(mean(tail(dataset$monthly_deaths, n)), 12)
names(sma_fcast) <- paste0("M", 61:72) #assigns label to values in a vector
  


#WEIGHTED MOVING AVERAGE
weights <- c(0.5, 0.3, 0.2, 0.1)
weights <- weights/sum(weights)   #normalize to make sure all weights sum up to exactly 1. turned weights to: (0.45, 0.27, 0.18, 0.09)
  
wma_fit <- rep(NA_real_, dataset_len) #vector of same length as the dataset and initially has NA values (type double) for storing fitted values
for(t in (n+1): dataset_len) { 
  window <- dataset$monthly_deaths[(t-n):(t-1)]   #retrieves the past n values
  wma_fit[t] <- sum(weights * rev(window))              #reverse the window vector to apply weights to most recent first
}  
  
#accuracy measure
wma_acc <- acc(dataset$monthly_deaths[(n+1):dataset_len], wma_fit[(n+1):dataset_len])
  
  
#Multi-step forecasts: constant = average of last n actuals
wma_fcast <- rep(sum(weights * rev(tail(dataset$monthly_deaths, n))), 12)   #retrieves the last 4 values from dataset, reverses it, the multiplied each to weights
names(wma_fcast) <- paste0("M", 61:72) #assigns label to values in a vector



#SIMPLE EXPONENTIAL SMOOTHING

#Holt-Winters exponential smoothing without trend and seasonal component
#Holt-Winters provides the best alpha for the dateset
#Holt-Winters provides the fitted values
#Holt-Winters provides the baseline level or forecast
hw_ses <- HoltWinters(ts(dataset$monthly_deaths), beta = FALSE, gamma = FALSE)
  
#retrieves the fitted values 
#fitted is a built in function that extracts fitted values from model object (hw_ses)
#fitted(hw_ses)[,xhat] retrieves only the fitted values (at each time point) -- without [,"xhat"] you'd get the whole matrix
ses_fit <- as.numeric(fitted(hw_ses)[,"xhat"])
  
#Accuracy measure
#actual[2:60] is due to SES doesn't produce a fitted value for the 1st observation
#HoltWinters() it automatically estimates the 1st observation using Least Squares Optimization
ses_acc <- acc(dataset$monthly_deaths[2:length(dataset)], ses_fit )

  
#predict() retrieves the forecast/baseline level (a) from the model object (hw_ses)
#takes the model, and gets the forecast 4 steps ahead (4 periods after time period in dataset)
ses_fcast <- as.numeric(predict(hw_ses, n.ahead = 12)) 
  
names(ses_fcast) <- paste0("M", 61:72) #assigns label to values in a vector
  


#TREND LINE EQUATION (Simple Linear Regression)
#lm is R's linear model function -- used to fit regression models
# (dependent or you want to predit) ~ (independent or predictor)   -- (~) means "is modeled as a function of"
#retrieves the intercept and slope, and fitted values
lm_fit <- lm(monthly_deaths ~ month_1974_to_1978, data = dataset)  
  
lm_fitted <- fitted(lm_fit)  #fitted() retrieves the fitted values in the linear regression model object lm_fit

#accuracy measures
lm_acc <- acc(dataset$monthly_deaths, lm_fitted)
  
#predict() is a function that takes the model and produces predictions for either:
#fitted values to train the model (if no "newdata" is is given), or
#new values of the predictor or forecasts (if "newdata" is provided)
lm_fcast <- predict(lm_fit, newdata = data.frame(month_1974_to_1978 = 61:72)) 
  
names(lm_fcast) <- paste0("M", 61:72)



#SEASONAL DECOMPOSITION WITH TREND
#frequency tells R how many observations in one seasonal cycle
#12 is chosen as its a monthly data with yearly cycle
y_ts <- ts(dataset$monthly_deaths, frequency = 12)
  
# Decompose: splits the series into 3 parts (trend, seasonal component, random noise)
dcmp <- decompose(y_ts, type = "additive")
  
# Seasonal component for first cycle (annual, 1-12)
#ex: if Jan's seasonal index = +500, then during Jan, there are 500 deaths above the trend
seasonal_idx <- dcmp$seasonal[1:12]
  
# Deseasonalize (numeric vector) and store in dataset
#leaves just trend + noise
# This makes the data easier to model, since seasonality is removed
dataset$deseason <- as.numeric(y_ts) - as.numeric(dcmp$seasonal)
  
# Fit linear trend to deseasonalized data
#models the underlying long-term trend without seasonal noise
lm_sa <- lm(deseason ~ month_1974_to_1978, data = dataset)
  
# Reseasonalize fitted values
# adds back seasonal component to fitted trend
# produces final fitted values that include both trend and seasonality, but without random noise
dcmp_fit <- fitted(lm_sa) + as.numeric(dcmp$seasonal)
  
dcmp_acc <- acc(dataset$monthly_deaths,dcmp_fit)
  
# Forecast Months 61 - 72: trend forecast + repeating seasonal pattern
seasonal_61_to_72 <- rep(as.numeric(seasonal_idx), length.out = 12)
trend_61_to_72 <- predict(
  lm_sa,
  newdata = data.frame(month_1974_to_1978 = 61:72)
)
dcmp_fcast <- trend_61_to_72 + seasonal_61_to_72
names(dcmp_fcast) <- paste0("M", 61:72)
  



#RESULTS
cat("\n=== Forecasts (MONTHS 61-72 or Jan - Dec 1979) ===\n")
print(list(
  SMA_4 = sma_fcast,
  WMA_4 = wma_fcast,
  SES = ses_fcast,
  Trend = lm_fcast,
  Decomp_Additive = dcmp_fcast
))


cat("\n=== Accuracy (one-step in-sample) ===\n")
acc_table <- rbind(
  SMA_4 = sma_acc,
  WMA_4 = wma_acc,
  SES = ses_acc,
  Trend = lm_acc,
  Decomp = dcmp_acc
)
print(round(acc_table, 3))







