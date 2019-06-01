* Instrumental Variables in Stata
* David Li 

clear all
set more off

use C:\Econometrics\Data\iv_health

* Define dependent variable y1, endogenous variable y2
* Define exogenous variables x1 and instrumental variables x2
* Define alternative set of instruments x2alt for overidentified case
* Define exogenous variables x12 for eq2, instrumental variable x22 for eq2
global y1list logmedexpense
global y2list healthinsu 
global x1list illnesses age logincome 
global x2list ssiratio
global x2listalt ssiratio firmlocation
global x1list2 illnesses
global x2list2 firmlocation

describe $y1list $y2list $x1list $x2list
summarize $y1list $y2list $x1list $x2list

* OLS regression
regress $y1list $y2list $x1list

* 2SLS estimation 
ivregress 2sls $y1list ($y2list = $x2list) $x1list, first

* 2SLS estimation - overidentified
ivregress 2sls $y1list ($y2list = $x2listalt) $x1list, first

* 2SLS estimation (details)
regress $y2list $x2list $x1list 
predict y2hat, xb
regress $y1list y2hat $x1list

* Durbin-Wu-Hausman test of endogeneity 
quietly ivregress 2sls $y1list ($y2list = $x2list) $x1list, first
estat endogenous

quietly regress $y2list $x2list $x1list
quietly predict v1hat, resid
quietly regress $y1list $y2list $x1list v1hat
test v1hat 

* Test of overidentifying restrictions
quietly ivregress gmm $y1list ($y2list = $x2listalt) $x1list, wmatrix(robust) 
estat overid

* IV estimation with binary endogenous regressor (first step is probit model)
treatreg $y1list $x1list, treat($y2list = $x2list $x1list)


* Weak instruments
* Correlations of endogenous regressors with instruments
correlate $y2list $x2listalt

* Weak instrument tests - just-identified model
quietly ivregress 2sls $y1list  ($y2list = $x2list) $x1list, vce(robust)
estat firststage, forcenonrobust

* Weak instrument tests - two or more overidentifying restrictions
quietly ivregress gmm $y1list  ($y2list = $x2listalt) $x1list, vce(robust)
estat firststage, forcenonrobust


* Systems of equations

* 2SLS estimation
reg3 ($y1list $y2list $x1list $x2list)($y2list $y1list $x1list2 $x2list2), 2sls

* 3SLS estimation 
reg3 ($y1list $y2list $x1list $x2list)($y2list $y1list $x1list2 $x2list2)
