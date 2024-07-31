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
	local upper_bound "2023m6"
	di "`upper_bound'"
	}	
else if "`x'"=="12m" {
	local upper_bound "2022m12"
	di "`upper_bound'"
	}	
	
*Restrict all analyses to patients with at least 6m/12m follow-up and registration after diagnosis================*
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_diag==1

**Time from diagnosis to prescription of ULT 
preserve
tab ult_`x'
tab mo_year_diagn ult_`x', row
collapse (sum) total_yes=ult_`x' (count) total_number=ult_`x', by(mo_year_diagn)

**Round to nearest 5
foreach var of varlist total_yes total_number {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate proportion from rounded data
gen prop_ult_delay=total_yes_round/total_number_round

**Save rounded table
export delimited using "$projectdir/output/tables/ITSA_ult_`x'.csv", replace

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa prop_ult_delay if inrange(mo_year_diagn, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion prescribed ULT", size(medsmall) margin(small)) xscale(range(660(12)768)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023" 768 "2024", nogrid) yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_ult_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*ITSA models for ULT prescription in patients who have additional risk factors =============================================================*/

*Restrict all analyses to patients with at least 6m/12m follow-up and registration after diagnosis================*
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_diag==1 

*Restrict to patients with additional risk factors
keep if high_risk==1

**Time from diagnosis to prescription of ULT 
preserve
tab ult_`x'
tab mo_year_diagn ult_`x', row 
collapse (sum) total_yes=ult_`x' (count) total_number=ult_`x', by(mo_year_diagn)

**Round to nearest 5
foreach var of varlist total_yes total_number {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate proportion from rounded data
gen prop_ult_delay=total_yes_round/total_number_round

**Save rounded table
export delimited using "$projectdir/output/tables/ITSA_ult_hrisk_`x'.csv", replace

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa prop_ult_delay if inrange(mo_year_diagn, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion prescribed ULT", size(medsmall) margin(small)) xscale(range(660(12)768)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023" 768 "2024", nogrid) yscale(range(0(0.1)0.7)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5" 0.6 "0.6" 0.7 "0.7", format(%03.1f) nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_ult_hrisk_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*ITSA models for urate attainment ===========================================================================*/

*Restrict all analyses to patients who had at least 6m/12m follow-up================*/

use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_diag==1

**Time from diagnosis to attainment of urate <360, irrespective of ULT or whether test performed
preserve
tab urate_below360_`x'
tab mo_year_diagn urate_below360_`x', row 
collapse (sum) total_yes=urate_below360_`x' (count) total_number=urate_below360_`x', by(mo_year_diagn)

**Round to nearest 5
foreach var of varlist total_yes total_number {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate proportion from rounded data
gen prop_360_delay=total_yes_round/total_number_round

**Save rounded table
export delimited using "$projectdir/output/tables/ITSA_360_diag_`x'.csv", replace

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa prop_360_delay if inrange(mo_year_diagn, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion attaining urate <360 micromol/L", size(medsmall) margin(small)) xscale(range(660(12)768)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023" 768 "2024", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_360_diag_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*Restrict all analyses to patients who had at least 6m/12m follow-up and who had a test performed ================*/

use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_diag==1 & had_test_`x'==1

**Time from diagnosis to attainment of urate <360 irrespective of ULT, restricted to those who had a test performed
preserve
tab urate_below360_`x'
tab mo_year_diagn urate_below360_`x', row 
collapse (sum) total_yes=urate_below360_`x' (count) total_number=urate_below360_`x', by(mo_year_diagn)

**Round to nearest 5
foreach var of varlist total_yes total_number {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate proportion from rounded data
gen prop_360_delay=total_yes_round/total_number_round

**Save rounded table
export delimited using "$projectdir/output/tables/ITSA_360_diag_test_`x'.csv", replace

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa prop_360_delay if inrange(mo_year_diagn, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion attaining urate <360 micromol/L", size(medsmall) margin(small)) xscale(range(660(12)768)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023" 768 "2024", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
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
collapse (sum) total_yes=urate_below360_ult_`x' (count) total_number=urate_below360_ult_`x', by(mo_year_ult)

**Round to nearest 5
foreach var of varlist total_yes total_number {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate proportion from rounded data
gen prop_360_delay=total_yes_round/total_number_round

**Save rounded table
export delimited using "$projectdir/output/tables/ITSA_360_ult_`x'.csv", replace

tsset mo_year_ult

**Newey Standard Errors with 5 lags
itsa prop_360_delay if inrange(mo_year_ult, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion attaining urate <360 micromol/L", size(medsmall) margin(small)) xscale(range(660(12)768)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023" 768 "2024", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of first ULT prescription", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
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
collapse (sum) total_yes=urate_below360_ult_`x' (count) total_number=urate_below360_ult_`x', by(mo_year_ult)

**Round to nearest 5
foreach var of varlist total_yes total_number {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate proportion from rounded data
gen prop_360_delay=total_yes_round/total_number_round

**Save rounded table
export delimited using "$projectdir/output/tables/ITSA_360_ult_test_`x'.csv", replace

tsset mo_year_ult

**Newey Standard Errors with 5 lags
itsa prop_360_delay if inrange(mo_year_ult, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion attaining urate <360 micromol/L", size(medsmall) margin(small)) xscale(range(660(12)768)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023" 768 "2024", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of first ULT prescription", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_360_ult_test_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore

*ITSA models for urate monitoring after ULT - at least 2 urate levels within 6m/12m of ULT ==================================================*/

*Restrict all analyses to patients prescribed ULT within 6m who had at least 6m/12m follow-up after ULT ================*/

use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_`x'_post_ult==1 & ult_6m==1

preserve
tab two_urate_ult_`x'
tab mo_year_ult two_urate_ult_`x', row 
collapse (sum) total_yes=two_urate_ult_`x' (count) total_number=two_urate_ult_`x', by(mo_year_ult)

**Round to nearest 5
foreach var of varlist total_yes total_number {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate proportion from rounded data
gen prop_two_urate=total_yes_round/total_number_round

**Save rounded table
export delimited using "$projectdir/output/tables/ITSA_two_urate_`x'.csv", replace

tsset mo_year_ult

**Newey Standard Errors with 5 lags
itsa prop_two_urate if inrange(mo_year_ult, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion with two or more urate checks after ULT", size(medsmall) margin(small)) xscale(range(660(12)768)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023" 768 "2024", nogrid)  yscale(range(0(0.1)0.5)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5", format(%03.1f) nogrid) xtitle("Date of first ULT prescription", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_two_urate_`x'.svg", as(svg) replace
	
actest, lag(18)	
	
restore
}

*ITSA models for baseline urate ===========================================================================*/
	
use "$projectdir/output/data/file_gout_all.dta", clear

*Restrict all analyses to patients who had at least 6m follow-up after diagnosis (we check for baseline urate up to 6m after ULT) ================*/
keep if has_6m_post_diag==1

preserve
tab had_baseline_urate
tab mo_year_diagn had_baseline_urate, row
collapse (sum) total_yes=had_baseline_urate (count) total_number=had_baseline_urate, by(mo_year_diagn)

**Round to nearest 5
foreach var of varlist total_yes total_number {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate proportion from rounded data
gen prop_baseline_urate=total_yes_round/total_number_round

**Save rounded table
export delimited using "$projectdir/output/tables/ITSA_baseline_urate.csv", replace

tsset mo_year_diagn

**Newey Standard Errors with 5 lags
itsa prop_baseline_urate if inrange(mo_year_diagn, tm(2015m3), tm(`upper_bound')), single trperiod(2020m3) lag(5) replace figure(title("", size(small)) subtitle("", size(medsmall)) ytitle("Proportion with a serum urate level at diagnosis", size(medsmall) margin(small)) xscale(range(660(12)768)) xlabel(660 "2015" 672 "2016" 684 "2017" 696 "2018" 708 "2019" 720 "2020" 732 "2021" 744 "2022" 756 "2023" 768 "2024", nogrid) yscale(range(0.3(0.1)0.8)) ylabel(0.3 "0.3" 0.4 "0.4" 0.5 "0.5" 0.6 "0.6" 0.7 "0.7" 0.8 "0.8", format(%03.1f) nogrid) xtitle("Date of diagnosis", size(medsmall) margin(medsmall)) note("", size(v.small)) legend(off)) posttrend 
	graph export "$projectdir/output/figures/ITSA_baseline_urate.svg", as(svg) replace
	
actest, lag(18)	
	
restore

log close