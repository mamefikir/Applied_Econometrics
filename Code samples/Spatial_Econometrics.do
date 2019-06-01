* Spatial Econometrics in Stata 
* David Li 

clear all
set more off 

* Downloading "spareg"

use C:\...\...\spatial_ABC

* Defining variables 
global ylist EFG
global xlist HIJ KLM
gloabl xcoord x 
global ycoord y 
global band 10 

describe $ylist $xlist 
summarize $ylist $xlist 

* Spatial Weight Matrix 
spatwmat, name(W) xcoord($scoord) ycoord($ycoord) band(0 $band) standardize eigenval(E)
* Matrix List W 

* Regression 
reg $ylist $xlist 

* Spatial Diagnostics
spatdiag, weights(W)

* Spatial Error Model 
spatreg $ylist $xlist, weights(W) eigenval(E) model(error)

* Spatial Lag Model 
spatreg $ylist $xlist, weights(W) eigenval(E) model(lag)
