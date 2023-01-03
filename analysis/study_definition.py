from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv, combine_codelists, filter_codes_by_category

from codelists import *

year_preceding = "2014-01-01"
start_date = "2015-01-01"
end_date = "today"

# Date of first gout code in primary care record
def first_code_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.99,
            "date": {"earliest": year_preceding, "latest": end_date},
        },
    )

# Presence/date of specified comorbidities (first match up to point of gout diagnosis)
def first_comorbidity_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        between = ["1900-01-01", "gout_code_date"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.2,
            "date": {"earliest": "1950-01-01", "latest": end_date},
        },
    )

# Get dates of recurrent clinical events (up to 6m after diagnosis)
def with_these_clinical_events_date_X(name, codelist, index_date, n, return_expectations):

    def var_signature(name, codelist, on_or_after, return_expectations):
        return {
            name: patients.with_these_clinical_events(
                    codelist,
                    returning="date",
                    between=[on_or_after, "gout_code_date + 6 months"],
                    date_format="YYYY-MM-DD",
                    find_first_match_in_period=True,
                    return_expectations=return_expectations
        ),
        }
    variables = var_signature(f"{name}_1", codelist, index_date, return_expectations)
    for i in range(2, n+1):
        variables.update(var_signature(f"{name}_{i}", codelist, f"{name}_{i-1} + 1 day", return_expectations))
    return variables

# Get dates of recurrent medication events (up to 6 months after diagnosis)
def with_these_medication_events_date_X(name, codelist, index_date, n, return_expectations):

    def var_signature(name, codelist, on_or_after, return_expectations):
        return {
            name: patients.with_these_medications(
                    codelist,
                    returning="date",
                    between=[on_or_after, "gout_code_date + 6 months"],
                    date_format="YYYY-MM-DD",
                    find_first_match_in_period=True,
                    return_expectations=return_expectations
        ),
        }
    variables = var_signature(f"{name}_1", codelist, index_date, return_expectations)
    for i in range(2, n+1):
        variables.update(var_signature(f"{name}_{i}", codelist, f"{name}_{i-1} + 1 day", return_expectations))
    return variables

# Get dates of recurrent blood tests (up to 2 years after diagnosis)
def with_these_bloods_date_X(name, codelist, index_date, n, return_expectations):

    def var_signature(name, codelist, on_or_after, return_expectations):
        return {
            name: patients.with_these_clinical_events(
                    codelist,
                    find_first_match_in_period=True,
                    returning="numeric_value",
                    ignore_missing_values=True,
                    include_date_of_match=True,
                    date_format="YYYY-MM-DD",
                    between=[on_or_after, "gout_code_date + 2 years"],
                    return_expectations=return_expectations
        ),
        }
    variables = var_signature(f"{name}_1", codelist, index_date, return_expectations)
    for i in range(2, n+1):
        variables.update(var_signature(f"{name}_{i}", codelist, f"{name}_{i-1}_date + 1 day", return_expectations))
    return variables

# Get dates of recurrent admissions for gout flares (up to 1 year after diagnosis)
def with_these_admitted_events_date_X(name, codelist, index_date, n, return_expectations):

    def var_signature(name, codelist, on_or_after, return_expectations):
        return {
            name: patients.admitted_to_hospital(
                    with_these_diagnoses=codelist,
                    find_first_match_in_period=True,
                    returning="date_admitted",
                    date_format="YYYY-MM-DD",
                    between=[on_or_after, "gout_code_date + 1 year"],
                    return_expectations=return_expectations
        ),
        }
    variables = var_signature(f"{name}_1", codelist, index_date, return_expectations)
    for i in range(2, n+1):
        variables.update(var_signature(f"{name}_{i}", codelist, f"{name}_{i-1} + 1 day", return_expectations))
    return variables

# Get dates of recurrent ED attendances for gout flares (up to 1 year after diagnosis)
def with_these_emerg_events_date_X(name, codelist, index_date, n, return_expectations):

    def var_signature(name, codelist, on_or_after, return_expectations):
        return {
            name: patients.attended_emergency_care(
                    with_these_diagnoses=codelist,
                    find_first_match_in_period=True,
                    returning="date_arrived",
                    date_format="YYYY-MM-DD",
                    between=[on_or_after, "gout_code_date + 1 year"],
                    return_expectations=return_expectations
        ),
        }
    variables = var_signature(f"{name}_1", codelist, index_date, return_expectations)
    for i in range(2, n+1):
        variables.update(var_signature(f"{name}_{i}", codelist, f"{name}_{i-1} + 1 day", return_expectations))
    return variables

study = StudyDefinition(
    
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": end_date},
        "rate": "uniform",
        "incidence": 0.5,
    },
 
    # Disease codes
    gout_code_date=first_code_in_period(gout_codes),

    # Define study population 
    population=patients.satisfying(
            """
            gout_code_date AND
            has_follow_up AND
            (age >=18 AND age <= 110) AND
            (sex = "M" OR sex = "F")
            """,
            has_follow_up=patients.registered_with_one_practice_between(
                "gout_code_date - 1 year", "gout_code_date"        
            ),
        ),
    
    ## Has at least 6m of registration after index diagnosis
    has_6m_follow_up=patients.registered_with_one_practice_between(
            start_date = "gout_code_date", 
            end_date = "gout_code_date + 6 months",
            return_expectations={"incidence": 0.95}       
    ),

    ## Has at least 12m of registration after index diagnosis
    has_12m_follow_up=patients.registered_with_one_practice_between(
            start_date = "gout_code_date", 
            end_date = "gout_code_date + 1 year",
            return_expectations={"incidence": 0.90}       
    ),

    age=patients.age_as_of(
        "gout_code_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"1": 0.5, "2": 0.2, "3": 0.1, "4": 0.1, "5": 0.1}},
            "incidence": 0.75,
        },
    ),
    stp=patients.registered_practice_as_of(
        "gout_code_date",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    region=patients.registered_practice_as_of(
        "gout_code_date",
        returning="nuts1_region_name",
        return_expectations={
            "incidence": 0.99,
            "category": {
            "ratios": {
                "North East": 0.1,
                "North West": 0.1,
                "South West": 0.1,
                "Yorkshire and The Humber": 0.1,
                "East Midlands": 0.1,
                "West Midlands": 0.1,
                "East": 0.1,
                "London": 0.2,
                "South East": 0.1,
                },
            },
        },    
    ),
    imd=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "gout_code_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },
    ),
   
    # Death
    died_date_ons=patients.died_from_any_cause(
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": start_date}, "incidence": 0.05},
    ),

    # Medications
    ## Date of first ULT prescription on record
    first_ult_date=patients.with_these_medications(
        ult_codes,
        between = ["1900-01-01", end_date],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.7,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ),

    ## First ULT drug code and date (should match with above - if so, remove) - Nb. code will provide tablet strength, but not quantity or duration
    first_ult_code=patients.with_these_medications(
        ult_codes,
        between = ["1900-01-01", end_date],
        returning="code",
        find_first_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.7,
            "category": {"ratios": {"330061001": 0.3, "330062008": 0.3, "441623005": 0.2, "37197011000001106": 0.2}},
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ),

    ## Date of first allopurinol prescription on record (all doses)
    first_allo_date=patients.with_these_medications(
        allopurinol_codes,
        between = ["1900-01-01", end_date],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.6,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ),

    ## Date of first allopurinol prescription on record (100mg doses)
    first_allo100_date=patients.with_these_medications(
        allopurinol100_codes,
        between = ["1900-01-01", end_date],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.6,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ),

    ## Date of first allopurinol prescription on record (300mg doses)
    first_allo300_date=patients.with_these_medications(
        allopurinol300_codes,
        between = ["1900-01-01", end_date],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.6,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ),

    ## Date of first febuxostat prescription on record
    first_febux_date=patients.with_these_medications(
        febuxostat_codes,
        between = ["1900-01-01", end_date],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.2,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ),

    ## Number of ULT prescriptions issued in 6m after first script issued (Nb. doses may be double counted if both 300mg and 100mg issued)
    ult_count_6m=patients.with_these_medications(
        ult_codes,
        between = ["first_ult_date", "first_ult_date + 6 months"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.4,
        },
    ),

    ## Number of ULT prescriptions issued in 1 year after first script issued
    ult_count_12m=patients.with_these_medications(
        ult_codes,
        between = ["first_ult_date", "first_ult_date + 1 year"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.4,
        },
    ),

    ## Last ULT prescription within 6m of first script issued
    last_ult_6m=patients.with_these_medications(
        ult_codes,
        between = ["first_ult_date", "first_ult_date + 6 months"],
        returning="code",
        find_last_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.7,
            "category": {"ratios": {"330061001": 0.3, "330062008": 0.3, "441623005": 0.2, "37197011000001106": 0.2}},
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ), 

    ## Last allopurinol 100mg prescription within 6m of first script issued
    last_allo100_6m_date=patients.with_these_medications(
        allopurinol100_codes,
        between = ["first_ult_date", "first_ult_date + 6 months"],
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.7,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ), 

    ## Last allopurinol 300mg prescription within 6m of first script issued
    last_allo300_6m_date=patients.with_these_medications(
        allopurinol300_codes,
        between = ["first_ult_date", "first_ult_date + 6 months"],
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.7,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ), 

    ## Last ULT prescription within 1 year of first script issued
    last_ult_12m=patients.with_these_medications(
        ult_codes,
        between = ["first_ult_date", "first_ult_date + 1 year"],
        returning="code",
        find_last_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.7,
            "category": {"ratios": {"330061001": 0.3, "330062008": 0.3, "441623005": 0.2, "37197011000001106": 0.2}},
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ), 

    ## Last allopurinol 100mg prescription within 1 year of first script issued (to enable calculation of final dose)
    last_allo100_12m_date=patients.with_these_medications(
        allopurinol100_codes,
        between = ["first_ult_date", "first_ult_date + 1 year"],
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.7,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ), 

    ## Last allopurinol 300mg prescription within 1 year of first script issued (to enable calculation of final dose)
    last_allo300_12m_date=patients.with_these_medications(
        allopurinol300_codes,
        between = ["first_ult_date", "first_ult_date + 1 year"],
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.7,
            "date": {"earliest": "2013-01-01", "latest": end_date},
        },
    ),        

    ## Has at least 6m of registration after index ULT prescription
    has_6m_follow_up_ult=patients.registered_with_one_practice_between(
            start_date = "first_ult_date", 
            end_date = "first_ult_date + 6 months",
            return_expectations={"incidence": 0.95}       
    ),

    ## Has at least 12m of registration after index ULT prescription
    has_12m_follow_up_ult=patients.registered_with_one_practice_between(
            start_date = "first_ult_date", 
            end_date = "first_ult_date + 1 year",
            return_expectations={"incidence": 0.90}       
    ),

    # Serum urate monitoring (from 6 months before diagnosis to up to 2 years after diagnosis)
    ## Return first 10 serum urate levels after diagnosis
    **with_these_bloods_date_X(
        name="urate_test",
        codelist=urate_codes,
        index_date = "gout_code_date - 6 months",
        n=9,
        return_expectations={
            "date": {"earliest": "2014-04-01", "latest": end_date},
            "float": {"distribution": "normal", "mean": 400.0, "stddev": 100},
            "incidence": 0.70,
        },
    ),

    # Comorbidities (first comorbidity code prior to EIA code date; for bloods, test closest to EIA date chosen)
    chronic_cardiac_disease=first_comorbidity_in_period(chronic_cardiac_disease_codes),
    diabetes=first_comorbidity_in_period(diabetes_codes),
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        on_or_before = "gout_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"latest": end_date},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        on_or_before = "gout_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"latest": end_date},
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.95,
        },
    ),
    hypertension=first_comorbidity_in_period(hypertension_codes),
    chronic_respiratory_disease=first_comorbidity_in_period(chronic_respiratory_disease_codes),
    copd=first_comorbidity_in_period(copd_codes),
    chronic_liver_disease=first_comorbidity_in_period(chronic_liver_disease_codes),
    stroke=first_comorbidity_in_period(stroke_codes),
    lung_cancer=first_comorbidity_in_period(lung_cancer_codes),
    haem_cancer=first_comorbidity_in_period(haem_cancer_codes),
    other_cancer=first_comorbidity_in_period(other_cancer_codes),
    esrf=first_comorbidity_in_period(ckd_codes),
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before = "gout_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "float": {"distribution": "normal", "mean": 100.0, "stddev": 100.0},
            "date": {"latest": end_date},
            "incidence": 0.95,
        },
    ),
    organ_transplant=first_comorbidity_in_period(organ_transplant_codes),

    # BMI
    bmi=patients.most_recent_bmi(
        between = ["gout_code_date - 10 years", "gout_code_date"],
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.6,
            "float": {"distribution": "normal", "mean": 35, "stddev": 10},
        },
    ),

    # Smoking
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                     most_recent_smoking_code = 'E' OR (    
                       most_recent_smoking_code = 'N' AND ever_smoked   
                     )  
                """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before = "gout_code_date",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before = "gout_code_date",
        ),
    ),

    ## Use of diuretics around diagnosis (within 4m of diagnosis)
    diuretic_date=patients.with_these_medications(
        diuretic_codes,
        between = ["gout_code_date - 4 months", "gout_code_date"],
        returning="date",
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "incidence": 0.2,
            "date": {"earliest": "2014-01-01", "latest": end_date},
        },
    ),

    # Gout emergency attendances/admissions
    ## Dates of hospitals admission for flares (from the 1 month before index diagnostic code to 1 year after diagnosis, to account for index admissions)
    **with_these_admitted_events_date_X(
        name="gout_admission",
        codelist=gout_admission,
        index_date="gout_code_date - 1 month",
        n=9,
        return_expectations={
            "date": {"earliest": "2014-03-01", "latest": end_date},
            "incidence": 0.3,
        },
    ),

    ## Any admissions more than a month before index diagnosis code
    gout_admission_pre_date=patients.admitted_to_hospital(
        with_these_diagnoses=gout_admission,
        find_first_match_in_period=True,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        on_or_before ="gout_code_date - 1 month", 
        return_expectations={
            "date": {"earliest": "1950-03-01", "latest": end_date},
            "incidence": 0.05,
        },
    ),

    ## Gout hospital admission count in first year
    gout_admission_count=patients.admitted_to_hospital(
        with_these_diagnoses=gout_admission,
        returning="number_of_matches_in_period",
        between = ["gout_code_date - 1 month", "gout_code_date + 1 year"], 
        return_expectations={
            "int": {"distribution": "normal", "mean": 1, "stddev": 1},
            "date": {"earliest": "2015-04-01", "latest": end_date},
        },
    ),

    ## Dates of ED attendances for flares (from the 1 month before index diagnostic code to 1 year after diagnosis, to account for index admissions)
    **with_these_emerg_events_date_X(
        name="gout_emerg",
        codelist=gout_codes,
        index_date="gout_code_date - 1 month",
        n=9,
        return_expectations={
            "date": {"earliest": "2014-03-01", "latest": end_date},
            "incidence": 0.3,
        },
    ),

    gout_emerg_pre_date=patients.attended_emergency_care(
        with_these_diagnoses=gout_codes,
        find_first_match_in_period=True,
        returning="date_arrived",
        date_format="YYYY-MM-DD",
        on_or_before ="gout_code_date - 1 month", 
        return_expectations={
            "date": {"earliest": "1950-03-01", "latest": end_date},
            "incidence": 0.05,
        },
    ),

    ## Gout ED attendance count in first year
    gout_ed_count=patients.attended_emergency_care(
        with_these_diagnoses=gout_codes,
        returning="number_of_matches_in_period",
        between = ["gout_code_date - 1 month", "gout_code_date + 1 year"], 
        return_expectations={
            "int": {"distribution": "normal", "mean": 1, "stddev": 1},
            "date": {"earliest": "2015-04-01", "latest": end_date},
        },
    ),

    ## Tophi
    tophi_date=patients.with_these_clinical_events(
        tophi_codes,
        returning="date",
        on_or_after = "1900-01-01",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.2,
            "date": {"earliest": "2014-01-01", "latest": end_date},
        },
    ),

    ## Flare codes
    gout_flare_count=patients.with_these_clinical_events(
        gout_flare,
        between = ["gout_code_date + 14 days", "gout_code_date + 6 months"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
        },
    ),

    flare_treatment_count=patients.with_these_medications(
        flare_treatment,
        between = ["gout_code_date + 14 days", "gout_code_date + 6 months"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
        },
    ),

    **with_these_clinical_events_date_X(
        name="gout_flare",
        codelist=gout_flare,
        index_date="gout_code_date + 14 days",
        n=9,
        return_expectations={
            "date": {"earliest": "2014-04-01", "latest": end_date},
            "incidence": 0.4,
        },
    ),

    **with_these_clinical_events_date_X(
        name="gout_code_any",
        codelist=gout_codes,
        index_date="gout_code_date + 14 days",
        n=9,
        return_expectations={
            "date": {"earliest": "2014-04-01", "latest": end_date},
            "incidence": 0.5,
        },
    ),

    **with_these_medication_events_date_X(
        name="flare_treatment",
        codelist=flare_treatment,
        index_date="gout_code_date + 14 days",
        n=9,
        return_expectations={
            "date": {"earliest": "2014-04-01", "latest": end_date},
            "incidence": 0.4,
        },
    ),
)