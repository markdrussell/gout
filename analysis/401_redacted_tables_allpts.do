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
global end_date = "28/02/2023"

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
	gen count = round(_freq, 5)
	egen total = total(count)
	egen non_missing=sum(count) if categories!="Not known"
	drop if categories=="Not known"
	gen percent = round((count/non_missing)*100, 0.1)
	gen missing=(total-non_missing)
	order total, after(percent)
	order missing, after(total)
	gen countstr = string(count)
	replace countstr = "<8" if count<=7
	order countstr, after(count)
	drop count
	rename countstr count_all
	tostring percent, gen(percentstr) force format(%9.1f)
	replace percentstr = "-" if count =="<8"
	order percentstr, after(percent)
	drop percent
	rename percentstr percent_all
	gen totalstr = string(total)
	replace totalstr = "-" if count =="<8"
	order totalstr, after(total)
	drop total
	rename totalstr total_all
	gen missingstr = string(missing)
	replace missingstr = "-" if count =="<8"
	order missingstr, after(missing)
	drop missing
	rename missingstr missing
	list variable categories count percent total missing
	keep variable categories count percent total missing
	append using "$projectdir/output/data/table_1_rounded_allpts.dta"
	save "$projectdir/output/data/table_1_rounded_allpts.dta", replace
	restore
}
use "$projectdir/output/data/table_1_rounded_allpts.dta", clear
export excel "$projectdir/output/tables/table_1_rounded_allpts.xls", replace keepcellfmt firstrow(variables)

*Output tables as CSVs		 
import excel "$projectdir/output/tables/table_1_rounded_allpts.xls", clear
export delimited using "$projectdir/output/tables/table_1_rounded_allpts.csv" , novarnames  replace		

log close