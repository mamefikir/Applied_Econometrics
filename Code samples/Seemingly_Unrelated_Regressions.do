* Seemingly Unrelated Regressions (SUR) in Stata
* David Li 

clear all
set more off

use C:\Econometrics\Data\sur_scores

global y1list math
global y2list read
global x1list female prog science
global x2list female socst
global x1 female

describe $y1list $y2list $x1list $x2list
summarize $y1list $y2list $x1list $x2list

* OLS regressions
reg $y1list $x1list
reg $y2list $x2list

* SUR model
sureg ($y1list $x1list) ($y2list $x2list), corr

* Testing of cross-equation constraints
test [$y1list]$x1 = [$y2list]$x1

* SUR model with cross-equation constraint
constraint 1 [$y1list]$x1 = [$y2list]$x1
sureg ($y1list $x1list)($y2list $x2list), constraints(1) 
