* Time-Varying Volatility and ARCH Models
* David Li

* setup
version 15.1
capture log close // this is a comment too 
set more off

* open log
log using XXX14, replace text
use returns, clear

* ----------------------------------------------
* Create dates and declare time series 
* ----------------------------------------------

gen date = m(1988m1) + _n - 1
format date %tm
tsset date

* ----------------------------------------------
* Time series plots and histograms
* ----------------------------------------------

qui tsline nasdaq, name(nas, replace)
qui tsline allords, name(a, replace)
qui tsline ftse, name(f, replace)
qui tsline nikkei, name(nk, replace)
graph combine nas a f nk, cols(2) name(all1, replace)

qui histogram nasdaq, normal name(nas, replace)
qui histogram allords, normal name(a, replace)
qui histogram ftse, normal name(f, replace)
qui histogram nikkei, normal name(nk, replace)
graph combine nas a f nk, cols(2) name(all2, replace)

* ----------------------------------------------
* Load byd, create dates and declare time series
* ----------------------------------------------
use byd, clear
gen time = _n
tsset time

tsline r, name(g1, replace)

* ----------------------------------------------
* LM test for ARCH(1)
* ----------------------------------------------

regress r
predict ehat, residual

gen ehat2 = ehat * ehat
qui reg ehat2 L.ehat2
scalar TR2 = e(N)*e(r2)
scalar pvalue = chi2tail(1,TR2)
scalar crit = invchi2tail(1,.05)
scalar list TR2 pvalue crit

* ----------------------------------------------
* Built-in LM Test for ARCH(1)
* ----------------------------------------------

regress r
estat archlm, lags(1)

* ----------------------------------------------
* ARCH(1)
* ----------------------------------------------

arch r, arch(1)
predict htarch1, variance
tsline htarch, name(g2, replace)

gen ht_1 = _b[ARCH:_cons]+_b[ARCH:L1.arch]*(L.r-_b[r:_cons])^2
list htarch ht_1 in 496/500

* ----------------------------------------------
* GARCH(1,1)
* ----------------------------------------------

arch r, arch(1) garch(1)
predict htgarch, variance
tsline htgarch, name(g3, replace)

* ----------------------------------------------
* Threshold GARCH
* ----------------------------------------------

arch r, arch(1) garch(1) tarch(1)
predict httgarch, variance
tsline httgarch, name(g4, replace)

* ----------------------------------------------
* GARCH in mean
* ----------------------------------------------

arch r, archm arch(1) garch(1) tarch(1)
predict m_mgarch, xb
predict htmgarch, variance
qui tsline m_mgarch, name(g5, replace)
qui tsline htmgarch, name(g6, replace)
graph combine g5 g6, cols(1)

summarize m_mgarch r, detail 
histogram m_mgarch, normal

log close

