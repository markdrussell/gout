version 16

/*==============================================================================
DO FILE NAME:			define covariates consults
PROJECT:				Gout OpenSAFELY project
DATE: 					27/02/2024
AUTHOR:					M Russell / J Galloway			
DESCRIPTION OF FILE:	data management for Gout project  
						reformat variables 
						categorise variables
						label variables 
DATASETS USED:			data in memory (from output/input_consults.csv)
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

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Open a log file
cap log close
log using "$logdir/cleaning_dataset_consults_year.log", replace


****Loop for each year of data===============================================*/
cd "$projectdir/output/measures"
fs *input_consults_year_*.csv.gz

foreach f in `r(files)' {
	
	local file_name = "`f'"
	local name_len = length("`file_name'")
	local out_file = substr("`file_name'",1,(`name_len'-7)) //gets rid of original file suffix
	di "`out_file'"
	local index_date = substr("`file_name'",-17,10) //keeps date
	di "`index_date'"
	
	*Set index dates
	global start_date = date("`index_date'", "YMD")
	di $start_date
	global end_date = $start_date + 365
	di $end_date
	global follow_up = $start_date + 365 + 182
	di $follow_up
	global year_preceding = $start_date - 365
	di $year_preceding
	
	*Import data
	!gunzip "$projectdir/output/measures/`out_file'.csv.gz"
	import delimited "$projectdir/output/measures/`out_file'.csv", clear

**Rename variables =======================================*/

foreach var of varlist 	 urate_test_?						///
						 {
			rename `var' `var'_val
			order `var'_val, after(`var'_date)
		}

foreach var of varlist   died_date_ons						///
						 {
			rename `var' `var'_date
		} 
		
**Change date format and create binary indicator variables for relevant conditions ====================================================*/

foreach var of varlist 	 gout_code_date						///
						 gout_prevalent_date				///
						 first_ult_date						///
						 recent_ult_date					///
						 died_date_ons						///
						 urate_test_?_date					///
						 {		
						 	
	/*date ranges are applied in python, so presence of date indicates presence of 
	  disease in the correct time frame*/ 
	  
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

**For repeated measures, change number to end of variable number (for reshaping)
		
forval i = 1/7 	{
					rename urate_test_`i'_date urate_date_`i'
					order urate_test_`i', after(urate_date_`i')
					rename urate_test_`i'_val urate_val_`i'
}
					
**Create and label variables ===========================================================*/

**Demographics
***Sex
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"
lab var male "Male"
lab define male 0 "No" 1 "Yes", modify
lab val male male
tab male, missing

***STP 
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp) //
drop stp_old

***Regions
encode region, gen(nuts_region)
tab region, missing
replace region="Not known" if region==""
gen region_nospace=region
replace region_nospace="SouthWest" if region=="South West"
replace region_nospace="EastMidlands" if region=="East Midlands"
replace region_nospace="East" if region=="East"
replace region_nospace="London" if region=="London"
replace region_nospace="NorthEast" if region=="North East"
replace region_nospace="NorthWest" if region=="North West"
replace region_nospace="SouthEast" if region=="South East"
replace region_nospace="WestMidlands" if region=="West Midlands"
replace region_nospace="YorkshireandTheHumber" if region=="Yorkshire and The Humber"
drop region

***Age variables
*Nb. works if ages 18 and over
*Create categorised age
drop if age<18 & age !=.
drop if age>109 & age !=.
drop if age==.
lab var age "Age"

recode age 18/39.9999 = 1 /// 
           40/49.9999 = 2 ///
		   50/59.9999 = 3 ///
	       60/69.9999 = 4 ///
		   70/79.9999 = 5 ///
		   80/max = 6, gen(agegroup) 

label define agegroup 	1 "18-39" ///
						2 "40-49" ///
						3 "50-59" ///
						4 "60-69" ///
						5 "70-79" ///
						6 "80+"
						
label values agegroup agegroup
lab var agegroup "Age group"
tab agegroup, missing

*Ensure everyone has gout consultation=============================================================*/
tab gout_code, missing
keep if gout_code==1

**Check date range of gout consultations is within study window
codebook gout_code_date

**Check most common codes
tab gout_snomed

*Prevalent gout_admission if first gout code was before study start date
gen prevalent_gout=1 if gout_prevalent_date<$start_date & gout_prevalent_date!=.
recode prevalent_gout .=0

*Patients with 6m+ follow-up after consultation==============================*/

**Check proportion of patients with at least 6 months of registration after diagnosis - should be all
tab has_6m_follow_up, missing

**Create variable whereby patients have at least 6 months of registration and follow-up time after diagnosis - should be all
gen has_6m_post_diag=1 if gout_code_date!=. & gout_code_date<($follow_up-182) & has_6m_follow_up==1
recode has_6m_post_diag .=0
lab var has_6m_post_diag ">6m follow-up"
lab define has_6m_post_diag 0 "No" 1 "Yes", modify
lab val has_6m_post_diag has_6m_post_diag
tab has_6m_post_diag, missing 

*ULT prescriptions=================================================================*/

*Patients who had ever received ULT prior to consultation (not necessary on it at the time of consultation) - less relevant
gen ult_ever_pre_consult=1 if first_ult_date!=. & first_ult_date<gout_code_date
recode ult_ever_pre_consult .=0
tab ult_ever_pre_consult

*Patients who had received ULT prescription in 6m prior to consultation
gen ult_6m_pre_consult=1 if recent_ult_date!=. & recent_ult_date<gout_code_date & recent_ult_date>(gout_code_date-182)
recode ult_6m_pre_consult .=0
tab ult_6m_pre_consult

*Patients who had not been prescribed ULT in 6m before consultation who were prescribed ULT in 6m after consultation
gen ult_post_consult=1 if recent_ult_date!=. & recent_ult_date>=gout_code_date
recode ult_post_consult .=0
tab ult_post_consult

*Patients on ULT before or after consultation
gen ult_any=1 if ult_6m_pre_consult==1 | ult_post_consult==1
recode ult_any .=0
tab ult_any

*Patients on no ULT before or after consultation
gen no_ult=1 if ult_6m_pre_consult!=1 & ult_post_consult!=1
recode no_ult .=0
tab no_ult

**Generate demoninator for individuals who were not prescribed ULT in 6m before consultation and who had 6m+ follow-up after their consult
gen no_pre_ULT_has_6m=1 if has_6m_post_diag==1 & ult_6m_pre_consult!=1
recode no_pre_ULT_has_6m .=0
tab no_pre_ULT_has_6m

**Generate variable for time to first ULT prescription (if started after consultation)
gen time_to_ult = (recent_ult_date-gout_code_date) if recent_ult_date!=. & gout_code_date!=. & (recent_ult_date>=gout_code_date)
tabstat time_to_ult, stats(n mean sd median p25 p75)

**Generate variable for time to first ULT prescription, limited to 6m post-consultation - should be the same as above
gen time_to_ult_6m=(recent_ult_date-gout_code_date) if recent_ult_date!=. & gout_code_date!=. & (recent_ult_date>=gout_code_date) & (recent_ult_date<gout_code_date+182)
tabstat time_to_ult_6m, stats(n mean sd median p25 p75)

**Generate variable for those who had ULT prescription within 6m of diagnosis, who were not already on ULT and who have 6m+ follow-up post consultation
gen ult_6m_diag = 1 if time_to_ult_6m<=182 & time_to_ult_6m!=. & has_6m_post_diag==1 
recode ult_6m_diag .=0 if ult_6m_pre_consult!=1 //leaves missing for those who were on ULT pre-consultation
lab var ult_6m_diag "ULT initiated within 6 months of diagnosis"
lab define ult_6m_diag 0 "No" 1 "Yes", modify
lab val ult_6m_diag ult_6m_diag
tab ult_6m_diag, missing

*Proportion of patients with >6m of registration and follow-up after first ULT prescription, assuming first prescription was within 6m of diagnosis
gen has_6m_post_ult=1 if ult_6m_diag==1 & has_6m_follow_up_ult==1 & recent_ult_date!=. & recent_ult_date<($follow_up-182) 
recode has_6m_post_ult .=0
lab var has_6m_post_ult ">6m follow-up after ULT commenced"
lab define has_6m_post_ult 0 "No" 1 "Yes", modify
lab val has_6m_post_ult has_6m_post_ult

*Serum urate measurements==================================================*/

*Set implausible urate values to missing (Note: zero changed to missing) and remove urate dates if no measurements, and vice versa 
**Depending on code, urate is in range 0.05 - 2 (mmol/L) or 50 - 2000 (micromol/L). Need also to consider mg/dL
forval i = 1/7 	{
						codebook urate_val_`i' 
						summ urate_val_`i' if inrange(urate_val_`i', 0.05, 2) // for mmol/L
						summ urate_val_`i' if inrange(urate_val_`i', 50, 2000) // for micromol/L
						summ urate_val_`i' if urate_val_`i'==. | urate_val_`i'==0 // missing or zero
						summ urate_val_`i' if ((!inrange(urate_val_`i', 0.05, 2)) & (!inrange(urate_val_`i', 50, 2000)) & urate_val_`i'!=. & urate_val_`i'!=0) // not missing or zero or in above ranges	
						replace urate_val_`i' = . if ((!inrange(urate_val_`i', 0.05, 2)) & (!inrange(urate_val_`i', 50, 2000))) // keep values that are mmol/L or micromol/L	
						codebook urate_val_`i'
						replace urate_val_`i' = . if urate_date_`i' == . 
						replace urate_date_`i' = . if urate_val_`i' == . 
						codebook urate_val_`i'
						replace urate_test_`i' = . if urate_val_`i' == .
						recode urate_test_`i' .=0
						tab urate_test_`i', missing
						replace urate_val_`i' = (urate_val_`i'*1000) if inrange(urate_val_`i', 0.05, 2) //*1000 for those that are in mmol/L
						codebook urate_val_`i'
}

reshape long urate_val_ urate_date_ urate_test_, i(patient_id) j(urate_order)

*Define baseline serum urate level as urate level closest to consultation date (must be within 6m before/after diagnosis), irrespective of ULT (as outcome is urate attainment, irrespective of ULT)
bys patient_id urate_date_ (urate_val_): gen n=_n //keeps only single urate test from same day (i.e. delete duplicates), priotising ones !=.
drop if n>1 
drop n

gen time_to_test = urate_date_-gout_code_date if urate_date_!=. & gout_code_date!=. //time to urate test from consultation date

gen test_after_ult=1 if urate_date_>recent_ult_date & urate_date_!=. & recent_ult_date!=.
replace test_after_ult=0 if urate_date_<=recent_ult_date & urate_date_!=.

gen abs_time_to_test = abs(time_to_test) if time_to_test!=. & time_to_test<=182 & time_to_test>=-182 & urate_val_!=. //within 6 months before/after consultation
bys patient_id (abs_time_to_test): gen n=_n 
gen baseline_urate=urate_val_ if n==1 & abs_time_to_test!=. 
lab var baseline_urate "Serum urate at baseline"
gen had_baseline_urate = 1 if baseline_urate!=.
lab var had_baseline_urate "Had serum urate performed at baseline"
lab define had_baseline_urate 0 "No" 1 "Yes", modify
lab val had_baseline_urate had_baseline_urate
drop n
by patient_id: replace baseline_urate = baseline_urate[_n-1] if missing(baseline_urate)
by patient_id: replace had_baseline_urate = had_baseline_urate[_n-1] if missing(had_baseline_urate)
recode had_baseline_urate .=0
gen baseline_urate_below360=1 if baseline_urate<=360 & baseline_urate!=.
lab var baseline_urate_below360 "Baseline serum urate <360 micromol/L"
lab define baseline_urate_below360 0 "No" 1 "Yes", modify
lab val baseline_urate_below360 baseline_urate_below360
replace baseline_urate_below360=0 if baseline_urate>360 & baseline_urate!=.
drop abs_time_to_test

*Define proportion of patients who attained serum urate <360 within 6 months of consultation (had to be >7 days after consult, to ensure this was a follow-up test), irrespective of ULT
gen had_test_6m = 1 if (time_to_test>7 & time_to_test<=182) & urate_val_!=. //any test done within 6 months of diagnosis
bys patient_id (had_test_6m): gen n=_n if had_test_6m!=.
by patient_id: egen count_urate_6m = max(n) //number of tests within 6m
recode count_urate_6m .=0 //includes those who didn't receive ULT
lab var count_urate_6m "Number of urate levels within 6m of diagnosis"
drop n
sort patient_id had_test_6m
by patient_id: replace had_test_6m = had_test_6m[_n-1] if missing(had_test_6m) //any test done within 6 months of diagnosis
recode had_test_6m .=0 //includes those who didn't receive ULT
lab var had_test_6m "Urate test performed within 6 months of diagnosis"
lab def had_test_6m 0 "No" 1 "Yes", modify
lab val had_test_6m had_test_6m
gen had_test_6m_fup=1 if had_test_6m==1 & has_6m_post_diag==1
recode had_test_6m_fup .=0 
lab var had_test_6m_fup "Urate test performed within 6 months of diagnosis (6m+ follow-up)"
lab def had_test_6m_fup 0 "No" 1 "Yes", modify
lab val had_test_6m_fup had_test_6m_fup
gen value_test_6m = urate_val_ if (time_to_test>7 & time_to_test<=182) & urate_val_!=. //test values within 6 months of diagnosis
bys patient_id (value_test_6m): gen n=_n if value_test_6m!=.
gen lowest_urate_6m = value_test_6m if n==1 //lowest urate value within 6m of diagnosis
lab var lowest_urate_6m "Lowest urate value within 6m of diagnosis"
sort patient_id (lowest_urate_6m)
by patient_id: replace lowest_urate_6m = lowest_urate_6m[_n-1] if missing(lowest_urate_6m)
drop n value_test_6m
gen urate_below360_6m = 1 if lowest_urate_6m<=360 & lowest_urate_6m!=.
lab var urate_below360_6m  "Urate <360 micromol/L within 6m of diagnosis"
lab def urate_below360_6m 0 "No" 1 "Yes", modify
lab val urate_below360_6m urate_below360_6m
recode urate_below360_6m .=0 //includes those who didn't have a test within 6m
gen urate_below360_6m_fup = 1 if urate_below360_6m==1 & has_6m_post_diag==1
lab var urate_below360_6m_fup  "Urate <360 micromol/L within 6m of diagnosis (6m+ follow-up)"
lab def urate_below360_6m_fup 0 "No" 1 "Yes", modify
lab val urate_below360_6m_fup urate_below360_6m_fup
recode urate_below360_6m_fup .=0 //includes those who didn't have a test within 6m

drop time_to_test

*Define proportion of patients commenced on ULT within 6 months of diagnosis who attained serum urate <360 within 6 months of ULT commencement (had to be >7 days after ULT initiation), assuming ULT was initiated after consultation date 
gen time_to_test_ult_6m = urate_date_- recent_ult_date if urate_date_!=. & recent_ult_date!=. & test_after_ult==1 & ((recent_ult_date>=gout_code_date) & (recent_ult_date<(gout_code_date+182)))
gen had_test_ult_6m = 1 if (time_to_test_ult_6m>7 & time_to_test_ult_6m<=182) & time_to_test_ult_6m!=. & urate_val_!=. //any test done within 6 months of ULT
bys patient_id (had_test_ult_6m): gen n=_n if had_test_ult_6m!=.
by patient_id: egen count_urate_ult_6m = max(n) //number of tests within 6m of ULT
recode count_urate_ult_6m .=0 //includes those who didn't receive ULT
lab var count_urate_ult_6m "Number of urate levels within 6m of ULT initiation"
drop n
sort patient_id had_test_ult_6m
by patient_id: replace had_test_ult_6m = had_test_ult_6m[_n-1] if missing(had_test_ult_6m) //any test done within 6 months of ULT
recode had_test_ult_6m .=0 //includes those who didn't receive ULT
lab var had_test_ult_6m "Urate test performed within 6 months of ULT"
lab def had_test_ult_6m 0 "No" 1 "Yes", modify
lab val had_test_ult_6m had_test_ult_6m
tab had_test_ult_6m if has_6m_post_ult==1
gen had_test_ult_6m_fup = 1 if had_test_ult_6m==1 & has_6m_post_ult==1
recode had_test_ult_6m_fup .=0
lab var had_test_ult_6m_fup "Urate test performed within 6 months of ULT if >6m of follow-up"
lab def had_test_ult_6m_fup 0 "No" 1 "Yes", modify
lab val had_test_ult_6m_fup had_test_ult_6m_fup
tab had_test_ult_6m_fup, missing

gen value_test_ult_6m = urate_val_ if (time_to_test_ult_6m>7 & time_to_test_ult_6m<=182) & time_to_test_ult_6m!=. & urate_val_!=. //test values within 6 months of ULT
bys patient_id (value_test_ult_6m): gen n=_n if value_test_ult_6m!=.
gen lowest_urate_ult_6m = value_test_ult_6m if n==1 //lowest urate value within 6m of ULT
lab var lowest_urate_ult_6m "Lowest urate value within 6m of ULT initiation"
sort patient_id (lowest_urate_ult_6m)
by patient_id: replace lowest_urate_ult_6m = lowest_urate_ult_6m[_n-1] if missing(lowest_urate_ult_6m)
drop n value_test_ult_6m
gen urate_below360_ult_6m = 1 if lowest_urate_ult_6m<=360 & lowest_urate_ult_6m!=.
lab var urate_below360_ult_6m  "Urate <360 micromol/L within 6m of ULT initiation"
lab def urate_below360_ult_6m 0 "No" 1 "Yes", modify
lab val urate_below360_ult_6m urate_below360_ult_6m
recode urate_below360_ult_6m .=0 //includes those who didn't receive ULT or didn't have a test within 6m
drop time_to_test_ult_6m
gen urate_below360_ult_6m_fup=1 if urate_below360_ult_6m==1 & has_6m_post_ult==1
recode urate_below360_ult_6m_fup .=0
lab var urate_below360_ult_6m_fup  "Urate <360 micromol/L within 6m of ULT initiation (6m+ follow-up)"
lab def urate_below360_ult_6m_fup 0 "No" 1 "Yes", modify
lab val urate_below360_ult_6m_fup urate_below360_ult_6m_fup

drop test_after_ult		
reshape wide urate_val_ urate_date_ urate_test_, i(patient_id) j(urate_order)

tabstat baseline_urate, stats(n mean p50 p25 p75)
tab baseline_urate_below360, missing

tabstat lowest_urate_ult_6m, stats(n mean p50 p25 p75)
tab urate_below360_ult_6m if has_6m_post_ult==1, missing //for those who received ULT within 6m and had >6m of follow-up
tab urate_below360_ult_6m if has_6m_post_ult==1 & had_test_ult_6m==1, missing //for those who received ULT within 6m, had >6m of follow-up, and had a test performed within 6m of ULT
tabstat count_urate_ult_6m if has_6m_post_ult==1, stats(n mean p50 p25 p75) //number of tests performed within 6m of ULT initiation
gen two_urate_ult_6m=1 if count_urate_ult_6m>=2 & count_urate_ult_6m!=. //two or more urate tests performed within 6m of ULT initiation
recode two_urate_ult_6m .=0 //includes those who didn't receive ULT
lab var two_urate_ult_6m "At least 2 urate tests performed within 6 months of ULT initiation"
lab def two_urate_ult_6m 0 "No" 1 "Yes", modify
lab val two_urate_ult_6m two_urate_ult_6m
tab two_urate_ult_6m if has_6m_post_ult==1, missing 
gen two_urate_ult_6m_fup=1 if two_urate_ult_6m==1 & has_6m_post_ult==1
recode two_urate_ult_6m_fup .=0 
lab var two_urate_ult_6m_fup "At least 2 urate tests performed within 6 months of ULT initiation if >6m of follow-up"
lab def two_urate_ult_6m_fup 0 "No" 1 "Yes", modify
lab val two_urate_ult_6m_fup two_urate_ult_6m_fup
tab two_urate_ult_6m_fup, missing 

*Number of practices who had a least one gout consultations within study window==============================*/
preserve
collapse (count) count_consults=gout_code (sum) prevalent_consults=prevalent_gout follow_up=has_6m_post_diag ult_ever_pre_consult=ult_ever_pre_consult ult_6m_pre_consult=ult_6m_pre_consult ult_post_consult=ult_post_consult ult_any=ult_any no_ult=no_ult no_pre_ULT_has_6m=no_pre_ULT_has_6m ult_6m_diag=ult_6m_diag has_6m_post_ult=has_6m_post_ult had_baseline_urate=had_baseline_urate baseline_urate_below360=baseline_urate_below360 had_test_6m=had_test_6m had_test_6m_fup=had_test_6m_fup urate_below360_6m=urate_below360_6m urate_below360_6m_fup=urate_below360_6m_fup had_test_ult_6m=had_test_ult_6m had_test_ult_6m_fup=had_test_ult_6m_fup urate_below360_ult_6m=urate_below360_ult_6m urate_below360_ult_6m_fup=urate_below360_ult_6m_fup two_urate_ult_6m=two_urate_ult_6m two_urate_ult_6m_fup=two_urate_ult_6m_fup (mean) mean_ult_time=time_to_ult (sd) sd_ult_time=time_to_ult (mean) mean_ult_time_6m=time_to_ult_6m (sd) sd_ult_time_6m=time_to_ult_6m, by(practice)

tabstat count_consults, stats(n mean sd median p25 p75)

foreach var of varlist prevalent_consults follow_up ult_ever_pre_consult ult_6m_pre_consult ult_any no_ult no_pre_ULT_has_6m had_baseline_urate {
gen prop_`var'=`var'/count_consults
tabstat prop_`var', stats(n mean sd median p25 p75)
}

gen prop_no_pre_ult_prev=1 if no_pre_ULT_has_6m/prevalent_consults //denominator is those with prevalent gout only - more relevant; looking at proportion who were not on ULT pre-consult
tabstat prop_no_pre_ult_prev, stats(n mean sd median p25 p75)

gen prop_ult_6m_pre_prev=1 if ult_6m_pre_consult/prevalent_consults //denominator is those with prevalent gout only; looking at proportion who were on ULT pre-consult
tabstat prop_ult_6m_pre_prev, stats(n mean sd median p25 p75) 

gen prop_ult_ever_pre_prev=1 if ult_ever_pre_consult/prevalent_consults //denominator is those with prevalent gout only; looking at proportion who had ever had a ULT prescription pre-consult
tabstat prop_ult_ever_pre_prev, stats(n mean sd median p25 p75) 

**Primary outcome
gen prop_ult_6m_diag = ult_6m_diag/no_pre_ULT_has_6m //denominator are those who have 6m+ follow-up and who were not prescribed ULT in the 6m pre-consultation (includes both prevalent and incident gout)
tabstat prop_ult_6m_diag, stats(n mean sd median p25 p75)

***ICC for primary outcome
melogit prop_ult_6m_diag || practice:
estat icc

**Secondary outcomes
gen prop_baseline_urate_below360 = baseline_urate_below360/had_baseline_urate //denominator are those who had a baseline serum urate (between 6m before/after, irrespective of ULT)
tabstat prop_baseline_urate_below360, stats(n mean sd median p25 p75)

gen prop_had_test_6m = had_test_6m/follow_up //denominator are those who had 6m+ follow-up after consultation
tabstat prop_had_test_6m, stats(n mean sd median p25 p75)

gen prop_urate_below360_6m = urate_below360_6m/had_test_6m //denominator are those who had at least one test within 6m of consultation, irrespective of follow-up duration
tabstat prop_urate_below360_6m, stats(n mean sd median p25 p75)

gen prop_urate_below360_6m_fup = urate_below360_6m_fup/had_test_6m_fup //denominator are those who had 6m+ follow-up after consultation and a least one test within 6m
tabstat prop_urate_below360_6m_fup, stats(n mean sd median p25 p75)

gen prop_had_test_ult_6m = had_test_ult_6m/ult_6m_diag //denominator are those who had ULT within 6m of consultation and who had 6m+ follow-up post consultation
tabstat prop_had_test_ult_6m, stats(n mean sd median p25 p75)

gen prop_had_test_ult_6m_fup = had_test_ult_6m_fup/has_6m_post_ult //denominator are those who had ULT within 6m of consultation and who had 6m+ follow-up post ULT
tabstat prop_had_test_ult_6m_fup, stats(n mean sd median p25 p75)

gen prop_urate_below360_ult_6m = urate_below360_ult_6m/had_test_ult_6m //denominator are those who had a test within within 6m of ULT
tabstat prop_urate_below360_ult_6m, stats(n mean sd median p25 p75)

gen prop_urate_below360_ult_6m_fup = urate_below360_ult_6m_fup/had_test_ult_6m_fup //denominator are those who had a test within within 6m of ULT and had had 6m+ follow-up post ULT
tabstat prop_urate_below360_ult_6m_fup, stats(n mean sd median p25 p75)

gen prop_two_urate_ult_6m = two_urate_ult_6m/ult_6m_diag //denominator are those who had ULT within 6m of consultation and who had 6m+ follow-up post consultation
tabstat prop_two_urate_ult_6m, stats(n mean sd median p25 p75)

gen prop_two_urate_ult_6m_fup = two_urate_ult_6m_fup/has_6m_post_ult //denominator are those who had ULT within 6m of consultation and who had 6m+ follow-up post ULT
tabstat prop_two_urate_ult_6m_fup, stats(n mean sd median p25 p75)


tabstat mean_ult_time, stats(n mean sd median p25 p75) //doesn't account for those practices/patients who didn't start ULT - presumably this would need individual level data
tabstat mean_ult_time_6m, stats(n mean sd median p25 p75) //doesn't account for those practices/patients who didn't start ULT - presumably this would need individual level data

restore

/*
Check if first ULT prescription was before index diagnosis code 
tab first_ult if gout_code_date!=. & first_ult_date!=. & first_ult_date<gout_code_date
tab first_ult if gout_code_date!=. & first_ult_date!=. & (first_ult_date+30)<gout_code_date //30 days before
tab first_ult if gout_code_date!=. & first_ult_date!=. & (first_ult_date+60)<gout_code_date //60 days before
drop if gout_code_date!=. & first_ult_date!=. & (first_ult_date+30)<gout_code_date //drop if first ULT script more than 30 days before first gout code - think about what to do with these (don't drop?)

*Recode index diagnosis date as first ULT date if first ULT date <30 days before index gout code date
replace gout_code_date=first_ult_date if gout_code_date!=. & first_ult_date!=. & (first_ult_date<gout_code_date)



*Define flare

*Define flare (adapted from https://jamanetwork.com/journals/jama/fullarticle/2794763): 1) presence of a non-index diagnostic code for gout exacerbation; 2) non-index admission with primary gout diagnostic code; 3) non-index ED attendance with primary gout diagnostic code; 4) any non-index gout diagnostic code AND prescription for a flare treatment on same day as that code; all within 6m of index diagnostic code. Exclude events that occur within 14 days of one another

**Non-index admission with primary gout diagnostic code
reshape long gout_admission_date_ gout_admission_, i(patient_id) j(admission_order)
preserve
gen flare_overall_date=gout_admission_date_ if ((gout_admission_date_<(gout_code_date+180)) & (gout_admission_date_>(gout_code_date+14))) & gout_admission_date_!=. //save a list of admission dates within 6m of diagnosis, but not within first 14 days of diagnosis
format %td flare_overall_date
keep patient_id admission_order flare_overall_date
save "$projectdir/output/data/admission_dates_long.dta", replace
restore
bys patient_id (gout_admission_date_): gen n=_n
replace gout_admission_=0 if (gout_admission_date_-14<gout_admission_date_[_n-1]) & gout_admission_date_!=. & gout_admission_date_[_n-1]!=. //remove admissions within 14 days of one another
replace gout_admission_date_=. if (gout_admission_date_-14<gout_admission_date_[_n-1]) & gout_admission_date_!=. & gout_admission_date_[_n-1]!=.
drop n
bys patient_id (gout_admission_date_): gen n=_n
replace gout_admission_=0 if (gout_admission_date_-14<gout_admission_date_[_n-1]) & gout_admission_date_!=. & gout_admission_date_[_n-1]!=. //remove admissions within 14 days of one another (repeat this)
replace gout_admission_date_=. if (gout_admission_date_-14<gout_admission_date_[_n-1]) & gout_admission_date_!=. & gout_admission_date_[_n-1]!=.
drop n
reshape wide gout_admission_date_ gout_admission_, i(patient_id) j(admission_order)

**Non-index ED attendance with primary gout diagnostic code
reshape long gout_emerg_date_ gout_emerg_, i(patient_id) j(emerg_order)
preserve
gen flare_overall_date=gout_emerg_date_ if ((gout_emerg_date_<(gout_code_date+180)) & (gout_emerg_date_>(gout_code_date+14))) & gout_emerg_date_!=. //save a list of ED dates within 6m of diagnosis, but not within first 14 days of diagnosis
format %td flare_overall_date
keep patient_id emerg_order flare_overall_date
save "$projectdir/output/data/emerg_dates_long.dta", replace
restore
bys patient_id (gout_emerg_date_): gen n=_n
replace gout_emerg_=0 if (gout_emerg_date_-14<gout_emerg_date_[_n-1]) & gout_emerg_date_!=. & gout_emerg_date_[_n-1]!=. //remove emergs within 14 days of one another
replace gout_emerg_date_=. if (gout_emerg_date_-14<gout_emerg_date_[_n-1]) & gout_emerg_date_!=. & gout_emerg_date_[_n-1]!=.
drop n
bys patient_id (gout_emerg_date_): gen n=_n
replace gout_emerg_=0 if (gout_emerg_date_-14<gout_emerg_date_[_n-1]) & gout_emerg_date_!=. & gout_emerg_date_[_n-1]!=. //remove emergs within 14 days of one another (repeat this)
replace gout_emerg_date_=. if (gout_emerg_date_-14<gout_emerg_date_[_n-1]) & gout_emerg_date_!=. & gout_emerg_date_[_n-1]!=.
drop n
reshape wide gout_emerg_date_ gout_emerg_, i(patient_id) j(emerg_order)

**Any non-index gout diagnostic code AND prescription for a flare treatment on same day as that code;
reshape long gout_code_any_ gout_code_any_date_, i(patient_id) j(code_order)
gen code_and_tx_date_=.
format %td code_and_tx_date_
forval i = 1/6 	{
replace code_and_tx_date_=gout_code_any_date_ if gout_code_any_date_==flare_treatment_date_`i' & gout_code_any_date_!=. & flare_treatment_date_`i'!=.
}
preserve
gen flare_overall_date=code_and_tx_date_ if ((code_and_tx_date_<(gout_code_date+180)) & (code_and_tx_date_>(gout_code_date+14))) & code_and_tx_date_!=. //save a list of code/Tx dates within 6m of diagnosis
format %td flare_overall_date
keep patient_id code_order flare_overall_date
save "$projectdir/output/data/code_tx_dates_long.dta", replace
restore
bys patient_id (code_and_tx_date_): gen n=_n
replace code_and_tx_date_=. if (code_and_tx_date_-14<code_and_tx_date_[_n-1]) & code_and_tx_date_!=. & code_and_tx_date_[_n-1]!=. //remove flares within 14 days of one another
drop n
bys patient_id (code_and_tx_date_): gen n=_n
replace code_and_tx_date_=. if (code_and_tx_date_-14<code_and_tx_date_[_n-1]) & code_and_tx_date_!=. & code_and_tx_date_[_n-1]!=. //remove flares within 14 days of one another (repeat this)
drop n
reshape wide gout_code_any_ gout_code_any_date_ code_and_tx_date_, i(patient_id) j(code_order)

**Presence of a non-index diagnostic code for gout exacerbation
reshape long gout_flare_date_ gout_flare_, i(patient_id) j(flare_order)
preserve
gen flare_overall_date=gout_flare_date_ if ((gout_flare_date_<(gout_code_date+180)) & (gout_flare_date_>(gout_code_date+14))) & gout_flare_date_!=. //save a list of code/Tx dates within 6m of diagnosis, but not within first 14 days of diagnosis
format %td flare_overall_date
keep patient_id flare_order flare_overall_date
save "$projectdir/output/data/flare_dates_long.dta", replace
append using "$projectdir/output/data/code_tx_dates_long.dta" //append all other flares/admissions/ED
append using "$projectdir/output/data/emerg_dates_long.dta"
append using "$projectdir/output/data/admission_dates_long.dta"
bys patient_id (flare_overall_date): gen n=_n 
replace flare_overall_date=. if (flare_overall_date-14<flare_overall_date[_n-1]) & flare_overall_date!=. & flare_overall_date[_n-1]!=. //remove flares within 14 days of one another
drop n
bys patient_id (flare_overall_date): gen n=_n 
replace flare_overall_date=. if (flare_overall_date-14<flare_overall_date[_n-1]) & flare_overall_date!=. & flare_overall_date[_n-1]!=. //remove flares within 14 days of one another (repeat this)
drop n
bys patient_id (flare_overall_date): gen n=_n 
replace flare_overall_date=. if (flare_overall_date-14<flare_overall_date[_n-1]) & flare_overall_date!=. & flare_overall_date[_n-1]!=. //remove flares within 14 days of one another (repeat this)
drop n
bys patient_id (flare_overall_date): gen n=_n 
replace flare_overall_date=. if (flare_overall_date-14<flare_overall_date[_n-1]) & flare_overall_date!=. & flare_overall_date[_n-1]!=. //remove flares within 14 days of one another (repeat this)
drop n
bys patient_id (flare_overall_date): gen n=_n if flare_overall_date!=.
by patient_id: egen flare_count=max(n) //count of flares/admissions/ED within 6 months 
lab var flare_count "Number of gout flares in 6 months after diagnosis"
drop n
bys patient_id (flare_overall_date): gen n=_n 
keep if n==1
keep patient_id flare_count
save "$projectdir/output/data/flare_count.dta", replace
restore
bys patient_id (gout_flare_date_): gen n=_n
replace gout_flare_=0 if (gout_flare_date_-14<gout_flare_date_[_n-1]) & gout_flare_date_!=. & gout_flare_date_[_n-1]!=. //remove flares within 14 days of one another
replace gout_flare_date_=. if (gout_flare_date_-14<gout_flare_date_[_n-1]) & gout_flare_date_!=. & gout_flare_date_[_n-1]!=.
drop n
bys patient_id (gout_flare_date_): gen n=_n
replace gout_flare_=0 if (gout_flare_date_-14<gout_flare_date_[_n-1]) & gout_flare_date_!=. & gout_flare_date_[_n-1]!=. //remove flares within 14 days of one another (repeat this)
replace gout_flare_date_=. if (gout_flare_date_-14<gout_flare_date_[_n-1]) & gout_flare_date_!=. & gout_flare_date_[_n-1]!=.
drop n
reshape wide gout_flare_date_ gout_flare_, i(patient_id) j(flare_order)

**Now merge flare count in with original dataset
merge 1:1 patient_id using "$projectdir/output/data/flare_count.dta"
drop _merge
recode flare_count .=0
lab var flare_count "Number of flares after diagnosis"
tabstat flare_count, stats (n mean p50 p25 p75)
gen multiple_flares = 1 if flare_count>=1 & flare_count!=. //define multiple flares as one or more additional flare within first 6 months of diagnosis
recode multiple_flares .=0
lab var multiple_flares "At least one additional flare within 6 months of diagnosis"
lab def multiple_flares 0 "No" 1 "Yes", modify
lab val multiple_flares multiple_flares
tab multiple_flares	

*Define high-risk patients for ULT
gen high_risk = 1 if tophi==1 | ckd==1 | diuretic==1 | multiple_flares==1
recode high_risk .=0	
lab var high_risk "Presence of risk factors"
lab def high_risk 0 "No" 1 "Yes", modify
lab val high_risk high_risk

**Time to first ULT; prescription must be within 6 months of diagnosis
tabstat time_to_ult, stats (n mean p50 p25 p75) //without any time restriction
gen time_to_ult_6m=(first_ult_date-gout_code_date) if first_ult_date!=. & (first_ult_date<=gout_code_date+180)
tabstat time_to_ult_6m, stats (n mean p50 p25 p75) //with 6m time restriction

**ULT time categories
gen ult_time=1 if time_to_ult_6m<=90 & time_to_ult_6m!=. 
replace ult_time=2 if time_to_ult_6m>90 & time_to_ult_6m<=180 & time_to_ult_6m!=.
replace ult_time=3 if time_to_ult_6m>180 | time_to_ult_6m==.
lab define ult_time 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months", modify
lab val ult_time ult_time
lab var ult_time "ULT initiation, overall" 

**Generate ULT variables used for box plots
gen ult_time_19=ult_time if diagnosis_year==5
recode ult_time_19 .=4
gen ult_time_20=ult_time if diagnosis_year==6
recode ult_time_20 .=4
gen ult_time_21=ult_time if diagnosis_year==7
recode ult_time_21 .=4
gen ult_time_22=ult_time if diagnosis_year==8
recode ult_time_22 .=4
lab define ult_time_19 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months" 4 "Outside 2019", modify
lab val ult_time_19 ult_time_19
lab var ult_time_19 "ULT initiation, 2019/20" 
lab define ult_time_20 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months" 4 "Outside 2020", modify
lab val ult_time_20 ult_time_20
lab var ult_time_20 "ULT initiation, 2020/21" 
lab define ult_time_21 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months" 4 "Outside 2021", modify
lab val ult_time_21 ult_time_21
lab var ult_time_21 "ULT initiation, 2021/22" 
lab define ult_time_22 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months" 4 "Outside 2021", modify
lab val ult_time_22 ult_time_22
lab var ult_time_22 "ULT initiation, 2022/23" 

**Urate time categories
gen urate_6m_ult_time=1 if urate_below360_ult_6m==1
replace urate_6m_ult_time=2 if urate_below360_ult_6m!=1
lab define urate_6m_ult_time 1 "Within 6 months" 2 "Not attained within 6 months", modify
lab val urate_6m_ult_time urate_6m_ult_time
lab var urate_6m_ult_time "Urate attainment, overall" 

gen urate_12m_ult_time=1 if urate_below360_ult_6m==1
replace urate_12m_ult_time=2 if urate_below360_ult_6m!=1 & urate_below360_ult_12m==1
replace urate_12m_ult_time=3 if urate_below360_ult_6m!=1 & urate_below360_ult_12m!=1
lab define urate_12m_ult_time 1 "Within 6 months" 2 "Within 12 months" 3 "Not attained within 12 months", modify
lab val urate_12m_ult_time urate_12m_ult_time
lab var urate_12m_ult_time "Urate attainment, overall" 

**Generate urate variables used for box plots
gen urate_6m_ult_time_19=urate_6m_ult_time if ult_year==5
recode urate_6m_ult_time_19 .=3
gen urate_6m_ult_time_20=urate_6m_ult_time if ult_year==6
recode urate_6m_ult_time_20 .=3
gen urate_6m_ult_time_21=urate_6m_ult_time if ult_year==7
recode urate_6m_ult_time_21 .=3
gen urate_6m_ult_time_22=urate_6m_ult_time if ult_year==8
recode urate_6m_ult_time_22 .=3
lab define urate_6m_ult_time_19 1 "Within 6 months" 2 "Not attained within 6 months" 3 "Outside 2019", modify
lab val urate_6m_ult_time_19 urate_6m_ult_time_19
lab var urate_6m_ult_time_19 "Urate attainment, 2019/20" 
lab define urate_6m_ult_time_20 1 "Within 6 months" 2 "Not attained within 6 months" 3 "Outside 2020", modify
lab val urate_6m_ult_time_20 urate_6m_ult_time_20
lab var urate_6m_ult_time_20 "Urate attainment, 2020/21" 
lab define urate_6m_ult_time_21 1 "Within 6 months" 2 "Not attained within 6 months" 3 "Outside 2021", modify
lab val urate_6m_ult_time_21 urate_6m_ult_time_21
lab var urate_6m_ult_time_21 "Urate attainment, 2021/22" 
lab define urate_6m_ult_time_22 1 "Within 6 months" 2 "Not attained within 6 months" 3 "Outside 2022", modify
lab val urate_6m_ult_time_22 urate_6m_ult_time_22
lab var urate_6m_ult_time_22 "Urate attainment, 2022/23" 

gen urate_12m_ult_time_19=urate_12m_ult_time if ult_year==5
recode urate_12m_ult_time_19 .=4
gen urate_12m_ult_time_20=urate_12m_ult_time if ult_year==6
recode urate_12m_ult_time_20 .=4
gen urate_12m_ult_time_21=urate_12m_ult_time if ult_year==7
recode urate_12m_ult_time_21 .=4
gen urate_12m_ult_time_22=urate_12m_ult_time if ult_year==8
recode urate_12m_ult_time_22 .=4
lab define urate_12m_ult_time_19 1 "Within 6 months" 2 "Within 12 months" 3 "Not attained within 12 months" 4 "Outside 2019", modify
lab val urate_12m_ult_time_19 urate_12m_ult_time_19
lab var urate_12m_ult_time_19 "Urate attainment, 2019/20" 
lab define urate_12m_ult_time_20 1 "Within 6 months" 2 "Within 12 months" 3 "Not attained within 12 months" 4 "Outside 2020", modify
lab val urate_12m_ult_time_20 urate_12m_ult_time_20
lab var urate_12m_ult_time_20 "Urate attainment, 2020/21" 
lab define urate_12m_ult_time_21 1 "Within 6 months" 2 "Within 12 months" 3 "Not attained within 12 months" 4 "Outside 2021", modify
lab val urate_12m_ult_time_21 urate_12m_ult_time_21
lab var urate_12m_ult_time_21 "Urate attainment, 2021/22" 
lab define urate_12m_ult_time_22 1 "Within 6 months" 2 "Within 12 months" 3 "Not attained within 12 months" 4 "Outside 2022", modify
lab val urate_12m_ult_time_22 urate_12m_ult_time_22
lab var urate_12m_ult_time_22 "Urate attainment, 2022/23" 

*What was first ULT drug in GP record

**Within 6 months of diagnosis
gen first_ult_d_6m=""
foreach var of varlist first_allo_date first_febux_date {
	replace first_ult_d_6m="`var'" if first_ult_date==`var' & first_ult_date!=. & (`var'<=(gout_code_date+180)) & `var'!=.
	}
gen first_ult_drug_6m = substr(first_ult_d_6m, 1, length(first_ult_d_6m) - 5) if first_ult_d_6m!="" 
drop first_ult_d_6m
replace first_ult_drug_6m="Febuxostat" if first_ult_drug_6m =="first_febux"
replace first_ult_drug_6m="Allopurinol" if first_ult_drug_6m =="first_allo"
lab var first_ult_drug_6m "First ULT drug"

tab first_ult_drug_6m, missing
tab first_ult_drug_6m if ult_6m==1, missing

**Within 12 months of diagnosis
gen first_ult_d_12m=""
foreach var of varlist first_allo_date first_febux_date {
	replace first_ult_d_12m="`var'" if first_ult_date==`var' & first_ult_date!=. & (`var'<=(gout_code_date+365)) & `var'!=.
	}
gen first_ult_drug_12m = substr(first_ult_d_12m, 1, length(first_ult_d_12m) - 5) if first_ult_d_12m!="" 
drop first_ult_d_12m
replace first_ult_drug_12m="Febuxostat" if first_ult_drug_12m =="first_febux"
replace first_ult_drug_12m="Allopurinol" if first_ult_drug_12m =="first_allo"
lab var first_ult_drug_12m "First ULT drug"

tab first_ult_drug_12m, missing
tab first_ult_drug_12m if ult_12m==1, missing

*/
save "$projectdir/output/data/`out_file'.dta", replace

}

log close


