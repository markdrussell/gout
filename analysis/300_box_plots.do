version 16

/*==============================================================================
DO FILE NAME:			Box plots
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway																					
DESCRIPTION OF FILE:	Box plots
DATASETS USED:			main data file
DATASETS CREATED: 		Box plots and outputs
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

**Set filepaths
global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir `c(pwd)'

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

global logdir "$projectdir/logs"

**Open a log file
cap log close
log using "$logdir/box_plots.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_gout_all.dta", clear

set scheme plotplainblind

*Initiation of ULT within 6m by region, overall (all years)=========================================================================*

**Restrict all analyses to patients with at least 6m follow-up and registration after diagnosis
keep if has_6m_post_diag==1

preserve
gen ult_0 =1 if time_to_ult_6m<=90 & time_to_ult_6m!=.
recode ult_0 .=0
gen ult_1 =1 if time_to_ult_6m>90 & time_to_ult_6m<=180 & time_to_ult_6m!=.
recode ult_1 .=0
gen ult_2 = 1 if time_to_ult_6m>180 | time_to_ult_6m==. 
recode ult_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) ult_0 (mean) ult_1 (mean) ult_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to ULT initiation") name(regional_qs1_bar, replace)
graph export "$projectdir/output/figures/regional_ult_overall.svg", replace
restore

*Initiation of ULT within 6m by region, overall (individual years)========================================================================*

//May need to change to April to April years
foreach year in 2019 2020 2021 2022 {

preserve
keep if year_diag==`year'
gen ult_0 =1 if time_to_ult_6m<=90 & time_to_ult_6m!=.
recode ult_0 .=0
gen ult_1 =1 if time_to_ult_6m>90 & time_to_ult_6m<=180 & time_to_ult_6m!=.
recode ult_1 .=0
gen ult_2 = 1 if time_to_ult_6m>180 | time_to_ult_6m==. 
recode ult_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) ult_0 (mean) ult_1 (mean) ult_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to ULT initiation") name(regional_ult_`year', replace)
graph export "$projectdir/output/figures/regional_ult_`year'.svg", replace
restore
}

/*Initiation of ULT within 6m by region, merged===========================================================================*/

preserve
keep if year_diag==2019 | year_diag==2020 | year_diag==2021 | year_diag==2022

gen ult_0 =1 if time_to_ult_6m<=90 & time_to_ult_6m!=.
recode ult_0 .=0
gen ult_1 =1 if time_to_ult_6m>90 & time_to_ult_6m<=180 & time_to_ult_6m!=.
recode ult_1 .=0
gen ult_2 = 1 if time_to_ult_6m>180 | time_to_ult_6m==. 
recode ult_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) ult_0 (mean) ult_1 (mean) ult_2, over(year_diag, gap(20) label(labsize(*0.75))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients)  ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to ULT initiation") name(regional_ult_merged, replace)
graph export "$projectdir/output/figures/regional_ult_merged.svg", width(12in)replace
restore

log off