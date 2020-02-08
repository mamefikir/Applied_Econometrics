* The Simple Linear Regression Model
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open food data
log using XXX02_food, replace text
use food, clear

* examine data
describe

* browse
list
list in 1/5
list food_exp in 1/5
list food_exp if income < 10

* compute summary statistics
summarize

* summarize food expenditure with detail
summarize food_exp, detail

* simple plot data
twoway (scatter food_exp income)
graph save food1, replace         // open for editing with: graph use food1

* save graph using saving
twoway (scatter food_exp income), saving(food1, replace)

* store the graph in memory only
twoway (scatter food_exp income), name(food1, replace)

* enhanced plot /* with comments */
twoway (scatter food_exp income), ///  /* basic plot control */
        ylabel(0(100)600)         ///  /* Y axis 0 to 600 with ticks each 100 */           
		xlabel(0(5)35)            ///  /* X axis 0 to 35 with ticks each 5 */
		title(Food Expenditure Data)   /* graph title */
graph save food2, replace

* compute least squares regression
regress food_exp income

* calculate fitted values & residuals
predict yhat, xb
predict ehat, residuals

* compute elasticity at means
margins, eyex(income) atmeans

* compute average of elasticities at each data point
margins, eyex(income)
generate elas = _b[income]*income/yhat
summarize elas

* plot fitted values and data scatter
twoway (scatter food_exp income) ///    /* basic plot control */
       (lfit food_exp income),   ///    /* add linear fit */
	   ylabel(0(100)600)         ///    /* label Y axis */
	   xlabel(0(5)35)            ///    /* label X axis */
	   title(Fitted Regression Line)    /* graph title */
graph save food3, replace

* examine variances and covariances
estat vce

* add observation to data file
edit
set obs 41
replace income=20 in 41

* obtain prediction
predict yhat0
list income yhat0 in 41
log close 

* to save changes to food data
* save chap02.dta, replace

* Chapter 2.8.2 Using a Quadratic Model

* new log file
log using chap02_quad, replace text

* open br data and examine
use br, clear
describe
summarize

* create new variable
generate sqft2=sqft^2

* regression
regress price sqft2
predict priceq, xb

* plot fitted line
twoway (scatter price sqft) 	  ///     	/* basic plot */
       (line priceq sqft,         ///		/* 2nd plot: line is continuous */
	    sort lwidth(medthick))	        	/* sort & change line thickness */
graph save br_quad, replace

* slope and elasticity calculations
di "slope at 2000 = " 2*_b[sqft2]*2000
di "slope at 4000 = " 2*_b[sqft2]*4000
di "slope at 6000 = " 2*_b[sqft2]*6000
di "predicted price at 2000 = " _b[_cons]+_b[sqft2]*2000^2
di "predicted price at 4000 = " _b[_cons]+_b[sqft2]*4000^2
di "predicted price at 6000 = " _b[_cons]+_b[sqft2]*6000^2
di "elasticity at 2000 = " 2*_b[sqft2]*2000^2/(_b[_cons]+_b[sqft2]*2000^2)
di "elasticity at 4000 = " 2*_b[sqft2]*4000^2/(_b[_cons]+_b[sqft2]*4000^2)
di "elasticity at 6000 = " 2*_b[sqft2]*6000^2/(_b[_cons]+_b[sqft2]*6000^2)

* using factor variables
regress price c.sqft#c.sqft
predict price2
margins, dydx(*) at(sqft=(2000 4000 6000))
margins, eyex(*) at(sqft=(2000 4000 6000))
margins, eyex(*)
regress, coeflegend
generate elas2 = 2*_b[c.sqft#c.sqft]*(sqft^2)/price2
summarize elas2

log close

* Chapter 2.8.4 Using a Log-linear Model

log using chap02_llin, replace text
use br, clear

* distribution of prices
summarize price, detail
histogram price, percent
graph save price, replace

* distribution of log(price)
generate lprice = ln(price)
histogram lprice, percent
graph save lprice, replace

* log-linear regression
reg lprice sqft
predict lpricef, xb

* price prediction using anti-log
generate pricef = exp(lpricef)
twoway (scatter price sqft) ///
       (line pricef sqft, sort lwidth(medthick))
graph save br_loglin, replace

* slope and elasticity calculations
di "slope at 100000 = " _b[sqft]*100000
di "slope at 500000 = " _b[sqft]*500000
di "elasticity at 2000 = " _b[sqft]*2000
di "elasticity at 4000 = " _b[sqft]*4000

* average marginal effects
generate me = _b[sqft]*pricef
summarize me

generate elas = _b[sqft]*sqft
summarize elas

log close

* Section 2.9 Regression with Indicator Variables

* open new log
log using chap02_indicator, replace text

* open utown data and examine
use utown, clear
describe
summarize

* histograms of utown data by neighborhood
histogram price if utown==0, width(12) start(130) percent  ///
          xtitle(House prices ($1000) in Golden Oaks)      ///
		  xlabel(130(24)350) legend(off)
graph save utown_0, replace

histogram price if utown==1, width(12) start(130) percent  ///
          xtitle(House prices ($1000) in University Town)  ///
		  xlabel(130(24)350) legend(off)
graph save utown_1, replace

graph combine "utown_0" "utown_1", col(1) iscale(1)
graph save combined, replace

* using by option
label define utownlabel 0 "Golden Oaks" 1 "University Town"
label value utown utownlabel
histogram price, by(utown, cols(1))  			///
          start(130) percent                	///
          xtitle(House prices ($1000))     		///
          xlabel(130(24)350) legend(off)
graph save combined2, replace  

* summary stats
summarize price if utown==0
summarize price if utown==1

* summary stats using by
by utown, sort: summarize price  

* summary stats using bysort
bysort utown: summarize price

* regression
regress price utown

* test of two means
ttest price, by(utown)
log close

* Appendix 2A on calculation of Average marginal effects

* food expenditure example
log using chap02_food_me, replace text
use food, clear
summarize income
return list
scalar xbar = r(mean)
quietly regress food_exp income
margins, eyex(*) atmeans
nlcom _b[income]*xbar/(_b[_cons]+_b[income]*xbar) 
log close

* quadratic house price example
log using chap02_quad_me, replace text
use br, clear
quietly regress price c.sqft#c.sqft
margins, eyex(*) at(sqft=2000)
nlcom 2*_b[c.sqft#c.sqft]*(2000^2)/(_b[_cons]+_b[c.sqft#c.sqft]*(2000^2))
log close

* slope in log-linear model
log using chap02_llin_me, replace text
use br, clear
gen lprice = log(price)
quietly regress lprice sqft
nlcom _b[sqft]*exp(_b[_cons]+_b[sqft]*2000)
log close

* Appendix 2B

*clear memory and start new log
clear all
log using chap02_app2G, replace text

* define some global macros
global numobs 40		// sample size  					     
global beta1 100		// intercept parameter					
global beta2 10			// slope parameter						
global sigma 50			// error standard deviation

* random number seed
set seed 1234567

* create artificial data using y = beta1+beta2*x+e
set obs $numobs
generate x = 10
replace x = 20 if _n > $numobs/2
generate y = $beta1 + $beta2*x + rnormal(0,$sigma)

* regression with artifical data
regress y x
di "rmse " e(rmse)
estat vce
	
* data file mc1.data created using following command	
save mc1, replace

* program to generate data and estimate regression
program chap02sim, rclass
    version 11.1 
    drop _all
    set obs $numobs
    generate x = 10
	replace x = 20 if _n > $numobs/2
    generate ey = $beta1 + $beta2*x
	generate e = rnormal(0, $sigma)
	generate y = ey + e
	regress y x
    return scalar b2 =_b[x]				// saves slope
	return scalar b1 =_b[_cons]			// saves intercept
	return scalar sig2 = (e(rmse))^2	// saves sigma^2
end

* simulate command
simulate b1r = r(b1) b2r=r(b2) sig2r=r(sig2) , ///
         reps(1000) nodots nolegend seed(1234567): chap02sim

* display experiment parameters
di " Simulation parameters"	
di " beta1 = " $beta1
di " beta2 = " $beta2
di " N = " $numobs	 
di " sigma^2 = " $sigma^2

* summarize experiment results
summarize, detail

* histogram sampling distribution of LS estimates
histogram b2r, percent normal
graph save b2r, replace
log close
