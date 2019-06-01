    
* Mathematical Tools
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log file
log using appx_a, replace text
clear

********** numerical derivatives

range x 0 8 9					//create x
gen y = x^2 - 8*x + 16			//generate function
label variable y "x^2-8*x+16"	//label
twoway connected y x			//graph
dydx y x, gen(dy)				//derivative
gen elas=round(dy*x/y,.01)		//elasticity
gen dytrue = 2*x - 8			//true derivative
list

* partial derivative

scalar z0 = 2					//specific value
gen y2 = 3*x^2+2*x+3*z0+14		//new function at z0
dydx y2 x, gen(dy2)				//partial derivative
gen dy2true = 6*x + 2			//true partial at z0
list x dy2 dy2true

********** numerical integrals
clear
range x 0 1 101					//create x
gen y = 2*x						//generate y=f(x)
integ y x, gen(iy)				//integral				
list in 41/51					//list integral values 
log close
