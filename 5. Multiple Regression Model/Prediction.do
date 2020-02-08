
* Introducing Stata 
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX04_food, replace text

* open data
use food, clear

* add observation 
edit
set obs 41
replace income=20 in 41

* estimate regression
quietly regress food_exp income
predict yhat
predict ehat, residuals
predict sef, stdf

* compute t-critical value
scalar define tc = invttail(38,.025)
di "t critical value 97.5 percentile = "  tc
gen lb = yhat - tc*sef
gen ub = yhat + tc*sef
list income lb yhat ub in 41
drop in 41

* R2
pwcorr food_exp income yhat

* effect of scaling

* create $ income and regress
gen inc_dollar = income*100
reg food_exp income
reg food_exp inc_dollar
log close

* Chapter 4.3.3 linear-log model
log using chap04_linlog, replace text

* open data
use food, clear

* log of income
gen lincome = ln(income)

* linear-log regression
reg food_exp lincome
predict lyhat
predict lehat, resid

* slope = beta2/x
summarize income
return list
scalar xbar = r(mean)
lincom lincome/xbar
lincom lincome/10
lincom lincome/20
lincom lincome/30

* fitted value plot
twoway (scatter food_exp income, sort) 				///
       (line lyhat income, sort lwidth(medthick)), 	///
	    xtitle(Income) ytitle(Food Expenditure) ylabel(0(100)600) ///
		title(Linear Log Model) 
graph save linlog, replace

* linear relationship
quietly reg food_exp income
predict yhat
predict ehat, resid

* linear and linear-log fitted lines
twoway (scatter food_exp income, sort) 				///
(line lyhat income, sort lwidth(medthick)) 			///
(line yhat income, sort lpattern(dash) lwidth(medthick)), ///
xtitle(Income) ytitle(Food Expenditure) ylabel(0(100)600) ///
title(Linear Log Model) 
graph save linlog2, replace

* plot linear-log model residuals		
twoway (scatter lehat income, sort) , 	///
       xtitle(Income) ytitle(Residuals) ///
	   title(Linear Log Model Residuals) 
graph save linlog_residual, replace

* analyze residuals from original equation
histogram ehat, percent title(Linear Model Residuals)
graph save olsehat_hist, replace

* Jarque-Bera test of error normality
summarize ehat, detail
return list

scalar jb = (r(N)/6)*( (r(skewness)^2) + ((r(kurtosis)-3)^2)/4 )
di "Jarque-Bera Statistic = " jb
scalar chic = invchi2tail(2,.05)
di "Chi-square(2) 95th percentile = " chic
scalar pvalue = chi2tail(2,jb)
di "Jarque-Bera p-value = " pvalue
log close

* Polynomial model Chapter 4.4

* open new log
log using chap04_wheat, replace text

* open data and examine
use wa_wheat, clear
describe
summarize
gen yield = greenough
label variable yield "wheat yield greenough shire"

* plot data
twoway (scatter yield time, sort msymbol(circle)) , 	///
       xtitle(Time) ylabel(0(.5)2.5) ytitle(Yield) 		///
	   title(Wheat Yield) 
graph save wawheat, replace

* regression
reg yield time
predict yhat
predict ehat, residuals

* plot fitted lines and data
twoway (scatter yield time, sort) ///
       (line yhat time, sort lwidth(medthick)) , 	///
	   xtitle(Time) ytitle(Yield) ylabel(0(.5)2.5) 	///
	   title(Wheat Yield Fitted Linear Model) 
graph save wheat_fit, replace

* plot residuals
twoway (scatter ehat time, sort) , 					///
       xtitle(Time) ytitle(Residuals) yline(0) 		///
	   title(Wheat Linear Model Residuals) 
graph save wheat_ehat, replace

rvpplot time, recast(bar) yline(0)
graph save wheat_ehat_bar, replace

* Chapter 4.4.2 Cubic equation for yield

* create scaled cubic variable
generate time0=time/100
list yield time0 in 1/5
summarize time0

* cubic regression
reg yield c.time0#c.time0#c.time0
predict yhat3
predict ehat3, residuals

* slopes
margins, dydx(*) at(time=(0.15 0.30 0.45))

* plot fitted lines and data
twoway (scatter yield time, sort) 					///
       (line yhat3 time, sort lwidth(medthick)) , 	///
	   xtitle(Time) ytitle(Yield) ylabel(0(.5)2.5) 	///
	   title(Wheat Yield Fitted Cubic Model) 
graph save wheat_cubic_fit, replace

* plot residuals
twoway (scatter ehat3 time, sort) , 				///
       xtitle(Time) ytitle(Residuals) yline(0) 		///
	   title("Residuals Wheat" "Cubic Specification")
graph save wheat_cube_ehat, replace

* Chapter 4.5 Log-linear Models

* Wheat growth model
gen lyield = ln(yield)
reg lyield time
log close

* Wage Equation

* open new log file
log using chap04_lwage, replace text

* open cps4_small data
use cps4_small, clear

* summarize and plot
describe
summarize
tabulate educ

twoway (scatter wage educ, msize(small)) , 	///
       xtitle(Education) ytitle(Wage) 		///
	   title(Wage-Education Scatter) 
graph save wage_educ, replace

* create log(wage) and plot
gen lwage = ln(wage)
twoway (scatter lwage educ, msize(small)), 	///
       xtitle(Education) ytitle(ln(Wage)) 	///
	   title(ln(Wage)-Education Scatter) 
graph save lwage_educ, replace 

* log-linear regression
* add one observation
edit 
set obs 1001
replace educ=12 in 1001
reg lwage educ
predict lwagehat
predict ehat, residuals
predict sef, stdf

* calculate sigma-hat^2
ereturn list
scalar sig2 = e(rss)/e(df_r)
di "sigma-hat squared = " sig2

* Analyze resdiduals
histogram ehat, percent title(ln(Wage) Model Residuals)
graph save lwage_ehat, replace

summarize ehat, detail
scalar jb = (r(N)/6)*( (r(skewness)^2) + ((r(kurtosis)-3)^2)/4 )
di "Jarque-Bera Statistic = " jb
scalar chic = invchi2tail(2,.05)
di "Chi-square(2) 95th percentile = " chic
scalar pvalue = chi2tail(2,jb)
di "Jarque-Bera p-value = " pvalue
rvpplot educ, yline(0)

* compute natural and corrected predictor and plot
gen yhatn = exp(lwagehat)
di "correction factor = " exp(sig2/2)
gen yhatc = yhatn*exp(sig2/2)
twoway (scatter wage educ, sort msize(small)) 	///
       (line yhatn educ, sort  					///
	        lwidth(medthick) lpattern(dash)) 	///
	   (line yhatc educ, sort lwidth(medthick) lpattern(solid))
graph save lwage_predict, replace

* list predicted values
list educ yhatn yhatc in 1001
summarize wage if educ==12 in 1/1000

* R^2
correlate wage yhatn yhatc
di "r2g = " r(rho)^2

* prediction interval
scalar tc = invttail(998,.025)
gen lb_lwage = lwagehat - tc*sef
gen ub_lwage = lwagehat + tc*sef
gen lb_wage = exp(lb_lwage)
gen ub_wage = exp(ub_lwage)

* list and plot
list lb_wage ub_wage in 1001
twoway (scatter wage educ, sort msize(small)) 						///
       (line yhatn educ, sort lwidth(medthick) lpattern(solid)) 	///
	   (line ub_wage educ, sort lcolor(forest_green) lwidth(medthick) ///
			lpattern(dash)) ///
	   (line lb_wage educ, sort lcolor(forest_green) lwidth(medthick) ///
			lpattern(dash))
graph save lwage_interval, replace
log close

* A log-log model example
log using chap04_loglog, replace text
use newbroiler, clear
describe
summarize

gen lq = ln(q)
gen lp = ln(p)
reg lq lp
predict lqhat
scalar sig2 = e(rss)/e(df_r)
gen qhatc = exp(lqhat)*exp(sig2/2)
twoway (scatter q p, sort msize(small) lwidth(medthick) ///
		lpattern(solid)) 								///
		(line qhatc p, sort lwidth(medthick)), 			///
		xtitle(Price of Chicken) ytitle(Quantity of Chicken) ///
		title(Poultry Demand)

correlate q qhatc
di "r2g = " r(rho)^2
log close
