* Survival Analysis in Stata
* David Li 

clear all
set more off

use C:\Econometrics\Data\survival_unemployment

global time spell
global event event
global xlist logwage ui age
global group ui

describe $time $event $xlist
summarize $time $event $xlist

* Set data as survival time
stset $time, failure($event)
stdescribe
stsum

* Nonparametric estimation 

* Graph of hazard ratio
sts graph, hazard

* Graph of cumulative hazard ratio (Nelson-Aalen cumulative hazard curve)
sts graph, cumhaz

*Graph of survival function (Kaplan-Meier survival curve)
sts graph, survival

* List of survival function
sts list, survival

* Kaplan-Meier survival curves for two groups
sts graph, by($group) 

* Test for equality of survival functions between two groups
sts test $group


* Parametric models

* Exponential regression coefficients and hazard rates
streg $xlist, nohr dist(exponential)
streg $xlist, dist(exponential)

* Weibull regression coefficients and hazard rates
streg $xlist, nohr dist(weibull)
streg $xlist, dist(weibull)

* Gompertz regression coefficients and hazard rates
streg $xlist, nohr dist(gompertz)
streg $xlist, dist(gompertz)

* Cox proportional hazard model coefficients and hazard rates
stcox $xlist, nohr
stcox $xlist
