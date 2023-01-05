version 16

/*==============================================================================
DO FILE NAME:			ITSA models
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway												
DESCRIPTION OF FILE:	ITSA models
DATASETS USED:			main data file
DATASETS CREATED: 		tables
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

**Set filepaths
global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir `c(pwd)'

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

global logdir "$projectdir/logs"

**Open a log file
cap log close
log using "$logdir/itsa_models.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_gout_all.dta", clear

set scheme plotplainblind

*Restrict all analyses to patients with at least 6m follow-up and registration after diagnosis================*/
keep if has_6m_post_diag==1

*ITSA models for ULT prescription ===========================================================================*/

**Time from diagnosis to prescription of ULT 
preserve
tab ult_6m
tab mo_year_diagn ult_6m, row 
collapse (mean) mean_ult_delay=ult_6m, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa mean_ult_delay if inrange(mo_year_diagn, tm(2015m1), tm(2022m12)), single trperiod(2020m4; 2021m4) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean proportion prescribed ULT within 6 months", size(medsmall) margin(small)) xlabel(, nogrid) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_ult_newey.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*Restrict all analyses to patients prescribed ULT within 6m who had at least 6m follow-up after ULT================*/

use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_6m_follow_up_ult==1 & ult_6m==1

//Could also look at target attainment overall; i.e. irrespective of ULT

*ITSA models for urate attainment ===========================================================================*/

**Time from diagnosis to prescription of ULT 
preserve
tab urate_below360_ult_6m
tab mo_year_diagn urate_below360_ult_6m, row 
collapse (mean) mean_360_delay=urate_below360_ult_6m, by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa mean_360_delay if inrange(mo_year_diagn, tm(2015m1), tm(2022m12)), single trperiod(2020m4; 2021m4) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Mean proportion prescribed ULT and attaining urate target within 6 months", size(medsmall) margin(small)) xlabel(, nogrid) ylabel(, nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_360_newey.svg", as(svg) replace
	
actest, lag(18)	
	
restore

log close