version 16

/*==============================================================================
DO FILE NAME:			summary counts
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway			
DESCRIPTION OF FILE:	data management for Gout project  
						reformat variables 
						categorise variables
						label variables 
						outputs summary statistics for variables that are iterated
DATASETS USED:			data in memory (from output/input.csv)
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
log using "$logdir/summary_counts.log", replace

!gunzip "$projectdir/output/input_count.csv.gz"
import delimited "$projectdir/output/input_count.csv", clear

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Set index dates ===========================================================*/
global year_preceding = "01/01/2018"
global start_date = "01/01/2019"
global end_date = "01/01/2020"
	
**Change date format and create binary indicator variables for relevant conditions ====================================================*/

foreach var of varlist 	 gout_code_date						///
						 {		
	  
	  capture confirm string variable `var'
		if _rc!=0 {
			assert `var'==.
			rename `var' `var'_Y
		}
		else {
				rename `var' `var'_dstr
				gen `var'_Y = date(`var'_dstr, "YMD") 
				order `var'_Y, after(`var'_dstr)
				drop `var'_dstr
				rename `var'_Y `var'
		}
	format `var' %td
	local newvar =  substr("`var'", 1, length("`var'") - 5)
	gen `newvar' = (`var'!=. )
	order `newvar', after(`var')
}

*Generate diagnosis date===============================================================*/

*Use first gout code date (in GP record) as diagnosis date
gen diagnosis_date=gout_code_date
format diagnosis_date %td

*Refine diagnostic window=============================================================*/

**Keep patients with diagnosis date was after study start date and before end date
keep if diagnosis_date>=date("$start_date", "DMY") & diagnosis_date!=. 
tab gout_code, missing
keep if diagnosis_date<date("$end_date", "DMY") & diagnosis_date!=. 
tab gout_code, missing

codebook diagnosis_date

*Check counts for key variables=======================================================*/

foreach var of varlist urate_count gout_admission_count gout_ed_count gout_flare_count gout_code_count flare_treatment_count {
	tabstat `var', stats (n mean sd p50 p25 p75 p5 p95)
} 

log close
