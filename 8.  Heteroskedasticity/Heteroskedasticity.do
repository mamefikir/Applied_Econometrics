* Heteroskedasticity
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX08, replace text

* --------------------------------------------
* food expenditure example
* OLS, OLS with White's std errors, GLS
* --------------------------------------------
use food, clear

regress food_exp income
predict ehat, res

graph twoway (scatter food_exp income) (lfit food_exp income, lw(thick))

* --------------------------------------------
* Graph relationship between size of errors and income
* --------------------------------------------
generate abs_e = abs(ehat)
twoway (scatter abs_e income) (lowess abs_e income, lw(thick))

* --------------------------------------------
* Graph relationship between errors and income
* --------------------------------------------
graph twoway scatter ehat income, yline(0) 
drop ehat

* --------------------------------------------
* Breusch-Pagan and White tests
* --------------------------------------------

quietly regress food_exp income
predict ehat, residual
gen ehat2=ehat^2
quietly regress ehat2 income
di "NR2 = " e(N)*e(r2)
di "5% critical value = " invchi2tail(e(df_m),.05)
di "P-value = " chi2tail(e(df_m),e(N)*e(r2))

quietly regress ehat2 income c.income#c.income
di "NR2 = " e(N)*e(r2)
di "5% critical value = " invchi2tail(e(df_m),.05)
di "P-value = " chi2tail(e(df_m),e(N)*e(r2))

quietly regress food_exp income
estat hettest income, iid
estat imtest, white

* --------------------------------------------
* Goldfeld Quandt test
* --------------------------------------------
use cps2, clear
regress wage educ exper metro

* --------------------------------------------
* Rural subsample regression
* --------------------------------------------

regress wage educ exper if metro == 0 
scalar rmse_r = e(rmse)
scalar df_r = e(df_r)

* --------------------------------------------
* Urban subsample regression
* --------------------------------------------

regress wage educ exper if metro == 1 
scalar rmse_m = e(rmse)
scalar df_m = e(df_r)

scalar GQ = rmse_m^2/rmse_r^2
scalar crit = invFtail(df_m,df_r,.05)
scalar pvalue = Ftail(df_m,df_r,GQ)
scalar list GQ pvalue crit

* --------------------------------------------
* Goldfeld Quandt test for food 
* expenditure example
* --------------------------------------------
use food, clear
sort income

regress food_exp income in 1/20
scalar s_small = e(rmse)^2
scalar df_small = e(df_r)

regress food_exp income in 21/40
scalar s_large = e(rmse)^2
scalar df_large = e(df_r)

scalar GQ = s_large/s_small
scalar crit = invFtail(df_large,df_small,.05)
scalar pvalue = Ftail(df_large,df_small,GQ)
scalar list GQ pvalue crit

* --------------------------------------------
* HCCME
* --------------------------------------------

use food, clear
quietly reg food_exp income
estimates store Usual
scalar bL = _b[income] - invttail(e(df_r),.025) * _se[income]
scalar bU = _b[income] + invttail(e(df_r),.025) * _se[income]
scalar list bL bU

quietly reg food_exp income, vce(robust)
estimates store White
scalar bL = _b[income] - invttail(e(df_r),.025) * _se[income]
scalar bU = _b[income] + invttail(e(df_r),.025) * _se[income]
scalar list bL bU

estimates table Usual White,  b(%7.4f) se(%7.3f) stats(F)

reg food_exp income, vce(robust) level(90)
* --------------------------------------------
* GLS
* --------------------------------------------

regress food_exp income [aweight = 1/income]
scalar bL = _b[income] - invttail(e(df_r),.025) * _se[income]
scalar bU = _b[income] + invttail(e(df_r),.025) * _se[income]
scalar list bL bU

* --------------------------------------------
* cps example
* --------------------------------------------

use cps2, clear
regress wage educ exper

* --------------------------------------------
* Groupwise heteroskedastic regression using FGLS
* --------------------------------------------

gen rural = 1 - metro
gen wt=(rmse_r^2*rural) + (rmse_m^2*metro)
regress wage educ exper metro [aweight = 1/wt]

* --------------------------------------------
* subsample regressions using dummy variables 
* for weights
* --------------------------------------------

regress wage educ exper [aweight = rural]
scalar sr = e(rmse)^2
regress wage educ exper [aweight = metro]
scalar sm = e(rmse)^2
scalar df_r = e(df_r)

* --------------------------------------------
* Groupwise heteroskedastic regression using FGLS
* --------------------------------------------

gen wtall=(sr*rural) + (sm*metro)
regress wage educ exper metro [aweight = 1/wtall]

regress wage educ exper metro
predict ehat, residual

twoway (scatter ehat metro)
more

twoway (scatter ehat wage)
more

* --------------------------------------------
* Heteroskedastic regression using FGLS
* --------------------------------------------

use food, clear
gen z = ln(income)
reg food_exp income
predict ehat, residual
gen ln_ehat_sq = ln(ehat^2)
reg ln_ehat_sq z
predict sighat, xb
gen wt = exp(sighat)
regress food_exp income [aweight=(1/wt)]

* --------------------------------------------
* FGLS with Linear Probability Model
* --------------------------------------------
use coke, clear
summarize
* OLS with inconsistent std errors
quietly regress coke pratio disp_coke disp_pepsi
estimates store LS

predict p, xb
gen var = p*(1-p)
summarize p var

predict ehat, res
gen ehat2=ehat^2

* White's test
quietly imtest
scalar NR2 = r(chi2_h)
scalar crit05 = invchi2tail(r(df_h),.05)
scalar pval = chi2tail(r(df_h),r(chi2_h))
scalar list NR2 crit05 pval

* White's test manually
quietly regress ehat2 pratio disp_coke disp_pepsi i.disp_coke#i.disp_pepsi i.disp_coke#c.pratio i.disp_pepsi#c.pratio c.pratio#c.pratio
di "NR2 = " e(N)*e(r2)

* OLS with HCCME std errors
quietly reg coke pratio disp_coke disp_pepsi, vce(robust)
estimates store Robust

* OLS, omitting observations with negative variances
quietly reg coke pratio disp_coke disp_pepsi [aweight=1/var] if  p > 0
estimates store Omit

* OLS, where all p<.01 are truncated to be equal .01
replace p = .01 if p < .01
replace var = p*(1-p)
quietly reg coke pratio disp_coke disp_pepsi [aweight=1/var] 
estimates store Trunc

estimates table LS Robust Trunc Omit, b(%7.4f) se(%7.4f) stats(F N)

* Test for heteroskedasticity
quietly regress coke pratio disp_coke disp_pepsi
imtest, white

log close
