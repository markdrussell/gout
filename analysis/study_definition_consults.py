from cohortextractor import StudyDefinition, patients

from cohortextractor.codelistlib import filter_codes_by_category

from codelists import *

year_preceding = "2018-03-01"
start_date = "2019-03-01"
end_date = "2020-03-01"
follow_up = "2020-09-01"

# Date of first consultation for gout in primary care record within a 1-year period - code
def first_consultation_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        find_first_match_in_period=True,
        between=[start_date, end_date],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": start_date, "latest": end_date},
            "incidence": 0.99,
        },
    )

# Date of first consultation for gout in primary care record within a 1-year period - code
def first_consultation_code_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="code",
        find_first_match_in_period=True,
        between=[start_date, end_date],
        return_expectations={
            "incidence": 0.99,
            "category": {
                "ratios": {
                    "10000000": 0.2,
                    "11000000": 0.2,
                    "12000000": 0.2,
                    "13000000": 0.2,
                    "14000000": 0.2,
                }
            },
        },
    )    

# Date of first gout code prior to start date (i.e. date of prevalent gout diagnosis)
def first_code_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        find_first_match_in_period=True,
        on_or_before=start_date,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.70,
            "date": {"earliest": "1920-01-01", "latest": start_date},
        },
    )

# Get dates of recurrent blood tests (up to 6 months after consultation)
def with_these_bloods_date_X(name, codelist, index_date, n, return_expectations):
    def var_signature(name, codelist, on_or_after, return_expectations):
        return {
            name: patients.with_these_clinical_events(
                codelist,
                find_first_match_in_period=True,
                returning="numeric_value",
                include_date_of_match=True,
                date_format="YYYY-MM-DD",
                between=[on_or_after, "gout_code_date + 6 months"],
                return_expectations=return_expectations,
            ),
        }

    variables = var_signature(f"{name}_1", codelist, index_date, return_expectations)
    for i in range(2, n + 1):
        variables.update(
            var_signature(
                f"{name}_{i}",
                codelist,
                f"{name}_{i-1}_date + 1 day",
                return_expectations,
            )
        )
    return variables

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": end_date},
        "rate": "uniform",
        "incidence": 0.5,
    },
    # Disease codes - any gout code during 1-year period
    gout_code_date=first_consultation_in_period(prevalent_gout_codes),

    # Define study population
    population=patients.satisfying(
        """
            gout_code_date AND
            has_6m_follow_up AND
            (age >=18 AND age <= 110) AND
            (sex = "M" OR sex = "F")
            """,
    ),

    ## Has at least 6m of registration after consultation
    has_6m_follow_up=patients.registered_with_one_practice_between(
        start_date="gout_code_date",
        end_date="gout_code_date + 6 months",
        return_expectations={"incidence": 1},
    ),

    # Snomed code for consultation
    gout_snomed=first_consultation_code_in_period(prevalent_gout_codes),

    # First gout code prior to start date (i.e. prevalent diagnoses)
    gout_prevalent_date=first_code_in_period(
        prevalent_gout_codes
    ),

    ## Has registration for the full study period (18m)
    registered_18m=patients.registered_with_one_practice_between(
        start_date=start_date,
        end_date=follow_up,
        return_expectations={"incidence": 0.90},
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

    practice=patients.registered_practice_as_of(
        "gout_code_date",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 1000, "stddev": 100},
            "incidence": 1,
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
        between=["1920-01-01", "gout_code_date + 6 months"],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.90,
            "date": {"earliest": "1920-01-01", "latest": follow_up},
        },
    ),

    ## First ULT prescription within 6m before or after consultation 
    recent_ult_date=patients.with_these_medications(
        ult_codes,
        between=["gout_code_date - 6 months", "gout_code_date + 6 months"],
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.90,
            "date": {"earliest": start_date, "latest": follow_up},
        },
    ),

    ## Has at least 6m of registration after ULT prescription
    has_6m_follow_up_ult=patients.registered_with_one_practice_between(
        start_date="recent_ult_date",
        end_date="recent_ult_date + 6 months",
        return_expectations={"incidence": 0.80},
    ),

    # Serum urate monitoring (from 6 months before consultation to up to 6 months after consultation)
    ## Return first n serum urate levels after diagnosis
    **with_these_bloods_date_X(
        name="urate_test",
        codelist=urate_codes,
        index_date="gout_code_date - 6 months",
        n=7,
        return_expectations={
            "date": {"earliest": year_preceding, "latest": follow_up},
            "float": {"distribution": "normal", "mean": 300, "stddev": 100},
            "incidence": 0.95,
        },
    ),
)
