* Simultaneous Equations Models
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log file
log using XXX11_truffles, replace text

* open data
use truffles, clear

* examine data
describe
list in 1/5
summarize 

* reduced form equations
reg q ps di pf 
reg p ps di pf 
predict phat 

* 2sls of demand
reg q phat ps di

* IV/2sls of demand equation
ivregress 2sls  q (p=pf) ps di 
ivregress 2sls  q (p=pf) ps di, small 
ivregress 2sls  q (p=pf) ps di, small first 
estat firststage

* 2sls of supply using least squares
reg q phat pf

* IV/2sls of supply equation 
ivregress 2sls q (p=ps di) pf, small first
estat firststage

********* 2sls using REG3
********* This is not discussed in the chapter.
********* Enter help reg3

reg3 (q p ps di) (q p pf), endog(q p) 2sls
log close

********** Chapter 11.7 Fulton Fish Market 

* open log
log using chap11_fish, replace text

* open data
use fultonfish, clear 

* examine data
describe
list lquan lprice mon tue wed thu stormy in 1/5
summarize lquan lprice mon tue wed thu stormy

* estimate reduced forms
reg lquan mon tue wed thu stormy 
reg lprice mon tue wed thu stormy
test mon tue wed thu

* IV/2sls 
ivregress 2sls lquan (lprice=stormy) mon tue wed thu, small first
estat firststage

log close

*********** Chapter 11B.2.3a

log using chap11_liml, replace text
use mroz, clear
drop if lfp==0
gen lwage=ln(wage)
gen nwifeinc =  (faminc-wage*hours)/1000
gen exper2 = exper^2

* B=1, L=1
ivregress liml hours (mtr = exper) educ kidsl6 nwifeinc, small
estat firststage
estimates store m11

* B=1, L=2
ivregress liml hours (mtr =  exper exper2) educ kidsl6 nwifeinc, small
estat firststage
estimates store m12

*********** View LIML as IV estimator

* save liml k-value
scalar kvalue=e(kappa)

* reduced form residuals
reg mtr exper exper2 educ kidsl6 nwifeinc
predict vhat, r

* create purged endogenous variable
gen emtr = mtr - kvalue*vhat

* apply 2sls with IV = purged endogenous variable
ivregress 2sls hours (mtr = emtr) educ kidsl6 nwifeinc, small

* B=1, L=3
ivregress liml hours (mtr = exper exper2 largecity) educ kidsl6 nwifeinc, small
estat firststage
estimates store m13

* B=1, L=4
ivregress liml hours (mtr = exper exper2 largecity unemployment) educ kidsl6  nwifeinc, small
estat firststage
estimates store m14

* B=2, L=2
ivregress liml hours (mtr educ =  mothereduc fathereduc) kidsl6 nwifeinc, small
estat firststage
estimates store m22

* B=2, L=3
ivregress liml hours (mtr educ =  mothereduc fathereduc exper) kidsl6 nwifeinc, small
estat firststage
estimates store m23

* B=2, L=4
ivregress liml hours (mtr educ =  mothereduc fathereduc exper exper2) kidsl6  nwifeinc, small
estat firststage
estimates store m24

********** Table 11B.3

esttab m11 m13 m22 m23, t(%12.2f) b(%12.4f) nostar ///
       gaps scalars(kappa) title("LIML estimations")
log close
 
********** Chapter 11B.2.3b Fuller modified LIML
********** Estimation using IVREG2 a user written command
********** In the command line type FINDIT IVREG2 and click to install
********** You must have administrative power to install

* open log file
log using chap11_fuller, text replace

* open data
use mroz, clear
drop if lfp==0
gen lwage=ln(wage)
gen nwifeinc = (faminc-wage*hours)/1000
gen exper2 = exper^2

* B=1, L=1
ivreg2 hours (mtr = exper) educ kidsl6 nwifeinc, fuller(1) small
estimates store m11

* B=1, L=2
ivreg2 hours (mtr = exper exper2) educ kidsl6 nwifeinc, fuller(1) small
estimates store m12

* B=1, L=3
ivreg2 hours (mtr = exper exper2 largecity) educ kidsl6 nwifeinc, ///
	fuller(1) small
estimates store m13

* B=1, L=4
ivreg2 hours (mtr = exper exper2 largecity unemployment) educ kidsl6 nwifeinc, ///
	fuller(1) small
estimates store m14

* B=2, L=2
ivreg2 hours (mtr educ = mothereduc fathereduc) kidsl6 nwifeinc, ///
	fuller(1) small
estimates store m22

* B=2, L=3
ivreg2 hours (mtr educ =  mothereduc fathereduc exper) kidsl6 nwifeinc, ///
	fuller(1) small
estimates store m23

* B=2, L=4
ivreg2 hours (mtr educ =  mothereduc fathereduc exper exper2) kidsl6 ///
	nwifeinc, fuller(1) small
estimates store m24

esttab  m11 m13 m22 m23, t(%12.2f) b(%12.4f) nostar ///
       gaps scalars(kclass fuller widstat) title("fuller(1) estimations")
log close

********** Chapter 11B.3 Monte Carlo simulation

* open log
log using chap11_sim, replace text

* clear memory
clear all
set more off

* set experiment parameters
global numobs 100  					     
global pi     0.5				// reduced form parameter controls IV strength
global rho    0.8				// rho controls endogeneity

set seed 1234567    			// random number seed
set obs $numobs

* draw correlated e and v
matrix sig = (1, $rho \ $rho, 1)		// corr(e1,v2)
drawnorm e v, n($numobs) corr(sig)	    // e1 & v2 values

* draw 3 uncorrelated standard normals              						
generate z1 = rnormal()
generate z2 = rnormal()
generate z3 = rnormal()
	
* DGP
generate x = $pi*z1 + $pi*z2 + $pi*z3 + v		// reduced form
generate y = x + e				

* correlation between x and e
correlate x e

* reduced form regression
regress x z1 z2	z3		

* OLS
regress y x

* 2sls

ivregress 2sls y (x=z1 z2 z3), small

* liml
ivregress liml y (x=z1 z2 z3), small

* fuller(1)
ivreg2 y (x=z1 z2 z3), small fuller(1)

* fuller(4)
ivreg2 y (x=z1 z2 z3), small fuller(4)

* program to carry out simulation
 				
program ch11sim, rclass
    version 11.1 
    drop _all

    set obs $numobs
    matrix sig = (1, $rho \ $rho, 1)		// cov(e1,v2)
    drawnorm e v, n($numobs) corr(sig)	    // e1 & v2 values
                  						
	generate z1 = rnormal()
	generate z2 = rnormal()
	generate z3 = rnormal()
	 		
	* DGP
	generate x = $pi*z1 + $pi*z2 + $pi*z3 + v				
	generate y = x + e				
     	
	* 2sls
	ivregress 2sls y (x=z1 z2 z3), small
	return scalar b2sls =_b[x]
    return scalar se2sls = _se[x]
    return scalar t2sls = (_b[x]-1)/_se[x]
    return scalar r2sls = abs(return(t2sls))>invttail($numobs-2,.025)
 	
	* liml
	ivregress liml y (x=z1 z2 z3), small
	return scalar bliml =_b[x]
    return scalar seliml = _se[x]
    return scalar tliml = (_b[x]-1)/_se[x]
    return scalar rliml = abs(return(tliml))>invttail($numobs-2,.025)
 
	* fuller a=1
	ivreg2 y (x=z1 z2 z3), small fuller(1)
	return scalar bfull =_b[x]
    return scalar sefull = _se[x]
    return scalar tfull = (_b[x]-1)/_se[x]
    return scalar rfull = abs(return(tfull))>invttail($numobs-2,.025)

 	* fuller a=4
	ivreg2 y (x=z1 z2 z3), small fuller(4)
	return scalar bfull4 =_b[x]
    return scalar sefull4 = _se[x]
    return scalar tfull4 = (_b[x]-1)/_se[x]
    return scalar rfull4 = abs(return(tfull4))>invttail($numobs-2,.025)
end

simulate b2slsr=r(b2sls) se2slsr=r(se2sls) t2slsr=r(t2sls) ///
	r2slsr=r(r2sls) blimlr=r(bliml) selimlr=r(seliml) ///
	tlimlr=r(tliml) rlimlr=r(rliml) bfullr=r(bfull) ///
	sefullr=r(sefull) tfullr=r(tfull) rfullr=r(rfull) ///
	bfull4r=r(bfull4) sefull4r=r(sefull4) tfull4r=r(tfull4) ///
	rfull4r=r(rfull4), reps(10000) nodots nolegend ///
	seed(1234567): ch11sim


di " Simulation parameters"	
di " rho = " $rho
di " N = " $numobs	 
di " pi = "  $pi


* For each estimator compute 
* avg and standard deviation estimate beta
* avg nominal standard error
* avg percent rejection 5% test

di " 2sls"
gen mse2sls = (b2slsr-1)^2
tabstat b2slsr se2slsr r2slsr mse2sls, stat(mean sd)

di " liml"
gen mseliml = (blimlr-1)^2
tabstat blimlr selimlr rlimlr mseliml, stat(mean sd)

di " fuller(1)"
gen msefull = (bfullr-1)^2
tabstat bfullr sefullr rfullr msefull, stat(mean sd)

di " fuller(4)"
gen msefull4 = (bfull4r-1)^2
tabstat bfull4r sefull4r rfull4r msefull4, stat(mean sd)


log close
