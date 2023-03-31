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
*global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
global projectdir `c(pwd)'

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/figures"
capture mkdir "$projectdir/output/tables"

global logdir "$projectdir/logs"

**Open a log file
cap log close
log using "$logdir/cleaning_dataset.log", replace

!gunzip "$projectdir/output/input.csv.gz"
import delimited "$projectdir/output/input.csv", clear

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Set index dates ===========================================================*/
global year_preceding = "01/03/2014"
global start_date = "01/03/2015"
global end_date = "01/03/2023"

**Rename variables =======================================*/
rename chronic_respiratory_disease chronic_resp_disease
rename chronic_cardiac_disease chronic_card_disease
rename bmi_date_measured bmi_date

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
						 first_ult_date						///
						 first_allo_date					///
						 first_febux_date					///
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
		
forval i = 1/7 	{
					rename urate_test_`i'_date urate_date_`i'
					order urate_test_`i', after(urate_date_`i')
					rename urate_test_`i'_val urate_val_`i'
}

forval i = 1/3 	{
					rename gout_flare_`i'_date gout_flare_date_`i'
					rename gout_code_any_`i'_date gout_code_any_date_`i'
					rename gout_emerg_`i'_date gout_emerg_date_`i'
					rename gout_admission_`i'_date  gout_admission_date_`i'	
}

forval i = 1/6 	{
					rename flare_treatment_`i'_date flare_treatment_date_`i'					
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

***Ethnicity
replace ethnicity = 9 if ethnicity == .
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
						9 "Not known"
label values ethnicity ethnicity
lab var ethnicity "Ethnicity"
tab ethnicity, missing

gen ethnicity_bme=0 if ethnicity==1
replace ethnicity_bme=1 if ethnicity>1 & ethnicity<5
replace ethnicity_bme=9 if ethnicity==9
label define ethnicity_bme 	0 "White"  		///
						1 "Non-white"		///
						9 "Not known"
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
recode imd 0 = 9
label define imd 1 "1 most deprived" 2 "2" 3 "3" 4 "4" 5 "5 least deprived" 9 "Not known"
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
replace bmicat = 9 if bmi_val >= .

label define bmicat 1 "Underweight (<18.5)" 	///
					2 "Normal (18.5-24.9)"		///
					3 "Overweight (25-29.9)"	///
					4 "Obese I (30-34.9)"		///
					5 "Obese II (35-39.9)"		///
					6 "Obese III (40+)"			///
					9 "Not known"
					
label values bmicat bmicat
lab var bmicat "BMI"
tab bmicat, missing

*Create less granular categorisation
recode bmicat 1/3 9 = 1 4 = 2 5 = 3 6 = 4, gen(obese4cat)

label define obese4cat 	1 "No record of obesity" 	///
						2 "Obese I (30-34.9)"		///
						3 "Obese II (35-39.9)"		///
						4 "Obese III (40+)"		

label values obese4cat obese4cat
order obese4cat, after(bmicat)

***Smoking 
label define smoke 1 "Never" 2 "Former" 3 "Current" 9 "Not known"

gen     smoke = 1  if smoking_status == "N"
replace smoke = 2  if smoking_status == "E"
replace smoke = 3  if smoking_status == "S"
replace smoke = 9 if smoking_status == "M"
replace smoke = 9 if smoking_status == "" 

label values smoke smoke
lab var smoke "Smoking status"
drop smoking_status
tab smoke, missing

*Create non-missing 3-category variable for current smoking (assumes missing smoking is never smoking)
recode smoke 9 = 1, gen(smoke_nomiss)
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
replace egfr_cat = 9 if egfr >= .

label define egfr_cat 	1 ">=60" 		///
						2 "30-59"		///
						3 "<30"			///
						9 "Not known"
					
label values egfr_cat egfr_cat
lab var egfr_cat "eGFR"
tab egfr_cat, missing

*If missing eGFR, assume normal
gen egfr_cat_nomiss = egfr_cat
replace egfr_cat_nomiss = 1 if egfr_cat == 9

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
replace hba1ccatmm =9 if hba1ccatmm==. 
label define hba1ccatmm 0 "HbA1c <58mmol/mol" 1 "HbA1c >=58mmol/mol" 9 "Not known"
label values hba1ccatmm hba1ccatmm
lab var hba1ccatmm "HbA1c"
tab hba1ccatmm, missing

*Create diabetes, split by control/not (assumes missing = no diabetes)
gen     diabcatm = 1 if diabetes==0
replace diabcatm = 2 if diabetes==1 & hba1ccatmm==0
replace diabcatm = 3 if diabetes==1 & hba1ccatmm==1
replace diabcatm = 4 if diabetes==1 & hba1ccatmm==9

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

tab first_ult if gout_code_date!=. & first_ult_date!=. & first_ult_date<gout_code_date
tab first_ult if gout_code_date!=. & first_ult_date!=. & (first_ult_date+30)<gout_code_date //30 days before
tab first_ult if gout_code_date!=. & first_ult_date!=. & (first_ult_date+60)<gout_code_date //60 days before
drop if gout_code_date!=. & first_ult_date!=. & (first_ult_date+30)<gout_code_date //drop if first ULT script more than 30 days before first gout code - think about what to do with these (don't drop?)

*Recode index diagnosis date as first ULT date if first ULT date <30 days before index gout code date
replace gout_code_date=first_ult_date if gout_code_date!=. & first_ult_date!=. & (first_ult_date<gout_code_date)

*Check if first gout admission/emergency attendance was before index diagnosis code=====================================================*/

tab gout_admission_pre //admissions for gout that were more than 30 days before gout code
drop if gout_admission_pre==1 //drop those with gout admissions that were more than 30 days before GP gout code 

tab gout_admission_1 //admissions for gout that were from 30 days before gout code and onwards
tab gout_admission_1 if gout_code_date!=. & gout_admission_date_1!=. & gout_admission_date_1<gout_code_date
tab gout_admission_1 if gout_code_date!=. & gout_admission_date_1!=. & (gout_admission_date_1+30)<gout_code_date //30 days before - should be accounted for by study definition - check

*Recode index diagnosis date as gout admission date if gout admission date less than 30 days before index gout code date
replace gout_code_date=gout_admission_date_1 if gout_code_date!=. & first_ult_date!=. & (gout_admission_date_1<gout_code_date)

tab gout_emerg_pre //ED attendances for gout that were more than 30 days before gout code
drop if gout_emerg_pre==1 //drop those with gout ED attendances that were more than 30 days before GP gout code 

tab gout_emerg_1 //ED attendances for gout that were from 30 days before gout code and onwards
tab gout_emerg_1 if gout_code_date!=. & gout_emerg_date_1!=. & gout_emerg_date_1<gout_code_date
tab gout_emerg_1 if gout_code_date!=. & gout_emerg_date_1!=. & (gout_emerg_date_1+30)<gout_code_date //check

*Recode index diagnosis date as gout emerg date if gout emerg date less than 30 days before index gout code date
replace gout_code_date=gout_emerg_date_1 if gout_code_date!=. & first_ult_date!=. & (gout_emerg_date_1<gout_code_date)

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
gen diagnosis_year=1 if diagnosis_date>=td(01mar2015) & diagnosis_date<td(01mar2016)
replace diagnosis_year=2 if diagnosis_date>=td(01mar2016) & diagnosis_date<td(01mar2017)
replace diagnosis_year=3 if diagnosis_date>=td(01mar2017) & diagnosis_date<td(01mar2018)
replace diagnosis_year=4 if diagnosis_date>=td(01mar2018) & diagnosis_date<td(01mar2019)
replace diagnosis_year=5 if diagnosis_date>=td(01mar2019) & diagnosis_date<td(01mar2020)
replace diagnosis_year=6 if diagnosis_date>=td(01mar2020) & diagnosis_date<td(01mar2021)
replace diagnosis_year=7 if diagnosis_date>=td(01mar2021) & diagnosis_date<td(01mar2022)
replace diagnosis_year=8 if diagnosis_date>=td(01mar2022) & diagnosis_date<td(01mar2023)
lab define diagnosis_year 1 "2015" 2 "2016" 3 "2017" 4 "2018" 5 "2019" 6 "2020" 7 "2021" 8 "2022", modify
lab val diagnosis_year diagnosis_year
lab var diagnosis_year "Year of diagnosis"
tab diagnosis_year, missing

*Number of diagnoses in time windows=========================================*/

**Month/Year of first ult
gen year_ult=year(first_ult_date)
format year_ult %ty
gen month_ult=month(first_ult_date)
gen mo_year_ult=ym(year_ult, month_ult)
format mo_year_ult %tmMon-CCYY
generate str16 mo_year_ult_s = strofreal(mo_year_ult,"%tmCCYY!mNN")
lab var mo_year_ult "Month/Year of first ULT prescription"
lab var mo_year_ult_s "Month/Year of first ULT prescription"

**Separate into 12-month time windows (for first ult date)
gen ult_year=1 if first_ult_date>=td(01mar2015) & first_ult_date<td(01mar2016)
replace ult_year=2 if first_ult_date>=td(01mar2016) & first_ult_date<td(01mar2017)
replace ult_year=3 if first_ult_date>=td(01mar2017) & first_ult_date<td(01mar2018)
replace ult_year=4 if first_ult_date>=td(01mar2018) & first_ult_date<td(01mar2019)
replace ult_year=5 if first_ult_date>=td(01mar2019) & first_ult_date<td(01mar2020)
replace ult_year=6 if first_ult_date>=td(01mar2020) & first_ult_date<td(01mar2021)
replace ult_year=7 if first_ult_date>=td(01mar2021) & first_ult_date<td(01mar2022)
replace ult_year=8 if first_ult_date>=td(01mar2022) & first_ult_date<td(01mar2023)
lab define ult_year 1 "2015" 2 "2016" 3 "2017" 4 "2018" 5 "2019" 6 "2020" 7 "2021" 8 "2022", modify
lab val ult_year ult_year
lab var ult_year "Year of first ULT prescription"
tab ult_year, missing

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
lab var ult_6m "ULT within 6 months of diagnosis"
lab define ult_6m 0 "No" 1 "Yes", modify
lab val ult_6m ult_6m
tab ult_6m, missing
tab ult_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
gen ult_6m_diag = 1 if ult_6m==1 & has_6m_post_diag==1 //should be same as above
recode ult_6m_diag .=0
lab var ult_6m_diag "ULT within 6 months of diagnosis (6m+ follow-up)"
lab define ult_6m_diag 0 "No" 1 "Yes", modify
lab val ult_6m_diag ult_6m_diag
tab ult_6m_diag, missing
tab ult_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Generate variable for those who had ULT prescription within 12m of diagnosis 
gen ult_12m = 1 if time_to_ult<=365 & time_to_ult!=.
recode ult_12m .=0
lab var ult_12m "ULT within 12 months of diagnosis"
lab define ult_12m 0 "No" 1 "Yes", modify
lab val ult_12m ult_12m
tab ult_12m, missing
tab ult_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up
gen ult_12m_diag = 1 if ult_12m==1 & has_12m_post_diag==1 //should be same as above
recode ult_12m_diag .=0
lab var ult_12m_diag "ULT within 12 months of diagnosis (12m+ follow-up)"
lab define ult_12m_diag 0 "No" 1 "Yes", modify
lab val ult_12m_diag ult_12m_diag
tab ult_12m_diag, missing

**Generate variable for time to first allopurinol prescription
gen time_to_allo = first_allo_date-gout_code_date if first_allo_date!=. & gout_code_date!=.

**Generate variable for those who had allopurinol prescription within 6m of diagnosis 
gen allo_6m = 1 if time_to_allo<=180 & time_to_allo!=.
recode allo_6m .=0
lab var allo_6m "Allopurinol within 6 months of diagnosis"
lab define allo_6m 0 "No" 1 "Yes", modify
lab val allo_6m allo_6m
tab allo_6m, missing
tab allo_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
tab allo_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Generate variable for those who had allopurinol prescription within 12m of diagnosis 
gen allo_12m = 1 if time_to_allo<=365 & time_to_allo!=.
recode allo_12m .=0
lab var allo_12m "Allopurinol within 12 months of diagnosis"
lab define allo_12m 0 "No" 1 "Yes", modify
lab val allo_12m allo_12m
tab allo_12m, missing
tab allo_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up 

**Generate variable for time to first febuxostat prescription
gen time_to_febux = first_febux_date-gout_code_date if first_febux_date!=. & gout_code_date!=.

**Generate variable for those who had febuxostat prescription within 6m of diagnosis 
gen febux_6m = 1 if time_to_febux<=180 & time_to_febux!=.
recode febux_6m .=0
lab var febux_6m "Febuxostat within 6 months of diagnosis"
lab define febux_6m 0 "No" 1 "Yes", modify
lab val febux_6m febux_6m
tab febux_6m, missing
tab febux_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
tab febux_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Generate variable for those who had febuxostat prescription within 12m of diagnosis 
gen febux_12m = 1 if time_to_febux<=365 & time_to_febux!=.
recode febux_12m .=0
lab var febux_12m "Febuxostat within 12 months of diagnosis"
lab define febux_12m 0 "No" 1 "Yes", modify
lab val febux_12m febux_12m
tab febux_12m, missing
tab febux_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up 

//Nb. can't tell dose - e.g. if allopurinol 100mg tablets issued, don't know dose prescribed

*Proportion of patients with >6m/12m of registration and follow-up after first ULT prescription, assuming first prescription was within 6m of diagnosis
gen has_6m_post_ult=1 if first_ult_date!=. & first_ult_date<(date("$end_date", "DMY")-180) & has_6m_follow_up_ult==1 & ult_6m==1 & has_6m_post_diag==1
recode has_6m_post_ult .=0
lab var has_6m_post_ult ">6m follow-up after ULT commenced"
lab define has_6m_post_ult 0 "No" 1 "Yes", modify
lab val has_6m_post_ult has_6m_post_ult
tab has_6m_post_ult, missing 
tab has_6m_post_ult if ult_6m==1, missing 
tab has_6m_post_ult if ult_6m==1 & has_6m_post_diag==1, missing 

gen has_12m_post_ult=1 if first_ult_date!=. & first_ult_date<(date("$end_date", "DMY")-365) & has_12m_follow_up_ult==1 & ult_6m==1 & has_12m_post_diag==1
recode has_12m_post_ult .=0
lab var has_12m_post_ult ">12m follow-up after ULT commenced"
lab define has_12m_post_ult 0 "No" 1 "Yes", modify
lab val has_12m_post_ult has_12m_post_ult
tab has_12m_post_ult, missing 
tab has_12m_post_ult if ult_12m==1, missing
tab has_12m_post_ult if ult_12m==1 & has_12m_post_diag==1, missing

**Number of ULT prescriptions issued in 6m after first script issued (Nb. doses may be double counted if both 300mg and 100mg issued)
tabstat ult_count_6m, stats (n mean sd p50 p25 p75)
tabstat ult_count_12m, stats (n mean sd p50 p25 p75)

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

*Define baseline serum urate level as urate level closest to index diagnosis date (must be within 6m before/after diagnosis and before ULT commencement)
bys patient_id urate_date_ (urate_val_): gen n=_n //keeps only single urate test from same day (i.e. delete duplicates), priotising ones !=.
drop if n>1 
drop n

gen test_after_ult=1 if urate_date_>first_ult_date & urate_date_!=. & first_ult_date!=.
replace test_after_ult=0 if urate_date_<=first_ult_date & urate_date_!=.
gen time_to_test = urate_date_-gout_code_date if urate_date_!=. & gout_code_date!=. //time to urate test from diagnosis date

gen abs_time_to_test = abs(time_to_test) if time_to_test!=. & time_to_test<=180 & time_to_test>=-180 & test_after_ult!=1 & urate_val_!=.
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

*Define proportion of patients who attained serum urate <360 within 6 months of diagnosis, irrespective of ULT
gen had_test_6m = 1 if (time_to_test>0 & time_to_test<=180) & urate_val_!=. //any test done within 6 months of diagnosis
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
gen value_test_6m = urate_val_ if (time_to_test>0 & time_to_test<=180) & urate_val_!=. //test values within 6 months of diagnosis
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

*Define proportion of patients who attained serum urate <360 within 12 months of diagnosis, irrespective of ULT
gen had_test_12m = 1 if (time_to_test>0 & time_to_test<=365) & urate_val_!=. //any test done within 12 months of diagnosis
bys patient_id (had_test_12m): gen n=_n if had_test_12m!=.
by patient_id: egen count_urate_12m = max(n) //number of tests within 12m
recode count_urate_12m .=0 //includes those who didn't receive ULT
lab var count_urate_12m "Number of urate levels within 12m of diagnosis"
drop n
sort patient_id had_test_12m
by patient_id: replace had_test_12m = had_test_12m[_n-1] if missing(had_test_12m) //any test done within 12 months of diagnosis
recode had_test_12m .=0 //includes those who didn't receive ULT
lab var had_test_12m "Urate test performed within 12 months of diagnosis"
lab def had_test_12m 0 "No" 1 "Yes", modify
lab val had_test_12m had_test_12m
gen value_test_12m = urate_val_ if (time_to_test>0 & time_to_test<=365) & urate_val_!=. //test values within 12 months of diagnosis
bys patient_id (value_test_12m): gen n=_n if value_test_12m!=.
gen lowest_urate_12m = value_test_12m if n==1 //lowest urate value within 12m of diagnosis
lab var lowest_urate_12m "Lowest urate value within 12m of diagnosis"
sort patient_id (lowest_urate_12m)
by patient_id: replace lowest_urate_12m = lowest_urate_12m[_n-1] if missing(lowest_urate_12m)
drop n value_test_12m
gen urate_below360_12m = 1 if lowest_urate_12m<=360 & lowest_urate_12m!=.
lab var urate_below360_12m  "Urate <360 micromol/L within 12m of diagnosis"
lab def urate_below360_12m 0 "No" 1 "Yes", modify
lab val urate_below360_12m urate_below360_12m
recode urate_below360_12m .=0 //includes those who didn't have a test within 12m

drop time_to_test

*Define proportion of patients commenced on ULT within 6 months of diagnosis who attained serum urate <360 within 6 months of ULT commencement 
gen time_to_test_ult_6m = urate_date_- first_ult_date if urate_date_!=. & first_ult_date!=. & test_after_ult==1
gen had_test_ult_6m = 1 if time_to_test_ult_6m<=180 & time_to_test_ult_6m!=. & urate_val_!=. //any test done within 6 months of ULT
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
gen value_test_ult_6m = urate_val_ if time_to_test_ult_6m<=180 & time_to_test_ult_6m!=. & urate_val_!=. //test values within 6 months of ULT
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

*Define proportion of patients commenced on ULT within 6 months (important) of diagnosis who attained serum urate <360 within 12 months of ULT commencement
gen time_to_test_ult_12m = urate_date_- first_ult_date if urate_date_!=. & first_ult_date!=. & test_after_ult==1
gen had_test_ult_12m = 1 if time_to_test_ult_12m<=365 & time_to_test_ult_12m!=. & urate_val_!=. //test done within 12 months of ULT
bys patient_id (had_test_ult_12m): gen n=_n if had_test_ult_12m!=.
by patient_id: egen count_urate_ult_12m = max(n) //number of tests within 12m of ULT
recode count_urate_ult_12m .=0 //includes those who didn't receive ULT
lab var count_urate_ult_12m "Number of urate levels within 12m of ULT initiation"
drop n
sort patient_id had_test_ult_12m
by patient_id: replace had_test_ult_12m = had_test_ult_12m[_n-1] if missing(had_test_ult_12m)
recode had_test_ult_12m .=0 //includes those who didn't receive ULT
lab var had_test_ult_12m "Urate test performed within 12 months of ULT"
lab def had_test_ult_12m 0 "No" 1 "Yes", modify
lab val had_test_ult_12m had_test_ult_12m
gen value_test_ult_12m = urate_val_ if time_to_test_ult_12m<=365 & time_to_test_ult_12m!=. & urate_val_!=. //test values within 12 months of ULT
bys patient_id (value_test_ult_12m): gen n=_n if value_test_ult_12m!=.
gen lowest_urate_ult_12m = value_test_ult_12m if n==1 //lowest urate value within 12m of ULT
lab var lowest_urate_ult_12m "Lowest urate value within 12m of ULT initiation"
sort patient_id (lowest_urate_ult_12m)
by patient_id: replace lowest_urate_ult_12m = lowest_urate_ult_12m[_n-1] if missing(lowest_urate_ult_12m)
drop n value_test_ult_12m
gen urate_below360_ult_12m = 1 if lowest_urate_ult_12m<=360 & lowest_urate_ult_12m!=.
recode urate_below360_ult_12m .=0 //includes those who didn't receive ULT or didn't have a test within 12m
lab var urate_below360_ult_12m  "Urate <360 micromol/L within 12m of ULT initiation"
lab def urate_below360_ult_12m 0 "No" 1 "Yes", modify
lab val urate_below360_ult_12m urate_below360_ult_12m
drop time_to_test_ult_12m
gen urate_below360_ult_12m_fup=1 if urate_below360_ult_12m==1 & has_12m_post_ult==1
recode urate_below360_ult_12m_fup .=0
lab var urate_below360_ult_12m_fup  "Urate <360 micromol/L within 12m of ULT initiation (12m+ follow-up)"
lab def urate_below360_ult_12m_fup 0 "No" 1 "Yes", modify
lab val urate_below360_ult_12m_fup urate_below360_ult_12m_fup

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

tabstat lowest_urate_ult_12m, stats(n mean p50 p25 p75)
tab urate_below360_ult_12m if has_12m_post_ult==1, missing //for those who received ULT within 6m and had >12m of follow-up
tab urate_below360_ult_12m if has_12m_post_ult==1 & had_test_ult_12m==1, missing //for those who received ULT within 6m, had >12m of follow-up, and had a test performed within 12m of ULT
tabstat count_urate_ult_12m if has_12m_post_ult==1, stats(n mean p50 p25 p75) //number of tests performed within 12m of ULT initiation
gen two_urate_ult_12m=1 if count_urate_ult_12m>=2 & count_urate_ult_12m!=. //two or more urate tests performed within 12m of ULT initiation
recode two_urate_ult_12m .=0 //includes those who didn't receive ULT
lab var two_urate_ult_12m "At least 2 urate tests performed within 6 months of ULT initiation"
lab def two_urate_ult_12m 0 "No" 1 "Yes", modify
lab val two_urate_ult_12m two_urate_ult_12m
tab two_urate_ult_12m if has_12m_post_ult==1, missing 

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

*Define high-risk patients for ULT===========================================================*/
gen high_risk = 1 if tophi==1 | ckd==1 | diuretic==1 | multiple_flares==1
recode high_risk .=0	
lab var high_risk "Presence of risk factors"
lab def high_risk 0 "No" 1 "Yes", modify
lab val high_risk high_risk

**Time to first ULT; prescription must be within 6 months of diagnosis ==========================*/
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

*What was first ULT drug in GP record==============================================================================*

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

save "$projectdir/output/data/file_gout_all.dta", replace

**Import prevalence and denominator for prevalence=========================*/

import delimited "$projectdir/output/measures/measure_prevalent_gout.csv", clear

gen date_dstr = date(date, "YMD") 
format date_dstr %td
drop date
rename date_dstr date
gen year=year(date)
format year %ty
drop value //will round and calculate prevalence at analysis step

bys year: egen pop_all = total(population)
bys year: egen prev_gout_all = total(prevalent_gout)
rename prevalent_gout prev_gout
rename population pop
save "$projectdir/output/data/gout_prevalence_sex_long.dta", replace

**Import denominator for incidence=========================*/

set type double

import delimited "$projectdir/output/measures/measure_pre_registration.csv", clear

summ value //check - what proportion of individuals have 12 months of preceding registration

gen date_dstr = date(date, "YMD") 
format date_dstr %td
drop date
rename date_dstr date
gen year=year(date)
format year %ty
drop value //will round and calculate prevalence at analysis step

drop population
rename pre_registration pop_inc
bys year: egen pop_inc_all = total(pop_inc)
save "$projectdir/output/data/gout_incidence_sex_long.dta", replace

**Import admissions and denominators for admissions=========================*/

import delimited "$projectdir/output/measures/measure_gout_admission_pop.csv", clear

gen date_dstr = date(date, "YMD") 
format date_dstr %td
drop date
rename date_dstr date
gen year=year(date)
format year %ty
drop value //will round and calculate prevalence at analysis step

bys year: egen pop_all = total(population)
bys year: egen gout_admission_all = total(gout_admission)
rename population pop
save "$projectdir/output/data/gout_admissions_sex_long.dta", replace

log close
