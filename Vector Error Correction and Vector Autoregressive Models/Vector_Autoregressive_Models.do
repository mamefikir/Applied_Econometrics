* Vector Error Correction and Vector Autoregressive Models
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX13, replace text

*-----------------------------------------
* Estimating a VECM
* Load the data and create a time variable
*-----------------------------------------

use gdp, clear
gen date = q(1970q1) + _n - 1 
format %tq date
tsset date

*-----------------------------------------
* Plot the series to identify constants 
* and trends.
*-----------------------------------------

tsline aus usa, scheme(sj) name(level, replace)
tsline D.aus D.usa, scheme(sj) name(difference, replace)

* Test for Unit Roots
* Experiment with noconst, trend, drift, and lag length
dfuller aus, regress lags(1)
dfuller usa, regress lags(3)

* Cointegrating regression
reg aus usa, noconst
predict ehat, res
tsline ehat, name(C1, replace)

* Engle-Granger Test for Cointegration
reg D.ehat L.ehat, noconst
dfuller ehat, lags(0) noconst

*-----------------------------------------
* VECM 
*-----------------------------------------

regress D.aus L.ehat
regress D.usa L.ehat
drop ehat

*-----------------------------------------
* VAR Estimation 
*-----------------------------------------

use fred, clear
gen date = q(1960q1) + _n - 1 
format %tq date
tsset date

*-----------------------------------------
* Plot the series to identify constants 
* and trends.
*-----------------------------------------

tsline c y, legend(lab (1 "ln(RPCE)") lab(2 "ln(RPDI)")) /// 
       name(l1, replace) lpattern(solid dash)
tsline D.c D.y, legend(lab (1 "ln(RPCE)") lab(2 "ln(RPDI)")) ///
       name(d1, replace) lpattern(solid dash)

* Stationarity Analysis
* Brute force, 1 equation at a time
qui reg L(0/1).D.c L.c 
di "Lags = 1"   
estat bgodfrey, lags(1 2 3)
qui reg L(0/2).D.c L.c 
di "Lags = 2"  
estat bgodfrey, lags(1 2 3)
qui reg L(0/3).D.c L.c 
di "Lags = 3"
estat bgodfrey, lags(1 2 3)
dfuller c, lags(3)

* Use the loop to compute stats for y
forvalues p = 1/3 {
   qui reg L(0/`p').D.y L.y
   di "Lags =" `p'  
   estat bgodfrey, lags(1 2 3)
}
dfuller y, lags(0)

* Cointegration Test: Case 2
reg c y
predict ehat, res
reg D.ehat L.ehat D.L.ehat, noconst
di _b[L.ehat]/_se[L.ehat]

reg D.c D.L.c D.L.y
reg D.y D.L.c D.L.y

varbasic D.c D.y, lags(1/1) step(12) nograph

*-------------------------------------------
* Test residuals for autocorrelation
*-------------------------------------------
varlmar 

* Try extending lags to 3 and repeat
quietly varbasic D.c D.y, lags(1/3) step(12)
varlmar
* There is evidence of autocorrelation so extend the lag to 3

* Selecting lags using model selection criteria
varsoc D.c D.y, maxlag(4)

* Impulse responses and variance decompositions
qui varbasic D.c D.y, lags(1/1) step(12)
irf table irf
irf table fevd

irf graph irf, name(g1, replace)
irf graph fevd, name(g2, replace)

* Combining irf and fevd in a single table
irf table irf fevd, title("Combined IRF/FEVD for C and Y")

log close

