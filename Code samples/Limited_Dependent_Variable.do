* Limited Dependent Variable Models in Stata (Tobit, Truncated Regression, Heckman Models)
* David Li 

clear all
set more off

use C:\Econometrics\Data\limdep_ambexp

global ylist ambexp
global xlist age female totchr

describe $ylist $xlist
summarize $ylist $xlist

summarize $ylist, detail
summarize $ylist if $ylist >0, detail 

* Dummy variable 0 or 1 for y
generate dy = $ylist > 0

* Regression
reg $ylist $xlist

* Tobit
tobit $ylist $xlist, ll(0) 

* Tobit model marginal effects for the censored sample
 margins, dydx(*) atmeans predict (ystar(0,.))
 
* Tobit model marginal effects for the truncated sample
margins, dydx(*) atmeans predict (e(0,.))

* Two-limit Tobit
*tobit $ylist $xlist, ll(0) ul(10000)

* Probit
probit $ylist $xlist

* Truncated regression
truncreg $ylist $xlist, ll(0)
margins, dydx(*) atmeans predict(e(0,.))

* Test for Tobit vs Probit + truncated regression
quietly tobit $ylist $xlist, ll(0)
scalar lltobit=e(ll)
quietly probit $ylist $xlist
scalar llprobit=e(ll)
quietly truncreg $ylist $xlist, ll(0)
scalar lltruncreg=e(ll)
scalar Tobittest=2*(llprobit+lltruncreg-lltobit)
display "Tobittest = " Tobittest

* Heckman model
heckman $ylist $xlist, select(dy = $xlist) twostep
margins, dydx(*) atmeans predict(e(0,.))
