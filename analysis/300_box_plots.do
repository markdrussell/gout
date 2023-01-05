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

*Restrict all analyses to patients with at least 6m follow-up and registration after diagnosis================*/
keep if has_6m_post_diag==1

preserve
gen ult_0 =1 if time_to_ult_6m<=90 & time_to_ult_6m!=.
recode ult_0 .=0 if time_to_ult_6m!=.
gen ult_1 =1 if time_to_ult_6m>90 & time_to_ult_6m<=180 & time_to_ult_6m!=.
recode ult_1 .=0 if time_to_ult_6m!=.
gen ult_2 = 1 if time_to_ult_6m>180 & time_to_ult_6m!=. //this needs editing I think
recode ult_2 .=0 if time_to_ult_6m!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) ult_0 (mean) ult_1 (mean) ult_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "More than 6 months")) title("Time to ULT initiation") name(regional_qs1_bar, replace)
graph export "$projectdir/output/figures/regional_ult_overall.svg", replace
restore

/*GP referral performance by region, Apr 2019 to Apr 2020; low capture of rheum referrals presently, therefore using last GP appt as proxy measure currently - see below===========================================================================*/

preserve
keep if appt_year==1
gen qs1_0 =1 if time_gp_rheum_ref_appt<=3 & time_gp_rheum_ref_appt!=.
recode qs1_0 .=0 if time_gp_rheum_ref_appt!=.
gen qs1_1 =1 if time_gp_rheum_ref_appt>3 & time_gp_rheum_ref_appt<=7 & time_gp_rheum_ref_appt!=.
recode qs1_1 .=0 if time_gp_rheum_ref_appt!=.
gen qs1_2 = 1 if time_gp_rheum_ref_appt>7 & time_gp_rheum_ref_appt!=.
recode qs1_2 .=0 if time_gp_rheum_ref_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs1_0 (mean) qs1_1 (mean) qs1_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 days" 2 "Within 7 days" 3 "More than 7 days")) title("Time to rheumatology referral") name(regional_qs1_bar, replace)
graph export "$projectdir/output/figures/regional_qs1_bar_2019.svg", replace
restore

/*GP referral performance by region, Apr 2020 to Apr 2021; low capture of rheum referrals presently, therefore using last GP appt as proxy measure currently - see below===========================================================================*/

preserve
keep if appt_year==2
gen qs1_0 =1 if time_gp_rheum_ref_appt<=3 & time_gp_rheum_ref_appt!=.
recode qs1_0 .=0 if time_gp_rheum_ref_appt!=.
gen qs1_1 =1 if time_gp_rheum_ref_appt>3 & time_gp_rheum_ref_appt<=7 & time_gp_rheum_ref_appt!=.
recode qs1_1 .=0 if time_gp_rheum_ref_appt!=.
gen qs1_2 = 1 if time_gp_rheum_ref_appt>7 & time_gp_rheum_ref_appt!=.
recode qs1_2 .=0 if time_gp_rheum_ref_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs1_0 (mean) qs1_1 (mean) qs1_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 days" 2 "Within 7 days" 3 "More than 7 days")) title("Time to rheumatology referral") name(regional_qs1_bar, replace)
graph export "$projectdir/output/figures/regional_qs1_bar_2020.svg", replace
restore

/*GP referral performance by region, Apr 2021 to Apr 2022; low capture of rheum referrals presently, therefore using last GP appt as proxy measure currently - see below===========================================================================*/

preserve
keep if appt_year==3
gen qs1_0 =1 if time_gp_rheum_ref_appt<=3 & time_gp_rheum_ref_appt!=.
recode qs1_0 .=0 if time_gp_rheum_ref_appt!=.
gen qs1_1 =1 if time_gp_rheum_ref_appt>3 & time_gp_rheum_ref_appt<=7 & time_gp_rheum_ref_appt!=.
recode qs1_1 .=0 if time_gp_rheum_ref_appt!=.
gen qs1_2 = 1 if time_gp_rheum_ref_appt>7 & time_gp_rheum_ref_appt!=.
recode qs1_2 .=0 if time_gp_rheum_ref_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs1_0 (mean) qs1_1 (mean) qs1_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 days" 2 "Within 7 days" 3 "More than 7 days")) title("Time to rheumatology referral") name(regional_qs1_bar, replace)
graph export "$projectdir/output/figures/regional_qs1_bar_2021.svg", replace
restore


*Rheum ref to appt performance by region, all years; low capture of rheum referrals presently, therefore using last GP appt as proxy measure currently - see below==========================================================================*/

preserve
gen qs2_0 =1 if time_ref_rheum_appt<=21 & time_ref_rheum_appt!=.
recode qs2_0 .=0 if time_ref_rheum_appt!=.
gen qs2_1 =1 if time_ref_rheum_appt>21 & time_ref_rheum_appt<=42 & time_ref_rheum_appt!=.
recode qs2_1 .=0 if time_ref_rheum_appt!=.
gen qs2_2 = 1 if time_ref_rheum_appt>42 & time_ref_rheum_appt!=.
recode qs2_2 .=0 if time_ref_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from rheumatology referral to assessment") name(regional_qs2_bar, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_overall.svg", replace
restore

*Rheum ref to appt performance by region, Apr 2019 to Apr 2020; low capture of rheum referrals presently, therefore using last GP appt as proxy measure currently - see below==========================================================================*/

preserve
keep if appt_year==1
gen qs2_0 =1 if time_ref_rheum_appt<=21 & time_ref_rheum_appt!=.
recode qs2_0 .=0 if time_ref_rheum_appt!=.
gen qs2_1 =1 if time_ref_rheum_appt>21 & time_ref_rheum_appt<=42 & time_ref_rheum_appt!=.
recode qs2_1 .=0 if time_ref_rheum_appt!=.
gen qs2_2 = 1 if time_ref_rheum_appt>42 & time_ref_rheum_appt!=.
recode qs2_2 .=0 if time_ref_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from rheumatology referral to assessment") name(regional_qs2_bar, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_2019.svg", replace
restore

*Rheum ref to appt performance by region, Apr 2020 to Apr 2021; low capture of rheum referrals presently, therefore using last GP appt as proxy measure currently - see below==========================================================================*/

preserve
keep if appt_year==2
gen qs2_0 =1 if time_ref_rheum_appt<=21 & time_ref_rheum_appt!=.
recode qs2_0 .=0 if time_ref_rheum_appt!=.
gen qs2_1 =1 if time_ref_rheum_appt>21 & time_ref_rheum_appt<=42 & time_ref_rheum_appt!=.
recode qs2_1 .=0 if time_ref_rheum_appt!=.
gen qs2_2 = 1 if time_ref_rheum_appt>42 & time_ref_rheum_appt!=.
recode qs2_2 .=0 if time_ref_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from rheumatology referral to assessment") name(regional_qs2_bar, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_2020.svg", replace
restore

*Rheum ref to appt performance by region, Apr 2021 to Apr 2022; low capture of rheum referrals presently, therefore using last GP appt as proxy measure currently - see below==========================================================================*/

preserve
keep if appt_year==3
gen qs2_0 =1 if time_ref_rheum_appt<=21 & time_ref_rheum_appt!=.
recode qs2_0 .=0 if time_ref_rheum_appt!=.
gen qs2_1 =1 if time_ref_rheum_appt>21 & time_ref_rheum_appt<=42 & time_ref_rheum_appt!=.
recode qs2_1 .=0 if time_ref_rheum_appt!=.
gen qs2_2 = 1 if time_ref_rheum_appt>42 & time_ref_rheum_appt!=.
recode qs2_2 .=0 if time_ref_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from rheumatology referral to assessment") name(regional_qs2_bar, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_2021.svg", replace
restore

*Last GP to rheum appt performance by region, all years==========================================================================*/

preserve
gen qs2_0 =1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=.
recode qs2_0 .=0 if time_gp_rheum_appt!=.
gen qs2_1 =1 if time_gp_rheum_appt>21 & time_gp_rheum_appt<=42 & time_gp_rheum_appt!=.
recode qs2_1 .=0 if time_gp_rheum_appt!=.
gen qs2_2 = 1 if time_gp_rheum_appt>42 & time_gp_rheum_appt!=.
recode qs2_2 .=0 if time_gp_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from referral to rheumatology assessment, overall") name(regional_qs2_bar_GP, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_GP_overall.svg", replace
restore

//for output checking tables for boxplot - see output/tables/referral_byregion_rounded.csv

*Last GP to rheum appt performance by region, Apr 2019 to Apr 2020==========================================================================*/

preserve
keep if appt_year==1
gen qs2_0 =1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=.
recode qs2_0 .=0 if time_gp_rheum_appt!=.
gen qs2_1 =1 if time_gp_rheum_appt>21 & time_gp_rheum_appt<=42 & time_gp_rheum_appt!=.
recode qs2_1 .=0 if time_gp_rheum_appt!=.
gen qs2_2 = 1 if time_gp_rheum_appt>42 & time_gp_rheum_appt!=.
recode qs2_2 .=0 if time_gp_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from referral to rheumatology assessment, Apr 2019 to Apr 2020") name(regional_qs2_bar_GP, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_GP_2019.svg", replace
restore

//for output checking tables for boxplot - see output/tables/referral_byregion_rounded.csv

*Last GP to rheum appt performance by region, Apr 2020 to Apr 2021==========================================================================*/

preserve
keep if appt_year==2
gen qs2_0 =1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=.
recode qs2_0 .=0 if time_gp_rheum_appt!=.
gen qs2_1 =1 if time_gp_rheum_appt>21 & time_gp_rheum_appt<=42 & time_gp_rheum_appt!=.
recode qs2_1 .=0 if time_gp_rheum_appt!=.
gen qs2_2 = 1 if time_gp_rheum_appt>42 & time_gp_rheum_appt!=.
recode qs2_2 .=0 if time_gp_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from referral to rheumatology assessment, Apr 2020 to Apr 2021") name(regional_qs2_bar_GP, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_GP_2020.svg", replace
restore

//for output checking tables for boxplot - see output/tables/referral_byregion_rounded.csv

*Last GP to rheum appt performance by region, Apr 2021 to Apr 2022==========================================================================*/

preserve
keep if appt_year==3
gen qs2_0 =1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=.
recode qs2_0 .=0 if time_gp_rheum_appt!=.
gen qs2_1 =1 if time_gp_rheum_appt>21 & time_gp_rheum_appt<=42 & time_gp_rheum_appt!=.
recode qs2_1 .=0 if time_gp_rheum_appt!=.
gen qs2_2 = 1 if time_gp_rheum_appt>42 & time_gp_rheum_appt!=.
recode qs2_2 .=0 if time_gp_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from referral to rheumatology assessment, Apr 2021 to Apr 2022") name(regional_qs2_bar_GP, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_GP_2021.svg", replace
restore

//for output checking tables for boxplot - see output/tables/referral_byregion_rounded.csv

/*GP referral performance by region, merged===========================================================================*/

preserve
keep if appt_year==1 | appt_year==2 | appt_year==3
lab define appt_year 1 "Year 1" 2 "Year 2" 3 "Year 3", modify
lab val appt_year appt_year

gen qs2_0 =1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=.
recode qs2_0 .=0 if time_gp_rheum_appt!=.
gen qs2_1 =1 if time_gp_rheum_appt>21 & time_gp_rheum_appt<=42 & time_gp_rheum_appt!=.
recode qs2_1 .=0 if time_gp_rheum_appt!=.
gen qs2_2 = 1 if time_gp_rheum_appt>42 & time_gp_rheum_appt!=.
recode qs2_2 .=0 if time_gp_rheum_appt!=.

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(appt_year, gap(20) label(labsize(*0.75))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients)  ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from referral to rheumatology assessment") name(regional_qs2_bar_GP, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_GP_merged.svg", width(12in)replace
restore

/*GP referral performance by ethnicity, merged===========================================================================*/

preserve
keep if appt_year==1 | appt_year==2 | appt_year==3
lab define appt_year 1 "Year 1" 2 "Year 2" 3 "Year 3", modify
lab val appt_year appt_year

gen qs2_0 =1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=.
recode qs2_0 .=0 if time_gp_rheum_appt!=.
gen qs2_1 =1 if time_gp_rheum_appt>21 & time_gp_rheum_appt<=42 & time_gp_rheum_appt!=.
recode qs2_1 .=0 if time_gp_rheum_appt!=.
gen qs2_2 = 1 if time_gp_rheum_appt>42 & time_gp_rheum_appt!=.
recode qs2_2 .=0 if time_gp_rheum_appt!=.

expand=2, gen(copy)
replace ethnicity = 0 if copy==1  

lab define ethnicity 0 "Overall" 2 "Asian", modify
lab val ethnicity ethnicity

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(appt_year, gap(20) label(labsize(*0.9))) over(ethnicity, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients)  ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from referral to rheumatology assessment, by ethnicity") name(regional_qs2_bar_GP_ethnicity, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_GP_ethnicity.svg", replace
restore

/*GP referral performance by IMD quintile, merged===========================================================================*/

preserve
keep if appt_year==1 | appt_year==2 | appt_year==3
lab define appt_year 1 "Year 1" 2 "Year 2" 3 "Year 3", modify
lab val appt_year appt_year

gen qs2_0 =1 if time_gp_rheum_appt<=21 & time_gp_rheum_appt!=.
recode qs2_0 .=0 if time_gp_rheum_appt!=.
gen qs2_1 =1 if time_gp_rheum_appt>21 & time_gp_rheum_appt<=42 & time_gp_rheum_appt!=.
recode qs2_1 .=0 if time_gp_rheum_appt!=.
gen qs2_2 = 1 if time_gp_rheum_appt>42 & time_gp_rheum_appt!=.
recode qs2_2 .=0 if time_gp_rheum_appt!=.

expand=2, gen(copy)
replace imd = 0 if copy==1  

lab define imd 0 "Overall" 1 "1st Quintile" 2 "2nd Quintile" 3 "3rd Quintile" 4 "4th Quintile" 5 "5th Quintile", modify
lab val imd imd

graph hbar (mean) qs2_0 (mean) qs2_1 (mean) qs2_2, over(appt_year, gap(20) label(labsize(*0.9))) over(imd, gap(60) label(labsize(*0.8)) relabel(2 `" "1st Quintile" "(most deprived)" "' 6 `" "5th Quintile" "(least deprived)" "')) stack ytitle(Proportion of patients)  ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 weeks" 2 "Within 6 weeks" 3 "More than 6 weeks")) title("Time from referral to rheumatology assessment, by IMD quintile") name(regional_qs2_bar_GP_imd, replace)
graph export "$projectdir/output/figures/regional_qs2_bar_GP_imd.svg", replace
restore

*csDMARD shared care performance by region prescriptions, all years==========================================================================*/

*As above, all patients must have 1) rheum appt 2) 6m+ follow-up after rheum appt 3) 6m+ of registration after appt (changed from 12m requirement, for purposes of OpenSAFELY report)

**For RA, PsA and Undiff IA patients combined (not including AxSpA - low counts)
keep if (ra_code==1 | psa_code==1 | undiff_code==1)

preserve
gen csdmard_0 =1 if time_to_csdmard<=90 & time_to_csdmard!=.
recode csdmard_0 .=0
gen csdmard_1 =1 if time_to_csdmard>90 & time_to_csdmard<=180 & time_to_csdmard!=.
recode csdmard_1 .=0
gen csdmard_2 = 1 if time_to_csdmard>180 | time_to_csdmard==.
recode csdmard_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) csdmard_0 (mean) csdmard_1 (mean) csdmard_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to first csDMARD in primary care, overall") name(regional_csdmard_bar, replace)

graph export "$projectdir/output/figures/regional_csdmard_bar_overall.svg", replace

//for output checking table for boxplot - see output/tables/drug_byyearandregion_rounded.csv

restore

*csDMARD shared care performance by region prescriptions, Apr 2019 to Apr 2020==========================================================================*/

preserve
keep if appt_year==1
gen csdmard_0 =1 if time_to_csdmard<=90 & time_to_csdmard!=.
recode csdmard_0 .=0
gen csdmard_1 =1 if time_to_csdmard>90 & time_to_csdmard<=180 & time_to_csdmard!=.
recode csdmard_1 .=0
gen csdmard_2 = 1 if time_to_csdmard>180 | time_to_csdmard==.
recode csdmard_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) csdmard_0 (mean) csdmard_1 (mean) csdmard_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to first csDMARD in primary care, Apr 2019 to Apr 2020") name(regional_csdmard_bar, replace)
graph export "$projectdir/output/figures/regional_csdmard_bar_2019.svg", replace
restore

//for output checking table for boxplot - see output/tables/drug_byyearandregion_rounded.csv

*csDMARD shared care performance by region prescriptions, Apr 2020 to Apr 2021==========================================================================*/

preserve
keep if appt_year==2
gen csdmard_0 =1 if time_to_csdmard<=90 & time_to_csdmard!=.
recode csdmard_0 .=0
gen csdmard_1 =1 if time_to_csdmard>90 & time_to_csdmard<=180 & time_to_csdmard!=.
recode csdmard_1 .=0
gen csdmard_2 = 1 if time_to_csdmard>180 | time_to_csdmard==.
recode csdmard_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) csdmard_0 (mean) csdmard_1 (mean) csdmard_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to first csDMARD in primary care, Apr 2020 to Apr 2021") name(regional_csdmard_bar, replace)
graph export "$projectdir/output/figures/regional_csdmard_bar_2020.svg", replace
restore

//for output checking table for boxplot - see output/tables/drug_byyearandregion_rounded.csv

*csDMARD shared care performance by region prescriptions, Apr 2021 to Apr 2022==========================================================================*/

preserve
keep if appt_year==3
gen csdmard_0 =1 if time_to_csdmard<=90 & time_to_csdmard!=.
recode csdmard_0 .=0
gen csdmard_1 =1 if time_to_csdmard>90 & time_to_csdmard<=180 & time_to_csdmard!=.
recode csdmard_1 .=0
gen csdmard_2 = 1 if time_to_csdmard>180 | time_to_csdmard==.
recode csdmard_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

graph hbar (mean) csdmard_0 (mean) csdmard_1 (mean) csdmard_2, over(nuts_region, relabel(1 "National")) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to first csDMARD in primary care, Apr 2021 to Apr 2022") name(regional_csdmard_bar, replace)
graph export "$projectdir/output/figures/regional_csdmard_bar_2021.svg", replace
restore

//for output checking table for boxplot - see output/tables/drug_byyearandregion_rounded.csv

*csDMARD shared care performance by region prescriptions, merged==========================================================================*/

preserve
keep if appt_year==1 | appt_year==2 | appt_year==3
lab define appt_year 1 "Year 1" 2 "Year 2" 3 "Year 3", modify
lab val appt_year appt_year

gen csdmard_0 =1 if time_to_csdmard<=90 & time_to_csdmard!=.
recode csdmard_0 .=0
gen csdmard_1 =1 if time_to_csdmard>90 & time_to_csdmard<=180 & time_to_csdmard!=.
recode csdmard_1 .=0
gen csdmard_2 = 1 if time_to_csdmard>180 | time_to_csdmard==.
recode csdmard_2 .=0 

expand=2, gen(copy)
replace nuts_region = 0 if copy==1  

lab define nuts_region 0 "National" 9 "Yorkshire/Humber", modify
lab val nuts_region nuts_region

graph hbar csdmard_0 (mean) csdmard_1 (mean) csdmard_2, over(appt_year, gap(20) label(labsize(*0.75))) over(nuts_region, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients) ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to first csDMARD in primary care") name(regional_csdmard_bar, replace)
graph export "$projectdir/output/figures/regional_csdmard_bar_merged.svg", width(12in) replace
restore

/*csDMARD shared care performance by ethnicity, merged===========================================================================*/

preserve
keep if appt_year==1 | appt_year==2 | appt_year==3
lab define appt_year 1 "Year 1" 2 "Year 2" 3 "Year 3", modify
lab val appt_year appt_year

gen csdmard_0 =1 if time_to_csdmard<=90 & time_to_csdmard!=.
recode csdmard_0 .=0
gen csdmard_1 =1 if time_to_csdmard>90 & time_to_csdmard<=180 & time_to_csdmard!=.
recode csdmard_1 .=0
gen csdmard_2 = 1 if time_to_csdmard>180 | time_to_csdmard==.
recode csdmard_2 .=0 

expand=2, gen(copy)
replace ethnicity = 0 if copy==1  

lab define ethnicity 0 "Overall" 2 "Asian", modify
lab val ethnicity ethnicity

graph hbar (mean) csdmard_0 (mean) csdmard_1 (mean) csdmard_2, over(appt_year, gap(20) label(labsize(*0.9))) over(ethnicity, gap(60) label(labsize(*0.8))) stack ytitle(Proportion of patients)  ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to first csDMARD in primary care, by ethnicity") name(regional_csdmard_bar_ethnicity, replace)
graph export "$projectdir/output/figures/regional_csdmard_bar_ethnicity.svg", replace
restore

/*csDMARD shared care performance by IMD quintile, merged===========================================================================*/

preserve
keep if appt_year==1 | appt_year==2 | appt_year==3
lab define appt_year 1 "Year 1" 2 "Year 2" 3 "Year 3", modify
lab val appt_year appt_year

gen csdmard_0 =1 if time_to_csdmard<=90 & time_to_csdmard!=.
recode csdmard_0 .=0
gen csdmard_1 =1 if time_to_csdmard>90 & time_to_csdmard<=180 & time_to_csdmard!=.
recode csdmard_1 .=0
gen csdmard_2 = 1 if time_to_csdmard>180 | time_to_csdmard==.
recode csdmard_2 .=0 

expand=2, gen(copy)
replace imd = 0 if copy==1  

lab define imd 0 "Overall" 1 "1st Quintile" 2 "2nd Quintile" 3 "3rd Quintile" 4 "4th Quintile" 5 "5th Quintile", modify
lab val imd imd

graph hbar (mean) csdmard_0 (mean) csdmard_1 (mean) csdmard_2, over(appt_year, gap(20) label(labsize(*0.9))) over(imd, gap(60) label(labsize(*0.8)) relabel(2 `" "1st Quintile" "(most deprived)" "' 6 `" "5th Quintile" "(least deprived)" "')) stack ytitle(Proportion of patients)  ytitle(, size(small)) ylabel(0.0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0") legend(order(1 "Within 3 months" 2 "Within 6 months" 3 "None within 6 months")) title("Time to first csDMARD in primary care, by IMD quintile") name(regional_csdmard_bar_imd, replace)
graph export "$projectdir/output/figures/regional_csdmard_bar_imd.svg", replace
restore

log off