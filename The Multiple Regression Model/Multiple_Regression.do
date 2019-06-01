* The Multiple Regression Model
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX05_food, replace text

* open data
use andy, clear

* Summary Statistics
summarize

* List subset of observations
list in 1/5

* Least squares regression with covariance matrix
regress sales price advert
estat vce

* Predict sales when price is 5.50 and adv is 1200
di _b[_cons] + _b[price]*5.50 + _b[advert]*1.2

* Using the data editor to predict
set obs 76
replace price = 5.50 in 76
replace advert = 1.2 in 76
predict yhat
list yhat in 76

* Calculate sigma-hat square
ereturn list
scalar sighat2 = e(rss)/e(df_r)
scalar list sighat2

* Standard error of the regression
di sqrt(sighat2)

* Confidence Intervals
scalar bL = _b[price] - invttail(e(df_r),.025) * _se[price]
scalar bU = _b[price] + invttail(e(df_r),.025) * _se[price]

scalar list bL bU

* Using the level() command to change size of default intervals
regress sales price advert, level(90)

* Interval for a linear combination
* Easy way
lincom -0.4*price+0.8*advert, level(90)

* Hard way
matrix cov=e(V)
scalar lambda = -0.4*_b[price]+0.8*_b[advert]
scalar var_lambda = (-0.4)^2*cov[1,1]+(0.8)^2*cov[2,2]+2*(-0.4)*(0.8)*cov[1,2]
scalar se = sqrt(var_lambda)
scalar t = lambda/se
scalar lb = lambda-invttail(e(df_r),.05)*se
scalar ub = lambda+invttail(e(df_r),.05)*se
scalar list lambda var_lambda se t lb ub

* t-ratios
scalar t1 = (_b[price]-0)/_se[price]
scalar t2 = (_b[advert]-0)/_se[advert]
scalar list t1 t2

* pvalues
scalar p1 = 2*ttail(72,abs(t1))
scalar p2 = ttail(72,abs(t2))
scalar list p1 p2

* One sided significance test
scalar t1 = (_b[price]-0)/_se[price]
scalar crit = -invttail(e(df_r),.05)
scalar pval = 1-ttail(e(df_r),t1)
scalar list t1 crit pval

* One sided test of Advertising effectiveness
scalar t2 = (_b[advert]-1)/_se[advert]
scalar crit = invttail(e(df_r),.05)
scalar pval = ttail(e(df_r),t2)
scalar list t2 crit pval

* Linear combination
lincom -0.2*price-0.5*advert
scalar t = r(estimate)/r(se)
scalar crit = invttail(e(df_r),.05)
scalar pval = ttail(e(df_r),t)
scalar list crit t pval

return list

* Polynomial
generate a2 = advert*advert
reg sales price advert a2
scalar me1 = _b[advert]+2*(.5)*_b[a2]
scalar me2 = _b[advert]+2*(2)*_b[a2]
scalar list me1 me2

* Nonlinear combinations of variables
scalar advertt0 = (1-_b[advert])/(2*_b[a2])
scalar list advertt0

nlcom (1-_b[advert])/(2*_b[a2])

* Polynomial using factor variables
regress sales price advert c.advert#c.advert
margins, dydx(advert) at(advert=(.5 2))

* Interactions
use pizza4, clear
regress pizza age income c.age#c.income
margins, dydx(age) at(income=(25 90))

use cps4_small, clear
gen lwage = ln(wage)
regress lwage educ exper c.educ#c.exper 
regress lwage educ exper c.educ#c.exper c.exper#c.exper

use andy, clear
reg sales price advert

di "R-square " e(mss)/(e(mss)+e(rss))
di "R-square " 1-e(rss)/(e(mss)+e(rss))
log close
