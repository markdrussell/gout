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
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
global projectdir `c(pwd)'

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

*ITSA models for ULT prescription ===========================================================================*/

foreach x in "6m" "12m" {
	
if "`x'"=="6m" {
	local upper_bound "2022m6"
	di "`upper_bound'"
	}	
else if "`x'"=="12m" {
	local upper_bound "2021m12"
	di "`upper_bound'"
	}	
	
*Restrict all analyses to patients with at least 6m/12m follow-up and registration after diagnosis================*
keep if has_`x'_post_diag==1

**Time from diagnosis to prescription of ULT 
preserve
tab ult_`x'
tab mo_year_diagn ult_`x', row 
collapse (mean) mean_ult_delay=ult_`x', by(mo_year_diagn)

//output ITSA tables separately - keep within same range as below

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa mean_ult_delay if inrange(mo_year_diagn, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion prescribed ULT", size(medsmall) margin(small)) xscale(range(660(12)756)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023", nogrid) yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_ult_newey_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*ITSA models for urate attainment ===========================================================================*/

*Restrict all analyses to patients who had at least 6m/12m follow-up================*/

use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_diag==1

**Time from ULT to attainment of urate <360, irrespective of ULT or whether test performed
preserve
tab urate_below360_`x'
tab mo_year_diagn urate_below360_`x', row 
collapse (mean) mean_360_delay=urate_below360_`x', by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa mean_360_delay if inrange(mo_year_diagn, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion attaining urate <360 micromol/L", size(medsmall) margin(small)) xscale(range(660(12)756)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_360_diag_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*Restrict all analyses to patients who had at least 6m/12m follow-up and who had a test performed ================*/

use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_diag==1 & had_test_`x'==1

**Time from ULT to attainment of urate <360 irrespective of ULT, restricted to those who had a test performed
preserve
tab urate_below360_`x'
tab mo_year_diagn urate_below360_`x', row 
collapse (mean) mean_360_delay=urate_below360_`x', by(mo_year_diagn)

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa mean_360_delay if inrange(mo_year_diagn, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion attaining urate <360 micromol/L", size(medsmall) margin(small)) xscale(range(660(12)756)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_360_diag_test_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*Restrict all analyses to patients prescribed ULT within 6m who had at least 6m/12m follow-up after ULT================*/

use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_ult==1 & ult_6m==1

**Time from ULT to attainment of urate <360, irrespective of whether test performed - use first ULT date as time category
preserve
tab urate_below360_ult_`x'
tab mo_year_ult urate_below360_ult_`x', row 
collapse (mean) mean_360_delay=urate_below360_ult_`x', by(mo_year_ult)

tsset mo_year_ult

**Newey Standard Errors with 5 lags
itsa mean_360_delay if inrange(mo_year_ult, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion attaining urate <360 micromol/L", size(medsmall) margin(small)) xscale(range(660(12)756)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of first ULT prescription", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_360_ult_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*Restrict all analyses to patients prescribed ULT within 6m who had at least 6m/12m follow-up after ULT and who had a test performed ================*/

use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_ult==1 & ult_6m==1 & had_test_ult_`x'==1

**Time from ULT to attainment of urate <360, restricted to those who had a test performed - use first ULT date as time category
preserve
tab urate_below360_ult_`x'
tab mo_year_ult urate_below360_ult_`x', row 
collapse (mean) mean_360_delay=urate_below360_ult_`x', by(mo_year_ult)

tsset mo_year_ult

**Newey Standard Errors with 5 lags
itsa mean_360_delay if inrange(mo_year_ult, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion attaining urate <360 micromol/L", size(medsmall) margin(small)) xscale(range(660(12)756)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of first ULT prescription", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_360_ult_test_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

}

log close