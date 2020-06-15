* Further Inference in the Multiple Regression Model
* Shaofei Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX06, replace text

use andy, clear

* -------------------------------------------
* The following block estimates Andy's sales
* and uses the difference in SSE to test 
* a hypothesis using an F-statistic
* -------------------------------------------

* Unrestricted Model
regress sales price advert c.advert#c.advert
scalar sseu = e(rss)
scalar df_unrest = e(df_r)

* Restricted Model
regress sales price
scalar sser = e(rss)
scalar df_rest = e(df_r)
scalar J = df_rest - df_unrest

* F-statistic, critical value, pvalue
scalar fstat = ((sser -sseu)/J)/(sseu/(df_unrest))
scalar crit1 = invFtail(J,df_unrest,.05)
scalar pvalue = Ftail(J,df_unrest,fstat)

scalar list sseu sser J df_unrest fstat pvalue crit1

* -------------------------------------------
* Here, we use Stata's test statement 
* to test hypothesis using an F-statistic
* Note: Three versions of the syntax
* -------------------------------------------

regress sales price advert c.advert#c.advert
testparm advert c.advert#c.advert
test (advert=0)(c.advert#c.advert=0)
test (_b[advert]=0)(_b[c.advert#c.advert]=0)

* -------------------------------------------
* Overall Significance of the Model
* Uses same Unrestricted Model as above
* -------------------------------------------

* Unrestricted Model (all variables)
regress sales price advert c.advert#c.advert
scalar sseu = e(rss)
scalar df_unrest = e(df_r)

* Restricted Model (no explanatory variables)
regress sales 
scalar sser = e(rss)
scalar df_rest = e(df_r)
scalar J = df_rest - df_unrest

* F-statistic, critical value, pvalue
scalar fstat = ((sser -sseu)/J)/(sseu/(df_unrest))
scalar crit2 = invFtail(J,df_unrest,.05)
scalar pvalue = Ftail(J,df_unrest,fstat)

scalar list sseu sser J df_unrest fstat pvalue crit2

* -------------------------------------------
* Relationship between t and F
* -------------------------------------------

* Unrestricted Regression
regress sales price advert c.advert#c.advert
scalar sseu = e(rss)
scalar df_unrest = e(df_r)

scalar tratio = _b[price]/_se[price]
scalar t_sq = tratio^2

* Restricted Regression
regress sales advert c.advert#c.advert
scalar sser = e(rss)
scalar df_rest = e(df_r)
scalar J = df_rest - df_unrest

* F-statistic, critical value, pvalue
scalar fstat = ((sser -sseu)/J)/(sseu/(df_unrest))
scalar crit = invFtail(J,df_unrest,.05)
scalar pvalue = Ftail(J,df_unrest,fstat)

scalar list sseu sser J df_unrest fstat pvalue crit tratio t_sq

* -------------------------------------------
* Optimal Advertising
* Uses both sets of syntax for test
* -------------------------------------------

* Equivalent to Two sided t-test
regress sales price advert c.advert#c.advert
test _b[advert]+3.8*_b[c.advert#c.advert]=1
test advert+3.8*c.advert#c.advert=1

* t stat for Optimal Advertising (use lincom)
lincom _b[advert]+3.8*_b[c.advert#c.advert]-1
lincom advert+3.8*c.advert#c.advert-1
scalar t = r(estimate)/r(se)
scalar pvalue2tail = 2*ttail(e(df_r),t)
scalar pvalue1tail = ttail(e(df_r),t)
scalar list t pvalue2tail pvalue1tail

* t stat for Optimal Advertising (alternate method) 
gen xstar = c.advert#c.advert-3.8*advert
gen ystar = sales - advert
regress ystar price advert xstar
scalar t = (_b[advert])/_se[advert]
scalar pvalue = ttail(e(df_r),t)
scalar list t pvalue
 
* One-sided t-test
regress sales price advert c.advert#c.advert
lincom advert+3.8*c.advert#c.advert-1
scalar tratio = r(estimate)/r(se)
scalar pval = ttail(e(df_r),tratio)
scalar crit = invttail(e(df_r),.05)

scalar list tratio pval crit

*  Joint Test
regress sales price advert c.advert#c.advert
test (_b[advert]+3.8*_b[c.advert#c.advert]=1) ///
     (_b[_cons]+6*_b[price]+1.9*_b[advert]+3.61*_b[c.advert#c.advert]= 80)

* -------------------------------------------
*  Nonsample Information
* -------------------------------------------

use beer, clear
gen lq = ln(q)
gen lpb = ln(pb)
gen lpl = ln(pl)
gen lpr = ln(pr)
gen li = ln(i)

constraint 1 lpb+lpl+lpr+li=0
cnsreg lq lpb lpl lpr li, c(1)

* -------------------------------------------
* MROZ Examples 
* -------------------------------------------

use edu_inc, clear
regress faminc he we
regress faminc he

* correlations among regressors
correlate

regress faminc he we kl6

* Irrelevant variables
regress faminc he we kl6 xtra_x5 xtra_x6

* Model selection
program modelsel
  scalar aic = ln(e(rss)/e(N))+2*e(rank)/e(N) 
  scalar bic = ln(e(rss)/e(N))+e(rank)*ln(e(N))/e(N)
  di "r-square = "e(r2) " and adjusted r_square " e(r2_a)
  scalar list aic bic
end

quietly regress faminc he
di "Model 1 (he) "
modelsel
estimates store Model1
quietly regress faminc he we
di "Model 2 (he, we) "
modelsel
estimates store Model2
quietly regress faminc he we kl6
di "Model 3 (he, we, kl6) "
modelsel
estimates store Model3
quietly regress faminc he we kl6 xtra_x5 xtra_x6
di "Model 4 (he, we, kl6. x5, x6) "
modelsel
estimates store Model4


estimates table Model1 Model2 Model3 Model4, b(%9.3f) stfmt(%9.3f) se stats(N r2 r2_a aic bic)

* RESET
regress faminc he we kl6
predict yhat
gen yhat2=yhat^2
gen yhat3=yhat^3

summarize faminc he we kl6 

*-------------------------------
* Data are ill-conditioned
* Reset test won' work here
* Try it anyway!
*-------------------------------

regress faminc he we kl6 yhat2  
test yhat2 
regress faminc he we kl6 yhat2 yhat3 
test yhat2 yhat3

*----------------------------------------
* Drop the previously defined predictions
* from the dataset
*----------------------------------------

drop yhat yhat2 yhat3

*--------------------------------
* Recondition the data by
* scaling FAMINC by 10000
* -------------------------------
gen faminc_sc = faminc/10000
regress faminc_sc he we kl6
predict yhat
gen yhat2 = yhat^2
gen yhat3 = yhat^3

summarize faminc_sc faminc he we kl6 yhat yhat2 yhat3

regress faminc_sc he we kl6 yhat2  
test yhat2 
regress faminc_sc he we kl6 yhat2 yhat3 
test yhat2 yhat3

* -------------------------------------------
* Stata uses the estat ovtest following
* a regression to do a RESET(3) test.  
* -------------------------------------------

regress faminc he we kl6
estat ovtest 


* -------------------------------------------
* Cars Example 
* -------------------------------------------

use cars, clear

summarize
corr

regress mpg cyl
regress mpg cyl eng wgt
test cyl
test eng
test eng cyl

* Auxiliary regressions for collinearity
* Check: r2 >.8 means severe collinearity
regress cyl eng wgt
scalar r1 = e(r2)
regress eng wgt cyl
scalar r2 = e(r2)
regress wgt eng cyl
scalar r3 = e(r2)
scalar list r1 r2 r3

log close
program drop modelsel
