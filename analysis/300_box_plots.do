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
global projectdir `c(pwd)'

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

graph hbar (mean) ult_0 (mean) ult_1 (mean) ult_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to ULT initiation") name(regional_ult_overall_6m, replace)
graph export "$projectdir/output/figures/regional_ult_overall_6m.svg", replace
restore

/*Initiation of ULT within 6m by region, merged===========================================================================*/

preserve
keep if diagnosis_year>=5 & diagnosis_year!=. //restrict to 2019 onwards

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

graph hbar (mean) ult_0 (mean) ult_1 (mean) ult_2, over(diagnosis_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients)  ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to ULT initiation") name(regional_ult_merged_6m, replace)
graph export "$projectdir/output/figures/regional_ult_merged_6m.svg", width(12in)replace
restore

*Initiation of ULT within 12m by region, overall (all years)=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 12m follow-up and registration after diagnosis
keep if has_12m_post_diag==1

preserve
gen ult_0 =1 if ult_6m==1
recode ult_0 .=0
gen ult_1 =1 if ult_6m!=1 & ult_12m==1
recode ult_1 .=0
gen ult_2 = 1 if ult_6m!=1 & ult_12m!=1 
recode ult_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) ult_0 (mean) ult_1 (mean) ult_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "None within 12 months")) title("Time to ULT initiation") name(regional_ult_overall_12m, replace)
graph export "$projectdir/output/figures/regional_ult_overall_12m.svg", replace
restore

/*Initiation of ULT within 12m by region, merged===========================================================================*/

preserve
keep if diagnosis_year>=5 & diagnosis_year<=8 & diagnosis_year!=. //restrict to 2019-2022

gen ult_0 =1 if ult_6m==1
recode ult_0 .=0
gen ult_1 =1 if ult_6m!=1 & ult_12m==1
recode ult_1 .=0
gen ult_2 = 1 if ult_6m!=1 & ult_12m!=1 
recode ult_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) ult_0 (mean) ult_1 (mean) ult_2, over(diagnosis_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients)  ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "None within 12 months")) title("Time to ULT initiation") name(regional_ult_merged_12m, replace)
graph export "$projectdir/output/figures/regional_ult_merged_12m.svg", width(12in)replace
restore

*Urate attainment within 6m of diagnosis by region, overall (all years); irrespective of whether a test was performed within that timeframe=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 6m follow-up and registration after diagnosis
keep if has_6m_post_diag==1

preserve
gen urate_0 =1 if urate_below360_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_6m!=1
recode urate_1 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") bar(1, color(black)) bar(2, color(sky)) legend(order(1 "Within 6 months" 2 "Not within 6 months")) title("Time to urate target attainment") name(regional_urate_overall_6m, replace)
graph export "$projectdir/output/figures/regional_urate_overall_6m.svg", replace
restore

*Urate attainment within 6m of diagnosis by region, merged; irrespective of whether a test was performed within that timeframe=========================================================================*

preserve
keep if diagnosis_year>=5 & diagnosis_year!=. //restrict to 2019 onwards

gen urate_0 =1 if urate_below360_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_6m!=1
recode urate_1 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1, over(diagnosis_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") bar(1, color(black)) bar(2, color(sky)) legend(order(1 "Within 6 months" 2 "Not within 6 months")) title("Time to urate target attainment") name(regional_urate_merged_6m, replace)
graph export "$projectdir/output/figures/regional_urate_merged_6m.svg", width(12in) replace
restore

*Urate attainment within 6m of diagnosis by region, overall (all years); restricted to those that had a test was performed within that timeframe=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 6m follow-up and registration after diagnosis
keep if has_6m_post_diag==1 & had_test_6m==1

preserve
gen urate_0 =1 if urate_below360_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_6m!=1
recode urate_1 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") bar(1, color(black)) bar(2, color(sky)) legend(order(1 "Within 6 months" 2 "Not within 6 months")) title("Time to urate target attainment") name(regional_urate_overall_6m_test, replace)
graph export "$projectdir/output/figures/regional_urate_overall_6m_test.svg", replace
restore

*Urate attainment within 6m of diagnosis by region, merged; restricted to those that had a test was performed within that timeframe=========================================================================*

preserve
keep if diagnosis_year>=5 & diagnosis_year!=. //restrict to 2019 onwards

gen urate_0 =1 if urate_below360_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_6m!=1
recode urate_1 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1, over(diagnosis_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") bar(1, color(black)) bar(2, color(sky)) legend(order(1 "Within 6 months" 2 "Not within 6 months")) title("Time to urate target attainment") name(regional_urate_merged_6m_test, replace)
graph export "$projectdir/output/figures/regional_urate_merged_6m_test.svg", width(12in) replace
restore

*Urate attainment within 6m of ULT by region, overall (all years); irrespective of whether a test was performed within that timeframe=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 6m follow-up and registration after ULT 
keep if ult_6m==1 & has_6m_post_ult==1

preserve
gen urate_0 =1 if urate_below360_ult_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_ult_6m!=1
recode urate_1 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") bar(1, color(black)) bar(2, color(sky)) legend(order(1 "Within 6 months" 2 "Not within 6 months")) title("Time to urate target attainment") name(regional_urate_overall_6m_ult, replace)
graph export "$projectdir/output/figures/regional_urate_overall_6m_ult.svg", replace
restore

*Urate attainment within 6m of ULT by region, merged; irrespective of whether a test was performed within that timeframe=========================================================================*

preserve
keep if ult_year>=5 & ult_year!=. //restrict to 2019 onwards. Note, this is year of first ULT, not year of diagnosis

gen urate_0 =1 if urate_below360_ult_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_ult_6m!=1
recode urate_1 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1, over(ult_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") bar(1, color(black)) bar(2, color(sky)) legend(order(1 "Within 6 months" 2 "Not within 6 months")) title("Time to urate target attainment") name(regional_urate_merged_6m_ult, replace)
graph export "$projectdir/output/figures/regional_urate_merged_6m_ult.svg", width(12in) replace
restore

*Urate attainment within 6m of ULT by region, overall (all years); restricted to those that had a test was performed within that timeframe=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 6m follow-up and registration after ULT
keep if ult_6m==1 & has_6m_post_ult==1 & had_test_ult_6m==1

preserve
gen urate_0 =1 if urate_below360_ult_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_ult_6m!=1
recode urate_1 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") bar(1, color(black)) bar(2, color(sky)) legend(order(1 "Within 6 months" 2 "Not within 6 months")) title("Time to urate target attainment") name(reg_urate_overall_6m_ult_test, replace)
graph export "$projectdir/output/figures/reg_urate_overall_6m_ult_test.svg", replace
restore

*Urate attainment within 6m of ULT by region, merged; restricted to those that had a test was performed within that timeframe=========================================================================*

preserve
keep if ult_year>=5 & ult_year!=. //restrict to 2019 onwards. Note, this is year of first ULT, not year of diagnosis

gen urate_0 =1 if urate_below360_ult_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_ult_6m!=1
recode urate_1 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1, over(ult_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") bar(1, color(black)) bar(2, color(sky)) legend(order(1 "Within 6 months" 2 "Not within 6 months")) title("Time to urate target attainment") name(reg_urate_merged_6m_ult_test, replace)
graph export "$projectdir/output/figures/reg_urate_merged_6m_ult_test.svg", width(12in) replace
restore

*Urate attainment within 12m of diagnosis by region, overall (all years); irrespective of whether a test was performed within that timeframe=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 12m follow-up and registration after diagnosis
keep if has_12m_post_diag==1

preserve
gen urate_0 =1 if urate_below360_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_6m!=1 & urate_below360_12m==1
recode urate_1 .=0
gen urate_2 =1 if urate_below360_6m!=1 & urate_below360_12m!=1
recode urate_2 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1 (mean) urate_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "Not within 12 months")) title("Time to urate target attainment") name(regional_urate_overall_12m, replace)
graph export "$projectdir/output/figures/regional_urate_overall_12m.svg", replace
restore

*Urate attainment within 12m of diagnosis by region, merged; irrespective of whether a test was performed within that timeframe=========================================================================*

preserve
keep if diagnosis_year>=5 & diagnosis_year<=8 & diagnosis_year!=. //restrict to 2019-2021

gen urate_0 =1 if urate_below360_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_6m!=1 & urate_below360_12m==1
recode urate_1 .=0
gen urate_2 =1 if urate_below360_6m!=1 & urate_below360_12m!=1
recode urate_2 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1 (mean) urate_2, over(diagnosis_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "Not within 12 months")) title("Time to urate target attainment") name(regional_urate_merged_12m, replace)
graph export "$projectdir/output/figures/regional_urate_merged_12m.svg", width(12in) replace
restore

*Urate attainment within 12m of diagnosis by region, overall (all years); restricted to those that had a test was performed within that timeframe=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 12m follow-up and registration after diagnosis
keep if has_12m_post_diag==1 & had_test_12m==1

preserve
gen urate_0 =1 if urate_below360_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_6m!=1 & urate_below360_12m==1
recode urate_1 .=0
gen urate_2 =1 if urate_below360_6m!=1 & urate_below360_12m!=1
recode urate_2 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1 (mean) urate_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "Not within 12 months")) title("Time to urate target attainment") name(regional_urate_overall_12m_test, replace)
graph export "$projectdir/output/figures/regional_urate_overall_12m_test.svg", replace
restore

*Urate attainment within 12m of diagnosis by region, merged; restricted to those that had a test was performed within that timeframe=========================================================================*

preserve
keep if diagnosis_year>=5 & diagnosis_year<=8 & diagnosis_year!=. //restrict to 2019-2021

gen urate_0 =1 if urate_below360_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_6m!=1 & urate_below360_12m==1
recode urate_1 .=0
gen urate_2 =1 if urate_below360_6m!=1 & urate_below360_12m!=1
recode urate_2 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1 (mean) urate_2, over(diagnosis_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "Not within 12 months")) title("Time to urate target attainment") name(regional_urate_merged_12m_test, replace)
graph export "$projectdir/output/figures/regional_urate_merged_12m_test.svg", width(12in) replace
restore

*Urate attainment within 12m of ULT by region, overall (all years); assuming ULT was within 6m of diagnosis, irrespective of whether a test was performed within that timeframe=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 12m follow-up and registration after ULT 
keep if ult_6m==1 & has_12m_post_ult==1

preserve
gen urate_0 =1 if urate_below360_ult_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_ult_6m!=1 & urate_below360_ult_12m==1
recode urate_1 .=0
gen urate_2 =1 if urate_below360_ult_6m!=1 & urate_below360_ult_12m!=1
recode urate_2 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1 (mean) urate_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "Not within 12 months")) title("Time to urate target attainment") name(regional_urate_overall_12m_ult, replace)
graph export "$projectdir/output/figures/regional_urate_overall_12m_ult.svg", replace
restore

*Urate attainment within 12m of ULT by region, merged; assuming ULT was within 6m of diagnosis, irrespective of whether a test was performed within that timeframe=========================================================================*

preserve
keep if ult_year>=5 & ult_year<=8 & ult_year!=. //restrict to 2019-2021. Note, this is year of first ULT, not year of diagnosis

gen urate_0 =1 if urate_below360_ult_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_ult_6m!=1 & urate_below360_ult_12m==1
recode urate_1 .=0
gen urate_2 =1 if urate_below360_ult_6m!=1 & urate_below360_ult_12m!=1
recode urate_2 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1 (mean) urate_2, over(ult_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "Not within 12 months")) title("Time to urate target attainment") name(regional_urate_merged_12m_ult, replace)
graph export "$projectdir/output/figures/regional_urate_merged_12m_ult.svg", width(12in) replace
restore

*Urate attainment within 12m of ULT by region, overall (all years); assuming ULT was within 6m of diagnosis, restricted to those that had a test was performed within that timeframe=========================================================================*

use "$projectdir/output/data/file_gout_all.dta", clear

**Restrict all analyses to patients with at least 12m follow-up and registration after ULT
keep if ult_6m==1 & has_12m_post_ult==1 & had_test_ult_12m==1

preserve
gen urate_0 =1 if urate_below360_ult_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_ult_6m!=1 & urate_below360_ult_12m==1
recode urate_1 .=0
gen urate_2 =1 if urate_below360_ult_6m!=1 & urate_below360_ult_12m!=1
recode urate_2 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1 (mean) urate_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "Not within 12 months")) title("Time to urate target attainment") name(reg_urate_overall_12m_ult_test, replace)
graph export "$projectdir/output/figures/reg_urate_overall_12m_ult_test.svg", replace
restore

*Urate attainment within 12m of ULT by region, merged; assuming ULT was within 6m of diagnosis, restricted to those that had a test was performed within that timeframe=========================================================================*

preserve
keep if ult_year>=5 & ult_year<=8 & ult_year!=. //restrict to 2019-2021. Note, this is year of first ULT, not year of diagnosis

gen urate_0 =1 if urate_below360_ult_6m==1
recode urate_0 .=0
gen urate_1 =1 if urate_below360_ult_6m!=1 & urate_below360_ult_12m==1
recode urate_1 .=0
gen urate_2 =1 if urate_below360_ult_6m!=1 & urate_below360_ult_12m!=1
recode urate_2 .=0

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) urate_0 (mean) urate_1 (mean) urate_2, over(ult_year, gap(20) label(labsize(*0.65))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 6 months" 2 "Within 12 months" 3 "Not within 12 months")) title("Time to urate target attainment") name(reg_urate_merged_12m_ult_test, replace)
graph export "$projectdir/output/figures/reg_urate_merged_12m_ult_test.svg", width(12in) replace
restore


log off