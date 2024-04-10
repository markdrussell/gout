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
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
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
collapse (sum) count_consults=gout_code prevalent_consults=prevalent_gout follow_up=has_6m_post_diag ult_ever_pre_consult=ult_ever_pre_consult ult_6m_pre_consult=ult_6m_pre_consult ult_any=ult_any no_ult=no_ult no_pre_ULT_has_6m=no_pre_ULT_has_6m ult_6m_diag=ult_6m_diag has_6m_post_ult=has_6m_post_ult had_baseline_urate=had_baseline_urate baseline_urate_below360=baseline_urate_below360 had_test_6m_fup=had_test_6m_fup urate_below360_6m_fup=urate_below360_6m_fup had_test_ult_6m_fup=had_test_ult_6m_fup urate_below360_ult_6m_fup=urate_below360_ult_6m_fup two_urate_ult_6m_fup=two_urate_ult_6m_fup, by(practice)

tabstat count_consults, stats(n mean sd median p25 p75) save //number of consults per practice for that year
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", replace
putexcel A1="Outcome" B1="Number practices" C1="Mean" D1="Standard Deviation" E1="Median" F1="25th Centile" G1="75th Centile" H1="Intraclass correlation" I1="Standard error of ICC"
putexcel A2="Number of consults"
putexcel B2=matrix(n)
putexcel C2=matrix(mean), nformat(0.000)
putexcel D2=matrix(sd), nformat(0.000)
putexcel E2=matrix(p50), nformat(0.000)
putexcel F2=matrix(p25), nformat(0.000)
putexcel G2=matrix(p75), nformat(0.000)
putexcel H3="Not required"
putexcel I3="Not required"

gen prop_prevalent_consults = prevalent_consults/count_consults //proportion of cases that were prevalent gout diagnoses
tabstat prop_prevalent_consults, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A3="Proportion of prevalent consults"
putexcel B3=matrix(n)
putexcel C3=matrix(mean), nformat(0.000)
putexcel D3=matrix(sd), nformat(0.000)
putexcel E3=matrix(p50), nformat(0.000)
putexcel F3=matrix(p25), nformat(0.000)
putexcel G3=matrix(p75), nformat(0.000)
putexcel H3="Not required"
putexcel I3="Not required"

gen prop_follow_up = follow_up/count_consults //proportion who had 6m+ follow-up post-diagnosis
tabstat prop_follow_up, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A4="Proportion with 6m+ follow-up"
putexcel B4=matrix(n)
putexcel C4=matrix(mean), nformat(0.000)
putexcel D4=matrix(sd), nformat(0.000)
putexcel E4=matrix(p50), nformat(0.000)
putexcel F4=matrix(p25), nformat(0.000)
putexcel G4=matrix(p75), nformat(0.000)
putexcel H4="Not required"
putexcel I4="Not required"

gen prop_ult_ever_pre_consult = ult_ever_pre_consult/count_consults //denominator is all cases of gout; proportion who had ever had a ULT prescription pre-consultation
tabstat prop_ult_ever_pre_consult, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A5="Ever prescribed ULT (all cases)"
putexcel B5=matrix(n)
putexcel C5=matrix(mean), nformat(0.000)
putexcel D5=matrix(sd), nformat(0.000)
putexcel E5=matrix(p50), nformat(0.000)
putexcel F5=matrix(p25), nformat(0.000)
putexcel G5=matrix(p75), nformat(0.000)
putexcel H5="Not required"
putexcel I5="Not required"

gen prop_ult_ever_pre_prev = ult_ever_pre_consult/prevalent_consults //denominator is those with prevalent gout only; proportion who had ever had a ULT prescription pre-consultation
tabstat prop_ult_ever_pre_prev, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A6="Ever prescribed ULT (prevalent cases)"
putexcel B6=matrix(n)
putexcel C6=matrix(mean), nformat(0.000)
putexcel D6=matrix(sd), nformat(0.000)
putexcel E6=matrix(p50), nformat(0.000)
putexcel F6=matrix(p25), nformat(0.000)
putexcel G6=matrix(p75), nformat(0.000)
putexcel H6="Not required"
putexcel I6="Not required"

gen prop_ult_6m_pre_consult = ult_6m_pre_consult/count_consults //denominator is all cases of gout; proportion who had a ULT prescription within 6m pre-consult
tabstat prop_ult_6m_pre_consult, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A7="Prescribed ULT in last 6m (all cases)"
putexcel B7=matrix(n)
putexcel C7=matrix(mean), nformat(0.000)
putexcel D7=matrix(sd), nformat(0.000)
putexcel E7=matrix(p50), nformat(0.000)
putexcel F7=matrix(p25), nformat(0.000)
putexcel G7=matrix(p75), nformat(0.000)
putexcel H7="Not required"
putexcel I7="Not required"

gen prop_ult_6m_pre_prev = ult_6m_pre_consult/prevalent_consults //denominator is those with prevalent gout only; proportion who had a ULT prescription within 6m pre-consult
tabstat prop_ult_6m_pre_prev, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A8="Prescribed ULT in last 6m (prevalent cases)"
putexcel B8=matrix(n)
putexcel C8=matrix(mean), nformat(0.000)
putexcel D8=matrix(sd), nformat(0.000)
putexcel E8=matrix(p50), nformat(0.000)
putexcel F8=matrix(p25), nformat(0.000)
putexcel G8=matrix(p75), nformat(0.000)
putexcel H8="Not required"
putexcel I8="Not required"

gen prop_no_pre_ULT_has_6m = no_pre_ULT_has_6m/count_consults //denominator is all counts for gout
tabstat prop_no_pre_ULT_has_6m, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A9="No ULT in last 6m (all cases)"
putexcel B9=matrix(n)
putexcel C9=matrix(mean), nformat(0.000)
putexcel D9=matrix(sd), nformat(0.000)
putexcel E9=matrix(p50), nformat(0.000)
putexcel F9=matrix(p25), nformat(0.000)
putexcel G9=matrix(p75), nformat(0.000)
putexcel H9="Not required"
putexcel I9="Not required"

gen prop_no_pre_ULT_6m_prev = no_pre_ULT_has_6m/prevalent_consults //denominator is those with prevalent gout only; looking at proportion who had ever had a ULT prescription pre-consult
tabstat prop_no_pre_ULT_6m_prev, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A10="No ULT in last 6m (prevalent cases)"
putexcel B10=matrix(n)
putexcel C10=matrix(mean), nformat(0.000)
putexcel D10=matrix(sd), nformat(0.000)
putexcel E10=matrix(p50), nformat(0.000)
putexcel F10=matrix(p25), nformat(0.000)
putexcel G10=matrix(p75), nformat(0.000)
putexcel H10="Not required"
putexcel I10="Not required"

**Primary outcome
gen prop_ult_6m_diag = ult_6m_diag/no_pre_ULT_has_6m //denominator are those who have 6m+ follow-up and who were not prescribed ULT in the 6m pre-consultation (includes both prevalent and incident gout); proportion who newly initiated ULT within 6m of consultation
tabstat prop_ult_6m_diag, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A11="ULT initiated within 6m (ULT naive)"
putexcel B11=matrix(n)
putexcel C11=matrix(mean), nformat(0.000)
putexcel D11=matrix(sd), nformat(0.000)
putexcel E11=matrix(p50), nformat(0.000)
putexcel F11=matrix(p25), nformat(0.000)
putexcel G11=matrix(p75), nformat(0.000)

***ICC
melogit prop_ult_6m_diag || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H11=matrix(icc), nformat(0.000)
putexcel I11=matrix(se), nformat(0.000)

gen prop_ult_any = ult_any/count_consults //denominator is all cases of gout, irrespective of follow-up; proportion who had a ULT prescription within 6 months before or after consultation
tabstat prop_ult_any, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A12="ULT before or after (all cases)"
putexcel B12=matrix(n)
putexcel C12=matrix(mean), nformat(0.000)
putexcel D12=matrix(sd), nformat(0.000)
putexcel E12=matrix(p50), nformat(0.000)
putexcel F12=matrix(p25), nformat(0.000)
putexcel G12=matrix(p75), nformat(0.000)

***ICC
melogit prop_ult_any || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H12=matrix(icc), nformat(0.000)
putexcel I12=matrix(se), nformat(0.000)

gen prop_no_ult = no_ult/count_consults //denominator is all cases of gout, irrespective of follow-up; proportion who had no ULT prescription in 6 months before or after consultation
tabstat prop_no_ult, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A13="No ULT before or after (all cases)"
putexcel B13=matrix(n)
putexcel C13=matrix(mean), nformat(0.000)
putexcel D13=matrix(sd), nformat(0.000)
putexcel E13=matrix(p50), nformat(0.000)
putexcel F13=matrix(p25), nformat(0.000)
putexcel G13=matrix(p75), nformat(0.000)

***ICC
melogit prop_no_ult || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H13=matrix(icc), nformat(0.000)
putexcel I13=matrix(se), nformat(0.000)

gen prop_baseline_urate = had_baseline_urate/count_consults //denominator is all cases of gout; proportion who had a urate level checked within 6 months before or after consultation, irrespective of ULT - could change this to e.g. 2 weeks after
tabstat prop_baseline_urate, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A14="Baseline urate within 6m (all cases)"
putexcel B14=matrix(n)
putexcel C14=matrix(mean), nformat(0.000)
putexcel D14=matrix(sd), nformat(0.000)
putexcel E14=matrix(p50), nformat(0.000)
putexcel F14=matrix(p25), nformat(0.000)
putexcel G14=matrix(p75), nformat(0.000)

***ICC
melogit prop_baseline_urate || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H14=matrix(icc), nformat(0.000)
putexcel I14=matrix(se), nformat(0.000)

gen prop_baseline_urate_360 = baseline_urate_below360/count_consults //denominator is all cases of gout, irrespective of test; proportion who had baseline serum urate <360 
tabstat prop_baseline_urate_360, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A15="Baseline urate <360 (all cases)"
putexcel B15=matrix(n)
putexcel C15=matrix(mean), nformat(0.000)
putexcel D15=matrix(sd), nformat(0.000)
putexcel E15=matrix(p50), nformat(0.000)
putexcel F15=matrix(p25), nformat(0.000)
putexcel G15=matrix(p75), nformat(0.000)

***ICC
melogit prop_baseline_urate_360 || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H15=matrix(icc), nformat(0.000)
putexcel I15=matrix(se), nformat(0.000)

gen prop_baseline_urate_360_test = baseline_urate_below360/had_baseline_urate //denominator is all cases of gout who had baseline test; proportion who had baseline serum urate <360 
tabstat prop_baseline_urate_360_test, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A16="Baseline urate <360 (with test)"
putexcel B16=matrix(n)
putexcel C16=matrix(mean), nformat(0.000)
putexcel D16=matrix(sd), nformat(0.000)
putexcel E16=matrix(p50), nformat(0.000)
putexcel F16=matrix(p25), nformat(0.000)
putexcel G16=matrix(p75), nformat(0.000)

melogit prop_baseline_urate_360_test || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H16=matrix(icc), nformat(0.000)
putexcel I16=matrix(se), nformat(0.000)

gen prop_had_test_6m_fup = had_test_6m_fup/follow_up //denominator are those who had 6m+ follow-up after consultation; proportion with a test performed within 6m after consultation
tabstat prop_had_test_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A17="Urate level in 6m after consult (follow-up)"
putexcel B17=matrix(n)
putexcel C17=matrix(mean), nformat(0.000)
putexcel D17=matrix(sd), nformat(0.000)
putexcel E17=matrix(p50), nformat(0.000)
putexcel F17=matrix(p25), nformat(0.000)
putexcel G17=matrix(p75), nformat(0.000)

melogit prop_had_test_6m_fup || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H17=matrix(icc), nformat(0.000)
putexcel I17=matrix(se), nformat(0.000)

gen prop_urate_360_6m_fup = urate_below360_6m_fup/follow_up //denominator are those who had 6m+ follow-up after consultation, irrespective of whether a test was performed; proportion who achieved urate<360 within 6m of consult
tabstat prop_urate_360_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A18="Urate <360 within 6m (all cases)"
putexcel B18=matrix(n)
putexcel C18=matrix(mean), nformat(0.000)
putexcel D18=matrix(sd), nformat(0.000)
putexcel E18=matrix(p50), nformat(0.000)
putexcel F18=matrix(p25), nformat(0.000)
putexcel G18=matrix(p75), nformat(0.000)

melogit prop_urate_360_6m_fup || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H18=matrix(icc), nformat(0.000)
putexcel I18=matrix(se), nformat(0.000)

gen prop_urate_360_6m_fup_test = urate_below360_6m_fup/had_test_6m_fup //denominator are those who had 6m+ follow-up after consultation and a least one test within 6m; proportion who achieved urate<360 within 6m of consult
tabstat prop_urate_360_6m_fup_test, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A19="Urate <360 within 6m (with test)"
putexcel B19=matrix(n)
putexcel C19=matrix(mean), nformat(0.000)
putexcel D19=matrix(sd), nformat(0.000)
putexcel E19=matrix(p50), nformat(0.000)
putexcel F19=matrix(p25), nformat(0.000)
putexcel G19=matrix(p75), nformat(0.000)

melogit prop_urate_360_6m_fup_test || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H19=matrix(icc), nformat(0.000)
putexcel I19=matrix(se), nformat(0.000)

gen prop_had_test_ult_6m_fup = had_test_ult_6m_fup/has_6m_post_ult //denominator are those who had new ULT within 6m of consultation and who had 6m+ follow-up post ULT; proportion who had test performed with 6m of starting ULT
tabstat prop_had_test_ult_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A20="Urate test within 6m of ULT (6m fup after ULT)"
putexcel B20=matrix(n)
putexcel C20=matrix(mean), nformat(0.000)
putexcel D20=matrix(sd), nformat(0.000)
putexcel E20=matrix(p50), nformat(0.000)
putexcel F20=matrix(p25), nformat(0.000)
putexcel G20=matrix(p75), nformat(0.000)

melogit prop_had_test_ult_6m_fup || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H20=matrix(icc), nformat(0.000)
putexcel I20=matrix(se), nformat(0.000)

gen prop_urate_360_ult_6m_fup = urate_below360_ult_6m_fup/has_6m_post_ult //denominator are those who had 6m+ follow-up post ULT, irrespective of whether test performed; proportion who achieved urate<360 within 6m of new ULT
tabstat prop_urate_360_ult_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A21="Urate <360 within 6m of ULT (all new ULT)"
putexcel B21=matrix(n)
putexcel C21=matrix(mean), nformat(0.000)
putexcel D21=matrix(sd), nformat(0.000)
putexcel E21=matrix(p50), nformat(0.000)
putexcel F21=matrix(p25), nformat(0.000)
putexcel G21=matrix(p75), nformat(0.000)

melogit prop_urate_360_ult_6m_fup || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H21=matrix(icc), nformat(0.000)
putexcel I21=matrix(se), nformat(0.000)

gen prop_urate_360_ult_6m_fup_test = urate_below360_ult_6m_fup/had_test_ult_6m_fup //denominator are those who had a test within within 6m of ULT and had had 6m+ follow-up post ULT; proportion who achieved urate<360 within 6m of new ULT
tabstat prop_urate_360_ult_6m_fup_test, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A22="Urate <360 within 6m of ULT (had test)"
putexcel B22=matrix(n)
putexcel C22=matrix(mean), nformat(0.000)
putexcel D22=matrix(sd), nformat(0.000)
putexcel E22=matrix(p50), nformat(0.000)
putexcel F22=matrix(p25), nformat(0.000)
putexcel G22=matrix(p75), nformat(0.000)

melogit prop_urate_360_ult_6m_fup_test || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H22=matrix(icc), nformat(0.000)
putexcel I22=matrix(se), nformat(0.000)

gen prop_two_urate_ult_6m_fup = two_urate_ult_6m_fup/has_6m_post_ult //denominator are those who had ULT within 6m of consultation and who had 6m+ follow-up post ULT; proportion who had 2+ urate levels check within 6m of new ULT
tabstat prop_two_urate_ult_6m_fup, stats(n mean sd median p25 p75) save
matrix table = r(StatTotal)'
matrix list table
matrix n = table[1,1]
matrix mean = table[1,2]
matrix sd = table[1,3]
matrix p50 = table[1,4]
matrix p25 = table[1,5]
matrix p75 = table[1,6]
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel A23="Two+ urate levels within 6m of ULT (all new ULT)"
putexcel B23=matrix(n)
putexcel C23=matrix(mean), nformat(0.000)
putexcel D23=matrix(sd), nformat(0.000)
putexcel E23=matrix(p50), nformat(0.000)
putexcel F23=matrix(p25), nformat(0.000)
putexcel G23=matrix(p75), nformat(0.000)

melogit prop_two_urate_ult_6m_fup || practice:
estat icc
matrix icc = r(icc2)
matrix se = r(se2)
putexcel set "$projectdir/output/tables/consults_averaged_`year'.xlsx", modify
putexcel H23=matrix(icc), nformat(0.000)
putexcel I23=matrix(se), nformat(0.000)

restore

import excel "$projectdir/output/tables/consults_averaged_`year'.xlsx", clear
outsheet * using "$projectdir/output/tables/consults_averaged_`year'.csv" , comma nonames replace	
}

log close