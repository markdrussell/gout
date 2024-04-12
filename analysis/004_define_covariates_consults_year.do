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

**Check number of episodes for gout consultations per person during study window
codebook gout_episodes
tabstat gout_episodes, stat(n mean sd p50 p25 p75)

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

gen abs_time_to_test = abs(time_to_test) if time_to_test!=. & time_to_test<=14 & time_to_test>=-182 & urate_val_!=. //within 6 months before consultation and 2 weeks after
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

save "$projectdir/output/data/`out_file'.dta", replace

}

log close


