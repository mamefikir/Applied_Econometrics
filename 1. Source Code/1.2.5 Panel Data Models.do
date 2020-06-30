* Panel Data Models
* Shaofei Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log file
log using chap15_nls, replace text

* Open and examine the data
use nls_panel, clear
xtset id year
describe
summarize lwage educ south black union exper tenure
list id year lwage educ south black union exper tenure in 1/10

*********** Pooled OLS

* OLS
reg lwage educ exper exper2 tenure tenure2 black south union

* OLS with cluster robust standard errors
reg lwage educ exper exper2 tenure tenure2 black south union, vce(cluster id)

********** LSDV estimator for small N
use nls_panel10, clear
summarize lwage educ exper exper2 tenure tenure2 black south union

* LSDV for wage equation
reg lwage ibn.id exper exper2 tenure tenure2 union, noconstant

scalar sse_u = e(rss)
scalar df_u = e(df_r)
scalar sig2u = sse_u/df_u

test (1.id=2.id) (2.id=3.id) (3.id=4.id) (4.id=5.id) ///
     (5.id=6.id) (6.id=7.id) (7.id=8.id) (8.id=9.id)(9.id=10.id)


* Pooled model
reg lwage exper exper2 tenure tenure2 union
scalar sse_r = e(rss)

* F-test: using sums of squared residuals

scalar f = (sse_r - sse_u)/(9*sig2u)
scalar fc = invFtail(9,df_u,.05)
scalar pval = Ftail(9,df_u,f)
di "F test of equal intercepts = " f
di "F(9,df_u,.95) = " fc
di "p value = " pval

********** Use data in deviation from mean form

use nls_panel_devn, clear
summarize
list lw_dev exp_dev union_dev in 1/10
reg lw_dev exp_dev exp2_dev ten_dev ten2_dev union_dev, noconstant

* Create deviation from mean data
use nls_panel10, clear
xtset id year
sort id, stable

* Sort data and create group means
global v1list lwage exper exper2 tenure tenure2 union

foreach var of varlist $v1list {
	by i: egen `var'bar = mean(`var')
	gen `var'_dev = `var' - `var'bar
	}

list id year lwage lwagebar lwage_dev in 1/10

* OLS regression on data in deviations from mean
reg lwage_dev exper_dev exper2_dev tenure_dev tenure2_dev union_dev, noconstant

* Using fixed effects software
xtreg lwage exper exper2 tenure tenure2 union, fe

* Fixed effects using complete NLS panel
use nls_panel, clear
xtset id year

global x1list exper exper2 tenure tenure2 south union
xtreg lwage $x1list, fe

* FE with robust cluster-corrected standard errors
xtreg lwage $x1list, fe vce(cluster id)

* Recover individual differences from mean
predict muhat, u
tabstat muhat if year==82, stat(sum)

* Using time invariant variables
global x2list educ black $x1list
xtreg lwage $x2list, fe
xtsum educ

********** Random Effects

xtreg lwage $x2list, re theta

* RE with robust cluster-corrected standard errors
xtreg lwage $x2list, re vce(cluster id)

* Calculation of RE transformation parameter
quietly xtreg lwage $x2list, fe
scalar sig2e =( e(sigma_e))^2

* Automatic Between estimator
xtreg lwage $x2list, be 
ereturn list

* Save sigma2_between and compute theta
scalar sig2b = e(rss)/e(df_r)
scalar sig2u = sig2b - sig2e/e(Tbar)
scalar sigu = sqrt(sig2u)
scalar theta = 1-sqrt(sig2e/(e(Tbar)*sig2u+sig2e))
di "Components of variance"
di "sig2e   = " sig2e " variance of overall error e(it)"
di "sige    = " sqrt(sig2e) " standard deviation of e(it)"
di "sig2b   = " sig2b " variance from between regression "
di "sig2u   = " sig2u " derived variance mu(i) "
di "sigu    = " sigu  " standard deviation mu(i) "
di "theta   = " theta " transformation parameter "

* transform data including intercept
gen one = 1
sort id, stable
global v2list lwage one $x2list

foreach var of varlist $v2list {
	by i: egen `var'bar = mean(`var')
	gen `var'd = `var' - theta*`var'bar
	}

* RE is ols applied to transformed data
reg lwaged educd blackd experd exper2d tenured tenure2d southd uniond oned, noconstant

* Breusch-Pagan test
quietly xtreg lwage $x2list, re 
xttest0

* Hausman contrast test
quietly xtreg lwage $x2list, fe
estimates store fe

quietly xtreg lwage $x2list, re 
estimates store re

hausman fe re

* Regression based Hausman test
global xlist3 experbar exper2bar tenurebar tenure2bar southbar ///
       unionbar educ exper exper2 tenure tenure2 black south union

xtreg lwage $xlist3, re 
test experbar exper2bar tenurebar tenure2bar southbar unionbar

* Hausman test with robust VCE
xtreg lwage $xlist3, re vce(cluster id)
test experbar exper2bar tenurebar tenure2bar southbar unionbar

* Add year specific indicator variable
tabulate year, generate (d)
xtreg lwage $xlist3 d2-d5, re vce(cluster id)
test experbar exper2bar tenurebar tenure2bar southbar unionbar

* Hausman-Taylor Model
xthtaylor lwage $x2list, endog(south educ) constant(educ black)

log close

********** Seemingly Unrelated Regressions

* open log
log using chap15_sur, replace text

* Open Grunfeld GE & WE data
use grunfeld2, clear
describe
summarize

* pooled least squares
reg inv v k

* Create slope and intercept indicators
tabulate firm, generate(d)
gen vd1 = v*d1
gen kd1 = k*d1
gen vd2 = v*d2
gen kd2 = k*d2

* model with indicator and slope-indicator variables
reg inv v k d2 vd2 kd2
test d2 vd2 kd2

reg inv v k ib1.firm ib1.firm#(c.v c.k)
test 2.firm 2.firm#c.v 2.firm#c.k

* model with firm specific variables
reg inv d1 d2 vd1 vd2 kd1 kd2, noconstant
test (d1=d2) (vd1=vd2) (kd1=kd2)

* use factor variable notation
reg inv ibn.firm ibn.firm#(c.v c.k), noconstant
test (1.firm=2.firm) (1.firm#c.v=2.firm#c.v) (1.firm#c.k=2.firm#c.k)

* Separate regressions allow different variances
reg inv v k if firm==1
scalar sse_ge = e(rss)

reg inv v k if firm==2
scalar sse_we = e(rss)

* Goldfeld-Quandt test
scalar GQ = sse_ge/sse_we
scalar fc95 = invFtail(17,17,.05)
di "Goldfeld-Quandt Test statistic = " GQ
di "F(17,17,.95) = " fc95

* SUR using XTGLS
xtset firm year, yearly
xtgls inv ibn.firm ibn.firm#(c.v c.k), noconstant panels(correlated) nmk
test (1.firm=2.firm) (1.firm#c.v=2.firm#c.v) (1.firm#c.k=2.firm#c.k)

* pooled model GLS with group hetero
xtgls inv v k, panels(heteroskedastic) nmk

* pooled model GLS with sur assumptions
xtgls inv v k, panels(correlated) nmk

* pooled model GLS with sur assumptions iterated
xtgls inv v k, panels(correlated) nmk igls

* pooled model GLS with sur assumptions and common ar(1)
xtgls inv v k, panels(correlated) corr(ar1) nmk

* pooled ols with sur cov matrix
xtpcse inv v k, nmk

* Convert long data to wide data and use SUREG
use grunfeld2, clear
reshape wide inv v k, i(year) j(firm)
describe
summarize
list in 1/5

sureg (inv1 v1 k1) (inv2 v2 k2), corr dfk small
matrix list e(Sigma)

log close

********** Mixed models

log using chap15_mixed, replace text 
clear

* set random number seed
set seed 1234567

* generate some panel data

set obs 10			// number of groups

* random group effects with correlation sgrp
matrix sgrp = (1, .5 \ .5, 1)		
drawnorm u1 u2, corr(sgrp)	

gen grp = _n		// assign group id
expand 20			// number of individuals per group

* random individual effects with correlation sind
matrix sind = (1, .7 \ .7, 1)		
drawnorm u3 u4, corr(sind)	

gen id = _n			// assign individual id
expand 10			// number of observations per individual
sort grp id 		// arrange by group and person

* generate time or occasion counter for each id
by grp id: gen t = _n

* generate uncorrelated x and e
matrix sigxe = (1, 0 \ 0,1)
drawnorm x e, corr(sigxe)

* change variable order
order grp id t u1 u2 u3 u4 x e
list grp id t u1 u2 u3 u4 x e in 1/20

* random individual intercept dgp
gen y = (10 + u3) + 5*x + 3*e

xtset id t
xtreg y x, re
xttest0

* random individual intercept and random slope
gen y2 = (10 + u3) + (5 + u4)*x + 3*e
xtmixed y2 x || id: x

* random intercept and slope: person and group effect
gen y3 = (10 + u3 + 2*u1) + (5 + u4 + 2*u2)*x + 3*e
xtmixed y3 x || grp: x, cov(un) ||id: x, cov(un)
log close
