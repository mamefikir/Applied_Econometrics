* Qualitative and Limited Dependent Variable Models
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open new log
log using XXX16_probit, replace text

* examine data
use transport, clear
describe
summarize

* probit estimation
probit auto dtime

* predicted probabililties
predict phat

* beta1 + beta2*2
lincom _b[_cons]+_b[dtime]*2 

* standard normal density
nlcom (normalden(_b[_cons]+_b[dtime]*2))

* marginal effect when dtime=2
nlcom (normalden(_b[_cons]+_b[dtime]*2)*_b[dtime] )

* calulations at mean -.122381
lincom _b[_cons]+_b[dtime]*(-.122381) 
nlcom (normalden(_b[_cons]+_b[dtime]*(-.122381)))
nlcom (normalden(_b[_cons]+_b[dtime]*(-.122381))*_b[dtime] )

* direct calculation of predicted probability at dtime=3
nlcom (normal(_b[_cons]+_b[dtime]*3) )

* marginal effect evaluated at each observation
gen ame = normalden(_b[_cons]+_b[dtime]*dtime)*_b[dtime]

* average marginal effect
tabstat ame, stat(n mean sd min max)

* marginal effects at means
margins, dydx(dtime) atmeans

* average marginal effects
margins, dydx(dtime)

* 0.975 percentile of t(19)-distribution
scalar t975 = invttail(19,.025)
di "0.975 critical value 19 df " t975

* 95% interval estimate of AME
scalar lbame =   .0484069   - t975*.003416
scalar ubame =   .0484069   + t975*.003416
di "95% interval estimate AME"
di "lbame = " lbame " ubame = " ubame

* ME at dtime = 2
margins, dydx(dtime) at(dtime=2)

* 95% interval estimate of AME at dtime = 2
scalar lb =  .1036899 - t975*.0326394
scalar ub =  .1036899 + t975*.0326394
di "95% interval estimate marginal effect dtime=2"
di "lb = " lb " ub= " ub

* ME at dtime=3
margins, dydx(dtime) at(dtime=3)

* predicted probability at dtime = 2
margins, predict(pr) at(dtime=2)

* predicted probability at dtime = 3
margins, predict(pr) at(dtime=3)

* 95% interval estimate of predicted probability at dtime = 3
scalar lbp =   .7982919 - t975*.1425387
scalar ubp =   .7982919 + t975*.1425387
di "95% interval estimate predicted probability dtime=3"
di "lb = " lbp " ub= " ubp

* Average predicted probability
margins, predict(pr)

* Average of predicted probability
summarize phat

*--------------------------------------------
* The Delta-method standard errors
*--------------------------------------------

********** Appendix 16A

* probit
probit auto dtime
ereturn list

matrix list e(V)

* ME at dtime=2
margins, dydx(dtime) at(dtime=2)

* dg-dbeta1
nlcom (-normalden(_b[_cons]+_b[dtime]*2)*(_b[_cons]+_b[dtime]*2)*_b[dtime])

* dg-dbeta2
nlcom (normalden(_b[_cons]+_b[dtime]*2)*(1-(_b[_cons]+_b[dtime]*2)*_b[dtime]*2))

* average marginal effects
margins, dydx(dtime)

* dg2-dbeta1
gen dg21 = -normalden(_b[_cons]+_b[dtime]*dtime)* ///
          (_b[_cons]+_b[dtime]*dtime)*_b[dtime] 
gen dg22 = normalden(_b[_cons]+_b[dtime]*dtime)* ///
          (1-(_b[_cons]+_b[dtime]*dtime)*_b[dtime]*dtime)
summarize dg21 dg22

log close

********** A Marketing example

* open new log
log using chap16_coke, replace text
use coke, clear

* examine data
describe
summarize

* linear probability model
regress coke pratio disp_coke disp_pepsi, vce(robust)
estimates store lpm
predict phat

* predict probability when pratio = 1.1
margins, predict(xb) at(pratio=1.1 disp_coke=0 disp_pepsi=0)

* predict outcomes using linear probability model
generate p1 = (phat >=.5)
tabulate p1 coke,row

* probit
probit coke pratio disp_coke disp_pepsi
estimates store probit

* predicted outcomes summary
estat classification

* average marginal effect of change in price ratio
margins, dydx(pratio)

* average marginal effect when pratio=1.1 and displays are not present 
margins, dydx(pratio) at(pratio=1.1 disp_coke=0 disp_pepsi=0)

* average predicted probability when pratio=1.1 and displays are not present
margins, predict(pr) at(pratio=1.1 disp_coke=0 disp_pepsi=0)

* t-test
lincom disp_coke + disp_pepsi

* chi-square tests
test disp_coke + disp_pepsi=0
test disp_coke disp_pepsi

* likelihood ratio test of model significance
scalar lnlu = e(ll)
scalar lnlr = e(ll_0)
scalar lr_test = 2*(lnlu-lnlr)
di "lnlu     = " lnlu 
di " lnlr    = " lnlr 
di " lr_test = " lr_test

* likelihood ratio test of displays equal but opposite effect
gen disp = disp_pepsi-disp_coke
probit coke pratio disp
estimates store probitr

* automatic test
lrtest probit probitr

* direct calculation
scalar lnlr = e(ll)
scalar lr_test = 2*(lnlu-lnlr)
di "lnlu     = " lnlu 
di " lnlr    = " lnlr 
di " lr_test = " lr_test

* likelihood ratio of significance of displays
probit coke pratio
estimates store probitr

* automatic test
lrtest probit probitr

* direct calculation
scalar lnlr = e(ll)
scalar lr_test = 2*(lnlu-lnlr)
di "lnlu     = " lnlu 
di " lnlr    = " lnlr 
di " lr_test = " lr_test

* logit
logit coke pratio disp_coke disp_pepsi
estimates store logit

* predicted outcomes summary
estat classification

* average marginal effects for logit
margins, dydx(pratio) 
margins, dydx(pratio) at(pratio=1.1 disp_coke=0 disp_pepsi=0)
margins, predict(pr) at(pratio=1.1 disp_coke=0 disp_pepsi=0)

* tables comparing models
esttab lpm probit logit , se(%12.4f) b(%12.5f) star(* 0.10 ** 0.05 *** 0.01) ///
       scalars(ll_0 ll chi2)gaps mtitles("LPM" "probit" "logit") ///
	   title("Coke-Pepsi Choice Models")

* out of sample forecasting
regress coke pratio disp_coke disp_pepsi in 1/1000
predict phat2
generate p2 = (phat2 >=.5)
tabulate p2 coke in 1001/1140,row

probit coke pratio disp_coke disp_pepsi in 1/1000
estat classification in 1001/1140

logit coke pratio disp_coke disp_pepsi in 1/1000
estat classification in 1001/1140

log close

********** Chapter 16.3 Multinomial logit

log using chap16_mlogit, replace text

use nels_small, clear

* summarize data
describe
summarize grades, detail
tab psechoice

* estimate model
mlogit psechoice grades, baseoutcome(1)

* compute predictions and summarize
predict ProbNo ProbCC ProbColl
summarize ProbNo ProbCC ProbColl

* predicted probabilities
margins, predict(outcome(1)) at(grades=6.64)
margins, predict(outcome(2)) at(grades=6.64)
margins, predict(outcome(3)) at(grades=6.64)
margins, predict(outcome(1)) at(grades=2.635)
margins, predict(outcome(2)) at(grades=2.635)
margins, predict(outcome(3)) at(grades=2.635)

* marginal effects
margins, dydx(grades) at(grades=6.64)
margins, dydx(grades)
margins, dydx(grades) at(grades=2.635)
margins, dydx(grades) predict(outcome(2)) at(grades=6.64)
margins, dydx(grades) predict(outcome(2)) at(grades=2.635)
margins, dydx(grades) predict(outcome(3)) at(grades=6.64)
margins, dydx(grades) predict(outcome(3)) at(grades=2.635)

log close

********* Conditional logit

log using chap16_clogit, replace text
use cola, clear

* examine data
describe
summarize 
list in 1/9

* create alternatives variable
sort id, stable
by id:gen alt = _n

* view some observations
list in 1/3

* summarize by alternative
bysort alt:summarize choice price feature display

* label values
label define brandlabel 1 "Pepsi"  2  "SevenUp" 3 "Coke" 
label values alt brandlabel

* estimate model
asclogit choice price, case(id) alternatives(alt) basealternative(Coke)

* post-estimation
estat alternatives
estat mfx
estat mfx, at(Coke:price=1.10 Pepsi:price=1 SevenUp:price=1.25)

log close

********** Ordered probit

log using chap16_oprobit, replace text
use nels_small, clear

* summarize data
summarize grades, detail
tab psechoice

* estimate model
oprobit psechoice grades

* marginal effects
margins, dydx(grades) at(grades=6.64)  predict(outcome(3))
margins, dydx(grades) at(grades=2.635) predict(outcome(3))
log close

********** Poisson Regression
log using chap16_poisson, replace 
use olympics, clear

* keep 1988 results
keep if year==88
keep medaltot pop gdp
describe

* log variables
gen lpop = ln(pop)
gen lgdp = ln(gdp)

* estimate poisson model
poisson medaltot lpop lgdp

* marginal effects at median of log variable
margins, dydx(*) at((median) lpop lgdp)

* predicted number of medals at medians
margins, predict(n) at((median) lpop lgdp)

log close

********** Tobit 
log using chap16_tobit, replace text

* using simulated data

use tobit, clear

* examine data
describe
summarize
summarize if y>0

* regression
reg y x
reg y x if y>0

* tobit
tobit y x, ll

* tobit using Mroz data

use mroz, clear

* examine data
describe lfp hours  educ exper age kidsl6
summarize lfp hours  educ exper age kidsl6
histogram hours, frequency title(Hours worked by married women)

summarize hours  educ exper age kidsl6 if (hours>0)
summarize hours  educ exper age kidsl6 if (hours==0)

* regression
regress hours  educ exper age kidsl6
regress hours  educ exper age kidsl6 if (hours>0)

* tobit
tobit hours  educ exper age kidsl6, ll

* tobit scale factor
scalar xb = _b[_cons]+_b[educ]*12.29+_b[exper]*10.63+_b[age]*42.5+_b[kidsl6]*1
scalar cdf = normal( xb/_b[/sigma])
display "x*beta = " xb
display "Tobit scale Factor: cdf evaluated at zi = " cdf
display "Marginal effect of education = " _b[educ]*cdf

quietly tobit hours  educ exper age kidsl6, ll

* marginal effect on E(y|x)
margins, dydx(educ) at(educ=12.29 exper=10.63 age=42.5 kidsl6=1) predict(ystar(0,.))

* marginal effect on E(y|x,y>0)
margins, dydx(educ) at(educ=12.29 exper=10.63 age=42.5 kidsl6=1) predict(e(0,.))


********** Heckit
use mroz, clear

generate lwage = ln(wage)

* ols
regress lwage educ exper if (hours>0)

* probit
generate kids = (kidsl6+kids618>0)
probit lfp age educ kids mtr
predict w, xb

* Inverse Mills Ratio
generate imr = normalden(w)/normal(w)

* Heckit two-step
regress lwage educ exper imr

* Heckit two-step automatic
heckman lwage educ exper, select(lfp=age educ kids mtr) twostep

* Heckit maximum likelihood
heckman lwage educ exper, select(lfp=age educ kids mtr)

log close
