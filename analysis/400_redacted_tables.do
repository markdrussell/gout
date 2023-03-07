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
log using "$logdir/redacted_tables.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

set scheme plotplainblind

**Set index dates ===========================================================*/
global year_preceding = "01/03/2014"
global start_date = "01/03/2015"
global end_date = "28/02/2023"

*Descriptive statistics======================================================================*/

**Baseline table for all gout patients
clear *
save "$projectdir/output/data/table_1_rounded_all.dta", replace emptyok
use "$projectdir/output/data/file_gout_all.dta", clear

drop if diagnosis_year==.

foreach var of varlist high_risk multiple_flares tophus diuretic ckd chronic_liver_disease chronic_resp_disease cancer stroke chronic_card_disease diabcatm hypertension smoke bmicat imd ethnicity male agegroup {
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
	append using "$projectdir/output/data/table_1_rounded_all.dta"
	save "$projectdir/output/data/table_1_rounded_all.dta", replace
	restore
}
use "$projectdir/output/data/table_1_rounded_all.dta", clear
export excel "$projectdir/output/tables/table_1_rounded_bydiag.xls", replace sheet("Overall") keepcellfmt firstrow(variables)

**Baseline table for gout diagnoses, by year of diagnosis - tagged to above excel
use "$projectdir/output/data/file_gout_all.dta", clear

drop if diagnosis_year==.
decode diagnosis_year, gen(year_str)

local index=0
levelsof year_str, local(levels)
foreach i of local levels {
	clear *
	save "$projectdir/output/data/table_1_rounded_`i'.dta", replace emptyok
	di `index'
	if `index'==0 {
		local col = word("`c(ALPHA)'", `index'+6)
	}
	else if `index'>0 & `index'<=22 {
	    local col = word("`c(ALPHA)'", `index'+4)
	}
	di "`col'"
	if `index'==0 {
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	else {
	    local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	di `index'

use "$projectdir/output/data/file_gout_all.dta", clear

drop if diagnosis_year==.
decode diagnosis_year, gen(year_str)

foreach var of varlist high_risk multiple_flares tophus diuretic ckd chronic_liver_disease chronic_resp_disease cancer stroke chronic_card_disease diabcatm hypertension smoke bmicat imd ethnicity male agegroup {
	preserve
	keep if year_str=="`i'"
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
	rename countstr count_`i'
	tostring percent, gen(percentstr) force format(%9.1f)
	replace percentstr = "-" if count =="<8"
	order percentstr, after(percent)
	drop percent
	rename percentstr percent_`i'
	gen totalstr = string(total)
	replace totalstr = "-" if count =="<8"
	order totalstr, after(total)
	drop total
	rename totalstr total_`i'
	gen missingstr = string(missing)
	replace missingstr = "-" if count =="<8"
	order missingstr, after(missing)
	drop missing
	rename missingstr missing_`i'
	list count percent total missing
	keep count percent total missing
	append using "$projectdir/output/data/table_1_rounded_`i'.dta"
	save "$projectdir/output/data/table_1_rounded_`i'.dta", replace
	restore
}
display `index'
display "`col'"
use "$projectdir/output/data/table_1_rounded_`i'.dta", clear
export excel "$projectdir/output/tables/table_1_rounded_bydiag.xls", sheet("Overall", modify) cell("`col'1") keepcellfmt firstrow(variables)
}

**Boxplot outputs - ULT prescription within 6m, by region (overall)
clear *
save "$projectdir/output/data/ult_byyearandregion_rounded_all.dta", replace emptyok
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_6m_post_diag==1
keep if diagnosis_year>=5 & diagnosis_year!=. //restrict to 2019 onwards
drop if region_nospace=="Not known"

foreach var of varlist ult_time_22 ult_time_21 ult_time_20 ult_time_19 ult_time {
	preserve
	contract `var'
	local v : variable label `var' 
	gen variable = `"`v'"'
    decode `var', gen(categories)
	gen count = round(_freq, 5)
	egen total = total(count)
	egen non_missing=sum(count) if !strmatch(categories, "Outside*")
	drop if strmatch(categories, "Outside*")
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
	rename missingstr missing_all
	list variable categories count percent total missing
	keep variable categories count percent total missing
	append using "$projectdir/output/data/ult_byyearandregion_rounded_all.dta"
	save "$projectdir/output/data/ult_byyearandregion_rounded_all.dta", replace
	restore
}
use "$projectdir/output/data/ult_byyearandregion_rounded_all.dta", clear
export excel "$projectdir/output/tables/ult_byyearandregion_rounded.xls", replace sheet("Overall") keepcellfmt firstrow(variables)

**Boxplot outputs - ULT prescription within 6m, by region and year - tagged to above
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_6m_post_diag==1
keep if diagnosis_year>=5 & diagnosis_year!=. //restrict to 2019 onwards
drop if region_nospace=="Not known"

local index=0
levelsof region_nospace, local(levels)
foreach i of local levels {
	clear *
	save "$projectdir/output/data/ult_byyearandregion_rounded_`i'.dta", replace emptyok
	di `index'
	if `index'==0 {
		local col = word("`c(ALPHA)'", `index'+7)
	}
	else if `index'>0 & `index'<=21 {
	    local col = word("`c(ALPHA)'", `index'+5)
	}
	else if `index'==22 {
	    local col = "AA"
	}
	else if `index'==26 {
	    local col = "AE"
	}	
	else if `index'==30 {
	    local col = "AI"	
	}	
	else if `index'==34 {
	    local col = "AM"
	}
	di "`col'"
	if `index'==0 {
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	else {
	    local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	di `index'	
	
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_6m_post_diag==1
keep if diagnosis_year>=5 & diagnosis_year!=. //restrict to 2019 onwards
drop if region_nospace=="Not known"


foreach var of varlist ult_time_22 ult_time_21 ult_time_20 ult_time_19 ult_time {
	preserve
	keep if region_nospace=="`i'"
	contract `var'
	local v : variable label `var' 
	gen variable = `"`v'"'
    decode `var', gen(categories)
	gen count = round(_freq, 5)
	egen total = total(count)
	egen non_missing=sum(count) if !strmatch(categories, "Outside*")
	drop if strmatch(categories, "Outside*")
	gen percent = round((count/non_missing)*100, 0.1)
	gen missing=(total-non_missing)
	order total, after(percent)
	order missing, after(total)
	gen countstr = string(count)
	replace countstr = "<8" if count<=7
	order countstr, after(count)
	drop count
	rename countstr count_`i'
	tostring percent, gen(percentstr) force format(%9.1f)
	replace percentstr = "-" if count =="<8"
	order percentstr, after(percent)
	drop percent
	rename percentstr percent_`i'
	gen totalstr = string(total)
	replace totalstr = "-" if count =="<8"
	order totalstr, after(total)
	drop total
	rename totalstr total_`i'
	gen missingstr = string(missing)
	replace missingstr = "-" if count =="<8"
	order missingstr, after(missing)
	drop missing
	rename missingstr missing_`i'
	list count percent total missing
	keep count percent total missing
	append using "$projectdir/output/data/ult_byyearandregion_rounded_`i'.dta"
	save "$projectdir/output/data/ult_byyearandregion_rounded_`i'.dta", replace
	restore
}
display `index'
display "`col'"
use "$projectdir/output/data/ult_byyearandregion_rounded_`i'.dta", clear
export excel "$projectdir/output/tables/ult_byyearandregion_rounded.xls", sheet("Overall", modify) cell("`col'1") keepcellfmt firstrow(variables)
}

**Boxplot outputs - Urate standards (<360 within 6m of ULT), by region (overall)
clear *
save "$projectdir/output/data/urate_6m_ult_byyearandregion_rounded_all.dta", replace emptyok
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_6m_post_ult==1
keep if ult_6m==1
keep if ult_year>=5 & ult_year!=. //restrict to 2019 onwards. Note, this is year of first ULT, not year of diagnosis
drop if region_nospace=="Not known"

foreach var of varlist urate_6m_ult_time_22 urate_6m_ult_time_21 urate_6m_ult_time_20 urate_6m_ult_time_19 urate_6m_ult_time {
	preserve
	contract `var'
	local v : variable label `var' 
	gen variable = `"`v'"'
    decode `var', gen(categories)
	gen count = round(_freq, 5)
	egen total = total(count)
	egen non_missing=sum(count) if !strmatch(categories, "Outside*")
	drop if strmatch(categories, "Outside*")
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
	rename missingstr missing_all
	list variable categories count percent total missing
	keep variable categories count percent total missing
	append using "$projectdir/output/data/urate_6m_ult_byyearandregion_rounded_all.dta"
	save "$projectdir/output/data/urate_6m_ult_byyearandregion_rounded_all.dta", replace
	restore
}
use "$projectdir/output/data/urate_6m_ult_byyearandregion_rounded_all.dta", clear
export excel "$projectdir/output/tables/urate_6m_ult_byyearandregion_rounded.xls", replace sheet("Overall") keepcellfmt firstrow(variables)

**Boxplot outputs - Urate standards (<360 within 6m of ULT), by region and year - tagged to above
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_6m_post_ult==1
keep if ult_6m==1
keep if ult_year>=5 & ult_year!=. //restrict to 2019 onwards. Note, this is year of first ULT, not year of diagnosis
drop if region_nospace=="Not known"

local index=0
levelsof region_nospace, local(levels)
foreach i of local levels {
	clear *
	save "$projectdir/output/data/urate_6m_ult_byyearandregion_rounded_`i'.dta", replace emptyok
	di `index'
	if `index'==0 {
		local col = word("`c(ALPHA)'", `index'+7)
	}
	else if `index'>0 & `index'<=21 {
	    local col = word("`c(ALPHA)'", `index'+5)
	}
	else if `index'==22 {
	    local col = "AA"
	}
	else if `index'==26 {
	    local col = "AE"
	}	
	else if `index'==30 {
	    local col = "AI"	
	}	
	else if `index'==34 {
	    local col = "AM"
	}
	di "`col'"
	if `index'==0 {
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	else {
	    local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	di `index'	
	
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_6m_post_ult==1
keep if ult_6m==1
keep if ult_year>=5 & ult_year!=. //restrict to 2019 onwards. Note, this is year of first ULT, not year of diagnosis
drop if region_nospace=="Not known"


foreach var of varlist urate_6m_ult_time_22 urate_6m_ult_time_21 urate_6m_ult_time_20 urate_6m_ult_time_19 urate_6m_ult_time {
	preserve
	keep if region_nospace=="`i'"
	contract `var'
	local v : variable label `var' 
	gen variable = `"`v'"'
    decode `var', gen(categories)
	gen count = round(_freq, 5)
	egen total = total(count)
	egen non_missing=sum(count) if !strmatch(categories, "Outside*")
	drop if strmatch(categories, "Outside*")
	gen percent = round((count/non_missing)*100, 0.1)
	gen missing=(total-non_missing)
	order total, after(percent)
	order missing, after(total)
	gen countstr = string(count)
	replace countstr = "<8" if count<=7
	order countstr, after(count)
	drop count
	rename countstr count_`i'
	tostring percent, gen(percentstr) force format(%9.1f)
	replace percentstr = "-" if count =="<8"
	order percentstr, after(percent)
	drop percent
	rename percentstr percent_`i'
	gen totalstr = string(total)
	replace totalstr = "-" if count =="<8"
	order totalstr, after(total)
	drop total
	rename totalstr total_`i'
	gen missingstr = string(missing)
	replace missingstr = "-" if count =="<8"
	order missingstr, after(missing)
	drop missing
	rename missingstr missing_`i'
	list count percent total missing
	keep count percent total missing
	append using "$projectdir/output/data/urate_6m_ult_byyearandregion_rounded_`i'.dta"
	save "$projectdir/output/data/urate_6m_ult_byyearandregion_rounded_`i'.dta", replace
	restore
}
display `index'
display "`col'"
use "$projectdir/output/data/urate_6m_ult_byyearandregion_rounded_`i'.dta", clear
export excel "$projectdir/output/tables/urate_6m_ult_byyearandregion_rounded.xls", sheet("Overall", modify) cell("`col'1") keepcellfmt firstrow(variables)
}

**Boxplot outputs - Urate standards (<360 within 12m of ULT), by region (overall)
clear *
save "$projectdir/output/data/urate_12m_ult_byyearandregion_rounded_all.dta", replace emptyok
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_12m_post_ult==1
keep if ult_6m==1
keep if ult_year>=5 & ult_year<=7 & ult_year!=. //restrict to 2019-2021. Note, this is year of first ULT, not year of diagnosis
drop if region_nospace=="Not known"

foreach var of varlist urate_12m_ult_time_21 urate_12m_ult_time_20 urate_12m_ult_time_19 urate_12m_ult_time {
	preserve
	contract `var'
	local v : variable label `var' 
	gen variable = `"`v'"'
    decode `var', gen(categories)
	gen count = round(_freq, 5)
	egen total = total(count)
	egen non_missing=sum(count) if !strmatch(categories, "Outside*")
	drop if strmatch(categories, "Outside*")
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
	rename missingstr missing_all
	list variable categories count percent total missing
	keep variable categories count percent total missing
	append using "$projectdir/output/data/urate_12m_ult_byyearandregion_rounded_all.dta"
	save "$projectdir/output/data/urate_12m_ult_byyearandregion_rounded_all.dta", replace
	restore
}
use "$projectdir/output/data/urate_12m_ult_byyearandregion_rounded_all.dta", clear
export excel "$projectdir/output/tables/urate_12m_ult_byyearandregion_rounded.xls", replace sheet("Overall") keepcellfmt firstrow(variables)

**Boxplot outputs - Urate standards (<360 within 12m of ULT), by region and year - tagged to above
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_12m_post_ult==1
keep if ult_6m==1
keep if ult_year>=5 & ult_year<=7 & ult_year!=. //restrict to 2019-2021. Note, this is year of first ULT, not year of diagnosis
drop if region_nospace=="Not known"

local index=0
levelsof region_nospace, local(levels)
foreach i of local levels {
	clear *
	save "$projectdir/output/data/urate_12m_ult_byyearandregion_rounded_`i'.dta", replace emptyok
	di `index'
	if `index'==0 {
		local col = word("`c(ALPHA)'", `index'+7)
	}
	else if `index'>0 & `index'<=21 {
	    local col = word("`c(ALPHA)'", `index'+5)
	}
	else if `index'==22 {
	    local col = "AA"
	}
	else if `index'==26 {
	    local col = "AE"
	}	
	else if `index'==30 {
	    local col = "AI"	
	}	
	else if `index'==34 {
	    local col = "AM"
	}
	di "`col'"
	if `index'==0 {
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	else {
	    local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	di `index'	
	
use "$projectdir/output/data/file_gout_all.dta", clear

keep if has_12m_post_ult==1
keep if ult_6m==1
keep if ult_year>=5 & ult_year<=7 & ult_year!=. //restrict to 2019-2021. Note, this is year of first ULT, not year of diagnosis
drop if region_nospace=="Not known"


foreach var of varlist urate_12m_ult_time_21 urate_12m_ult_time_20 urate_12m_ult_time_19 urate_12m_ult_time {
	preserve
	keep if region_nospace=="`i'"
	contract `var'
	local v : variable label `var' 
	gen variable = `"`v'"'
    decode `var', gen(categories)
	gen count = round(_freq, 5)
	egen total = total(count)
	egen non_missing=sum(count) if !strmatch(categories, "Outside*")
	drop if strmatch(categories, "Outside*")
	gen percent = round((count/non_missing)*100, 0.1)
	gen missing=(total-non_missing)
	order total, after(percent)
	order missing, after(total)
	gen countstr = string(count)
	replace countstr = "<8" if count<=7
	order countstr, after(count)
	drop count
	rename countstr count_`i'
	tostring percent, gen(percentstr) force format(%9.1f)
	replace percentstr = "-" if count =="<8"
	order percentstr, after(percent)
	drop percent
	rename percentstr percent_`i'
	gen totalstr = string(total)
	replace totalstr = "-" if count =="<8"
	order totalstr, after(total)
	drop total
	rename totalstr total_`i'
	gen missingstr = string(missing)
	replace missingstr = "-" if count =="<8"
	order missingstr, after(missing)
	drop missing
	rename missingstr missing_`i'
	list count percent total missing
	keep count percent total missing
	append using "$projectdir/output/data/urate_12m_ult_byyearandregion_rounded_`i'.dta"
	save "$projectdir/output/data/urate_12m_ult_byyearandregion_rounded_`i'.dta", replace
	restore
}
display `index'
display "`col'"
use "$projectdir/output/data/urate_12m_ult_byyearandregion_rounded_`i'.dta", clear
export excel "$projectdir/output/tables/urate_12m_ult_byyearandregion_rounded.xls", sheet("Overall", modify) cell("`col'1") keepcellfmt firstrow(variables)
}

*Output tables as CSVs		 
import excel "$projectdir/output/tables/table_1_rounded_bydiag.xls", clear
export delimited using "$projectdir/output/tables/table_1_rounded_bydiag.csv" , novarnames  replace		

import excel "$projectdir/output/tables/ult_byyearandregion_rounded.xls", clear
export delimited using "$projectdir/output/tables/ult_byyearandregion_rounded.csv" , novarnames  replace		

import excel "$projectdir/output/tables/urate_6m_ult_byyearandregion_rounded.xls", clear
export delimited using "$projectdir/output/tables/urate_6m_ult_byyearandregion_rounded.csv" , novarnames  replace	

import excel "$projectdir/output/tables/urate_12m_ult_byyearandregion_rounded.xls", clear
export delimited using "$projectdir/output/tables/urate_12m_ult_byyearandregion_rounded.csv" , novarnames  replace	

log close