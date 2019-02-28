* Time Series ARIMA Models in Stata 
* David Li 

clear all
set more off 

use C:\...\...\timeseries_ABC

global ylist ABC 
global dylist d.ABC
global time t 
global lags 50 

describe $time $ylist 
summarize $time $ylist 

* Set data as time series 
tset $time 
* tset $time, quarterly
* gen time=_n

* Plotting the data 
twoway (tsline $ylist)
twoway (tsline d.$ylist)

* twoway line $ylist $time 
* twoway line d.$ylist $time 

* Dickey-Fuller Test for Variable 
dfuller $ylist, dift regress lags(0)
regress d.$ylist l.$ylist 

dfuller $ylist, trend regresslags(0)
* dfuller $ylist, regress lags(2)

* Dickey-Fuller Test for Differencd variable 
dfuller d.$ylist, drift regress lags(0)
regress d.$dylist l.$dylist

* Correlogra, ACF and PACF
corrgram $ylist 
ac $ylist 
pac $ylist 
* pac d.$ylist, xscale(range(0 $lags)) yscale(range(-1 1))

corrgram d.$ylist
ac d.$ylist
pac d.$ylist 

* ARIMA Model 

* ARIMA(1,0,0) or AR(1)
arima $ylist, arima(1,0,0)

* ARIMA(2,0,0) or AR(2)
arima $ylist, arima(2,0,0)

* ARIMA(0,0,1) or MA(1)
arima $ylist, arima(0,0,1)

* ARIMA(1,0,1) or AR(1) MA(1)
arima $ylist, arima(1,0,1)

* ARIMA on differenced variable 
arima $ylist arima(1,1,0)
arima $ylist arima(0,1,1)
arima $ylist arima(1,1,1)
arima $ylist arima(1,1,3)
arima $ylist arima(2,1,3)

* arima d.$ylist, ar(1/2) ma(1/3)
* arima d.$ylist, ar(1 2) ma(1 2 3)

* AIC and BIC for Model Fit 
arima $ylist, arima(1,1,1)
estat ic 
arima $ylist, arima(2,1,3)
estat ic 

* Detrending 
reg $ylist $time 
predict et, resid 
twoway line et $time 
dfuller et, drift regress lags(0)
ac et 
pac et 

