* Introducing Stata 
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log file
log using xxx01, replace text

* open data
use cps4_small, clear
describe

* assign or modify label
label variable wage "earnings per hour"

*--------------------------------------------------------------
* this is a comment
*
/* this type of comment "/*  */" can contain other comments  */
*
* these commands presume you have changed to the working 
* directory. To change to a working directory enter
*   
*	cd c:\data\poe4
*
* use the clear option if previous work in memory can be erased
*--------------------------------------------------------------

/*
 With few exceptions, the basic language syntax is

        [prefix :] command [varlist] [=exp] [if] [in] [weight]
                           [using filename] [, options]


    see                language element      description
    -------------------------------------------------------------------------
    help prefix        prefix :              prefix command
    help command       command               Stata command
    help varlist       varlist               variable list
    help exp           =exp                  expression
    help if            if                    if exp qualifier
    help in            in                    in range qualifier
    help weight        weight                weight
    help using         using filename        using filename modifier
    help options       options               options
    -------------------------------------------------------------------------
*/

* summarize and variations
summarize					
summarize wage, detail		
summarize if exper >= 10	 
summarize in 1/50
summarize wage in 1/50, detail
summarize wage if female == 1 in 1/500, detail

*--------------------------------------------------------------
* path to dialog box via pull-down menu
*
* Statistics > Summaries, tables, and tests > Summary and descriptive
*        statistics > Summary statistics
*
* or enter: db summarize
*
* or enter: help summarize
*--------------------------------------------------------------

* illustrating help commands
help viewer
search mixed model
findit mixed model

* histogram menu: Graphics > Histogram
help histogram
db histogram
histogram wage, percent title(Histogram of wage data)
more

*------------------------------------------------------
* the above command -more- causes execution of
* the Do-file to pause so that the histogram can
* be inspected before the next command is carried out
* Press the space bar to continue
*------------------------------------------------------

* saving graphs
graph save Graph "histogram of wages.gph", replace

* alternative saving option
graph save chap01hist, replace

* one-part construction
histogram wage, percent title(Histogram of wage data) saving(chap01hist,replace)
more

* enhanced figure with long lines indicator "///"
histogram wage, percent ytitle(Percent) xtitle(wage) title(Histogram of wage data) ///
          saving(chap01hist, replace)

* scatter diagram

twoway (scatter wage educ), saving(wage_educ, replace)
more

* creating new variables
generate lwage = ln(wage)
label variable lwage "ln(wage)"
generate exper2 = exper^2
label variable exper2 "experience squared"

*-------------------------------------------------------
* Note: to drop variables use command: drop lwage exper2
*-------------------------------------------------------

* Computing normal probabilities
help functions
help normal
scalar phi = normal(1.27)
di phi
display phi
display "Prob (Z <= 1.27) = " phi
di "Prob (Z <= 1.27) = " phi
di "Prob (Z <= 1.27) = " normal(1.27)

* Computing percentile values
scalar z = invnormal(.90)
di "90th percentile value of standard normal is " z

* factor variables
help factor variables
summarize i.female
summarize i.female, allbaselevels   // identify base level
summarize ib1.female 				// change base level, omitted group, to female=1
summarize ibn.female				// show summarize statistics for all levels (no omitted group)

* interacting factor variables
summarize c.wage#i.female i.female#i.married

* fully interacted or full factorial
summarize ibn.female##(c.wage ibn.married)

* create indicator variables
generate hs = (9 <= educ)&(educ <=12)
label variable hs "=1 if 9<=educ<=12"
tabulate educ, gen(ed)

log close
