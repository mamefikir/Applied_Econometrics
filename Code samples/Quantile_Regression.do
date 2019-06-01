* Quantile Regression in Stata
* David Li 

clear all
set more off

* Download Stata ado file: qplot
* ssc install grqreg

use C:\Econometrics\Data\quantile_health.dta

global ylist totexp
global xlist suppins totchr age female white

describe $ylist $xlist
summarize $ylist $xlist

* Descriptive statistics by quantile
sort $ylist
xtile ycat= $ylist, nq(4)
bysort ycat:sum $ylist $xlist

* Regression 
reg $ylist $xlist

* Quantile regressions for 25th, 50th, and 75th quantiles
qreg $ylist $xlist, quantile(.25)
qreg $ylist $xlist
qreg $ylist $xlist, quantile(.75)

* Plot dependent variable by quantiles
qplot $ylist, recast(line) 

* Plot coefficients for each regressor by quantiles
quietly qreg $ylist $xlist
grqreg, cons ci ols olsci 

* Test for heteroskedasticity
quietly reg $ylist $xlist
estat hettest $xlist, iid
