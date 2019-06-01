    
* Probability Concepts
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log file
log using appx_b, replace text
clear

* binomial probabilities
scalar prob1 = binomial(13,7,0.7)
di "probability <= binomial(13,7,0.7) is " prob1

scalar prob2 = 1 - binomial(13,7,0.7)
di "probability > binomial(13,7,0.7) is " prob2

* plot standard normal density
twoway function y = normalden(x), range(-5 5) 			///
       title("Standard normal density") 				///
	   saving(normal_pdf.emf, replace)

* plot several normal densities 
twoway function y = normalden(x), range(-5 5) 			///
	|| function y = normalden(x,0.8), 					///
			range(-5 5) lpattern(dash)  				///
	|| function y = normalden(x,1,0.8), 				///
			range(-5 5) lpattern(dash_dot) 				///
    ||, title("Normal Densities") 						///
	    legend(label(1 "N(0,1)") label(2 "N(0,0.8^2)") 	///
		label(3 "N(1,0.8^2)")) 							
	
* compute normal probabilities
scalar n_tail = normal(1.33)
di "lower tail probability N(0,1) < 1.33 is " n_tail

scalar prob = normal((6-3)/3) - normal((4-3)/3)
di "probability 3<=N(3,9)<=6 is " prob

* compute normal percentiles
scalar n_95 = invnormal(.95)
di "95th percentile of standard normal = " n_95

* plot t(3)
twoway function y = normalden(x), range(-5 5)  				///
	|| function y = tden(3,x), range(-5 5) lpattern(dash)  	///
    ||, title("Standard normal and t(3)") 				 	///
		legend(label(1 "N(0,1)") label(2 "t(3)")) 		
				
* t probabilities
scalar t_tail = ttail(3,1.33)
di "upper tail probability t(3) > 1.33 = " t_tail
di "lower tail probability t(3) < 1.33 = " 1 - ttail(3,1.33)

* t critical values
scalar t3_95 = invttail(3,0.05)
di "95th percentile of t(3) = " t3_95
di "5th percentile of t(3) = " invttail(3,0.95)

* t(38) shaded tail graphs
di "95th percentile of t(38) = " invttail(38,0.05)

* one-tail rejection region
twoway function y=tden(38,x), range(1.686 5) 		///
			color(ltblue) recast(area) 				///
    || function y=tden(38,x), range(-5 5) 			///
			legend(off) plotregion(margin(zero)) 	///
	||, ytitle("f(t)") xtitle("t") 					///
		text(0 1.686 "1.686", place(s)) 			///
		title("Right-tail rejection region") 		
	
* two-tail p-value
twoway function y=tden(38,x), range(1.9216 5) 		///
			color(ltblue) recast(area) 				///
    ||  function y=tden(38,x), range(-5 -1.9216) 	///
			color(ltblue) recast(area) 				///
    ||  function y=tden(38,x), range(-5 5) 			///
    ||, legend(off) plotregion(margin(zero)) 		///
		ytitle("f(t)") xtitle("t") 					///
		text(0 -1.921578 "-1.9216", place(s)) 		///
		text(0 1.9216 "1.9216", place(s)) 			///
		title("Pr|t(38)|>1.9216") 	
		
* Plot F-density
twoway function y = Fden(8,20,x), range(0 6) 		///
		legend(off) plotregion(margin(zero)) 		///
		ytitle("F-density") xtitle("x") 			///
		title("F(8,20) density") 					
		
* F probabilities
scalar f_tail = Ftail(8,20,3.0)
di "upper tail probability F(8,20) > 3.0 = " f_tail
di "upper tail probability F(8,20) > 3.0 = " 1-F(8,20,3.0)

* F critical values
scalar f_95 = invFtail(8,20,.05)
di "95th percentile of F(8,20) = " f_95

* Chi square density
clear
set obs 101
gen x = _n/5
scalar df = 7
gen chi2_pdf = (1/(2^(df/2)))*(1/exp(lngamma(df/2)))* ///
				x^(df/2 - 1)*exp(-x/2)

twoway line chi2_pdf x, xlabel(0(2)21) 				///
		title("Chi-square density with 7 df") 		
		
* chi-square probabilities
scalar chi2_tail = 1 - chi2(df,15)
di "upper tail probability chi2(7) > 15 is " chi2_tail

* chi-square critical values
scalar chi2_95 = invchi2tail(df,.05)
di "95th percentile of chi2(7) = " chi2_95

********** Appendix B.4

* generating triangular distribution
clear
set obs 1000
set seed 12345
gen u1 = runiform()
set seed 1010101
label variable u1 "uniform random values"
histogram u1, bin(10) percent
gen y1 = sqrt(u1)
histogram y1, bin(10) percent

* generating extreme value distribution
clear
set obs 10000
set seed 12345
gen u1 = runiform()
gen v1=-3+(_n-1)*13/10000
gen fev1 = exp(-v1)*exp(-exp(-v1))

twoway line fev1 v1, ytitle("Extreme value density") 

* random values
gen ev1 = -log(-log(u1))
histogram ev1, bin(40) percent kdensity kdenopts(gaussian) 
	
* generating uniform random values
clear
set obs 10001
gen double u1 = 1234567
gen double u2 = 987654321
scalar a = 1664525
scalar c = 1013904223
scalar m = 2^32
replace u1 = (a*u1[_n-1]+c) - m*ceil((a*u1[_n-1]+c)/m) + m if _n >1
replace u1 = u1/m

replace u2 = (a*u2[_n-1]+c) - m*ceil((a*u2[_n-1]+c)/m) + m if _n >1
replace u2 = u2/m

label variable u1 "uniform random number using seed = 1234567"
label variable u2 "uniform random number using seed = 987654321"

list u1 in 1/4
drop if _n==1
histogram u1, bin(20) percent
summarize u1

histogram u2, bin(20) percent
summarize u2

log close
