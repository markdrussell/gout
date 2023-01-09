version 16

/*==============================================================================
DO FILE NAME:			baseline tables all pts
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway												
DESCRIPTION OF FILE:	baseline tables
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
log using "$logdir/descriptive_tables_allpts.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_eia_allpts.dta", clear

set scheme plotplainblind

/*Tables=====================================================================================*/
tabstat age, stats (n mean sd)

*Baseline table
table1_mc, onecol nospacelowpercent iqrmiddle(",")  ///
	vars(agegroup cat %5.1f \ ///
		 male bin %5.1f \ ///
		 ethnicity cat %5.1f \ ///
		 imd cat %5.1f \ ///
		 bmicat cat %5.1f \ ///
		 smoke cat %5.1f \ ///
		 hypertension bin %5.1f \ ///
		 diabcatm cat %5.1f \ ///
		 chronic_card_disease bin %5.1f \ /// 
		 stroke bin %5.1f \ ///
		 cancer bin %5.1f \ ///
		 chronic_resp_disease bin  %5.1f \ ///
		 chronic_liver_disease bin %5.1f \ ///
		 ckd bin %5.1f \ ///
		 diuretic bin %5.1f \ ///
		 ) saving("$projectdir/output/tables/baseline_allpts.xls", replace)
		 
import excel "$projectdir/output/tables/baseline_allpts.xls", clear
outsheet * using "$projectdir/output/tables/baseline_allpts.csv" , comma nonames replace			 
		 
log close