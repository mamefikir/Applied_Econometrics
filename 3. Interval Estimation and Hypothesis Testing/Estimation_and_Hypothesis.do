* Interval Estimation and Hypothesis Testing
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX03, replace text

* open food
use food, clear

* estimate regression
reg food_exp income

* compute t-critical value
scalar tc975 = invttail(38,.025)
di "t critical value 97.5 percentile = "  tc975

* calculating 95% interval estimate
scalar ub2 = _b[income] + tc975*_se[income]
scalar lb2 = _b[income] - tc975*_se[income]
di "beta 2 95% interval estimate is " lb2 " , " ub2

* examples of computing t-critical values
di "t(30) 95th percentile = " invttail(30,0.05)
di "t(20) 95th percentile = " invttail(20,0.05)
di "t(20) 5th percentile  = " invttail(20,0.95)
di "t(30) 97.5th percentile = " invttail(30,0.025)
di "t(30) 2.5th percentile  = " invttail(30,0.975)

* right-tail test ho:beta2 = 0
scalar tstat0 = _b[income]/_se[income]
di "t statistic for Ho: beta2=0 = " tstat0
di "t(38) 95th percentile = " invttail(38,0.05)

* using lincom
lincom income

* right-tail test ho:beta2 = 5.5
scalar tstat1 = (_b[income]-5.5)/_se[income]
di "t-statistic for Ho: beta2 = 5.5 is " tstat1
di "t(38) 99th percentile = " invttail(38,0.01)

* using lincom for calculation
lincom income-5.5

* left-tail test ho:beta2 = 15
scalar tstat2 = (_b[income]-15)/_se[income]
di "t-statistic for Ho: beta2 = 15 is " tstat2
di "t(38) 5th percentile = " invttail(38,0.95)
lincom income-15

* two-tail test ho:beta2 = 7.5
scalar tstat3 = (_b[income]-7.5)/_se[income]
di "t-statistic for Ho: beta2 = 7.5 is " tstat3
di "t(38) 97.5th percentile = " invttail(38,0.025)
di "t(38) 2.5th percentile = " invttail(38,0.975)
lincom income-7.5

* two-tail test ho:beta1 = 0
lincom _cons

* p-value for right-tail test
scalar tstat1 = (_b[income]-5.5)/_se[income]
di "p-value for right-tail test ho:beta2 = 5.5 is " ttail(38,tstat1)

* p-value for left-tail test
scalar tstat2 = (_b[income]-15)/_se[income]
di "p-value for left-tail test ho:beta2 = 15 is " 1-ttail(38,tstat2)

* p-value for a two-tail test
scalar tstat3 = (_b[income]-7.5)/_se[income]
scalar phalf = ttail(38,abs(tstat3))
scalar p3 = 2*phalf
di "p-value for two-tail test ho:beta2 = 7.5 is " p3
di "p-value for ho:beta2 = 7.5 is " 2*ttail(38,abs(tstat3))

* linear combinations of parameters
* estimating a linear combination
estat vce
lincom _cons + income*20

* testing a linear combination
lincom _cons + income*20 - 250

log close

* Appendix 3A Graphing rejection regions

clear

* specify critcal values as globals
global t025=invttail(38,0.975)
global t975=invttail(38,0.025)

* draw the shaded areas, then draw the overall curve
twoway (function y=tden(38,x), range(-5 $t025) ///
                   color(ltblue) recast(area)) ///
       (function y=tden(38,x), range($t975 5)  ///
	               color(ltblue) recast(area)) ///
       (function y=tden(38,x), range(-5 5)),   ///
       legend(off) plotregion(margin(zero))    ///
	             ytitle("f(t)") xtitle("t")    ///
	   text(0 -2.024 "-2.024", place(s))       ///
	   text(0 2.024 "2.024", place(s))         ///
	   title("Two-tail rejection region" "t(38), alpha=0.05")

* one-tail rejection region
twoway (function y=tden(38,x), range(1.686 5) ///
                   color(ltblue) recast(area)) ///
       (function y=tden(38,x), range(-5 5)), ///
       legend(off) plotregion(margin(zero)) ///
	              ytitle("f(t)") xtitle("t") ///
	   text(0 1.686 "1.686", place(s)) ///
	   title("Right-tail rejection region" "t(38), alpha=0.05")
	   
* Appendix 3C

* set up
clear all

* open log
log using app3c, replace text

* define global variables
global numobs 40  					     
global beta1 100					
global beta2 10						
global sigma 50

* set random number seed
set seed 1234567

* generate sample of data
set obs $numobs
gen x = 10
replace x = 20 if _n > $numobs/2
gen y = $beta1 + $beta2*x + rnormal(0,$sigma)

* regression
quietly regress y x

* test h0: beta2 = 10
scalar tstat = (_b[x]-$beta2)/_se[x]
di "ttest of ho b2 = 10 " tstat

* program to generate data and to examine
* 	performance of interval estimator and
*	hypothesis test  	
program chap03sim, rclass
    version 11.1 
    drop _all
    set obs $numobs
    gen x = 10
	replace x = 20 if _n > $numobs/2
    gen ey = $beta1 + $beta2*x
	gen e = rnormal(0, $sigma)
	gen y = ey + e
	regress y x
	scalar tc975 = invttail($numobs-2,0.025)

	* calculating 95% interval estimate
	return scalar b2 = _b[x]
	return scalar se2 = _se[x]
	return scalar ub = _b[x] + tc975*_se[x]
    return scalar lb = _b[x] - tc975*_se[x]
	
	* calculating t-statistic
    return scalar tstat = (_b[x] - $beta2)/_se[x]
end

* display 95% interval for test size with different number 
*	of monte carlo samples 

di "lower bound with 10000 replications is " 0.05 - 1.96*sqrt(0.05*0.95/10000)
di "upper bound with 10000 replications is " 0.05 + 1.96*sqrt(0.05*0.95/10000)
di "lower bound with 1000 replications is " 0.05 - 1.96*sqrt(0.05*0.95/1000)
di "upper bound with 1000 replications is " 0.05 + 1.96*sqrt(0.05*0.95/1000)

* simulate command
simulate b2r = r(b2) se2r = r(se2) ubr = r(ub) lbr=r(lb) ///
	tstatr=r(tstat) , reps(10000) nodots nolegend ///
	seed(1234567): chap03sim

* display experiment parameters		 
di " Simulation parameters"	
di " beta1 = " $beta1
di " beta2 = " $beta2
di " N = " $numobs	 
di " sigma^2 = " $sigma^2

* count intervals covering true beta2 = 10
gen cover = (lbr < $beta2) & ($beta2 < ubr)

* count rejections of true h0: beta2 = 10
gen reject = (tstatr > invttail($numobs-2,0.05))

* examine some values
list b2r se2r tstatr reject lbr ubr cover in 101/120, table

* summarize coverage and rejection
summarize cover reject


log close
