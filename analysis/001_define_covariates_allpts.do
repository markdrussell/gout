version 16

/*==============================================================================
DO FILE NAME:			define covariates allpts
PROJECT:				Gout OpenSAFELY project
DATE: 					01/12/2022
AUTHOR:					M Russell / J Galloway			
DESCRIPTION OF FILE:	data management for Gout project  
						reformat variables 
						categorise variables
						label variables 
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

import delimited "$projectdir/output/input_allpts.csv", clear

**Open a log file
cap log close
log using "$logdir/cleaning_dataset_allpts.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Set index dates ===========================================================*/
global year_preceding = "01/01/2018"
global start_date = "01/01/2019"
global end_date = "31/12/2022"

**Rename variables (some are too long for Stata to handle) =======================================*/
rename chronic_respiratory_disease chronic_resp_disease
rename chronic_cardiac_disease chronic_card_disease
rename bmi_date_measured bmi_date

foreach var of varlist 	 bmi 								///
						 creatinine							///
						 hba1c_mmol_per_mol					///
						 hba1c_percentage					///
						 {
			rename `var' `var'_val
			order `var'_val, after(`var'_date)
		}

foreach var of varlist   chronic_card_disease				///
						 diabetes							///
						 hypertension						///	
						 chronic_resp_disease				///
						 copd								///
						 chronic_liver_disease				///
						 stroke								///
						 lung_cancer						///
						 haem_cancer						///
						 other_cancer						///
						 esrf								///
						 organ_transplant					///
						 {
			rename `var' `var'_date
		} 
		
**Change date format and create binary indicator variables for relevant conditions ====================================================*/

foreach var of varlist 	 bmi_date 							///
						 creatinine_date 					///
						 chronic_card_disease_date			///
						 diabetes_date						///
						 hypertension_date					///	
						 chronic_resp_disease_date			///
						 copd_date							///
						 chronic_liver_disease_date			///
						 stroke_date						///
						 lung_cancer_date					///
						 haem_cancer_date					///
						 other_cancer_date					///
						 esrf_date							///
						 organ_transplant_date				///
						 hba1c_mmol_per_mol_date			///
						 hba1c_percentage_date				///
						 diuretic_date						///
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
						
**Demographics======================================================================*/

**Demographics
***Sex
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"
lab var male "Male"
lab define male 0 "No" 1 "Yes", modify
lab val male male
tab male, missing
drop sex

***Ethnicity
replace ethnicity = .u if ethnicity == .
****rearrange in order of prevalence
recode ethnicity 2=6 /* mixed to 6 */
recode ethnicity 3=2 /* south asian to 2 */
recode ethnicity 4=3 /* black to 3 */
recode ethnicity 6=4 /* mixed to 4 */
recode ethnicity 5=4 /* other to 4 */

label define ethnicity 	1 "White"  					///
						2 "Asian/Asian British"		///
						3 "Black"  					///
						4 "Mixed/Other"				///
						.u "Not known"
label values ethnicity ethnicity
lab var ethnicity "Ethnicity"
tab ethnicity, missing

gen ethnicity_bme=0 if ethnicity==1
replace ethnicity_bme=1 if ethnicity>1 & ethnicity<5
replace ethnicity_bme=.u if ethnicity==.u
label define ethnicity_bme 	0 "White"  		///
						1 "Non-white"		///
						.u "Not known"
label values ethnicity_bme ethnicity_bme
lab var ethnicity_bme "Ethnicity"
tab ethnicity_bme, missing

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

***IMD
recode imd 0 = .u
label define imd 1 "1 most deprived" 2 "2" 3 "3" 4 "4" 5 "5 least deprived" .u "Not known"
label values imd imd 
lab var imd "Index of multiple deprivation"
tab imd, missing

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

***Body Mass Index
*Recode strange values 
replace bmi_val = . if bmi_val == 0 
replace bmi_val = . if !inrange(bmi_val, 10, 80)

*Restrict to within 10 years of index date and aged>16 
gen bmi_time = (date("$start_date", "DMY") - bmi_date)/365.25
gen bmi_age = age - bmi_time
replace bmi_val = . if bmi_age < 16 
replace bmi_val = . if bmi_time > 10 & bmi_time != . 

*Set to missing if no date, and vice versa 
replace bmi_val = . if bmi_date == . 
replace bmi_date = . if bmi_val == . 
replace bmi_time = . if bmi_val == . 
replace bmi_age = . if bmi_val == . 

*Create BMI categories
gen 	bmicat = .
recode  bmicat . = 1 if bmi_val < 18.5
recode  bmicat . = 2 if bmi_val < 25
recode  bmicat . = 3 if bmi_val < 30
recode  bmicat . = 4 if bmi_val < 35
recode  bmicat . = 5 if bmi_val < 40
recode  bmicat . = 6 if bmi_val < .
replace bmicat = .u if bmi_val >= .

label define bmicat 1 "Underweight (<18.5)" 	///
					2 "Normal (18.5-24.9)"		///
					3 "Overweight (25-29.9)"	///
					4 "Obese I (30-34.9)"		///
					5 "Obese II (35-39.9)"		///
					6 "Obese III (40+)"			///
					.u "Not known"
					
label values bmicat bmicat
lab var bmicat "BMI"
tab bmicat, missing

*Create less granular categorisation
recode bmicat 1/3 .u = 1 4 = 2 5 = 3 6 = 4, gen(obese4cat)

label define obese4cat 	1 "No record of obesity" 	///
						2 "Obese I (30-34.9)"		///
						3 "Obese II (35-39.9)"		///
						4 "Obese III (40+)"		

label values obese4cat obese4cat
order obese4cat, after(bmicat)

***Smoking 
label define smoke 1 "Never" 2 "Former" 3 "Current" .u "Not known"

gen     smoke = 1  if smoking_status == "N"
replace smoke = 2  if smoking_status == "E"
replace smoke = 3  if smoking_status == "S"
replace smoke = .u if smoking_status == "M"
replace smoke = .u if smoking_status == "" 

label values smoke smoke
lab var smoke "Smoking status"
drop smoking_status
tab smoke, missing

*Create non-missing 3-category variable for current smoking (assumes missing smoking is never smoking)
recode smoke .u = 1, gen(smoke_nomiss)
order smoke_nomiss, after(smoke)
label values smoke_nomiss smoke

**Clinical comorbidities
***eGFR
*Set implausible creatinine values to missing (Note: zero changed to missing)
replace creatinine_val = . if !inrange(creatinine_val, 20, 3000) 

*Remove creatinine dates if no measurements, and vice versa 
replace creatinine_val = . if creatinine_date == . 
replace creatinine_date = . if creatinine_val == . 
replace creatinine = . if creatinine_val == .
recode creatinine .=0
tab creatinine, missing

*Divide by 88.4 (to convert umol/l to mg/dl) 
gen SCr_adj = creatinine_val/88.4

gen min = .
replace min = SCr_adj/0.7 if male==0
replace min = SCr_adj/0.9 if male==1
replace min = min^-0.329  if male==0
replace min = min^-0.411  if male==1
replace min = 1 if min<1

gen max=.
replace max=SCr_adj/0.7 if male==0
replace max=SCr_adj/0.9 if male==1
replace max=max^-1.209
replace max=1 if max>1

gen egfr=min*max*141
replace egfr=egfr*(0.993^age)
replace egfr=egfr*1.018 if male==0
label var egfr "egfr calculated using CKD-EPI formula with no ethnicity"

*Categorise into ckd stages
egen egfr_cat_all = cut(egfr), at(0, 15, 30, 45, 60, 5000)
recode egfr_cat_all 0 = 5 15 = 4 30 = 3 45 = 2 60 = 0, generate(ckd_egfr)

gen egfr_cat = .
recode egfr_cat . = 3 if egfr < 30
recode egfr_cat . = 2 if egfr < 60
recode egfr_cat . = 1 if egfr < .
replace egfr_cat = .u if egfr >= .

label define egfr_cat 	1 ">=60" 		///
						2 "30-59"		///
						3 "<30"			///
						.u "Not known"
					
label values egfr_cat egfr_cat
lab var egfr_cat "eGFR"
tab egfr_cat, missing

*If missing eGFR, assume normal
gen egfr_cat_nomiss = egfr_cat
replace egfr_cat_nomiss = 1 if egfr_cat == .u

label define egfr_cat_nomiss 	1 ">=60/not known" 	///
								2 "30-59"			///
								3 "<30"	
label values egfr_cat_nomiss egfr_cat_nomiss
lab var egfr_cat_nomiss "eGFR"
tab egfr_cat_nomiss, missing

gen egfr_date = creatinine_date
format egfr_date %td

*Add in end stage renal failure and create a single CKD variable 
*Missing assumed to not have CKD 
gen ckd = 0
replace ckd = 1 if ckd_egfr != . & ckd_egfr >= 1
replace ckd = 1 if esrf == 1

label define ckd 0 "No" 1 "Yes"
label values ckd ckd
label var ckd "Chronic kidney disease"
tab ckd, missing

*Create date (most recent measure prior to index)
gen temp1_ckd_date = creatinine_date if ckd_egfr >=1
gen temp2_ckd_date = esrf_date if esrf == 1
gen ckd_date = max(temp1_ckd_date,temp2_ckd_date) 
format ckd_date %td 

drop temp1_ckd_date temp2_ckd_date SCr_adj min max ckd_egfr egfr_cat_all

***HbA1c
*Set zero or negative to missing
replace hba1c_percentage_val   = . if hba1c_percentage_val <= 0
replace hba1c_mmol_per_mol_val = . if hba1c_mmol_per_mol_val <= 0

*Change implausible values to missing
replace hba1c_percentage_val   = . if !inrange(hba1c_percentage_val, 1, 20)
replace hba1c_mmol_per_mol_val = . if !inrange(hba1c_mmol_per_mol_val, 10, 200)

*Set most recent values of >24 months prior to index date to missing
replace hba1c_percentage_val   = . if (date("$start_date", "DMY") - hba1c_percentage_date) > 24*30 & hba1c_percentage_date != .
replace hba1c_mmol_per_mol_val = . if (date("$start_date", "DMY") - hba1c_mmol_per_mol_date) > 24*30 & hba1c_mmol_per_mol_date != .

*Clean up dates
replace hba1c_percentage_date = . if hba1c_percentage_val == .
replace hba1c_mmol_per_mol_date = . if hba1c_mmol_per_mol_val == .

*Express HbA1c as percentage
*Express all values as perecentage 
noi summ hba1c_percentage_val hba1c_mmol_per_mol_val 
gen 	hba1c_pct = hba1c_percentage_val 
replace hba1c_pct = (hba1c_mmol_per_mol_val/10.929)+2.15 if hba1c_mmol_per_mol_val<. 

*Valid % range between 0-20  
replace hba1c_pct = . if !inrange(hba1c_pct, 1, 20) 
replace hba1c_pct = round(hba1c_pct, 0.1)

*Categorise HbA1c and diabetes
*Group hba1c pct
gen 	hba1ccat = 0 if hba1c_pct <  6.5
replace hba1ccat = 1 if hba1c_pct >= 6.5  & hba1c_pct < 7.5
replace hba1ccat = 2 if hba1c_pct >= 7.5  & hba1c_pct < 8
replace hba1ccat = 3 if hba1c_pct >= 8    & hba1c_pct < 9
replace hba1ccat = 4 if hba1c_pct >= 9    & hba1c_pct !=.
label define hba1ccat 0 "<6.5%" 1">=6.5-7.4" 2">=7.5-7.9" 3">=8-8.9" 4">=9"
label values hba1ccat hba1ccat
tab hba1ccat, missing

*Express all values as mmol
gen hba1c_mmol = hba1c_mmol_per_mol_val
replace hba1c_mmol = (hba1c_percentage_val*10.929)-23.5 if hba1c_percentage_val<. & hba1c_mmol==.

*Group hba1c mmol
gen 	hba1ccatmm = 0 if hba1c_mmol < 58
replace hba1ccatmm = 1 if hba1c_mmol >= 58 & hba1c_mmol !=.
replace hba1ccatmm =.u if hba1ccatmm==. 
label define hba1ccatmm 0 "HbA1c <58mmol/mol" 1 "HbA1c >=58mmol/mol" .u "Not known"
label values hba1ccatmm hba1ccatmm
lab var hba1ccatmm "HbA1c"
tab hba1ccatmm, missing

*Create diabetes, split by control/not (assumes missing = no diabetes)
gen     diabcatm = 1 if diabetes==0
replace diabcatm = 2 if diabetes==1 & hba1ccatmm==0
replace diabcatm = 3 if diabetes==1 & hba1ccatmm==1
replace diabcatm = 4 if diabetes==1 & hba1ccatmm==.u

label define diabcatm 	1 "No diabetes" 			///
						2 "Diabetes with HbA1c <58mmol/mol"		///
						3 "Diabetes with HbA1c >58mmol/mol" 	///
						4 "Diabetes with no HbA1c measure"
label values diabcatm diabcatm
lab var diabcatm "Diabetes"

*Create cancer variable
gen cancer =0
replace cancer =1 if lung_cancer ==1 | haem_cancer ==1 | other_cancer ==1
lab var cancer "Cancer"
lab define cancer 0 "No" 1 "Yes", modify
lab val cancer cancer
tab cancer, missing

*Create other comorbid variables
gen combined_cv_comorbid =1 if chronic_card_disease ==1 | stroke==1
recode combined_cv_comorbid .=0

*Recode missing as zero for other variable
recode diuretic .=0

*Label variables
lab var hypertension "Hypertension"
lab define hypertension 0 "No" 1 "Yes", modify
lab val hypertension hypertension
lab var diabetes "Diabetes"
lab define diabetes 0 "No" 1 "Yes", modify
lab val diabetes diabetes
lab var stroke "Stroke"
lab define stroke 0 "No" 1 "Yes", modify
lab val stroke stroke
lab var chronic_resp_disease "Chronic respiratory disease"
lab define chronic_resp_disease 0 "No" 1 "Yes", modify
lab val chronic_resp_disease chronic_resp_disease
lab var copd "COPD"
lab define copd 0 "No" 1 "Yes", modify
lab val copd copd
lab var esrf "End-stage renal failure"
lab define esrf 0 "No" 1 "Yes", modify
lab val esrf esrf
lab var chronic_liver_disease "Chronic liver disease"
lab define chronic_liver_disease 0 "No" 1 "Yes", modify
lab val chronic_liver_disease chronic_liver_disease
lab var chronic_card_disease "Chronic cardiac disease"
lab define chronic_card_disease 0 "No" 1 "Yes", modify
lab val chronic_card_disease chronic_card_disease
lab define diuretic 0 "No" 1 "Yes", modify
lab val diuretic diuretic
lab var diuretic "Diuretic at diagnosis"


save "$projectdir/output/data/file_gout_allpts", replace	

log close

