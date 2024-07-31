version 16

/*==============================================================================
DO FILE NAME:			defines admissions
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway			
DESCRIPTION OF FILE:	define monthly gout admissions
DATASETS USED:			data in memory 
DATASETS CREATED: 		analysis files
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

**Set filepaths
global projectdir `c(pwd)'

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/figures"
capture mkdir "$projectdir/output/tables"

global logdir "$projectdir/logs"

**Open a log file
cap log close
log using "$logdir/admissions_dataset.log", replace

**Create blank dta
clear
save "$projectdir/output/measures/gout_admissions", emptyok replace

**Locates relevant input files, then keeps year and month of gout admissions, then append
cd "$projectdir/output/measures/"
local filelist : dir . files "input_year_*.csv.gz"
foreach file of local filelist {
	di "`file'"
	!gunzip "$projectdir/output/measures/`file'"
	local filesub = substr("`file'", 1, strlen("`file'") - 7)
	di "`filesub'"
	import delimited "$projectdir/output/measures/`filesub'.csv", clear
	gen date_dstr = date(gout_adm_date, "YMD") 
	format date_dstr %td
	drop gout_adm_date
	rename date_dstr gout_adm_date
	gen gout_adm_ym= ym(year(gout_adm_date),month(gout_adm_date))
	gen adm_count=1 if gout_adm_ym!=.
	format %tm gout_adm_ym
	keep adm_count gout_adm_ym sex
	drop if gout_adm_ym==.
	save "$projectdir/output/measures/`filesub'.dta", replace
	use "$projectdir/output/measures/gout_admissions", clear
	append using "$projectdir/output/measures/`filesub'.dta"
	save "$projectdir/output/measures/gout_admissions", replace
}

log close
