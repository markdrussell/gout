version 16

/*==============================================================================
DO FILE NAME:			baseline tables
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
global projectdir "C:\Users\k1754142\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir "C:\Users\Mark\OneDrive\PhD Project\OpenSAFELY Gout\OpenSAFELY gout"
*global projectdir `c(pwd)'

capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

global logdir "$projectdir/logs"

**Open a log file
cap log close
log using "$logdir/descriptive_tables.log", replace

**Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

**Use cleaned data from previous step
use "$projectdir/output/data/file_gout_all.dta", clear

set scheme plotplainblind

**Set index dates ===========================================================*/
global year_preceding = "01/01/2014"
global start_date = "01/01/2015"
global end_date = "31/12/2022"

*Diagnostic incidence======================================================================*/

**Total number of patients with diagnosis date after 1st April 2019 and before end date
tab gout_code

**Verify that all diagnoses were in study windows
tab mo_year_diagn, missing
tab diagnosis_year, missing

*Diagnostic incidence by year, by disease
preserve
collapse (count) total_diag=gout_code, by(diagnosis_year) 
**Round to nearest 5
foreach var of varlist *_diag {
	gen `var'_round=round(`var', 5)
	drop `var'
}
**Generate incidences by year (baseline population 17,683,500)
foreach var of varlist *_diag_round {
	gen incidence_`var'=((`var'/17683500)*10000)
}
export delimited using "$projectdir/output/tables/diag_count_byyear.csv", replace
restore

*Diagnostic incidence by year; female patients
preserve
keep if male==0
collapse (count) total_diag=gout_code, by(diagnosis_year) 
**Round to nearest 5
foreach var of varlist *_diag {
	gen `var'_round=round(`var', 5)
	drop `var'
}
**Generate incidences by year (baseline female population 8,866,535)
foreach var of varlist *_diag_round {
	gen incidence_`var'=((`var'/8866535)*10000)
}
export delimited using "$projectdir/output/tables/diag_count_byyear_female.csv", replace
restore

*Diagnostic incidence by year, by disease; male patients
preserve
keep if male==1
collapse (count) total_diag=gout_code, by(diagnosis_year) 
**Round to nearest 5
foreach var of varlist *_diag {
	gen `var'_round=round(`var', 5)
	drop `var'
}
**Generate incidences by year (baseline male population 8,816,965)
foreach var of varlist *_diag_round {
	gen incidence_`var'=((`var'/8816965)*10000)
}
export delimited using "$projectdir/output/tables/diag_count_byyear_male.csv", replace
restore

*Graph of diagnoses by month, by disease
preserve
collapse (count) total_diag=gout_code, by(mo_year_diagn) 
**Round to nearest 5
foreach var of varlist *_diag {
	gen `var'_round=round(`var', 5)
	drop `var'
}

**Generate incidences by month (baseline population 17,683,500)
foreach var of varlist *_diag_round {
	gen incidence_`var'=((`var'/17683500)*10000)
}
export delimited using "$projectdir/output/tables/diag_count_bymonth.csv", replace

twoway connected incidence_total_diag_round mo_year_diagn, ytitle("Monthly incidence of gout diagnoses per 10,000 population", size(small)) color(gold) xline(722) xtitle("Date of diagnosis", size(small) margin(medsmall)) title("", size(small)) name(incidence_twoway, replace) legend(region(fcolor(white%0)) order(1 "Gout diagnoses")) saving("$projectdir/output/figures/incidence_twoway_rounded.gph", replace)
	graph export "$projectdir/output/figures/incidence_twoway_rounded.svg", width(12in)replace
	
//Ideally would input baseline population for each study year	

/*
twoway connected incidence_total_diag_round mo_year_diagn, ytitle("Monthly incidence of gout diagnoses per 10,000 population", size(small)) || connected incidence_ra_diag_round mo_year_diagn, color(sky) || connected incidence_psa_diag_round mo_year_diagn, color(red) || connected incidence_axspa_diag_round mo_year_diagn, color(green) || connected incidence_undiff_diag_round mo_year_diagn, color(gold) xline(722) yscale(range(0(0.1)0.6)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5" 0.6 "0.6", nogrid labsize(vsmall)) xtitle("Date of diagnosis", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021" 747 "Apr 2022" 753 "Oct 2022", nogrid labsize(vsmall)) title("", size(small)) name(incidence_twoway, replace) legend(region(fcolor(white%0)) order(1 "Total IA diagnoses" 2 "RA" 3 "PsA" 4 "axSpA" 5 "Undifferentiated IA")) saving("$projectdir/output/figures/incidence_twoway_rounded.gph", replace)
	graph export "$projectdir/output/figures/incidence_twoway_rounded.svg", width(12in)replace

	
restore	

*Graph of diagnoses by month, by disease; female patients
preserve
keep if male==0
recode ra_code 0=.
recode psa_code 0=.
recode anksp_code 0=.
recode undiff_code 0=.
collapse (count) total_diag=eia_code ra_diag=ra_code psa_diag=psa_code axspa_diag=anksp_code undiff_diag=undiff_code, by(mo_year_diagn) 
**Round to nearest 5
foreach var of varlist *_diag {
	gen `var'_round=round(`var', 5)
	drop `var'
}
**Generate incidences by month (baseline female population 8,866,535)
foreach var of varlist *_diag_round {
	gen incidence_`var'=((`var'/8866535)*10000)
}
export delimited using "$projectdir/output/tables/diag_count_bymonth_female.csv", replace

twoway connected incidence_total_diag_round mo_year_diagn, ytitle("Monthly incidence of IA diagnoses per 10,000 female population", size(small)) || connected incidence_ra_diag_round mo_year_diagn, color(sky) || connected incidence_psa_diag_round mo_year_diagn, color(red) || connected incidence_axspa_diag_round mo_year_diagn, color(green) || connected incidence_undiff_diag_round mo_year_diagn, color(gold) xline(722) yscale(range(0(0.1)0.8)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5" 0.6 "0.6" 0.7 "0.7" 0.8 "0.8", nogrid) xtitle("Date of diagnosis", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021" 747 "Apr 2022" 753 "Oct 2022", nogrid ) title("", size(small)) name(incidence_twoway_rounded_female, replace) legend(region(fcolor(white%0)) order(1 "Total EIA diagnoses" 2 "RA" 3 "PsA" 4 "AxSpA" 5 "Undifferentiated IA")) saving("$projectdir/output/figures/incidence_twoway_rounded_female.gph", replace)
	graph export "$projectdir/output/figures/incidence_twoway_rounded_female.svg", replace	
	
restore	

*Graph of diagnoses by month, by disease; male patients
preserve
keep if male==1
recode ra_code 0=.
recode psa_code 0=.
recode anksp_code 0=.
recode undiff_code 0=.
collapse (count) total_diag=eia_code ra_diag=ra_code psa_diag=psa_code axspa_diag=anksp_code undiff_diag=undiff_code, by(mo_year_diagn) 
**Round to nearest 5
foreach var of varlist *_diag {
	gen `var'_round=round(`var', 5)
	drop `var'
}
**Generate incidences by month (baseline male population 8,816,965)
foreach var of varlist *_diag_round {
	gen incidence_`var'=((`var'/8816965)*10000)
}
export delimited using "$projectdir/output/tables/diag_count_bymonth_male.csv", replace

twoway connected incidence_total_diag_round mo_year_diagn, ytitle("Monthly incidence of IA diagnoses per 10,000 male population", size(small)) || connected incidence_ra_diag_round mo_year_diagn, color(sky) || connected incidence_psa_diag_round mo_year_diagn, color(red) || connected incidence_axspa_diag_round mo_year_diagn, color(green) || connected incidence_undiff_diag_round mo_year_diagn, color(gold) xline(722) yscale(range(0(0.1)0.8)) ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5" 0.6 "0.6" 0.7 "0.7" 0.8 "0.8", nogrid) xtitle("Date of diagnosis", size(small) margin(medsmall)) xlabel(711 "Apr 2019" 717 "Oct 2019" 723 "Apr 2020" 729 "Oct 2020" 735 "Apr 2021" 741 "Oct 2021" 747 "Apr 2022" 753 "Oct 2022", nogrid ) title("", size(small)) name(incidence_twoway_rounded_male, replace) legend(region(fcolor(white%0)) order(1 "Total EIA diagnoses" 2 "RA" 3 "PsA" 4 "AxSpA" 5 "Undifferentiated IA")) saving("$projectdir/output/figures/incidence_twoway_rounded_male.gph", replace)
	graph export "$projectdir/output/figures/incidence_twoway_rounded_male.svg", replace	
	
restore

*Incidence of rheumatology diagnoses, by ethnicity
preserve
gen total=1 if ethnicity!=.u
gen white=1 if ethnicity==1
gen asian=1 if ethnicity==2
gen black=1 if ethnicity==3
gen mixed=1 if ethnicity==4
collapse (count) total_diag=total white_diag=white asian_diag=asian black_diag=black mixed_diag=mixed, by(diagnosis_year) 
**Round to nearest 5
foreach var of varlist *_diag {
	gen `var'_round=round(`var', 5)
	drop `var'
}
**Generate incidences by year
gen incidence_total=((total_diag_round/13892705)*10000) //all non-missing ethnicities
gen incidence_white=((white_diag_round/12025695)*10000)
gen incidence_asian=((asian_diag_round/1029955)*10000)
gen incidence_black=((black_diag_round/343885)*10000)
gen incidence_mixed=((mixed_diag_round/493170)*10000)
export delimited using "$projectdir/output/tables/diag_count_byyear_ethn.csv", replace

restore

*Incidence of rheumatology diagnoses, by imd quintile
preserve
gen imd_all=1 if imd!=.u
gen imd_1=1 if imd==1
gen imd_2=1 if imd==2
gen imd_3=1 if imd==3
gen imd_4=1 if imd==4
gen imd_5=1 if imd==5
collapse (count) imd_all_diag=imd_all imd_1_diag=imd_1 imd_2_diag=imd_2 imd_3_diag=imd_3 imd_4_diag=imd_4 imd_5_diag=imd_5, by(diagnosis_year) 
**Round to nearest 5
foreach var of varlist *_diag {
	gen `var'_round=round(`var', 5)
	drop `var'
}
**Generate incidences by year
gen incidence_imd_all=((imd_all_diag_round/17415045)*10000) //all non-missing imds
gen incidence_imd_1=((imd_1_diag_round/3285410)*10000)
gen incidence_imd_2=((imd_2_diag_round/3557860)*10000)
gen incidence_imd_3=((imd_3_diag_round/3762515)*10000)
gen incidence_imd_4=((imd_4_diag_round/3448770)*10000)
gen incidence_imd_5=((imd_5_diag_round/3360490)*10000)
export delimited using "$projectdir/output/tables/diag_count_byyear_imd.csv", replace

restore
*/	

/*Baseline tables=====================================================================================*/

**Demographics
tabstat age, stats (n mean sd)
tab agegroup, missing
tab male, missing
tab ethnicity, missing
tab imd, missing
tab nuts_region, missing

**Comorbidities
tab smoke, missing
tabstat bmi_val, stats (n mean p50 p25 p75)
tab bmicat, missing
tabstat creatinine_val, stats (n mean p50 p25 p75)
tabstat egfr, stats (n mean p50 p25 p75)
tab egfr_cat, missing
tab egfr_cat_nomiss, missing
tab esrf, missing
tab ckd, missing //combination of creatinine and esrf codes
tab diabetes, missing 
tabstat hba1c_percentage_val, stats (n mean p50 p25 p75)
tabstat hba1c_mmol_per_mol_val, stats (n mean p50 p25 p75)
tabstat hba1c_pct, stats (n mean p50 p25 p75) //with conversion of mmol values
tab hba1ccat, missing
tabstat hba1c_mmol, stats (n mean p50 p25 p75) //with conversion of % values
tab hba1ccatmm, missing
tab diabcatm, missing //on basis of converted %
tab cancer, missing //lung, haem or other cancer
tab hypertension, missing
tab stroke, missing
tab chronic_resp_disease, missing
tab copd, missing
tab chronic_liver_disease, missing
tab chronic_card_disease, missing
tab diuretic, missing
tab tophus, missing
tab multiple_flares, missing
tabstat flare_count, stats (n mean p50 p25 p75)

*Baseline table overall
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
		 tophus bin %5.1f \ ///
		 ) saving("$projectdir/output/tables/baseline_bydiagnosis.xls", replace)

*Baseline table by year of diagnosis
table1_mc, by(diagnosis_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
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
		 tophus bin %5.1f \ ///
		 ) saving("$projectdir/output/tables/baseline_byyear.xls", replace)

*Follow-up=======================================================================================================*/

**Proportion of patients with at least 6/12 months of registration after diagnosis 
tab has_6m_follow_up, missing
tab has_12m_follow_up, missing
tab mo_year_diagn has_6m_follow_up
tab mo_year_diagn has_12m_follow_up

**Proportion of patients with at least 6/12 months of registration and follow-up time after diagnosis
tab has_6m_post_diag, missing 
tab has_12m_post_diag, missing 

*Baseline urate==================================================================================================*/

tabstat baseline_urate, stats(n mean p50 p25 p75)
tab baseline_urate_below360, missing
tab baseline_urate_below360
tab baseline_urate_below300, missing
tab baseline_urate_below300		 

*ULT prescriptions===============================================================================================*/

**Proportion with a prescription for ULT within 6m of diagnosis
tab ult_6m, missing
tab ult_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
tab ult_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Proportion with a prescription for ULT within 12m of diagnosis
tab ult_12m, missing
tab ult_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Proportion with a prescription for allopurinol within 6m of diagnosis
tab allo_6m, missing
tab allo_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
tab allo_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Proportion with a prescription for allopurinol within 12m of diagnosis
tab allo_12m, missing
tab allo_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Proportion with a prescription for febuxostat within 6m of diagnosis
tab febux_6m, missing
tab febux_6m if has_6m_post_diag==1, missing //for those with at least 6m of available follow-up
tab febux_6m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

**Proportion with a prescription for febuxostat within 12m of diagnosis
tab febux_12m, missing
tab febux_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up

*ULT prescriptions in context of additional risk factors=============================================================*/

**CKD
foreach var of varlist tophi ckd diuretic multiple_flares high_risk {
**ULT within 6m 
bys `var': tab ult_6m, missing
**ULT within 6m for those with at least 6m of available follow-up
bys `var': tab ult_6m if has_6m_post_diag==1, missing 
**ULT within 12m 
bys `var': tab ult_12m, missing
**ULT within 12m for those with at least 12m of available follow-up
bys `var': tab ult_12m if has_12m_post_diag==1, missing //for those with at least 12m of available follow-up
}

***Proportion of patients with >6m/12m of registration and follow-up after first ULT prescription, assuming first prescription was within 12m of diagnosis //should this be 6m or 12m
tab has_6m_post_ult, missing
tab has_12m_post_ult, missing 



 

**Referral standards, by eia diagnosis
table1_mc, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 gp_appt_cat cat %3.1f \ ///
		 gp_appt_cat_19 cat %3.1f \ ///
		 gp_appt_cat_20 cat %3.1f \ ///
		 gp_appt_cat_21 cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_bydiag_nomiss.xls", replace)		  
 
*Referral standards, by 12 months periods - date of first appt rather than date of EIA code
table1_mc, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_ref_cat cat %3.1f \ ///
		 ref_appt_cat cat %3.1f \ ///
		 gp_appt_cat cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byyear_nomiss.xls", replace) 
		 
*Referral standards, by region
table1_mc if nuts_region!=., by(nuts_region) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(gp_appt_cat cat %3.1f \ ///
		 gp_appt_cat_19 cat %3.1f \ ///
		 gp_appt_cat_20 cat %3.1f \ ///
		 gp_appt_cat_21 cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/referral_byregion_nomiss.xls", replace)

*Time from rheum appt to first csDMARD prescriptions on primary care record======================================================================*/

*As above, all patients must have 1) rheum appt and GP appt 2) 6m follow-up after rheum appt 3) 6m of registration after appt
**Note: in final redacted tables, axSpA patients are excluded (due to potential for small counts)
tab mo_year_diagn, missing
tab mo_year_appt, missing

**Proportion with a csDMARD prescription in GP record at any point after diagnosis; patients excluded if csDMARD or biologic was >60 days before rheumatology appt date
tab csdmard, missing
tab csdmard if (csdmard_date<=rheum_appt_date+180), missing //with 6-month limit
tab csdmard if (csdmard_date<=rheum_appt_date+365), missing //with 12-month limit
bys eia_diagnosis: tab csdmard
bys eia_diagnosis: tab csdmard if (csdmard_date<=rheum_appt_date+180) //with 6-month limit
bys eia_diagnosis: tab csdmard if (csdmard_date<=rheum_appt_date+365) //with 12-month limit


**With high cost MTX data
tab csdmard_hcd, missing //including high cost MTX scripts 
tab csdmard_hcd if (csdmard_hcd_date<=rheum_appt_date+180), missing //with 6-month limit
tab csdmard_hcd if (csdmard_hcd_date<=rheum_appt_date+365), missing //with 12-month limit
bys eia_diagnosis: tab csdmard_hcd, missing //including high cost MTX scripts 
bys eia_diagnosis: tab csdmard_hcd if (csdmard_hcd_date<=rheum_appt_date+180) //with 6-month limit
bys eia_diagnosis: tab csdmard_hcd if (csdmard_hcd_date<=rheum_appt_date+365) //with 12-month limit

**Compare proportion with more than one script issued for csDMARDs
tab csdmard, missing //all prescriptions, for comparison
tab csdmard_shared, missing //issued more than once (shared care)

**Time to first csDMARD in GP record for RA/PsA/undiff IA patients, not including high cost MTX prescriptions; prescription must be within 6 months of diagnosis for all csDMARDs below 
tabstat time_to_csdmard if ra_code==1 | psa_code==1 | undiff_code==1, stats (n mean p50 p25 p75)
bys appt_3m: tabstat time_to_csdmard if ra_code==1 | psa_code==1 | undiff_code==1, stats (n mean p50 p25 p75) //by diagnosis period
bys appt_year: tabstat time_to_csdmard if ra_code==1 | psa_code==1 | undiff_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if ra_code==1 | psa_code==1 | undiff_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first csDMARD in GP record for RA patients not including high cost MTX prescriptions; prescription must be within 6 months of diagnosis for all csDMARDs below 
tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75)
bys appt_3m: tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis period
bys appt_year: tabstat time_to_csdmard if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if ra_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75)
bys appt_3m: tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis period
bys appt_year: tabstat time_to_csdmard if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if psa_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

/*
**Time to first csDMARD script for RA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) 
bys appt_3m: tabstat time_to_csdmard_hcd if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis period
bys nuts_region: tabstat time_to_csdmard_hcd if ra_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) 
bys appt_3m: tabstat time_to_csdmard_hcd if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis period
bys nuts_region: tabstat time_to_csdmard_hcd if psa_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region
*/

**Time to first csDMARD script for axSpA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if anksp_code==1, stats (n mean p50 p25 p75)
bys appt_3m: tabstat time_to_csdmard if anksp_code==1, stats (n mean p50 p25 p75) //by diagnosis period
bys appt_year: tabstat time_to_csdmard if anksp_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if anksp_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first csDMARD script for Undiff IA patients (not including high cost MTX prescriptions)
tabstat time_to_csdmard if undiff_code==1, stats (n mean p50 p25 p75)
bys appt_3m: tabstat time_to_csdmard if undiff_code==1, stats (n mean p50 p25 p75) //by diagnosis period
bys appt_year: tabstat time_to_csdmard if undiff_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_csdmard if undiff_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**csDMARD time categories for RA and PsA patients (not including high cost MTX prescriptions)
tab csdmard_time if ra_code==1, missing
tab csdmard_time if psa_code==1, missing
tab csdmard_time if anksp_code==1, missing
tab csdmard_time if undiff_code==1, missing

/*
**csDMARD time categories for RA and PsA patients (including high cost MTX prescriptions)
tab csdmard_hcd_time if ra_code==1, missing 
tab csdmard_hcd_time if psa_code==1, missing
tab csdmard_hcd_time if anksp_code==1, missing  
tab csdmard_hcd_time if undiff_code==1, missing
*/

**What was first shared care csDMARD (not including high cost MTX prescriptions)
***Exclude axSpA patients due to potentially small counts; exclude leflunomide due to small counts by more granular time periods
keep if ra_code==1 | psa_code==1 | undiff_code==1

tab first_csDMARD
bys appt_year: tab first_csDMARD //did choice of first drug vary by year
bys appt_3m: tab first_csDMARD //did choice of first drug vary by time period
tab first_csDMARD if ra_code==1 //for RA patients
tab first_csDMARD if psa_code==1 //for PsA patients
tab first_csDMARD if undiff_code==1 //for Undiff IA patients

**What was first csDMARD (including high cost MTX prescriptions)
tab first_csDMARD_hcd if ra_code==1 //for RA patients
tab first_csDMARD_hcd if psa_code==1 //for PsA patients
tab first_csDMARD_hcd if undiff_code==1 //for Undiff IA patients
 
**Methotrexate use (not including high cost MTX prescriptions)
tab mtx if ra_code==1 //for RA patients; Nb. this is just a check; need time-to-MTX instead (below)
tab mtx if ra_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit
tab mtx if psa_code==1 //for PsA patients
tab mtx if psa_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit
tab mtx if undiff_code==1 //for undiff IA patients
tab mtx if undiff_code==1 & (mtx_date<=rheum_appt_date+180) //with 6-month limit

**Compare proportion with more than one script issued for csDMARDs
tab mtx, missing //all prescriptions (for comparison)
tab mtx_shared, missing //issued more than once (shared care)
tab mtx_issue, missing //issed none vs. once vs. more than once

/*
**Methotrexate use (including high cost MTX prescriptions)
tab mtx_hcd if ra_code==1 //for RA patients
tab mtx_hcd if ra_code==1 & (mtx_hcd_date<=rheum_appt_date+180) //with 6-month limit
tab mtx_hcd if psa_code==1 //for PsA patients
tab mtx_hcd if psa_code==1 & (mtx_hcd_date<=rheum_appt_date+180) //with 6-month limit
tab mtx_hcd if undiff_code==1 //for undiff IA patients
tab mtx_hcd if undiff_code==1 & (mtx_hcd_date<=rheum_appt_date+180) //with 6-month limit
*/

**Time to first methotrexate script for RA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if ra_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if psa_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

/*
**Time to first methotrexate script for RA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx_hcd if ra_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx_hcd if ra_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Time to first methotrexate script for PsA patients (including high cost MTX prescriptions)
tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx_hcd if psa_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx_hcd if psa_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region
*/

**Time to first methotrexate script for Undiff IA patients (not including high cost MTX prescriptions)
tabstat time_to_mtx if undiff_code==1, stats (n mean p50 p25 p75)
bys appt_year: tabstat time_to_mtx if undiff_code==1, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_mtx if undiff_code==1 & nuts_region!=., stats (n mean p50 p25 p75) //by region

**Methotrexate time categories for RA, PsA and Undiff IA patients (not including high-cost MTX)
tab mtx_time if ra_code==1, missing 
tab mtx_time if psa_code==1, missing 
tab mtx_time if undiff_code==1, missing 

/*
**Methotrexate time categories (including high-cost MTX)
tab mtx_hcd_time if ra_code==1, missing 
tab mtx_hcd_time if psa_code==1, missing 
tab mtx_hcd_time if undiff_code==1, missing 
*/

**Sulfasalazine time categories
tab ssz_time if ra_code==1, missing 
tab ssz_time if psa_code==1, missing 
tab ssz_time if undiff_code==1, missing 

**Compare proportion with more than one script issued for csDMARDs
tab ssz, missing //all prescriptions (for comparison)
tab ssz_shared, missing //issued more than once (shared care)
tab ssz_issue, missing //issed none vs. once vs. more than once

**Hydroxychloroquine time categories
tab hcq_time if ra_code==1, missing 
tab hcq_time if psa_code==1, missing 
tab hcq_time if undiff_code==1, missing 

**Compare proportion with more than one script issued for csDMARDs
tab hcq, missing //all prescriptions (for comparison)
tab hcq_shared, missing //issued more than once (shared care)
tab hcq_issue, missing //issed none vs. once vs. more than once

**Leflunomide time categories
tab lef_time if ra_code==1, missing 
tab lef_time if psa_code==1, missing 
tab lef_time if undiff_code==1, missing 

**Compare proportion with more than one script issued for csDMARDs
tab lef, missing //all prescriptions (for comparison)
tab lef_shared, missing //issued more than once (shared care)
tab lef_issue, missing //issed none vs. once vs. more than once

*Drug prescription table, for those with at least 6m follow-up - excluding axSpA (low counts)
table1_mc if eia_diagnosis!=3, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_bydiag_miss.xls", replace)
		 
*Drug prescription table, for those with at least 6m follow-up; all diagnoses but for AxSpA
table1_mc if eia_diagnosis!=3, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_miss.xls", replace)		 

*Drug prescription table, for those with at least 6m follow-up for RA patients
table1_mc if ra_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_ra_miss.xls", replace)
		 
*Drug prescription table, for those with at least 6m follow-up for PsA patients
table1_mc if psa_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_psa_miss.xls", replace)

*Drug prescription table, for those with at least 6m follow-up for Undiff IA patients
table1_mc if undiff_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyear_undiff_miss.xls", replace) 
		 
*Drug prescription table, for those with at least 6m follow-up for all diagnoses, by year
table1_mc, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 csdmard_time_19 cat %3.1f \ ///
		 csdmard_time_20 cat %3.1f \ ///
		 csdmard_time_21 cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyearanddisease.xls", replace) 
		 
*Drug prescription table, for those with at least 6m follow-up for all diagnoses, by region and year
table1_mc if nuts_region!=. & (ra_code==1 | psa_code==1 | undiff_code==1), by(nuts_region) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 csdmard_time_19 cat %3.1f \ ///
		 csdmard_time_20 cat %3.1f \ ///
		 csdmard_time_21 cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/drug_byyearandregion.xls", replace) 			 
		 
**Time to first biologic script, whereby first rheum appt is classed as diagnosis date; high cost drug data available to Nov 2020. Not for analysis currently due to small numbers======================================================================*/

/*
**Proportion with a bDMARD or tsDMARD prescription at any point after diagnosis (unequal follow-up); patients excluded if csDMARD or biologic was >60 days before rheumatology appt date (if present)
tab biologic, missing
tab biologic if (biologic_date<=rheum_appt_date+365), missing //with 12-month limit

bys eia_diagnosis: tab biologic, missing 
bys eia_diagnosis: tab biologic if (biologic_date<=rheum_appt_date+365), missing //with 12-month limit 

tabstat time_to_biologic, stats (n mean p50 p25 p75) //for all EIA patients
bys eia_diagnosis: tabstat time_to_biologic, stats (n mean p50 p25 p75) 
bys appt_6m: tabstat time_to_biologic, stats (n mean p50 p25 p75) //by diagnosis year
bys nuts_region: tabstat time_to_biologic if nuts_region!=., stats (n mean p50 p25 p75) //by region

**What was first biologic

tab first_biologic //for all EIA patients
bys eia_diagnosis: tab first_biologic

**Biologic time categories (for all patients)
tab biologic_time 

**Biologic time categories (by diagnosis)
bys eia_diagnosis: tab biologic_time 

**Biologic time categories (by time period)
bys appt_6m: tab biologic_time

*Drug prescription table at 12 months, for those with at least 12m registration
table1_mc, by(eia_diagnosis) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_bydiag_miss.xls", replace)
		 
*Drug prescription table at 12 months, for all patients with at least 12m registration, by year of diagnosis
table1_mc, by(appt_6m) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_miss.xls", replace)
		 
*Drug prescription table at 12 months, for RA patients with at least 12m registration, by year of diagnosis
table1_mc if ra_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_ra_miss.xls", replace)

*Drug prescription table at 12 months, for PsA patients with at least 12m registration, by year of diagnosis
table1_mc if psa_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_psa_miss.xls", replace)

*Drug prescription table at 12 months, for AxSpA patients with at least 12m registration, by year of diagnosis
table1_mc if anksp_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_axspa_miss.xls", replace)
		 
*Drug prescription table at 12 months, for Undiff IA patients with at least 12m registration, by year of diagnosis
table1_mc if undiff_code==1, by(appt_year) total(before) onecol nospacelowpercent iqrmiddle(",")  ///
	vars(csdmard_time cat %3.1f \ ///
		 mtx_time cat %3.1f \ ///
		 ssz_time cat %3.1f \ ///
		 hcq_time cat %3.1f \ ///
		 lef_time cat %3.1f \ ///
		 biologic_time cat %3.1f \ ///
		 ) saving("$projectdir/output/tables/biol_byyear_undiff_miss.xls", replace)
*/		 

*Output tables as CSVs		 
import excel "$projectdir/output/tables/baseline_bydiagnosis.xls", clear
outsheet * using "$projectdir/output/tables/baseline_bydiagnosis.csv" , comma nonames replace	

import excel "$projectdir/output/tables/baseline_byyear.xls", clear
outsheet * using "$projectdir/output/tables/baseline_byyear.csv" , comma nonames replace		 

import excel "$projectdir/output/tables/referral_bydiag_nomiss.xls", clear
outsheet * using "$projectdir/output/tables/referral_bydiag_nomiss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/referral_byyear_nomiss.xls", clear
outsheet * using "$projectdir/output/tables/referral_byyear_nomiss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/referral_byregion_nomiss.xls", clear
outsheet * using "$projectdir/output/tables/referral_byregion_nomiss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_bydiag_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_bydiag_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyear_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyear_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyear_ra_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyear_ra_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyear_psa_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyear_psa_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyear_undiff_miss.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyear_undiff_miss.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyearanddisease.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyearanddisease.csv" , comma nonames replace	

import excel "$projectdir/output/tables/drug_byyearandregion.xls", clear
outsheet * using "$projectdir/output/tables/drug_byyearandregion.csv" , comma nonames replace	

log close