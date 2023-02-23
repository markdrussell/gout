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
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
global projectdir `c(pwd)'

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/figures"
capture mkdir "$projectdir/output/tables"

global logdir "$projectdir/logs"

**Open a log file
cap log close
log using "$logdir/admissions_dataset.log", replace

**Locates relevant input files, then keeps year and month of gout admissions
cd "$projectdir/output/measures/"
local filelist : dir . files "input_year_*.csv.gz"
foreach file of local filelist {
	di "`file'"
	!gunzip "$projectdir/output/measures/`file'"
	import delimited "$projectdir/output/measures/`file'", clear
	gen date_dstr = date(gout_adm_date, "YMD") 
	format date_dstr %td
	drop gout_adm_date
	rename date_dstr gout_adm_date
	gen gout_adm_ym= ym(year(gout_adm_date),month(gout_adm_date))
	format %tm gout_adm_ym
	keep patient_id gout_adm_ym
	drop if gout_adm_ym==.
	save "$projectdir/output/measures/`file'", replace
}

**Append admission files to a blank dta
clear
save "$projectdir/output/measures/gout_admissions", emptyok replace
use "$projectdir/output/measures/gout_admissions", clear
cd "$projectdir/output/measures/"
local filelist : dir . files "input_year_*.csv.gz"
foreach file of local filelist {
	di "`file'"
	append using "$projectdir/output/measures/`file'"
	save "$projectdir/output/measures/gout_admissions", replace
}

log close
