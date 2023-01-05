from cohortextractor import StudyDefinition, patients, Measure, codelist, codelist_from_csv, combine_codelists, filter_codes_by_category

from codelists import *

study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "index_date"},
        "rate": "uniform",
        "incidence": 0.5,
    },

    index_date = "2015-01-01",
 
    # Define study population
    population=patients.satisfying(
            """
            registered AND
            (age >=18 AND age <= 110) AND
            (sex = "M" OR sex = "F")
            """,
            registered=patients.registered_as_of("index_date"),
        ),       
    age=patients.age_as_of(
        "index_date",
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
    # Patients with at least 12 months of registration with one practice before index date
    pre_registration=patients.registered_with_one_practice_between(
                start_date="index_date - 1 year",
                end_date="index_date",   
                return_expectations={"incidence": 0.98},  
    ),             
    # Prevalent gout patients: i.e. gout diagnosis code at any point before index date
    prevalent_gout=patients.with_these_clinical_events(
        gout_codes,
        returning="binary_flag",
        on_or_before="index_date",
        return_expectations={
            "incidence": 0.1,
        },
    ),    
    # Incidence of admissions to hospital with primary diagnosis code of gout in the 1 month after index date
    gout_admission=patients.admitted_to_hospital(
        with_these_diagnoses=gout_admission,
        returning="binary_flag",
        between=["index_date", "last_day_of_month(index_date)"],
        return_expectations={"incidence": 0.1},
   ),
)

measures = [
    Measure(
        id="registration_by_month",
        numerator="pre_registration",
        denominator="population",
        group_by="population"
    ),
    # Could change below to those with >12m of pre-registration
    Measure(
        id="prevalent_gout_by_month",
        numerator="prevalent_gout",
        denominator="population",
        group_by="population"
    ),
    Measure(
        id="pop_gout_admission_by_month",
        numerator="gout_admission",
        denominator="population",
        group_by="population"
    ),
    Measure(
        id="prev_gout_admission_by_month",
        numerator="gout_admission",
        denominator="prevalent_gout",
        group_by="population"
    ),
]    
