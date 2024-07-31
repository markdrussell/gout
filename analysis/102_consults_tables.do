version 16

/*==============================================================================
DO FILE NAME:			consults tables
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway												
DESCRIPTION OF FILE:	consults tables
DATASETS USED:			main data file
DATASETS CREATED: 		tables
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
log using "$logdir/consults_tables.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

set scheme plotplainblind

set type double

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

use "$projectdir/output/data/`out_file'.dta", replace

preserve
collapse (sum) count_consults=gout_code prevalent_consults=gout_prevalent follow_up=has_6m_post_diag ult_ever_pre_consult=ult_ever_pre_consult ult_6m_pre_consult=ult_6m_pre_consult ult_any=ult_any no_ult=no_ult no_pre_ULT_has_6m=no_pre_ULT_has_6m ult_6m_diag=ult_6m_diag has_6m_post_ult=has_6m_post_ult had_baseline_urate=had_baseline_urate baseline_urate_below360=baseline_urate_below360 had_test_6m_fup=had_test_6m_fup urate_below360_6m_fup=urate_below360_6m_fup had_test_ult_6m_fup=had_test_ult_6m_fup urate_below360_ult_6m_fup=urate_below360_ult_6m_fup two_urate_ult_6m_fup=two_urate_ult_6m_fup, by(practice)

tabstat count_consults, stats(n mean sd median p25 p75) save //number of consults per practice for that year
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", replace
putexcel A1="Variable" B1="Number practices" C1="Mean" D1="Standard Deviation" E1="Median" F1="25th Centile" G1="75th Centile" H1="Intraclass correlation" I1="Standard error of ICC"
putexcel A2="Number of consults"
putexcel B2=n
putexcel C2=mean
putexcel D2=sd
putexcel E2=p50
putexcel F2=p25
putexcel G2=p75
putexcel H2="Not required"
putexcel I2="Not required"
drop n mean sd p50 p25 p75

gen prop_prevalent_consults = prevalent_consults/count_consults //proportion of cases that were prevalent gout diagnoses
tabstat prop_prevalent_consults, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A3="Proportion of prevalent consults"
putexcel B3=n
putexcel C3=mean
putexcel D3=sd
putexcel E3=p50
putexcel F3=p25
putexcel G3=p75
putexcel H3="Not required"
putexcel I3="Not required"
drop n mean sd p50 p25 p75

gen prop_follow_up = follow_up/count_consults //proportion who had 6m+ follow-up post-diagnosis
tabstat prop_follow_up, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A4="Proportion with 6m+ follow-up"
putexcel B4=n
putexcel C4=mean
putexcel D4=sd
putexcel E4=p50
putexcel F4=p25
putexcel G4=p75
putexcel H4="Not required"
putexcel I4="Not required"
drop n mean sd p50 p25 p75

gen prop_ult_ever_pre_consult = ult_ever_pre_consult/count_consults //denominator is all cases of gout; proportion who had ever had a ULT prescription pre-consultation
tabstat prop_ult_ever_pre_consult, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A5="Ever prescribed ULT (all cases)"
putexcel B5=n
putexcel C5=mean
putexcel D5=sd
putexcel E5=p50
putexcel F5=p25
putexcel G5=p75
putexcel H5="Not required"
putexcel I5="Not required"
drop n mean sd p50 p25 p75

gen prop_ult_ever_pre_prev = ult_ever_pre_consult/prevalent_consults //denominator is those with prevalent gout only; proportion who had ever had a ULT prescription pre-consultation
tabstat prop_ult_ever_pre_prev, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A6="Ever prescribed ULT (prevalent cases)"
putexcel B6=n
putexcel C6=mean
putexcel D6=sd
putexcel E6=p50
putexcel F6=p25
putexcel G6=p75
putexcel H6="Not required"
putexcel I6="Not required"
drop n mean sd p50 p25 p75

gen prop_ult_6m_pre_consult = ult_6m_pre_consult/count_consults //denominator is all cases of gout; proportion who had a ULT prescription within 6m pre-consult
tabstat prop_ult_6m_pre_consult, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A7="Prescribed ULT in last 6m (all cases)"
putexcel B7=n
putexcel C7=mean
putexcel D7=sd
putexcel E7=p50
putexcel F7=p25
putexcel G7=p75
putexcel H7="Not required"
putexcel I7="Not required"
drop n mean sd p50 p25 p75

gen prop_ult_6m_pre_prev = ult_6m_pre_consult/prevalent_consults //denominator is those with prevalent gout only; proportion who had a ULT prescription within 6m pre-consult
tabstat prop_ult_6m_pre_prev, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A8="Prescribed ULT in last 6m (prevalent cases)"
putexcel B8=n
putexcel C8=mean
putexcel D8=sd
putexcel E8=p50
putexcel F8=p25
putexcel G8=p75
putexcel H8="Not required"
putexcel I8="Not required"
drop n mean sd p50 p25 p75

gen prop_no_pre_ULT_has_6m = no_pre_ULT_has_6m/count_consults //denominator is all counts for gout
tabstat prop_no_pre_ULT_has_6m, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A9="No ULT in last 6m (all cases)"
putexcel B9=n
putexcel C9=mean
putexcel D9=sd
putexcel E9=p50
putexcel F9=p25
putexcel G9=p75
putexcel H9="Not required"
putexcel I9="Not required"
drop n mean sd p50 p25 p75

putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A10="Key outcomes"

**Primary outcome
gen prop_ult_6m_diag = ult_6m_diag/no_pre_ULT_has_6m //denominator are those who have 6m+ follow-up and who were not prescribed ULT in the 6m pre-consultation (includes both prevalent and incident gout); proportion who newly initiated ULT within 6m of consultation
tabstat prop_ult_6m_diag, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A11="ULT initiated within 6m (ULT naive)"
putexcel B11=n
putexcel C11=mean
putexcel D11=sd
putexcel E11=p50
putexcel F11=p25
putexcel G11=p75
drop n mean sd p50 p25 p75

***ICC
melogit prop_ult_6m_diag || practice:
estat icc
gen icc_ = r(icc2)
gen se_ = r(se2)
tostring icc_, gen(icc) force format(%9.3f)
drop icc_
tostring se_, gen(se) force format(%9.3f)
drop se_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H11=icc
putexcel I11=se
drop icc se

gen prop_ult_any = ult_any/count_consults //denominator is all cases of gout, irrespective of follow-up; proportion who had a ULT prescription within 6 months before or after consultation
tabstat prop_ult_any, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A12="ULT before or after (all cases)"
putexcel B12=n
putexcel C12=mean
putexcel D12=sd
putexcel E12=p50
putexcel F12=p25
putexcel G12=p75
putexcel H12="Not required"
putexcel I12="Not required"
drop n mean sd p50 p25 p75

gen prop_no_ult = no_ult/count_consults //denominator is all cases of gout, irrespective of follow-up; proportion who had no ULT prescription in 6 months before or after consultation
tabstat prop_no_ult, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A13="No ULT before or after (all cases)"
putexcel B13=n
putexcel C13=mean
putexcel D13=sd
putexcel E13=p50
putexcel F13=p25
putexcel G13=p75
putexcel H13="Not required"
putexcel I13="Not required"
drop n mean sd p50 p25 p75

gen prop_baseline_urate = had_baseline_urate/count_consults //denominator is all cases of gout; proportion who had a urate level checked within 6 months before or after consultation, irrespective of ULT - could change this to e.g. 2 weeks after
tabstat prop_baseline_urate, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A14="Baseline urate within 6m (all cases)"
putexcel B14=n
putexcel C14=mean
putexcel D14=sd
putexcel E14=p50
putexcel F14=p25
putexcel G14=p75
putexcel H14="Not required"
putexcel I14="Not required"
drop n mean sd p50 p25 p75

gen prop_baseline_urate_360 = baseline_urate_below360/count_consults //denominator is all cases of gout, irrespective of test; proportion who had baseline serum urate <360 
tabstat prop_baseline_urate_360, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A15="Baseline urate <360 (all cases)"
putexcel B15=n
putexcel C15=mean
putexcel D15=sd
putexcel E15=p50
putexcel F15=p25
putexcel G15=p75
putexcel H15="Not required"
putexcel I15="Not required"
drop n mean sd p50 p25 p75

gen prop_baseline_urate_360_test = baseline_urate_below360/had_baseline_urate //denominator is all cases of gout who had baseline test; proportion who had baseline serum urate <360 
tabstat prop_baseline_urate_360_test, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A16="Baseline urate <360 (with test)"
putexcel B16=n
putexcel C16=mean
putexcel D16=sd
putexcel E16=p50
putexcel F16=p25
putexcel G16=p75
putexcel H16="Not required"
putexcel I16="Not required"
drop n mean sd p50 p25 p75

gen prop_had_test_6m_fup = had_test_6m_fup/follow_up //denominator are those who had 6m+ follow-up after consultation; proportion with a test performed within 6m after consultation
tabstat prop_had_test_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A17="Urate level in 6m after consult (follow-up)"
putexcel B17=n
putexcel C17=mean
putexcel D17=sd
putexcel E17=p50
putexcel F17=p25
putexcel G17=p75
putexcel H17="Not required"
putexcel I17="Not required"
drop n mean sd p50 p25 p75

gen prop_urate_360_6m_fup = urate_below360_6m_fup/follow_up //denominator are those who had 6m+ follow-up after consultation, irrespective of whether a test was performed; proportion who achieved urate<360 within 6m of consult
tabstat prop_urate_360_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A18="Urate <360 within 6m (all cases)"
putexcel B18=n
putexcel C18=mean
putexcel D18=sd
putexcel E18=p50
putexcel F18=p25
putexcel G18=p75
putexcel H18="Not required"
putexcel I18="Not required"
drop n mean sd p50 p25 p75

gen prop_urate_360_6m_fup_test = urate_below360_6m_fup/had_test_6m_fup //denominator are those who had 6m+ follow-up after consultation and a least one test within 6m; proportion who achieved urate<360 within 6m of consult
tabstat prop_urate_360_6m_fup_test, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A19="Urate <360 within 6m (with test)"
putexcel B19=n
putexcel C19=mean
putexcel D19=sd
putexcel E19=p50
putexcel F19=p25
putexcel G19=p75
putexcel H19="Not required"
putexcel I19="Not required"
drop n mean sd p50 p25 p75

gen prop_had_test_ult_6m_fup = had_test_ult_6m_fup/has_6m_post_ult //denominator are those who had new ULT within 6m of consultation and who had 6m+ follow-up post ULT; proportion who had test performed with 6m of starting ULT
tabstat prop_had_test_ult_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A20="Urate test within 6m of ULT (6m fup after ULT)"
putexcel B20=n
putexcel C20=mean
putexcel D20=sd
putexcel E20=p50
putexcel F20=p25
putexcel G20=p75
putexcel H20="Not required"
putexcel I20="Not required"
drop n mean sd p50 p25 p75

gen prop_urate_360_ult_6m_fup = urate_below360_ult_6m_fup/has_6m_post_ult //denominator are those who had 6m+ follow-up post ULT, irrespective of whether test performed; proportion who achieved urate<360 within 6m of new ULT
tabstat prop_urate_360_ult_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A21="Urate <360 within 6m of ULT (all new ULT)"
putexcel B21=n
putexcel C21=mean
putexcel D21=sd
putexcel E21=p50
putexcel F21=p25
putexcel G21=p75
putexcel H21="Not required"
putexcel I21="Not required"
drop n mean sd p50 p25 p75

gen prop_urate_360_ult_6m_fup_test = urate_below360_ult_6m_fup/had_test_ult_6m_fup //denominator are those who had a test within within 6m of ULT and had had 6m+ follow-up post ULT; proportion who achieved urate<360 within 6m of new ULT
tabstat prop_urate_360_ult_6m_fup_test, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A22="Urate <360 within 6m of ULT (had test)"
putexcel B22=n
putexcel C22=mean
putexcel D22=sd
putexcel E22=p50
putexcel F22=p25
putexcel G22=p75
putexcel H22="Not required"
putexcel I22="Not required"
drop n mean sd p50 p25 p75

gen prop_two_urate_ult_6m_fup = two_urate_ult_6m_fup/has_6m_post_ult //denominator are those who had ULT within 6m of consultation and who had 6m+ follow-up post ULT; proportion who had 2+ urate levels check within 6m of new ULT
tabstat prop_two_urate_ult_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
gen n_ = round(table[1,1], 5) //round practices to nearest 5
tostring n_, gen(n) force format(%9.0f)
drop n_
gen mean_ = table[1,2]
tostring mean_, gen(mean) force format(%9.3f)
drop mean_
gen sd_ = table[1,3]
tostring sd_, gen(sd) force format(%9.3f)
drop sd_
gen p50_ = table[1,4]
tostring p50_, gen(p50) force format(%9.3f)
drop p50_
gen p25_ = table[1,5]
tostring p25_, gen(p25) force format(%9.3f)
drop p25_
gen p75_ = table[1,6]
tostring p75_, gen(p75) force format(%9.3f)
drop p75_
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A23="Two+ urate levels within 6m of ULT (all new ULT)"
putexcel B23=n
putexcel C23=mean
putexcel D23=sd
putexcel E23=p50
putexcel F23=p25
putexcel G23=p75
putexcel H23="Not required"
putexcel I23="Not required"
drop n mean sd p50 p25 p75

restore

import excel "$projectdir/output/tables/consults_averaged_`year'.xlsx", clear
outsheet * using "$projectdir/output/tables/consults_averaged_`year'.csv" , comma nonames replace	
}

log close