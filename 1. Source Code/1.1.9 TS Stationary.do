* Regression with Time-Series Data: Stationary Variables
* Shaofei Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* dates
clear
set obs 100
generate date = tq(1961q1) + _n-1
list date in 1/5
format %tq date
list date in 1/5
tsset date
save new.dta, replace

* open log
log using XXX09, replace text
use okun, clear
generate date = tq(1985q2) + _n-1
list date in 1

format %tq date
list date in 1

tsset date

label var u "% Unemployed"
label var g "% GDP growth"
tsline u g, lpattern(solid dash)

list date u L.u D.u g L1.g L2.g L3.g in 1/5
list date u L.u D.u g L1.g L2.g L3.g in 96/98

regress D.u L(0/3).g
regress D.u L(0/2).g 

summarize g
return list

scatter g L.g, xline(`r(mean)') yline(`r(mean)')
ac g, lags(12) generate(ac_g)

* approximate z scores
gen z=sqrt(e(N))*ac_g
list ac_g z in 1/12

use phillips_aus, clear
generate date = tq(1987q1) + _n-1
format %tq date
tsset date

tsline inf
tsline D.u

reg inf D.u
predict ehat, res

ac ehat, lags(12) generate(rk)
list rk in 1/5

* --------------------------------------------------
* Corrgram 
* --------------------------------------------------
corrgram ehat, lags(5)
di "rho1 = " r(ac1) " rho2 = " r(ac2) " rho3 = " r(ac3)
drop rk ehat

* LM tests for AR(1) and AR(4) alternatives
reg inf D.u
predict ehat, res
regress inf D.u L.ehat
test L.ehat
* LM test for AR(1)
quietly regress ehat D.u L.ehat
di "Observations = " e(N) " and TR2 = " e(N)*e(r2)
* LM test for AR(4)
quietly regress ehat D.u L(1/4).ehat
di "Observations = " e(N) " and TR2 = " e(N)*e(r2)
drop ehat

* Using the built-in bgodfrey command to test the 
* AR(1) and AR(4) alternatives
regress inf D.u
predict ehat, res
estat bgodfrey, lags(1)
estat bgodfrey, lags(4)

* Replacing ehat(1) with zero and computing LM
replace ehat = 0 in 1
regress inf D.u L.ehat
test L.ehat
quietly regress ehat D.u L.ehat
di "Observations = " e(N) " and TR2 = " e(N)*e(r2)
drop ehat

* Getting Stata to use 90 observations for the LM test
reg inf D.u
predict ehat, res

* Using all observations for bgodfrey test
set obs 94                                   // add 3 observations to data
gsort -date                                  // moves missing observations to end
replace date = date[_n-1] - 1 if missing(date) // creates dates for missing obs
replace ehat = 0 if missing(ehat)            // puts zeros in for missing ehats
sort date                                    // re-sort data into ascending order
regress ehat D.u L(1/4).ehat
di "Observations = " e(N) " and TR2 = " e(N)*e(r2)

use phillips_aus, clear
generate date = tq(1987q1) + _n-1
format %tq date
tsset date

scalar B = round(4*(e(N)/100)^(2/9))
scalar list B

regress inf D.u
estimates store Wrong_SE
newey inf D.u, lag(4) 
estimates store HAC_4

esttab Wrong_SE HAC_4, compress se(%12.3f) b(%12.5f) gaps ///
	scalars(r2_a rss aic) title("Dependent Variable: inf") ///
	mtitles("LS" "HAC(4)")
  
* --------------------------------------------------
* Nonlinear least squares of AR(1) regression model
* --------------------------------------------------

nl (inf = {b1}*(1-{rho}) + {b2}*D.u + {rho}*L.inf - {rho}*{b2}*(L.D.u)), /// 
         variables(inf D.u L.inf L.D.u)
* To see the coefficient legend use coeflegend option
nl (inf = {b1}*(1-{rho}) + {b2}*D.u + {rho}*L.inf - {rho}*{b2}*(L.D.u)), /// 
          variables(inf D.u L.inf L.D.u) coeflegend
scalar delta = _b[b1:_cons]*(1-_b[rho:_cons])
scalar delta1 = - _b[rho:_cons]*_b[b2:_cons]

* --------------------------------------------------
* More general model
* --------------------------------------------------

regress inf L.inf D.u L.D.u
estimates store General
scalar list delta delta1

testnl _b[L.D.u]=-_b[L.inf]*_b[D.u]

regress inf L.inf D.u
estimates store No_LDu
 
regress inf D.u
estimates store Original
esttab General No_LDu Original, compress se(%12.3f) b(%12.5f) ///
       gaps scalars(r2_a rss aic) 

* ARDL
regress inf L.inf L(0/1).D.u
estimates store AR1_DL1 
regress inf L.inf D.u
estimates store AR1_DL0
esttab AR1_DL1 AR1_DL0, compress se(%12.3f) b(%12.5f) ///
       gaps scalars(r2_a rss aic) 

* Model selection program computes aic and sc
* To remove it from memory use:
* program drop modelsel
capture program drop modelsel

program modelsel
  scalar aic = ln(e(rss)/e(N))+2*e(rank)/e(N) 
  scalar sc = ln(e(rss)/e(N))+e(rank)*ln(e(N))/e(N)
  scalar obs = e(N)
  scalar list aic sc obs 
end

quietly regress inf L.inf L(0/1).D.u
modelsel
quietly regress inf L.inf L.D.u
modelsel

* --------------------------------------------------
* Residual correlogram and graph
* --------------------------------------------------

quietly regress inf L.inf D.u
predict ehat, res
corrgram ehat, lags(12)
ac ehat, lags(12) 
estat bgodfrey, lags(1 2 3 4 5)
drop ehat

* Table 9.4 AIC and SC Values for Phillips Curve ARDL model
* Note that regress can be abreviated to reg and quietly to qui

quietly reg L(0/1).inf D.u if date>= tq(1988q3)
di "p=1  q=0"
modelsel
quietly regress L(0/2).inf D.u if date>= tq(1988q3)
di "p=2  q=0"
modelsel
quietly regress L(0/3).inf D.u if date>= tq(1988q3)
di "p=3  q=0"
modelsel
quietly regress L(0/4).inf D.u if date>= tq(1988q3)
di "p=4  q=0"
modelsel
quietly regress L(0/5).inf D.u if date>= tq(1988q3)
di "p=5  q=0"
modelsel
quietly regress L(0/6).inf D.u if date>= tq(1988q3)
di "p=6  q=0"
modelsel

qui reg L(0/1).inf L(0/1).D.u if date>= tq(1988q3)
di "p=1  q=1"
modelsel
qui reg L(0/2).inf L(0/1).D.u if date>= tq(1988q3)
di "p=2  q=1"
modelsel
qui reg L(0/3).inf L(0/1).D.u if date>= tq(1988q3)
di "p=3  q=1"
modelsel
qui reg L(0/4).inf L(0/1).D.u if date>= tq(1988q3)
di "p=4  q=1"
modelsel
qui reg L(0/5).inf L(0/1).D.u if date>= tq(1988q3)
di "p=5  q=1"
modelsel
qui reg L(0/6).inf L(0/1).D.u if date>= tq(1988q3)
di "p=6  q=1"
modelsel

* Table 9.4 AIC and SC Values for Phillips Curve ARDL model
* Here is the entire thing again, using nested loops
forvalues q=0/1 {
   forvalues p=1/6 {
      quietly regress L(0/`p').inf L(0/`q').D.u if date >= tq(1988q3)
      display "p=`p'  q=`q'"
      modelsel
      }
   }
   
* Using var to estimate ARDL
* Disadvantage:  No estat after the procedure

var inf in 7/91, lags(1/3) exog(L(0/1).D.u) 

* ARDL models
use okun, clear
generate date = tq(1985q2) + _n-1
format %tq date
tsset date

* Estimate the ARDL(0,2) 
* Generate the correlogram and test for autocorrelation
reg D.u L(0/2).g 
predict ehat, res
ac ehat, lags(12)
drop ehat
estat bgodfrey, lags(1 2 3 4 5)

* Model Selection for Okun's Law model
forvalues q=1/3 {
   forvalues p=0/2 {
      quietly regress L(0/`p').D.u L(0/`q').g if date >= tq(1986q1)
      display "p=`p'  q=`q'"
      modelsel
      }
   }

reg D.u L.D.u L(0/1).g
estat bgodfrey

* Figure 9.11
reg g L(1/2).g
predict ehat, res
ac ehat, lags(12)

* Table 9.6
forvalues p=1/5 {
  qui reg L(0/`p').g if date> tq(1986q2)
  display "p=`p'"
  modelsel
  }


* Forecasting using -arima- instead of -regress-
* which, of course, yields different predictions
arima g, ar(1/2)
tsappend, add(3)
predict ghat, y // for the point estimates
predict ghatse, mse // for the standard error of prediction

* Forecasting with an AR model

reg g L(1/2).g 
scalar ghat1 = _b[_cons]+_b[L1.g]*g[98]+ _b[L2.g]*g[97]
scalar ghat2 = _b[_cons]+_b[L1.g]*ghat1+ _b[L2.g]*g[98]
scalar ghat3 = _b[_cons]+_b[L1.g]*ghat2+ _b[L2.g]*ghat1
scalar list ghat1 ghat2 ghat3

scalar var = e(rmse)^2
scalar se1 = sqrt(var)
scalar se2 = sqrt(var*(1+(_b[L1.g])^2))
scalar se3 = sqrt(var*((_b[L1.g]^2+_b[L2.g])^2+1+_b[L1.g]^2))
scalar list se1 se2 se3

scalar f1L = ghat1 - invttail(e(df_r),.025)*se1
scalar f1U = ghat1 + invttail(e(df_r),.025)*se1

scalar f2L = ghat2 - invttail(e(df_r),.025)*se2
scalar f2U = ghat2 + invttail(e(df_r),.025)*se2

scalar f3L = ghat3 - invttail(e(df_r),.025)*se3
scalar f3U = ghat3 + invttail(e(df_r),.025)*se3

scalar list f1L f1U f2L f2U f3L f3U

* --------------------------------------------------
* Impact and Delay Multipliers from Okun's ARDL(1,1) model
* --------------------------------------------------

regress D.u L.D.u L(0/1).g 

scalar b0 = _b[g]
scalar b1 = _b[L1.D.u]*b0+_b[L1.g]
scalar b2 = b1*_b[L1.D.u]
scalar list b0 b1 b2  

* An alternative method: Exploiting variable creation
regress D.u L.D.u L(0/1).g
gen mult = _b[g] in 1
replace mult = L.mult*_b[L1.D.u]+_b[L1.g] in 2
replace mult = L.mult*_b[L1.D.u] in 3/8
list mult in 1/8
gen lag = _n-1 in 1/8
line mult lag in 1/8

* --------------------------------------------------
* Exponential Smoothing
* --------------------------------------------------

use okun, clear
generate date = tq(1985q2) + _n-1
format %tq date
tsset date

tsappend, add(1)
tssmooth exponential sm1=g, parms(.38)
tsline sm1 g, legend(lab (1 "G") lab(2 "Ghat")) title(alpha=0.38) lpattern(solid dash)
scalar f1 = .38*g[98]+(1-.38)*sm1[98]
scalar list f1 
list sm1 in 99

tssmooth exponential sm2=g, parms(.8)
tsline sm2 g, legend(lab (1 "G") lab(2 "Ghat")) title(alpha=0.8) lpattern(solid dash)
scalar f2 = .8*g[98]+(1-.8)*sm2[98]
scalar list f2

tssmooth exponential sm3=g
scalar f3 = r(alpha)*g[98]+(1-r(alpha))*sm3[98]
scalar list f3
list sm3 in 99

program drop modelsel 
drop sm1 sm2 sm3 

* appendix
* Durbin Watson test
use phillips_aus, clear
generate date = tq(1987q1) + _n-1
format %tq date
tsset date

regress inf D.u
estat dwatson

* Prais-Winsten FGLS estimator
prais inf D.u, twostep
estimates store _2step
prais inf D.u
estimates store Iterate
esttab _2step Iterate, compress se(%12.3f) b(%12.5f) gaps scalars(rss rho) ///
        mtitle("2-step" "Iterated") title("Dependent Variable: inf")

* AR(1) using arima
arima inf D.u, ar(1)
log close
