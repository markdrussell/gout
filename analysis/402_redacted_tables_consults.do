version 16

/*==============================================================================
DO FILE NAME:			redacted output tables
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway									
DESCRIPTION OF FILE:	redacted output table for consults
DATASETS USED:			main data file
DATASETS CREATED: 		redacted output table for consults
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
log using "$logdir/redacted_tables_consults.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

set scheme plotplainblind

*Create blank dta file======================================================*/

clear *
save "$projectdir/output/data/consults_main_table_redacted.dta", replace emptyok

****Loop for each year of data===============================================*/

cd "$projectdir/output/data"
fs *input_consults_year_*.dta

foreach f in `r(files)' {
	
	local file_name = "`f'"
	local name_len = length("`file_name'")
	local out_file = substr("`file_name'",1,(`name_len'-4)) //gets rid of original file suffix
	di "`out_file'"
	local index_date = substr("`file_name'",-14,10) //keeps date
	di "`index_date'"
	local year = substr("`file_name'",-14,4) //keeps year
	di "`year'"

*Round and redact relevant statistics======================================================================*/

use "$projectdir/output/data/`out_file'.dta", clear

collapse (sum) N_gout_consults=gout_code N_prevalent_gout_consults=gout_prevalent N_male_gout_consults=male (mean) mean_age=age mean_episode_count=gout_episodes (sd) sd_age=age stdev_episode_count=gout_episodes

gen year="`year'"

foreach var of varlist N_gout_consults N_prevalent_gout_consults N_male_gout_consults {
	rename `var' `var'_freq
	gen count = round(`var'_freq, 5)
	gen countstr = string(count)
	replace countstr = "<8" if count<=7
	order countstr, after(count)
	drop count
	rename countstr `var'
	rename `var'_freq `var'_n
}	

foreach var of varlist mean_age mean_episode_count {
	tostring `var', gen(meanstr) force format(%9.3f)
	replace meanstr = "-" if N_gout_consults =="<8"
	order meanstr, after(`var')
	rename `var' `var'_n
	rename meanstr `var'
}

foreach var of varlist sd_age stdev_episode_count {
	tostring `var', gen(sdstr) force format(%9.3f)
	replace sdstr = "-" if N_gout_consults =="<8"
	order sdstr, after(`var')
	rename `var' `var'_n
	rename sdstr `var'
}

order year, first
order N_gout_consults, after(year)
order N_prevalent_gout_consults, after(N_gout_consults)
order N_male_gout_consults, after(N_prevalent_gout_consults)
order sd_age, after(mean_age)
list year N_gout_consults N_prevalent_gout_consults N_male_gout_consults mean_age sd_age mean_episode_count stdev_episode_count
keep year N_gout_consults N_prevalent_gout_consults N_male_gout_consults mean_age sd_age mean_episode_count stdev_episode_count

append using "$projectdir/output/data/consults_main_table_redacted.dta"
save "$projectdir/output/data/consults_main_table_redacted.dta", replace

}

use "$projectdir/output/data/consults_main_table_redacted.dta", clear
export excel "$projectdir/output/tables/consults_main_table_redacted.xls", sheet("Sheet1", modify) keepcellfmt firstrow(variables)

*Output tables as CSVs		 
import excel "$projectdir/output/tables/consults_main_table_redacted.xls", clear
export delimited using "$projectdir/output/tables/consults_main_table_redacted.csv", novarnames  replace		


log close