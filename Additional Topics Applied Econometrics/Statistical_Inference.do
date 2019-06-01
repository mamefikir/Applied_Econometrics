* Statistical Inference
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

********* examine hip data
log using appx_c, replace text

use hip, clear
describe
histogram y, percent saving(hip_hist,replace)
* graph export hip_hist.emf, replace

* histogram using pull down menu
histogram y, width(1) start(13) percent

* summary statistics
summarize y, detail

* estimate mean
mean y

* generate several normal variables
clear
matrix C = (1, .5 \ .5, 1)
drawnorm x y, n(1000) corr(C) seed(12345)
summarize x y
tabstat x y, statistics (mean median variance semean)
corr x y
twoway scatter y x, saving(xynorm ,replace)
* graph export xynorm.emf, replace

********* central limit theorem
clear
set obs 1000
set seed 12345

* generate triangular distributed value
gen y1 = sqrt(runiform())
histogram y1, saving(triangle_hist ,replace)
* graph export triangle_hist.emf, replace

* 11 more
forvalues rep=2/12 {
   gen y`rep' = sqrt(runiform())
   }

* standardize several and plot
foreach n in 3 7 12 {
   egen ybar`n' = rowmean(y1-y`n')
   gen z`n' = (ybar`n' - 2/3)/(sqrt((1/18)/`n'))
   histogram z`n', normal saving(ybar`n'_hist , replace)
*   graph export ybar`n'_hist.emf, replace
   summarize z`n', detail
   }

* interval estimates
* simulated data
clear
set obs 30
set seed 12345
drawnorm x1-x10

* transform
forvalues n=1/10 {
	gen y`n' = 10 + sqrt(10)*x`n'
	}

* compute interval estimates
ci y1-y10

* hip data
use hip, clear

* automatic interval estimate
ci y

* details of interval estimate
quietly summarize y, detail
return list
scalar ybar = r(mean)
scalar nobs = r(N)
scalar df = nobs - 1
scalar tc975 = invttail(df,.025)
scalar sighat = r(sd)
scalar se = sighat/sqrt(nobs)
scalar lb = ybar - tc975*se
scalar ub = ybar + tc975*se

di "lb of 95% confidence interval = " lb
di "ub of 95% confidence interval = " ub

********* hypothesis testing

* right tail test mu = 16.5

* details
use hip, clear
quietly summarize y, detail
scalar ybar = r(mean)
scalar nobs = r(N)
scalar df = nobs - 1
scalar sighat = r(sd)
scalar se = sighat/sqrt(nobs)
scalar t1 = (ybar - 16.5)/se
scalar tc95 = invttail(df,.05)
scalar p1 = ttail(df,t1)
di "right tail test"
di "tstat = " t1
di "tc95  = " tc95
di "pval  = " p1

* automatic version
ttest y==16.5

* two tail test mu = 17

* details
quietly summarize y, detail
scalar t2 = (ybar - 17)/se
scalar p2 = 2*ttail(df,abs(t2))
di "two tail test"
di "tstat = " t2
di "tc975  = " tc975
di "pval  = " p2

* automatic version
ttest y==17

********* Testing the variance

* automatic test
sdtest y == 2

* details
quietly summarize y, detail
scalar s0 = 4
scalar sighat2 = r(Var)
scalar df = r(N)-1
scalar v = df*sighat2/s0
scalar chi2_95 = invchi2(df,.95)
scalar chi2_05 = invchi2(df,.05)
scalar p = 2*chi2(df,v)
di "Chi square test stat = " v
di "5th percentile chisquare(49) = " chi2_05
di "95th percentile chisquare(49) = " chi2_95 
di "2 times p value = " p

********* testing equality of population means
clear
drawnorm x1 x2, n(50) means(1 2) seed(12345)
summarize

* assuming variances are equal
ttest x1 == x2, unpaired

* assuming variances unequal
drawnorm x3 x4, n(50) means(1 2) sds(1 2) seed(12345)
ttest x3 == x4, unpaired unequal

* testing population variances
sdtest x3 == x4

* test normality
use hip, clear

********* Jarque_Bera test
* automatic test
sktest y

* details
quietly summarize y, detail
scalar nobs = r(N)
scalar s = r(skewness)
scalar k = r(kurtosis)
scalar jb = (nobs/6)*(s^2 + ((k-3)^2)/4)
scalar chi2_95 = invchi2(2,.95)
scalar pval = 1 - chi2(2,jb)
di "jb test statistic = " jb
di "95th percentile chi2(2) = " chi2_95
di "pvalue = " pval


********* kernel density estimation
clear
set obs 500

* specify means and standard deviations
matrix m = (7,9,5)
matrix sd = (1.5,.5,1)

* draw normal random values
drawnorm x y1 y2, means(m) sds(sd) seed(1234567)

* examine
summarize
correlate 

* create mixture
set seed 987654321
gen u = uniform()
gen p = (u > .5)
gen y = p*y1+(1-p)*y2

* Figure C.19
histogram x, freq width(.25) xlabel(2(1)12) start(2) ///
	title("X~N(7,1.5^2)") saving(n1, replace)
histogram y, freq width(.25) xlabel(2(1)12) start(2) ///
	title("Y mixture of N(9,0.5^2) & N(5,1)") saving(mix1,replace)
graph combine "n1" "mix1", cols(2) ysize(4) xsize(6) ///
	title("Figure C.19 Histograms of X and Y") saving(figc19,replace)
* graph export figc19.emf, replace

* Figure C.20
histogram x, freq width(.25) xlabel(2(1)12) start(2) ///
	normal title("X~N(7,1.5^2)") saving(n2, replace)
histogram y, freq width(.25) xlabel(2(1)12)  start(2) ///
	normal title("Y mixture of N(9,0.5^2) & N(5,1)")	///
	saving(mix2,replace)
graph combine "n2" "mix2", cols(2) ysize(4) xsize(6) ///
	title("Figure C.20 Normal Parametric Densities") ///
	saving(figc20,replace)
*	graph export figc20.emf, replace

* Figure C.21
histogram y, width(1) freq xlabel(2(1)12) start(2) ///
	title("bin width=1") saving(y1,replace)

histogram y, width(.1) freq xlabel(2(1)12) start(2) ///
	title("bin width=0.1") saving(y2,replace)

graph combine "y1" "y2", cols(2) ysize(4) xsize(6) ///
	title("Figure C.21 Different Bin Widths") ///
	saving(figc21,replace)
* graph export figc21.emf, replace

* Figure C.22
histogram y, width(.25) freq xlabel(2(1)12)  start(2) ///
	kdensity kdenopts(gauss width(1.5)) title("bandwidth=1.5") ///
	saving(b1,replace)

histogram y, width(.25) freq xlabel(2(1)12)  start(2) ///
	kdensity kdenopts(gauss width(1)) title("bandwidth=1") ///
	saving(b2,replace)

histogram y, width(.25) freq xlabel(2(1)12)  start(2) ///
	kdensity kdenopts(gauss width(.4)) title("bandwidth=0.4") ///
	saving(b3,replace)

histogram y, width(.25) freq xlabel(2(1)12)  start(2) ///
	kdensity kdenopts(gauss width(.1)) title("bandwidth=0.1") ///
	saving(b4,replace)

graph combine "b1" "b2" "b3" "b4", cols(2) ysize(4) xsize(6) ///
	title("Figure C.22 Nonparametric Densities") ///
    saving(figc22,replace)
*	graph export figc22.emf, replace
log close
