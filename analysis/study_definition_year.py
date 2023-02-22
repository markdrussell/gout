from cohortextractor import StudyDefinition, patients, Measure

from cohortextractor.codelistlib import filter_codes_by_category

from codelists import *

study = StudyDefinition(

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "index_date"},
        "rate": "uniform",
        "incidence": 0.5,
    },

    # Mid-year population estimate
    index_date = "2015-07-01",
 
    # Define study population
    population=patients.satisfying(
            """
            registered AND
            (age >=18 AND age <= 110) AND
            (sex = "M" OR sex = "F")
            """,
            # Denominator for prevalence would be all patients registered at mid-year
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
    # Prevalent gout patients: i.e. registered patients with a gout diagnosis code at any point before index date
    prevalent_gout=patients.with_these_clinical_events(
        prevalent_gout_codes,
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
        between=["index_date - 6 months", "index_date + 6 months"],
        return_expectations={"incidence": 0.1},
    ),
    # Denominator for incidence: patients with at least 12 months of registration with one practice before index date
    pre_registration=patients.registered_with_one_practice_between(
        start_date="index_date - 12 months",
        end_date="index_date",   
        return_expectations={"incidence": 0.98},  
    ),   
    # Denominator for admissions could be patients with at least 6 months of registration before and after index date vs. single mid-year (as above)
    adm_registration=patients.registered_with_one_practice_between(
        start_date="index_date - 6 months",
        end_date="index_date + 6 months",   
        return_expectations={"incidence": 0.98},  
    ),   
)
measures = [
    Measure(
        id="pre_registration",
        numerator="pre_registration",
        denominator="population",
        group_by="sex"
    ),
    Measure(
        id="adm_registration",
        numerator="adm_registration",
        denominator="population",
        group_by="sex"
    ),
    Measure(
        id="prevalent_gout",
        numerator="prevalent_gout",
        denominator="population",
        group_by="sex"
    ),
    Measure(
        id="gout_admission_pop",
        numerator="gout_admission",
        denominator="population",
        group_by="sex"
    ),
    # Perhaps should restrict to admissions in patients with prevalent gout codes - may bias against index diagnoses - therefore could remove this
    Measure(
        id="gout_admission_prev",
        numerator="gout_admission",
        denominator="prevalent_gout",
        group_by="sex"
    ),
]    