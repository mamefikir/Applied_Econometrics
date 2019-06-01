* Random Regressors and Moment-Based Estimation
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX10_wage, replace text

* open data and examine
use mroz, clear
describe
summarize 

* drop nonworking women and summarize
drop if lfp==0
summarize wage educ exper

* create variables
gen lwage = ln(wage)
gen exper2 = exper^2

* Least squares estimation
reg lwage educ exper exper2
estimates store ls

********** POE4 Chapter 10.3.6: IV estimation of wage equation
* using only mothereduc as IV

* first stage regression
reg educ exper exper2 mothereduc

* test IV strength
test mothereduc

* obtain predicted values
predict educhat

* 2sls using 2-stages
reg lwage educhat exper exper2

* IV estimation using automatic command
ivregress 2sls lwage (educ=mothereduc) exper exper2
ivregress 2sls lwage (educ=mothereduc) exper exper2, small
ivregress 2sls lwage (educ=mothereduc) exper exper2, vce(robust) small

********** Add fathereduc as an IV
* Test fathereduc alone
reg educ exper exper2 fathereduc

* joint first stage regression F-test for weak instruments
reg educ exper exper2 mothereduc fathereduc
test mothereduc fathereduc

reg educ exper exper2 mothereduc fathereduc, vce(robust)
test mothereduc fathereduc

* IV estimation with surplus instruments
ivregress 2sls lwage (educ=mothereduc fathereduc) exper exper2, small 
estimates store iv

* Testing for weak instruments using estat
estat firststage 

* IV estimation with robust standard errors

ivregress 2sls lwage (educ=mothereduc fathereduc) exper exper2, vce(robust) small 
estat firststage

********** Chapter 10.3.7: Illustrate partial correlation
ivregress 2sls lwage (educ=mothereduc) exper exper2, small
estat firststage

* partial out exper and exper^2
reg educ exper exper2
predict v1, r

reg mothereduc exper exper2
predict v2, r

* partial correlation
correlate v1 v2
return list
di "partial correlation = "r(rho)^2

* effect of mothereduc on educ controlling for exper and exper^2
reg v1 v2, noconstant

* partial correlation
correlate v1 v2, covariance
return list

* calculate partial least squares regression coefficient
di "partial LS coefficient = " r(cov_12)/r(Var_2)

* calculate partial correlation
di "partial correlation = " r(cov_12)/sqrt(r(Var_2)*r(Var_1))

********** Chapter 10.4.3: Hausman test

* reduced form
reg educ exper exper2 mothereduc fathereduc
predict vhat, residuals

* augment wage equation with reduced form residuals
reg lwage exper exper2 educ vhat
reg lwage exper exper2 educ vhat, vce(robust)

* Hausman test automatic
hausman iv ls, constant sigmamore

********** Testing surplus moment conditions

* obtain 2sls residuals
quietly ivregress 2sls lwage (educ=mothereduc fathereduc) exper exper2, small
predict ehat, residuals

* regress 2sls residuals on all IV
reg ehat exper exper2 mothereduc fathereduc
ereturn list

* NR^2 test
scalar nr2 = e(N)*e(r2)
scalar chic = invchi2tail(1,.05)
scalar pvalue = chi2tail(1,nr2)
di "R^2 from artificial regression = " e(r2)
di "NR^2 test of overidentifying restriction  = " nr2
di "Chi-square critical value 1 df, .05 level = " chic
di "p value for overidentifying test 1 df, .05 level = " pvalue

* Using estat
quietly ivregress 2sls lwage (educ=mothereduc fathereduc) exper exper2, small
estat overid

log close

*********** Chapter 10E: Testing for Weak Instruments

* open new log
log using chap10_weakiv, replace text

* open data & create variables
use mroz, clear
drop if lfp==0
gen lwage=ln(wage)
gen nwifeinc = (faminc-wage*hours)/1000
gen exper2 = exper^2

********** 2SLS with various instrument sets

* B=1, L=1
ivregress 2sls hours (mtr = exper) educ kidsl6 nwifeinc, small
estat firststage
estimates store m11

* first stage
reg mtr exper educ kidsl6 nwifeinc
estimates store r11
test exper

* B=1, L=2
ivregress 2sls hours (mtr =  exper exper2) educ kidsl6  nwifeinc, small
estat firststage
estimates store m12

* first stage
reg mtr exper exper2 educ kidsl6 nwifeinc
estimates store r12
test exper exper2

* B=1, L=3
ivregress 2sls hours (mtr = exper exper2 largecity) educ kidsl6  nwifeinc, small
estat firststage
estimates store m13

* first stage
reg mtr exper exper2 largecity educ  kidsl6  nwifeinc
estimates store r13
test exper exper2 largecity

* B=1, L=4
ivregress 2sls hours (mtr = exper exper2 largecity unemployment) educ  kidsl6  nwifeinc, small
estat firststage
estimates store m14

* first stage
reg mtr exper exper2 largecity unemployment educ kidsl6 nwifeinc
estimates store r14
test exper exper2 largecity unemployment

* B=2, L=2
ivregress 2sls hours (mtr educ =  mothereduc fathereduc) kidsl6 nwifeinc, small
estat firststage
estimates store m22

* first stage
reg mtr mothereduc fathereduc kidsl6 nwifeinc
test mothereduc fathereduc
estimates store r22a

* first stage
reg educ mothereduc fathereduc kidsl6 nwifeinc
test mothereduc fathereduc
estimates store r22b

* B=2, L=3
ivregress 2sls hours (mtr educ =  mothereduc fathereduc exper) kidsl6 nwifeinc, small
estat firststage
estimates store m23

* first stage
reg mtr mothereduc fathereduc exper kidsl6 nwifeinc
test mothereduc fathereduc exper
estimates store r23a

* first stage
reg educ mothereduc fathereduc exper kidsl6 nwifeinc
test mothereduc fathereduc exper
estimates store r23b

* B=2, L=4
ivregress 2sls hours (mtr educ =  mothereduc fathereduc exper exper2) kidsl6 nwifeinc, small
estat firststage
estimates store m24

* create tables
esttab r11 r13 r22a r22b r23a r23b, compress t(%12.2f) b(%12.5f) nostar ///
       gaps scalars(r2_a rss) title("First Stage Equations")

esttab m11 m13 m22 m23, t(%12.4f) b(%12.4f) nostar ///
       gaps title("IV estimations")

********** Appendix 10E Calculating Cragg-Donald Statistic

ivregress 2sls hours (mtr educ =  mothereduc fathereduc) kidsl6 nwifeinc, small
ereturn list
scalar df_r = e(df_r)

* partial out kidsl6 and nwifeinc
reg mtr kidsl6 nwifeinc
predict mtrr, r

reg educ kidsl6 nwifeinc
predict educr, r

reg mothereduc kidsl6 nwifeinc
predict mothereducr, r

reg fathereduc kidsl6 nwifeinc
predict fathereducr, r

* canonical correlations
canon (mtrr educr) (mothereducr fathereducr)
ereturn list
matrix r2=e(ccorr)
di "Calculation of Cragg-Donald statistic "
di "The canonical correlations "
matrix list r2
scalar mincc = r2[1,2]
di "The minimum canonical correlation = " mincc
scalar cd = df_r*(mincc^2)/(2*(1-mincc^2))
di "The Cragg-Donald F-statistic = " cd

log close

********** Chapter 10F.1 Using Simulated Data

* open new log file
log using chap10_AppF, replace text

* open data
use ch10, clear
summarize

* Least squares estimation
reg y x
estimates store ls

* IV estimation
reg x z1
predict xhat
reg y xhat

* IV estimation using automatic command
ivregress 2sls y (x=z1)
ivregress 2sls y (x=z1), small
ivregress 2sls y (x=z2), small
ivregress 2sls y (x=z3), small

* IV estimation with surplus instruments
ivregress 2sls y (x=z1 z2), small
estimates store iv

* Hausman test regression based
reg x z1 z2
predict vhat, residuals
reg y x vhat

* Hausman test automatic contrast
hausman iv ls, constant sigmamore

* Testing for weak instrument
reg x z1
reg x z2

* Joint test for weak instrument
reg x z1 z2
test z1 z2

* Testing for weak iv using estat
ivregress 2sls y (x=z1 z2), small
estat firststage

* Testing surplus moment conditions
predict ehat, residuals
reg ehat z1 z2
scalar nr2 = e(N)*e(r2)
scalar chic = invchi2tail(1,.05)
scalar pvalue = chi2tail(1,nr2)
di "NR^2 test of overidentifying restriction  = " nr2
di "Chi-square critical value 1 df, .05 level = " chic
di "p value for overidentifying test 1 df, .05 level = " pvalue

* Testing for weak iv using estat
quietly ivregress 2sls y (x=z1 z2), small
estat overid

* Testing surplus moment conditions
ivregress 2sls y (x=z1 z2 z3), small
predict ehat2, residuals
reg ehat2 z1 z2 z3
scalar nr2 = e(N)*e(r2)
scalar chic = invchi2tail(2,.05)
scalar pvalue = chi2tail(2,nr2)
di "NR^2 test of overidentifying restriction  = " nr2
di "Chi-square critical value 2 df, .05 level = " chic
di "p value for overidentifying test 2 df, .05 level = " pvalue

* Testing surplus moments using estat
quietly ivregress 2sls y (x=z1 z2 z3)
estat overid

log close

********** Chapter 10F.2: Repeated Sampling Properties of IV/2SLS

* open log file and clear all 
log using chap10_sim, text replace
clear all

* specify constants to control simulation
*-----------------------------------------------------------------
global numobs 100	// number of simulated sample observations  					     
global pi     0.1	// reduced form parameter controls IV strength
global rho    0.8	// rho controls endogeneity
*-----------------------------------------------------------------


set obs $numobs
set seed 1234567    // random number seed

* correlation between e and v controls endogeneity
matrix sig = (1, $rho \ $rho, 1)		// corr(e,v)
drawnorm e v, n($numobs) corr(sig)	    // e & v values

* create 3 uncorrelated standard normal variables              						
gen z1 = rnormal()
gen z2 = rnormal()
gen z3 = rnormal()
	
* DGP
generate x = $pi*z1 + $pi*z2 + $pi*z3 + v				
generate y = x + e				
correlate x e

* first stage regression using all IV
reg x z1 z2 z3		

* OLS
reg y x

* 2sls
ivregress 2sls y (x=z1 z2 z3), small

* program used for simulation
   				
program ch10sim, rclass
    version 11.1 
    drop _all

    set obs $numobs
    matrix sig = (1, $rho \ $rho, 1)		
    drawnorm e v, n($numobs) corr(sig)	    
                  						
	gen z1 = rnormal()
	gen z2 = rnormal()
	gen z3 = rnormal()
			
	* DGP
	generate x = $pi*z1 + $pi*z2 + $pi*z3 + v				
	generate y = x + e				// structural equation
    
	* first stage regression using all IV
	reg x z1 z2	z3		
	return scalar rsq = e(r2)		// first stage r^2
	return scalar F=e(F)			// first stage F
	predict vhat, r
  	
	* OLS
	reg y x
    return scalar bols =_b[x]
    return scalar seols = _se[x]
    return scalar tols = (_b[x]-1)/_se[x]
    return scalar rols = abs(return(tols))>invttail($numobs-2,.025)
  	
	* Hausman
	reg y x vhat
    return scalar haust = _b[vhat]/_se[vhat]
    return scalar haus = abs(return(haust))>invttail($numobs-3,.025)
	
	* 2sls
	ivregress 2sls y (x=z1 z2 z3), small
	return scalar b2sls =_b[x]
    return scalar se2sls = _se[x]
    return scalar t2sls = (_b[x]-1)/_se[x]
    return scalar r2sls = abs(return(t2sls))>invttail($numobs-2,.025)
 	
end

simulate rsqf = r(rsq) Fr=r(F) bolsr=r(bols) seolsr=r(seols) /// 
         rolsr=r(rols) b2slsr=r(b2sls) se2slsr=r(se2sls) ///
		 t2slsr=r(t2sls) r2slsr=r(r2sls) hausr=r(haus),  ///
         reps(10000) nodots nolegend seed(1234567): ch10sim

di " Simulation parameters"	
di " rho = " $rho
di " N = " $numobs	 
di " pi = " $pi
di " average first stage r-square" 
mean rsqf

di " average first stage F" 
mean Fr

* For each estimator compute 
* avg and standard deviation estimate beta
* avg nominal standard error
* avg percent rejection 5% test

di " OLS"
gen mseols = (bolsr-1)^2
tabstat bolsr seolsr rolsr mseols hausr, stat(mean sd)

di " 2sls"
gen mse2sls = (b2slsr-1)^2
tabstat b2slsr se2slsr r2slsr mse2sls, stat(mean sd)

log close

