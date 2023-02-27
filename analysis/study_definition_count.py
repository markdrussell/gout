from cohortextractor import StudyDefinition, patients

from cohortextractor.codelistlib import filter_codes_by_category

from codelists import *

year_preceding = "2018-01-01"
start_date = "2019-01-01"
end_date = "2020-01-01"

# This study definition is used to determine distribution of key variables used for iterations (e.g. multiple urate levels)

# Date of first gout code in primary care record
def first_code_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        on_or_before=end_date,
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.99,
            "date": {"earliest": year_preceding, "latest": end_date},
        },
    )

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

    # Urate level count (from 6 months before diagnosis to up to 1 years after diagnosis)
    ## CTV3 codelist, including missing
    urate_count=patients.with_these_clinical_events(
        codelist=urate_codes,
        returning="number_of_matches_in_period",
        between=["gout_code_date - 6 months", "gout_code_date + 1 year"],
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
        },
    ),
    ## CTV3 codelist, ignoring missing
    urate_count_nom=patients.with_these_clinical_events(
        codelist=urate_codes,
        returning="number_of_matches_in_period",
        ignore_missing_values=True,
        between=["gout_code_date - 6 months", "gout_code_date + 1 year"],
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
        },
    ),
    ## Snomed codelist, including missing
    urate_count_sno=patients.with_these_clinical_events(
        codelist=urate_codes_snomed,
        returning="number_of_matches_in_period",
        between=["gout_code_date - 6 months", "gout_code_date + 1 year"],
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
        },
    ),
    ## Snomed codelist, ignoring missing
    urate_count_sno_nom=patients.with_these_clinical_events(
        codelist=urate_codes_snomed,
        returning="number_of_matches_in_period",
        ignore_missing_values=True,
        between=["gout_code_date - 6 months", "gout_code_date + 1 year"],
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
        },
    ),
    # Gout emergency attendances/admissions
    ## Gout hospital admission count in first year
    gout_admission_count=patients.admitted_to_hospital(
        with_these_primary_diagnoses=gout_admission,
        returning="number_of_matches_in_period",
        between=["gout_code_date - 1 month", "gout_code_date + 1 year"],
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
        },
    ),
    ## Gout ED attendance count in first year
    gout_ed_count=patients.attended_emergency_care(
        with_these_diagnoses=gout_codes,
        returning="number_of_matches_in_period",
        between=["gout_code_date - 1 month", "gout_code_date + 1 year"],
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
        },
    ),
    ## Flare codes
    gout_flare_count=patients.with_these_clinical_events(
        gout_flare,
        between=["gout_code_date + 14 days", "gout_code_date + 1 year"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
        },
    ),
    gout_code_count=patients.with_these_clinical_events(
        gout_codes,
        between=["gout_code_date + 14 days", "gout_code_date + 1 year"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
        },
    ),
    flare_treatment_count=patients.with_these_medications(
        flare_treatment,
        between=["gout_code_date + 14 days", "gout_code_date + 1 year"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 1},
        },
    ),
)