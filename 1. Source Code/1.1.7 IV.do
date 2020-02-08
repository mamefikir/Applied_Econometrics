* Using Indicator Variables
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX07_utown, replace text

* open data
use utown, clear

* summarize and examine
describe
summarize
list in 1/6
list in 501/506

* examples creating indicator variables
summarize price sqft, detail
gen large = (sqft > 25)
gen midprice = (215 < price) & (price < 275)
list sqft price large midprice in 1/5

* estimate dummy variable regression
reg price i.utown sqft i.utown#c.sqft age i.pool i.fplace
reg price i.utown##c.sqft age i.pool i.fplace

* test significance of utown
test 1.utown 1.utown#c.sqft

* use lincom for utown slope and intercept
lincom _cons + 1.utown
lincom c.sqft + 1.utown#c.sqft

* ame
margins, dydx(*)

* ame for utown
quietly summarize sqft
scalar asqft = r(mean)
lincom 1.utown+c.sqft#1.utown*asqft

* ame for sqft
quietly summarize utown
scalar autown = r(mean)
lincom c.sqft+c.sqft#1.utown*autown

/********************************/
/* A matrix approach            */
/* Not included in text material*/
/********************************/

matrix list e(b)
matrix list e(V)
matrix vbols = e(V)

*-----------------------------------
* for utown
*-----------------------------------
* extract variances and covariance
scalar vb2=vbols[2,2]
scalar vb5=vbols[5,5]
scalar cov52 = vbols[5,2]

* mean of _cons and sqft
quietly summarize sqft
scalar asqft = r(mean)
scalar aconst = 1

* delta method for ame of utown
scalar vame=(aconst^2)*vb2+(asqft^2)*vb5+2*asqft*aconst*cov52
scalar seame = sqrt(vame)
di "Delta-method standard error for utown " seame

*-----------------------------------
* for sqft
*-----------------------------------
* delta method se for sqft ame
quietly summarize utown
scalar autown = r(mean)
scalar vb3=vbols[3,3]
scalar cov53 = vbols[5,3]

* delta method
scalar vame=(aconst^2)*vb3+(autown^2)*vb5+2*autown*aconst*cov53
scalar seame = sqrt(vame)
di "Delta-method standard error for sqft " seame

log close

* Chapter 7.2 in POE4: Applying indicator variables

* open new log
log using chap07_cps4, replace text

* open data
use cps4_small, clear
describe
summarize

* estimate model with black-female interaction
reg wage educ i.black##i.female

* estimate wage difference between black-female and white-male
lincom 1.black + 1.female + 1.black#1.female

* F-test of joint significance
test 1.female 1.black 1.black#1.female

* Average marginal effects
margins, dydx(*)

quietly summarize black
scalar ablack = r(mean)
lincom 1.female + 1.black#1.female*ablack

* Chapter 7.2.2 Add regional indicators
reg wage educ i.black##i.female i.south i.midwest i.west
test 1.south 1.midwest 1.west

di "F(3,992,.95) = " invFtail(3,992,.05) 
di "F(3,992,.90) = " invFtail(3,992,.10)

* Chapter 7.2.3 Testing the equivalence of two regressions
reg wage i.south##(c.educ i.black##i.female)
test 1.south 1.south#c.educ 1.south#1.black 1.south#1.female ///
     1.south#1.black#1.female

* constructing estimates in separate regressions from fully interacted model
lincom 1.black + 1.black#1.south
lincom 1.female + 1.female#1.south

* Estimate separate regressions
bysort south: reg wage educ i.black##i.female

* Chapter 7.3 Log-linear models

gen lwage = ln(wage)

* estimate regression
reg lwage educ i.female

* use nlcom to obtain exact effect of dummy variable
nlcom 100*(exp(_b[1.female]) - 1)

* using nlcom with interaction variables
reg lwage c.educ##c.exper
reg, coeflegend

lincom 100*(exper+ c.educ#c.exper*16)
nlcom 100*(exp( _b[exper]+_b[c.educ#c.exper]*16) - 1)
log close

* Chapter 7.4 Linear Probability Model

* open new log
log using chap07_coke, replace text

* open data and examine
use coke, clear
describe
summarize

* estimate regression
reg coke pratio disp_coke disp_pepsi
predict phat
summarize phat
summarize phat if phat<=0
log close

* Chapter 7.5 Treatment Effects

* open new log
log using chap07_star, replace text

* open data and examine
use star, clear
describe

drop if aide==1
summarize 

* create lists
global x1list small
global x2list $x1list tchexper
global x3list $x2list boy freelunch white_asian
global x4list $x3list tchwhite tchmasters schurban schrural

* summarize for regular and small classes
summarize totalscore $x4list if regular==1
summarize  totalscore $x4list if small==1

* correlations
pwcorr $x3list

* create school indicators
tabulate schid, gen(school)

* regressions
quietly reg totalscore $x1list
estimates store model1

quietly reg totalscore $x2list
estimates store model2

quietly reg totalscore $x3list
estimates store model3

quietly reg totalscore $x4list
estimates store model4

* create simple tables
estimates table model1 model2 model3 model4, b(%12.3f) se stats(N r2 F bic)

* create better tables: enter findit esttab
esttab model1 model2 model3 model4 , se(%12.3f) b(%12.3f) ///
       star(* 0.10 ** 0.05 *** 0.01) gaps ar2 bic scalars(rss) ///
	   title("Project Star: Kindergarden")

* regressions with fixed effects
* the hard way
reg totalscore $x2list school2-school79

* using areg
areg totalscore $x1list, absorb(schid)
estimates store amodel1

areg totalscore $x2list, absorb(schid)
estimates store amodel2

quietly areg totalscore $x3list, absorb(schid)
estimates store amodel3

quietly areg totalscore $x4list, absorb(schid)
estimates store amodel4
   
esttab amodel1 amodel2 amodel3 amodel4 , se(%12.3f) b(%12.3f) ///
       star(* 0.10 ** 0.05 *** 0.01) gaps ar2 bic scalars(rss) ///
	   title("Project Star: Kindergarden, with school effects")

* create Table 7.7
esttab model1 model2 amodel1 amodel2 , se(%14.4f) b(%14.4f) ///
       star(* 0.10 ** 0.05 *** 0.01) gaps ar2 scalars(rss) ///
	   title("Project Star: Kindergarden")
 	   
* Chapter 7.5.4b Check randomness of treatment

* checking using linear probability models
reg small boy white_asian tchexper freelunch
areg small boy white_asian tchexper freelunch, absorb(schid)

/* The following are not discussed in the Chapter */
* adding robust covariance: see chapter 8
reg small boy white_asian tchexper freelunch, vce(robust)
areg small boy white_asian tchexper freelunch, absorb(schid) vce(robust)

* checking randomness using probit: see Chapter 16
probit small boy white_asian tchexper freelunch
probit small boy white_asian tchexper freelunch school2-school79
log close

* Chapter 7.5.6 Differences in Differences Estimators

* open new log file
log using chap07_nj, replace text

* open data file
use njmin3, clear
describe
summarize nj d d_nj fte

* DID estimation using sample means
bysort nj d: summarize fte

* DID estimation using regression
reg fte nj d d_nj
estimates store did

lincom _cons + nj
lincom _cons + d
lincom _cons + nj + d  + d_nj
lincom (_cons + nj + d + d_nj)-(_cons + d)-((_cons + nj)-_cons)

* add owner controls
reg fte nj d d_nj kfc roys wendys co_owned
estimates store did2

* add location controls
reg fte nj d d_nj kfc roys wendys co_owned southj centralj pa1
estimates store did3

esttab did did2 did3, b(%10.4f) se(%10.3f) t(%10.3f) r2 ar2 ///
title("Difference in Difference Regressions") 

* DID regression using only balanced sample
reg fte nj d d_nj if !missing(demp)

log close
