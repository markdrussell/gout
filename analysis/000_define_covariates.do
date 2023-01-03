version 16

/*==============================================================================
DO FILE NAME:			define covariates
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
global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir `c(pwd)'

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/figures"
capture mkdir "$projectdir/output/tables"

global logdir "$projectdir/logs"

**Open a log file
cap log close
log using "$logdir/cleaning_dataset.log", replace

import delimited "$projectdir/output/input.csv", clear

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Set index dates ===========================================================*/
global year_preceding = "01/01/2014"
global start_date = "01/01/2015"
global end_date = "31/12/2022"

**Rename variables =======================================*/
rename chronic_respiratory_disease chronic_resp_disease
rename chronic_cardiac_disease chronic_card_disease
rename first_ult_code first_ult_dmd
rename bmi_date_measured bmi_date
rename last_ult_6m last_ult_6m_code
rename last_ult_12m last_ult_12m_code

foreach var of varlist 	 bmi 								///
						 creatinine							///
						 hba1c_mmol_per_mol					///
						 hba1c_percentage					///
						 urate_test_?						///
						 {
			rename `var' `var'_val
			order `var'_val, after(`var'_date)
		}

foreach var of varlist   died_date_ons						///
						 chronic_card_disease				///
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
						 gout_flare_?						///
						 gout_code_any_?					///
						 flare_treatment_?					///
						 gout_admission_?					///	
						 gout_emerg_?						///
						 {
			rename `var' `var'_date
		} 
		
**Change date format and create binary indicator variables for relevant conditions ====================================================*/

foreach var of varlist 	 gout_code_date						///
						 first_ult_code_date	 			///
						 first_ult_date						///
						 first_allo_date					///
						 first_allo100_date					///
						 first_allo300_date					///
						 first_febux_date					///
						 last_ult_6m_date					///
						 last_allo100_6m_date				///
						 last_allo300_6m_date				///
						 last_ult_12m_date					///
						 last_allo100_12m_date				///
						 last_allo300_12m_date				///
						 bmi_date 							///
						 creatinine_date 					///
						 died_date_ons						///
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
						 gout_admission_?_date				///
						 gout_admission_pre_date			///
						 gout_emerg_?_date					///
						 gout_emerg_pre_date				///
						 tophi_date							///
						 gout_flare_?_date					///
						 gout_code_any_?_date				///
						 flare_treatment_?_date				///
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
		
forval i = 1/9 	{
					rename urate_test_`i'_date urate_date_`i'
					order urate_test_`i', after(urate_date_`i')
					rename urate_test_`i'_val urate_val_`i'
					rename gout_flare_`i'_date gout_flare_date_`i'
					rename gout_code_any_`i'_date gout_code_any_date_`i'
					rename flare_treatment_`i'_date flare_treatment_date_`i'
					rename gout_emerg_`i'_date gout_emerg_date_`i'
					rename gout_admission_`i'_date  gout_admission_date_`i'
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

*Restrict to within 10 years of gout diagnosis date and aged>16 
gen bmi_time = (gout_code_date - bmi_date)/365.25
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

*Set most recent values of >24 months prior to gout diagnosis date to missing
replace hba1c_percentage_val   = . if (gout_code_date - hba1c_percentage_date) > 24*30 & hba1c_percentage_date != .
replace hba1c_mmol_per_mol_val = . if (gout_code_date - hba1c_mmol_per_mol_date) > 24*30 & hba1c_mmol_per_mol_date != .

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

*Define tophaceous disease as a code for tophaecous gout at baseline or within 3m of diagnosis
gen time_to_tophus = tophi_date-gout_code_date if tophi_date!=. & gout_code_date!=.
gen tophus = 1 if time_to_tophus<90 & time_to_tophus!=.
recode tophus .=0

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
lab define tophus 0 "No" 1 "Yes", modify
lab val tophus tophus
lab var tophus "Tophaceous gout"

*Ensure everyone has gout code=============================================================*/

tab gout_code, missing
keep if gout_code==1

*Check if first ULT prescription was before index diagnosis code=====================================================*/

**Date of first ULT script
codebook first_ult_date
codebook first_ult_code_date //should be same as above; if so, delete above and study definition and below

tab first_ult if gout_code_date!=. & first_ult_code_date!=. & first_ult_code_date<gout_code_date
tab first_ult if gout_code_date!=. & first_ult_code_date!=. & (first_ult_code_date+30)<gout_code_date //30 days before
tab first_ult if gout_code_date!=. & first_ult_code_date!=. & (first_ult_code_date+60)<gout_code_date //60 days before
drop if gout_code_date!=. & first_ult_code_date!=. & (first_ult_code_date+30)<gout_code_date //drop if first ULT script more than 30 days before first gout code

*Recode index diagnosis date as first ULT date if first ULT date <30 days before index gout code date
replace gout_code_date=first_ult_code_date if gout_code_date!=. & first_ult_code_date!=. & (first_ult_code_date<gout_code_date)

*Check if first gout admission/emergency attendance was before index diagnosis code=====================================================*/

tab gout_admission_pre //admissions for gout that were more than 30 days before gout code
drop if gout_admission_pre==1 //drop those with gout admissions that were more than 30 days before GP gout code 

tab gout_admission_1 //admissions for gout that were from 30 days before gout code and onwards
tab gout_admission_1 if gout_code_date!=. & gout_admission_date_1!=. & gout_admission_date_1<gout_code_date
tab gout_admission_1 if gout_code_date!=. & gout_admission_date_1!=. & (gout_admission_date_1+30)<gout_code_date //30 days before - should be accounted for by study definition

*Recode index diagnosis date as gout admission date if gout admission date less than 30 days before index gout code date
replace gout_code_date=gout_admission_date_1 if gout_code_date!=. & first_ult_code_date!=. & (gout_admission_date_1<gout_code_date)

tab gout_emerg_pre //ED attendances for gout that were more than 30 days before gout code
drop if gout_emerg_pre==1 //drop those with gout ED attendances that were more than 30 days before GP gout code 

tab gout_emerg_1 //ED attendances for gout that were from 30 days before gout code and onwards
tab gout_emerg_1 if gout_code_date!=. & gout_emerg_date_1!=. & gout_emerg_date_1<gout_code_date
tab gout_emerg_1 if gout_code_date!=. & gout_emerg_date_1!=. & (gout_emerg_date_1+30)<gout_code_date 

*Recode index diagnosis date as gout emerg date if gout emerg date less than 30 days before index gout code date
replace gout_code_date=gout_emerg_date_1 if gout_code_date!=. & first_ult_code_date!=. & (gout_emerg_date_1<gout_code_date)

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

*Number of diagnoses in time windows=========================================*/

**Month/Year of diagnosis code
gen year_diag=year(gout_code_date)
format year_diag %ty
gen month_diag=month(gout_code_date)
gen mo_year_diagn=ym(year_diag, month_diag)
format mo_year_diagn %tmMon-CCYY
generate str16 mo_year_diagn_s = strofreal(mo_year_diagn,"%tmCCYY!mNN")
lab var mo_year_diagn "Month/Year of Diagnosis"
lab var mo_year_diagn_s "Month/Year of Diagnosis"

**Separate into 12-month time windows (for diagnosis date)
gen diagnosis_year=1 if diagnosis_date>=td(01jan2015) & diagnosis_date<td(31dec2015)
replace diagnosis_year=2 if diagnosis_date>=td(01jan2016) & diagnosis_date<td(31dec2016)
replace diagnosis_year=3 if diagnosis_date>=td(01jan2017) & diagnosis_date<td(31dec2017)
replace diagnosis_year=4 if diagnosis_date>=td(01jan2018) & diagnosis_date<td(31dec2018)
replace diagnosis_year=5 if diagnosis_date>=td(01jan2019) & diagnosis_date<td(31dec2019)
replace diagnosis_year=6 if diagnosis_date>=td(01jan2020) & diagnosis_date<td(31dec2020)
replace diagnosis_year=7 if diagnosis_date>=td(01jan2021) & diagnosis_date<td(31dec2021)
replace diagnosis_year=8 if diagnosis_date>=td(01jan2022) & diagnosis_date<td(31dec2022)
lab define diagnosis_year 1 "2015" 2 "2016" 3 "2017" 4 "2018" 5 "2019" 6 "2020" 7 "2021" 8 "2022", modify
lab val diagnosis_year diagnosis_year
lab var diagnosis_year "Year of diagnosis"
tab diagnosis_year, missing

*Prescription of ULT==================================================*/

**Check proportion of patients with at least 6/12 months of registration after diagnosis 
tab has_6m_follow_up, missing
tab has_12m_follow_up, missing

**Create variable whereby patients have at least 6/12 months of registration and follow-up time after diagnosis
gen has_6m_post_diag=1 if gout_code_date!=. & gout_code_date<(date("$end_date", "DMY")-180) & has_6m_follow_up==1
recode has_6m_post_diag .=0
lab var has_6m_post_diag ">6m follow-up"
lab define has_6m_post_diag 0 "No" 1 "Yes", modify
lab val has_6m_post_diag has_6m_post_diag
tab has_6m_post_diag, missing 

gen has_12m_post_diag=1 if gout_code_date!=. & gout_code_date<(date("$end_date", "DMY")-365) & has_12m_follow_up==1
recode has_12m_post_diag .=0
lab var has_12m_post_diag ">12m follow-up"
lab define has_12m_post_diag 0 "No" 1 "Yes", modify
lab val has_12m_post_diag has_12m_post_diag
tab has_12m_post_diag, missing 

**Generate variable for time to first ULT prescription
gen time_to_ult = first_ult_date-gout_code_date if first_ult_date!=. & gout_code_date!=.

**Generate variable for those who had ULT prescription within 6m of diagnosis 
gen ult_6m = 1 if time_to_ult<=180 & time_to_ult!=.
recode ult_6m .=0
tab ult_6m, missing
tab ult_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
tab ult_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Generate variable for those who had ULT prescription within 12m of diagnosis 
gen ult_12m = 1 if time_to_ult<=365 & time_to_ult!=.
recode ult_12m .=0
tab ult_12m, missing
tab ult_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Generate variable for time to first allopurinol prescription
gen time_to_allo = first_allo_date-gout_code_date if first_allo_date!=. & gout_code_date!=.

**Generate variable for those who had allopurinol prescription within 6m of diagnosis 
gen allo_6m = 1 if time_to_allo<=180 & time_to_allo!=.
recode allo_6m .=0
tab allo_6m, missing
tab allo_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
tab allo_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Generate variable for those who had allopurinol prescription within 12m of diagnosis 
gen allo_12m = 1 if time_to_allo<=365 & time_to_allo!=.
recode allo_12m .=0
tab allo_12m, missing
tab allo_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up 

**Generate variable for time to first febuxostat prescription
gen time_to_febux = first_febux_date-gout_code_date if first_febux_date!=. & gout_code_date!=.

**Generate variable for those who had febuxostat prescription within 6m of diagnosis 
gen febux_6m = 1 if time_to_febux<=180 & time_to_febux!=.
recode febux_6m .=0
tab febux_6m, missing
tab febux_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
tab febux_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Generate variable for those who had febuxostat prescription within 12m of diagnosis 
gen febux_12m = 1 if time_to_febux<=365 & time_to_febux!=.
recode febux_12m .=0
tab febux_12m, missing
tab febux_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up 

//Nb. can't tell dose - e.g. if allopurinol 100mg tablets issued, don't know dose prescribed

*Serum urate measurements==================================================*/

*Set implausible urate values to missing (Note: zero changed to missing) and remove urate dates if no measurements, and vice versa 
forval i = 1/9 	{
						replace urate_val_`i' = . if !inrange(urate_val_`i', 50, 2000) 	
						replace urate_val_`i' = . if urate_date_`i' == . 
						replace urate_date_`i' = . if urate_val_`i' == . 
						replace urate_test_`i' = . if urate_val_`i' == .
						recode urate_test_`i' .=0
						tab urate_test_`i', missing
}

reshape long urate_val_ urate_date_ urate_test_, i(patient_id) j(urate_order)

*Define baseline serum urate level as urate level closest to index diagnosis date (must be within 6m before/after diagnosis and before ULT commencement)
sort patient_id urate_date_
gen time_to_test = urate_date_-gout_code_date if urate_date_!=. & gout_code_date!=. //time to urate test from diagnosis date
gen test_after_ult=1 if urate_date_>first_ult_date & urate_date_!=. & first_ult_date!=.
replace test_after_ult=0 if urate_date_<=first_ult_date & urate_date_!=.

bys patient_id urate_date_ (urate_val_): gen n=_n //keeps only single urate test from same day (i.e. delete duplicates), priotising ones !=.
drop if n>1 
drop n

gen abs_time_to_test = abs(time_to_test) if time_to_test!=. & time_to_test<=180 & time_to_test>=-180 & test_after_ult!=1 & urate_val_!=.
bys patient_id (abs_time_to_test): gen n=_n 
gen baseline_urate=urate_val_ if n==1 & abs_time_to_test!=. 
lab var baseline_urate "Serum urate at baseline"
drop n
by patient_id: replace baseline_urate = baseline_urate[_n-1] if missing(baseline_urate)
gen baseline_urate_below360=1 if baseline_urate<=360 & baseline_urate!=.
replace baseline_urate_below360=0 if baseline_urate>360 & baseline_urate!=.
gen baseline_urate_below300=1 if baseline_urate<=300 & baseline_urate!=.
replace baseline_urate_below300=0 if baseline_urate>300 & baseline_urate!=.
drop abs_time_to_test

drop test_after_ult time_to_test		
reshape wide urate_val_ urate_date_ urate_test_, i(patient_id) j(urate_order)
tabstat baseline_urate, stats(n mean p50 p25 p75)
tab baseline_urate_below360, missing
tab baseline_urate_below300, missing

*Proportion of patients with >6m/12m of registration and follow-up after first ULT prescription, assuming first prescription was within 12m of diagnosis //should this be 6m or 12m
gen has_6m_post_ult=1 if first_ult_date!=. & first_ult_date<(date("$end_date", "DMY")-180) & has_6m_follow_up_ult==1 & ult_12m==1
recode has_6m_post_ult .=0
lab var has_6m_post_ult ">6m follow-up after ULT"
lab define has_6m_post_ult 0 "No" 1 "Yes", modify
lab val has_6m_post_ult has_6m_post_ult
tab has_6m_post_ult, missing 

gen has_12m_post_ult=1 if first_ult_date!=. & first_ult_date<(date("$end_date", "DMY")-365) & has_12m_follow_up_ult==1 & ult_12m==1
recode has_12m_post_ult .=0
lab var has_12m_post_ult ">12m follow-up after ULT"
lab define has_12m_post_ult 0 "No" 1 "Yes", modify
lab val has_12m_post_ult has_12m_post_ult
tab has_12m_post_ult, missing 

*Define flare==============================================================================*/

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
reshape wide gout_emerg_date_ gout_emerg_, i(patient_id) j(emerg_order)

**Any non-index gout diagnostic code AND prescription for a flare treatment on same day as that code;
reshape long gout_code_any_ gout_code_any_date_, i(patient_id) j(code_order)
gen code_and_tx_date_=.
format %td code_and_tx_date_
forval i = 1/9 	{
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
reshape wide gout_flare_date_ gout_flare_, i(patient_id) j(flare_order)

**Now merge flare count in with original dataset
merge 1:1 patient_id using "$projectdir/output/data/flare_count.dta"
drop _merge
recode flare_count .=0
tabstat flare_count, stats (n mean p50 p25 p75)
gen multiple_flares = 1 if flare_count>=1 & flare_count!=. //define multiple flares as one or more additional flare within first 6 months of diagnosis
recode multiple_flares .=0
tab multiple_flares	

*Define high-risk patients for ULT===========================================================*/
gen high_risk = 1 if tophi==1 | ckd==1 | diuretic==1 | multiple_flares==1
recode high_risk .=0	









*Time to rheum referral (see notes above)=============================================*/

**Time from last GP to rheum ref before rheum appt (i.e. if appts are present and in correct time order)
gen time_gp_rheum_ref_appt = (referral_rheum_prerheum_date - last_gp_refrheum_date) if referral_rheum_prerheum_date!=. & last_gp_refrheum_date!=. & rheum_appt_date!=. & referral_rheum_prerheum_date>=last_gp_refrheum_date & referral_rheum_prerheum_date<=rheum_appt_date
tabstat time_gp_rheum_ref_appt, stats (n mean p50 p25 p75) //all patients (should be same number as all_appts)

gen gp_ref_cat=1 if time_gp_rheum_ref_appt<=3 & time_gp_rheum_ref_appt!=. 
replace gp_ref_cat=2 if time_gp_rheum_ref_appt>3 & time_gp_rheum_ref_appt<=7 & time_gp_rheum_ref_appt!=. & gp_ref_cat==.
replace gp_ref_cat=3 if time_gp_rheum_ref_appt>7 & time_gp_rheum_ref_appt!=. & gp_ref_cat==.
lab define gp_ref_cat 1 "Within 3 days" 2 "Between 3-7 days" 3 "More than 7 days", modify
lab val gp_ref_cat gp_ref_cat
lab var gp_ref_cat "Time to GP referral"
tab gp_ref_cat, missing

gen gp_ref_3d=1 if time_gp_rheum_ref_appt<=3 & time_gp_rheum_ref_appt!=. 
replace gp_ref_3d=2 if time_gp_rheum_ref_appt>3 & time_gp_rheum_ref_appt!=.
lab define gp_ref_3d 1 "Within 3 days" 2 "More than 3 days", modify
lab val gp_ref_3d gp_ref_3d
lab var gp_ref_3d "Time to GP referral"
tab gp_ref_3d, missing

**Time from last GP to rheum ref before gout code (sensitivity analysis; includes those with no rheum appt)
gen time_gp_rheum_ref_code = (referral_rheum_precode_date - last_gp_refcode_date) if referral_rheum_precode_date!=. & last_gp_refcode_date!=. & referral_rheum_precode_date>=last_gp_refcode_date & referral_rheum_precode_date<=gout_code_date
tabstat time_gp_rheum_ref_code, stats (n mean p50 p25 p75)

**Time from last GP to rheum ref (combined - sensitivity analysis; includes those with no rheum appt)
gen time_gp_rheum_ref_comb = time_gp_rheum_ref_appt 
replace time_gp_rheum_ref_comb = time_gp_rheum_ref_code if time_gp_rheum_ref_appt==. & time_gp_rheum_ref_code!=.
tabstat time_gp_rheum_ref_comb, stats (n mean p50 p25 p75)

*Time to rheum appointment=============================================*/

**Time from last GP pre-rheum appt to first rheum appt (proxy for referral to appt delay)
gen time_gp_rheum_appt = (rheum_appt_date - last_gp_prerheum_date) if rheum_appt_date!=. & last_gp_prerheum_date!=. & rheum_appt_date>=last_gp_prerheum_date
tabstat time_gp_rheum_appt, stats (n mean p50 p25 p75)

**Time from rheum ref to rheum appt (i.e. if appts are present and in correct order)
gen time_ref_rheum_appt = (rheum_appt_date - referral_rheum_prerheum_date) if rheum_appt_date!=. & referral_rheum_prerheum_date!=. & referral_rheum_prerheum_date<=rheum_appt_date
tabstat time_ref_rheum_appt, stats (n mean p50 p25 p75)

gen gp_appt_cat=1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=. 
replace gp_appt_cat=2 if time_gp_rheum_appt>21 & time_gp_rheum_appt<=42 & time_gp_rheum_appt!=. & gp_appt_cat==.
replace gp_appt_cat=3 if time_gp_rheum_appt>42 & time_gp_rheum_appt!=. & gp_appt_cat==.
lab define gp_appt_cat 1 "Within 3 weeks" 2 "Between 3-6 weeks" 3 "More than 6 weeks", modify
lab val gp_appt_cat gp_appt_cat
lab var gp_appt_cat "Time to rheumatology assessment, overall"
tab gp_appt_cat, missing

gen gp_appt_cat_19=gp_appt_cat if appt_year==1
gen gp_appt_cat_20=gp_appt_cat if appt_year==2
gen gp_appt_cat_21=gp_appt_cat if appt_year==3
gen gp_appt_cat_22=gp_appt_cat if appt_year==4
lab define gp_appt_cat_19 1 "Within 3 weeks" 2 "Between 3-6 weeks" 3 "More than 6 weeks", modify
lab val gp_appt_cat_19 gp_appt_cat_19
lab var gp_appt_cat_19 "Time to rheumatology assessment, Apr 2019-2020"
lab define gp_appt_cat_20 1 "Within 3 weeks" 2 "Between 3-6 weeks" 3 "More than 6 weeks", modify
lab val gp_appt_cat_20 gp_appt_cat_20
lab var gp_appt_cat_20 "Time to rheumatology assessment, Apr 2020-2021"
lab define gp_appt_cat_21 1 "Within 3 weeks" 2 "Between 3-6 weeks" 3 "More than 6 weeks", modify
lab val gp_appt_cat_21 gp_appt_cat_21
lab var gp_appt_cat_21 "Time to rheumatology assessment, Apr 2021-2022"
lab define gp_appt_cat_22 1 "Within 3 weeks" 2 "Between 3-6 weeks" 3 "More than 6 weeks", modify
lab val gp_appt_cat_22 gp_appt_cat_22
lab var gp_appt_cat_22 "Time to rheumatology assessment, Apr 2022-2023"

gen gp_appt_3w=1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=. 
replace gp_appt_3w=2 if time_gp_rheum_appt>21 & time_gp_rheum_appt!=.
lab define gp_appt_3w 1 "Within 3 weeks" 2 "More than 3 weeks", modify
lab val gp_appt_3w gp_appt_3w
lab var gp_appt_3w "Time to rheumatology assessment, overall"
tab gp_appt_3w, missing

gen ref_appt_cat=1 if time_ref_rheum_appt<=21 & time_ref_rheum_appt!=. 
replace ref_appt_cat=2 if time_ref_rheum_appt>21 & time_ref_rheum_appt<=42 & time_ref_rheum_appt!=. & ref_appt_cat==.
replace ref_appt_cat=3 if time_ref_rheum_appt>42 & time_ref_rheum_appt!=. & ref_appt_cat==.
lab define ref_appt_cat 1 "Within 3 weeks" 2 "Between 3-6 weeks" 3 "More than 6 weeks", modify
lab val ref_appt_cat ref_appt_cat
lab var ref_appt_cat "Time to rheumatology assessment"
tab ref_appt_cat, missing

gen ref_appt_3w=1 if time_ref_rheum_appt<=21 & time_ref_rheum_appt!=. 
replace ref_appt_3w=2 if time_ref_rheum_appt>21 & time_ref_rheum_appt!=.
lab define ref_appt_3w 1 "Within 3 weeks" 2 "More than 3 weeks", modify
lab val ref_appt_3w ref_appt_3w
lab var ref_appt_3w "Time to rheumatology assessment"
tab ref_appt_3w, missing

**Time from rheum ref or last GP to rheum appt (combined; includes those with no rheum ref)
gen time_refgp_rheum_appt = time_ref_rheum_appt
replace time_refgp_rheum_appt = time_gp_rheum_appt if time_ref_rheum_appt==. & time_gp_rheum_appt!=.
tabstat time_refgp_rheum_appt, stats (n mean p50 p25 p75)

*Time to EIA code==================================================*/

**Time from last GP pre-code to EIA code (sensitivity analysis; includes those with no rheum ref and/or no rheum appt)
gen time_gp_eia_code = (eia_code_date - last_gp_precode_date) if eia_code_date!=. & last_gp_precode_date!=. & eia_code_date>=last_gp_precode_date
tabstat time_gp_eia_code, stats (n mean p50 p25 p75)

**Time from last GP to EIA diagnosis (combined - sensitivity analysis; includes those with no rheum appt)
gen time_gp_eia_diag = time_gp_rheum_appt
replace time_gp_eia_diag = time_gp_eia_code if time_gp_rheum_appt==. & time_gp_eia_code!=.
tabstat time_gp_eia_diag, stats (n mean p50 p25 p75)

**Time from rheum ref to EIA code (sensitivity analysis; includes those with no rheum appt)
gen time_ref_rheum_eia = (eia_code_date - referral_rheum_precode_date) if eia_code_date!=. & referral_rheum_precode_date!=. & referral_rheum_precode_date<=eia_code_date  
tabstat time_ref_rheum_eia, stats (n mean p50 p25 p75)

**Time from rheum ref to EIA diagnosis (combined - sensitivity analysis; includes those with no rheum appt)
gen time_ref_rheum_eia_comb = time_ref_rheum_appt
replace time_ref_rheum_eia_comb = time_ref_rheum_eia if time_ref_rheum_appt==. & time_ref_rheum_eia!=.
tabstat time_ref_rheum_eia_comb, stats (n mean p50 p25 p75)

**Time from rheum appt to EIA code
gen time_rheum_eia_code = (eia_code_date - rheum_appt_date) if eia_code_date!=. & rheum_appt_date!=. 
tabstat time_rheum_eia_code, stats (n mean p50 p25 p75) 
gen time_rheum2_eia_code = (eia_code_date - rheum_appt2_date) if eia_code_date!=. & rheum_appt2_date!=. 
tabstat time_rheum2_eia_code, stats (n mean p50 p25 p75) 
gen time_rheum3_eia_code = (eia_code_date - rheum_appt3_date) if eia_code_date!=. & rheum_appt3_date!=. 
tabstat time_rheum3_eia_code, stats (n mean p50 p25 p75) 

*Time from rheum appt to first csDMARD prescriptions on primary care record======================================================================*/

**Time to first csDMARD script for RA patients not including high cost MTX prescriptions; prescription must be within 6 months of first rheum appt for all csDMARDs below ==================*/
gen time_to_csdmard=(csdmard_date-rheum_appt_date) if csdmard==1 & rheum_appt_date!=. & (csdmard_date<=rheum_appt_date+180)
tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75)

**Time to first csDMARD script for RA patients (including high cost MTX prescriptions)
gen time_to_csdmard_hcd=(csdmard_hcd_date-rheum_appt_date) if csdmard_hcd==1 & rheum_appt_date!=. & (csdmard_hcd_date<=rheum_appt_date+180)
tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) 

**Time to first csDMARD script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75)

**Time to first csDMARD script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) 

**Time to first csDMARD script for axSpA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if anksp_code==1, stats (n mean p50 p25 p75)

**Time to first csDMARD script for Undiff IA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if undiff_code==1, stats (n mean p50 p25 p75)

**csDMARD time categories (not including high cost MTX prescriptions)
gen csdmard_time=1 if time_to_csdmard<=90 & time_to_csdmard!=. 
replace csdmard_time=2 if time_to_csdmard>90 & time_to_csdmard<=180 & time_to_csdmard!=.
replace csdmard_time=3 if time_to_csdmard>180 | time_to_csdmard==.
lab define csdmard_time 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months", modify
lab val csdmard_time csdmard_time
lab var csdmard_time "csDMARD in primary care, overall" 
tab csdmard_time if ra_code==1, missing 
tab csdmard_time if psa_code==1, missing
tab csdmard_time if anksp_code==1, missing
tab csdmard_time if undiff_code==1, missing

gen csdmard_time_19=csdmard_time if appt_year==1
recode csdmard_time_19 .=4
gen csdmard_time_20=csdmard_time if appt_year==2
recode csdmard_time_20 .=4
gen csdmard_time_21=csdmard_time if appt_year==3
recode csdmard_time_21 .=4
gen csdmard_time_22=csdmard_time if appt_year==4
recode csdmard_time_22 .=4
lab define csdmard_time_19 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months" 4 "Outside 2019", modify
lab val csdmard_time_19 csdmard_time_19
lab var csdmard_time_19 "csDMARD in primary care, Apr 2019-2020" 
lab define csdmard_time_20 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months" 4 "Outside 2020", modify
lab val csdmard_time_20 csdmard_time_20
lab var csdmard_time_20 "csDMARD in primary care, Apr 2020-2021" 
lab define csdmard_time_21 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months" 4 "Outside 2021", modify
lab val csdmard_time_21 csdmard_time_21
lab var csdmard_time_21 "csDMARD in primary care, Apr 2021-2022" 
lab define csdmard_time_22 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months" 4 "Outside 2021", modify
lab val csdmard_time_22 csdmard_time_22
lab var csdmard_time_22 "csDMARD in primary care, Apr 2022-2023" 

**csDMARD time categories - binary 6 months
gen csdmard_6m=1 if time_to_csdmard<=180 & time_to_csdmard!=. 
replace csdmard_6m=0 if time_to_csdmard>180 | time_to_csdmard==.
lab define csdmard_6m 1 "Yes" 0 "No", modify
lab val csdmard_6m csdmard_6m
lab var csdmard_6m "csDMARD in primary care within 6 months" 
tab csdmard_6m, missing 

**csDMARD time categories (including high cost MTX prescriptions)
gen csdmard_hcd_time=1 if time_to_csdmard_hcd<=90 & time_to_csdmard_hcd!=. 
replace csdmard_hcd_time=2 if time_to_csdmard_hcd>90 & time_to_csdmard_hcd<=180 & time_to_csdmard_hcd!=.
replace csdmard_hcd_time=3 if time_to_csdmard_hcd>180 | time_to_csdmard_hcd==.
lab define csdmard_hcd_time 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months", modify
lab val csdmard_hcd_time csdmard_hcd_time
lab var csdmard_hcd_time "csDMARD in primary care" 
tab csdmard_hcd_time if ra_code==1, missing 
tab csdmard_hcd_time if psa_code==1, missing
tab csdmard_hcd_time if anksp_code==1, missing 
tab csdmard_hcd_time if undiff_code==1, missing

**What was first csDMARD in GP record (not including high cost MTX prescriptions) - removed leflunomide (for OpenSAFELY report) due to small counts at more granular time periods
gen first_csD=""
foreach var of varlist hydroxychloroquine_date methotrexate_date methotrexate_inj_date sulfasalazine_date {
	replace first_csD="`var'" if csdmard_date==`var' & csdmard_date!=. & (`var'<=(rheum_appt_date+180)) & time_to_csdmard!=.
	}
gen first_csDMARD = substr(first_csD, 1, length(first_csD) - 5) if first_csD!="" 
drop first_csD
replace first_csDMARD="Methotrexate" if first_csDMARD=="methotrexate" | first_csDMARD=="methotrexate_inj" //combine oral and s/c MTX
replace first_csDMARD="Sulfasalazine" if first_csDMARD=="sulfasalazine"
replace first_csDMARD="Hydroxychloroquine" if first_csDMARD=="hydroxychloroquine" 
tab first_csDMARD if ra_code==1 //for RA patients
tab first_csDMARD if psa_code==1 //for PsA patients
tab first_csDMARD if anksp_code==1 //for axSpA patients
tab first_csDMARD if undiff_code==1 //for Undiff IA patients

**What was first csDMARD in GP record (including high cost MTX prescriptions)
gen first_csD_hcd=""
foreach var of varlist hydroxychloroquine_date methotrexate_date methotrexate_inj_date methotrexate_hcd_date sulfasalazine_date {
	replace first_csD_hcd="`var'" if csdmard_hcd_date==`var' & csdmard_hcd_date!=. & (csdmard_hcd_date<=rheum_appt_date+180) & time_to_csdmard_hcd!=.
	}
gen first_csDMARD_hcd = substr(first_csD_hcd, 1, length(first_csD_hcd) - 5) if first_csD_hcd!=""
drop first_csD_hcd
tab first_csDMARD_hcd if ra_code==1 //for RA patients
tab first_csDMARD_hcd if psa_code==1 //for PsA patients
tab first_csDMARD_hcd if anksp_code==1 //for axSpA patients
tab first_csDMARD_hcd if undiff_code==1 //for Undiff IA patients
 
**Methotrexate use (not including high cost MTX prescriptions)
gen mtx=1 if methotrexate==1 | methotrexate_inj==1
recode mtx .=0 

**Methotrexate use (including high cost MTX prescriptions)
gen mtx_hcd=1 if methotrexate==1 | methotrexate_inj==1 | methotrexate_hcd==1
recode mtx_hcd .=0 

**Date of first methotrexate script (not including high cost MTX prescriptions)
gen mtx_date=min(methotrexate_date, methotrexate_inj_date)
format %td mtx_date

**Date of first methotrexate script (including high cost MTX prescriptions)
gen mtx_hcd_date=min(methotrexate_date, methotrexate_inj_date, methotrexate_hcd_date)
format %td mtx_hcd_date

**Methotrexate use (not including high cost MTX prescriptions)
tab mtx if ra_code==1 //for RA patients; Nb. this is just a check; need time-to-MTX instead (below)
tab mtx if ra_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit
tab mtx if ra_code==1 & (mtx_date<=rheum_appt_date+365) //with 12-month limit
tab mtx if psa_code==1 //for PsA patients
tab mtx if psa_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit
tab mtx if psa_code==1 & (mtx_date<=rheum_appt_date+365) //with 12-month limit
tab mtx if undiff_code==1 //for undiff IA patients
tab mtx if undiff_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit
tab mtx if undiff_code==1 & (mtx_date<=rheum_appt_date+365) //with 12-month limit

**Methotrexate use (including high cost MTX prescriptions)
tab mtx_hcd if ra_code==1 //for RA patients
tab mtx_hcd if ra_code==1 & (mtx_hcd_date<=rheum_appt_date+180) //with 6-month limit
tab mtx_hcd if ra_code==1 & (mtx_hcd_date<=rheum_appt_date+365) //with 12-month limit
tab mtx_hcd if psa_code==1 //for PsA patients
tab mtx_hcd if psa_code==1 & (mtx_hcd_date<=rheum_appt_date+180) //with 6-month limit
tab mtx_hcd if psa_code==1 & (mtx_hcd_date<=rheum_appt_date+365) //with 12-month limit
tab mtx_hcd if undiff_code==1 //for undiff IA patients
tab mtx_hcd if undiff_code==1 & (mtx_hcd_date<=rheum_appt_date+180) //with 6-month limit
tab mtx_hcd if undiff_code==1 & (mtx_hcd_date<=rheum_appt_date+365) //with 12-month limit

**Check if medication issued >once
gen mtx_shared=1 if mtx==1 & (methotrexate_count>1 | methotrexate_inj_count>1)
recode mtx_shared .=0
tab mtx_shared

**Methotrexate use (shared care)
tab mtx_shared if ra_code==1 //for RA patients; Nb. this is just a check; need time-to-MTX instead (below)
tab mtx_shared if ra_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit
tab mtx_shared if psa_code==1 //for PsA patients
tab mtx_shared if psa_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit
tab mtx_shared if undiff_code==1 //for undiff IA patients
tab mtx_shared if undiff_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit

**Check medication issue number
gen mtx_issue=0 if mtx==1 & (methotrexate_count==0 | methotrexate_inj_count==0)
replace mtx_issue=1 if mtx==1 & (methotrexate_count==1 | methotrexate_inj_count==1)
replace mtx_issue=2 if mtx==1 & (methotrexate_count>1 | methotrexate_inj_count>1)
tab mtx_issue

**Time to first methotrexate script for RA patients (not including high cost MTX prescriptions)
gen time_to_mtx=(mtx_date-rheum_appt_date) if mtx==1 & rheum_appt_date!=. & (mtx_date<=rheum_appt_date+180)
tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75)

**Time to first methotrexate script for RA patients (including high cost MTX prescriptions)
gen time_to_mtx_hcd=(mtx_hcd_date-rheum_appt_date) if mtx_hcd==1 & rheum_appt_date!=. & (mtx_hcd_date<=rheum_appt_date+180)
tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75)

**Time to first methotrexate script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75)

**Time to first methotrexate script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75)

**Time to first methotrexate script for Undiff IA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if undiff_code==1, stats (n mean p50 p25 p75)

**Methotrexate time categories (not including high-cost MTX)  
gen mtx_time=1 if time_to_mtx<=90 & time_to_mtx!=. 
replace mtx_time=2 if time_to_mtx>90 & time_to_mtx<=180 & time_to_mtx!=.
replace mtx_time=3 if time_to_mtx>180 | time_to_mtx==.
lab define mtx_time 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months", modify
lab val mtx_time mtx_time
lab var mtx_time "Methotrexate in primary care" 
tab mtx_time if ra_code==1, missing 
tab mtx_time if psa_code==1, missing
tab mtx_time if undiff_code==1, missing 

**Methotrexate time categories for RA patients (including high-cost MTX)
gen mtx_hcd_time=1 if time_to_mtx_hcd<=90 & time_to_mtx_hcd!=. 
replace mtx_hcd_time=2 if time_to_mtx_hcd>90 & time_to_mtx_hcd<=180 & time_to_mtx_hcd!=.
replace mtx_hcd_time=3 if time_to_mtx_hcd>180 | time_to_mtx_hcd==.
lab define mtx_hcd_time 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months", modify
lab val mtx_hcd_time mtx_hcd_time
lab var mtx_hcd_time "Methotrexate in primary care" 
tab mtx_hcd_time if ra_code==1, missing 
tab mtx_hcd_time if psa_code==1, missing
tab mtx_hcd_time if undiff_code==1, missing 

**Sulfasalazine use
gen ssz=1 if sulfasalazine==1
recode ssz .=0 

**Time to first sulfasalazine script for RA patients
gen time_to_ssz=(sulfasalazine_date-rheum_appt_date) if sulfasalazine_date!=. & rheum_appt_date!=. & (sulfasalazine_date<=rheum_appt_date+180)
tabstat time_to_ssz if ra_code==1, stats (n mean p50 p25 p75)
tabstat time_to_ssz if psa_code==1, stats (n mean p50 p25 p75)

**Sulfasalazine time categories  
gen ssz_time=1 if time_to_ssz<=90 & time_to_ssz!=. 
replace ssz_time=2 if time_to_ssz>90 & time_to_ssz<=180 & time_to_ssz!=.
replace ssz_time=3 if time_to_ssz>180 | time_to_ssz==.
lab define ssz_time 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months", modify
lab val ssz_time ssz_time
lab var ssz_time "Sulfasalazine in primary care" 
tab ssz_time if ra_code==1, missing 
tab ssz_time if psa_code==1, missing
tab ssz_time if undiff_code==1, missing 

**Check if medication issued >once
gen ssz_shared=1 if ssz==1 & sulfasalazine_count>1
recode ssz_shared .=0
tab ssz_shared

**sulfasalazine use (shared care)
tab ssz_shared if ra_code==1 
tab ssz_shared if ra_code==1 & (sulfasalazine_date<=rheum_appt_date+180)
tab ssz_shared if psa_code==1 
tab ssz_shared if psa_code==1 & (sulfasalazine_date<=rheum_appt_date+180) 
tab ssz_shared if undiff_code==1
tab ssz_shared if undiff_code==1 & (sulfasalazine_date<=rheum_appt_date+180)

**Check medication issue number
gen ssz_issue=0 if ssz==1 & sulfasalazine_count==0 
replace ssz_issue=1 if ssz==1 & sulfasalazine_count==1 
replace ssz_issue=2 if ssz==1 & sulfasalazine_count>1
tab ssz_issue

**Hydroxychloroquine use
gen hcq=1 if hydroxychloroquine==1
recode hcq .=0 

**Time to first hydroxychloroquine script for RA patients
gen time_to_hcq=(hydroxychloroquine_date-rheum_appt_date) if hydroxychloroquine_date!=. & rheum_appt_date!=. & (hydroxychloroquine_date<=rheum_appt_date+180)
tabstat time_to_hcq if ra_code==1, stats (n mean p50 p25 p75)
tabstat time_to_hcq if psa_code==1, stats (n mean p50 p25 p75)

**Hydroxychloroquine time categories  
gen hcq_time=1 if time_to_hcq<=90 & time_to_hcq!=. 
replace hcq_time=2 if time_to_hcq>90 & time_to_hcq<=180 & time_to_hcq!=.
replace hcq_time=3 if time_to_hcq>180 | time_to_hcq==.
lab define hcq_time 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months", modify
lab val hcq_time hcq_time
lab var hcq_time "Hydroxychloroquine in primary care" 
tab hcq_time if ra_code==1, missing 
tab hcq_time if psa_code==1, missing
tab hcq_time if undiff_code==1, missing 

**Check if medication issued >once
gen hcq_shared=1 if hcq==1 & hydroxychloroquine_count>1
recode hcq_shared .=0
tab hcq_shared

**hydroxychloroquine use (shared care)
tab hcq_shared if ra_code==1 
tab hcq_shared if ra_code==1 & (hydroxychloroquine_date<=rheum_appt_date+180)
tab hcq_shared if psa_code==1 
tab hcq_shared if psa_code==1 & (hydroxychloroquine_date<=rheum_appt_date+180) 
tab hcq_shared if undiff_code==1
tab hcq_shared if undiff_code==1 & (hydroxychloroquine_date<=rheum_appt_date+180)

**Check medication issue number
gen hcq_issue=0 if hcq==1 & hydroxychloroquine_count==0 
replace hcq_issue=1 if hcq==1 & hydroxychloroquine_count==1 
replace hcq_issue=2 if hcq==1 & hydroxychloroquine_count>1
tab hcq_issue

**Leflunomide use
gen lef=1 if leflunomide==1
recode lef .=0 

**Time to first leflunomide script for RA patients
gen time_to_lef=(leflunomide_date-rheum_appt_date) if leflunomide_date!=. & rheum_appt_date!=. & (leflunomide_date<=rheum_appt_date+180)
tabstat time_to_lef if ra_code==1, stats (n mean p50 p25 p75)
tabstat time_to_lef if psa_code==1, stats (n mean p50 p25 p75)

**Leflunomide time categories  
gen lef_time=1 if time_to_lef<=90 & time_to_lef!=. 
replace lef_time=2 if time_to_lef>90 & time_to_lef<=180 & time_to_lef!=.
replace lef_time=3 if time_to_lef>180 | time_to_lef==.
lab define lef_time 1 "Within 3 months" 2 "3-6 months" 3 "No prescription within 6 months", modify
lab val lef_time lef_time
lab var lef_time "Leflunomide in primary care" 
tab lef_time if ra_code==1, missing 
tab lef_time if psa_code==1, missing
tab lef_time if undiff_code==1, missing 

**Check if medication issued >once
gen lef_shared=1 if lef==1 & leflunomide_count>1
recode lef_shared .=0
tab lef_shared

**leflunomide use (shared care)
tab lef_shared if ra_code==1 
tab lef_shared if ra_code==1 & (leflunomide_date<=rheum_appt_date+180)
tab lef_shared if psa_code==1 
tab lef_shared if psa_code==1 & (leflunomide_date<=rheum_appt_date+180) 
tab lef_shared if undiff_code==1
tab lef_shared if undiff_code==1 & (leflunomide_date<=rheum_appt_date+180)

**Check medication issue number
gen lef_issue=0 if lef==1 & leflunomide_count==0 
replace lef_issue=1 if lef==1 & leflunomide_count==1 
replace lef_issue=2 if lef==1 & leflunomide_count>1
tab lef_issue

**For all csDMARDs, check if issued more than once 
gen csdmard_shared=1 if lef_shared==1 | mtx_shared==1 | hcq_shared==1 | ssz_shared==1 
recode csdmard_shared .=0
tab csdmard_shared
tab csdmard //for comparison

save "$projectdir/output/data/file_gout_all", replace

log close
