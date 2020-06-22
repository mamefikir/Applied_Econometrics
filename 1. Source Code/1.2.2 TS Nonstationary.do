* Regression with Time-Series Data: Nonstationary Variables
* Shaofei Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX12, replace text
use usa, clear

* ---------------------------------------
* Create dates and declare time-series
* ---------------------------------------

generate date = q(1984q1) + _n-1
format date %tq
tsset date

* ---------------------------------------
* Extract dates with year and quarter 
* ---------------------------------------

gen double newdate = dofq(date)
gen y = year(newdate)
gen q = quarter(newdate)

list date y q in 1/9

* ---------------------------------------
* Graph time-series 
* Graphs are named with replace option
* and combined.
* ---------------------------------------

qui tsline gdp, name(gdp, replace)  
qui tsline D.gdp, name(dgdp, replace) 
graph combine gdp dgdp

qui tsline inf, name(inf, replace)
qui tsline D.inf, name(dinf, replace) yline(0)
qui tsline f, name(f, replace)
qui tsline D.f, name(df, replace) yline(0)
qui tsline b, name(b, replace)
qui tsline D.b, name(db, replace) yline(0)

graph combine inf dinf f df b db, cols(2)

* Two ways to limit dates
summarize if date<=q(1996q4)
summarize if date>=q(1997q1)

summarize if tin(,1996q4)
summarize if tin(1997q1,)

* To get summary stats for all variables and differences without generate
summarize gdp inf b f D.gdp D.inf D.b D.f if tin(1984q2,1996q4)
summarize gdp inf b f D.gdp D.inf D.b D.f if tin(1997q1,) 
summarize

* ---------------------------------------
* Spurious Regression
* ---------------------------------------

use spurious, clear
gen time = _n
tsset time

regress rw1 rw2
estat bgodfrey

tsline rw1 rw2, name(g1, replace)
scatter rw1 rw2, name(g2, replace)

regress rw1 rw2
estat bgodfrey

* ---------------------------------------
* Unit root tests and cointegration
* ---------------------------------------

use usa, clear
gen date = q(1984q1) + _n - 1
format %tq date
tsset date

* Augmented Dickey Fuller Regressions
regress D.f L.f L.D.f
regress D.b L.b L.D.b

* Augmented Dickey Fuller Regressions with built in functions
dfuller f, regress lags(1)
dfuller b, regress lags(1)

* ADF on differences
dfuller D.f, noconstant lags(0)
dfuller D.b, noconstant lags(0)

* DF-GLS tests
dfgls f
dfgls b

* Phillips-Perron tests
pperron f, regress trend
pperron b, regress trend

* Engle Granger cointegrations test
regress b f
predict ehat, residual
regress D.ehat L.ehat L.D.ehat, noconstant

* Using the built-in Stata commands
dfuller ehat, noconstant lags(1)
drop ehat

gen Db=D.b
nl (Db = -{alpha}*(L.b-{beta1}-{beta2}*L.f)+{delta0}*D.f+{delta1}*D.L.f), variables(L.b L.f D.L.f) 
scalar theta1 = 1-_b[alpha:_cons]
scalar list theta1

gen ehat = L.b - _b[beta1:_cons]-_b[beta2:_cons]*L.f
qui reg D.ehat L.ehat L.D.ehat, noconst
di _b[L.ehat]/_se[L.ehat]
log close
