version 16

/*==============================================================================
DO FILE NAME:			redacted output tables
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway										
DESCRIPTION OF FILE:	redacted output table
DATASETS USED:			main data file
DATASETS CREATED: 		redacted output table
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
log using "$logdir/redacted_tables_allpts.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

set scheme plotplainblind

**Set index dates ===========================================================*/
global year_preceding = "01/03/2014"
global start_date = "01/03/2015"
global end_date = "01/03/2023"

*Descriptive statistics======================================================================*/

**Baseline table for reference population
clear *
save "$projectdir/output/data/table_1_rounded_allpts.dta", replace emptyok
use "$projectdir/output/data/file_gout_allpts.dta", clear

set type double

foreach var of varlist diuretic ckd chronic_liver_disease chronic_resp_disease cancer stroke chronic_card_disease diabcatm hypertension smoke bmicat imd ethnicity male agegroup {
	preserve
	contract `var'
	local v : variable label `var' 
	gen variable = `"`v'"'
    decode `var', gen(categories)
	egen total_un = total(_freq)
	egen non_missing_un=sum(_freq) if categories!="Not known"
	gen missing_un=(total_un-non_missing_un)
	drop if categories=="Not known"
	gen count = round(_freq, 5)
	gen total = round(total_un, 5)
	gen missing = round(missing_un, 5)
	gen non_missing = round(non_missing_un, 5)
	gen percent = round((count/non_missing)*100, 0.1)
	order variable, first
	order categories, after(variable)
	order count, after(categories)
	order percent, after(count)
	order total, after(percent)
	order missing, after(total)
	list variable categories count percent total missing
	keep variable categories count percent total missing
	append using "$projectdir/output/data/table_1_rounded_allpts.dta"
	save "$projectdir/output/data/table_1_rounded_allpts.dta", replace
	restore
}
use "$projectdir/output/data/table_1_rounded_allpts.dta", clear
export excel "$projectdir/output/tables/table_1_rounded_allpts.xls", replace keepcellfmt firstrow(variables)

**Table of mean outputs
clear *
save "$projectdir/output/data/table_mean_rounded_allpts.dta", replace emptyok
use "$projectdir/output/data/file_gout_allpts.dta", clear

foreach var of varlist age {
	preserve
	collapse (count) "`var'_count"=`var' (mean) mean=`var' (sd) stdev=`var'
	gen varn = "`var'_count"
	gen variable = substr(varn, 1, strpos(varn, "_count") - 1)
	drop varn
	rename *count freq
	gen count = round(freq, 5)
	gen countstr = string(count)
	replace countstr = "<8" if count<=7
	order countstr, after(count)
	drop count
	rename countstr count
	tostring mean, gen(meanstr) force format(%9.1f)
	replace meanstr = "-" if count =="<8"
	order meanstr, after(mean)
	drop mean
	rename meanstr mean
	tostring stdev, gen(stdevstr) force format(%9.1f)
	replace stdevstr = "-" if count =="<8"
	order stdevstr, after(stdev)
	drop stdev
	rename stdevstr stdev
	gen diagnosis = "Total"
	order count, first
	order diagnosis, first
	order variable, first
	list variable diagnosis count mean stdev
	keep variable diagnosis count mean stdev
	append using "$projectdir/output/data/table_mean_rounded_allpts.dta"
	save "$projectdir/output/data/table_mean_rounded_allpts.dta", replace
	restore
} 

use "$projectdir/output/data/table_mean_rounded_allpts.dta", clear
export excel "$projectdir/output/tables/table_mean_rounded_allpts.xls", replace keepcellfmt firstrow(variables)

*Output tables as CSVs		 
import excel "$projectdir/output/tables/table_1_rounded_allpts.xls", clear
export delimited using "$projectdir/output/tables/table_1_rounded_allpts.csv" , novarnames  replace		

import excel "$projectdir/output/tables/table_mean_rounded_allpts.xls", clear
export delimited using "$projectdir/output/tables/table_mean_rounded_allpts.csv" , novarnames  replace		

log close