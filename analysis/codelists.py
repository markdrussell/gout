from cohortextractor import (
    codelist_from_csv,
    combine_codelists,
    codelist,
)

# Demographics
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)

# Smoking
clear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

# Clinical conditions
gout_codes = codelist_from_csv(
    "codelists/user-markdrussell-gout.csv", system="snomed", column="code",
)

urate_codes = codelist_from_csv(
    "codelists/user-markdrussell-serum-urateuric-acid-ctv3.csv", system="ctv3", column="code",
)

chronic_cardiac_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv", system="ctv3", column="CTV3ID",
)

diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes.csv", system="ctv3", column="CTV3ID",
)

hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")

hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension.csv", system="ctv3", column="CTV3ID",
)

chronic_respiratory_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

copd_codes = codelist_from_csv(
    "codelists/opensafely-current-copd.csv", system="ctv3", column="CTV3ID",
)

chronic_liver_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease.csv", system="ctv3", column="CTV3ID",
)

stroke_codes = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv", system="ctv3", column="CTV3ID",
)

lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv", system="ctv3", column="CTV3ID",
)

haem_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv", system="ctv3", column="CTV3ID",
)

other_cancer_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)

creatinine_codes = codelist(["XE2q5"], system="ctv3")

ckd_codes = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease.csv", system="ctv3", column="CTV3ID",
)

organ_transplant_codes = codelist_from_csv(
    "codelists/opensafely-solid-organ-transplantation.csv",
    system="ctv3",
    column="CTV3ID",
)

# Medications
allopurinol_codes = codelist_from_csv(
    "local_codelists/markdrussell-allopurinol-7cdcdf94-dmd.csv",
    system="snomed",
    column="dmd_id",
)

allopurinol100_codes = codelist_from_csv(
    "local_codelists/markdrussell-allopurinol-100mg-tablets-6be5ac41-dmd.csv",
    system="snomed",
    column="dmd_id",
)

allopurinol300_codes = codelist_from_csv(
    "local_codelists/markdrussell-allopurinol-300mg-doses-52d6390c-dmd.csv",
    system="snomed",
    column="dmd_id",
)

febuxostat_codes = codelist_from_csv(
    "local_codelists/markdrussell-febuxostat-4abdf92a-dmd.csv",
    system="snomed",
    column="dmd_id",
)

febuxostat80_codes = codelist_from_csv(
    "local_codelists/markdrussell-febuxostat-80mg-doses-39c6c5d7-dmd.csv",
    system="snomed",
    column="dmd_id",
)

febuxostat120_codes = codelist_from_csv(
    "local_codelists/markdrussell-febuxostat-120mg-doses-20b752a2-dmd.csv",
    system="snomed",
    column="dmd_id",
)

ult_codes = combine_codelists(
allopurinol_codes,
febuxostat_codes
)

loop_diuretics_codes = codelist_from_csv(
    "codelists/pincer-diur.csv",
    system="snomed",
    column="id",
)

thiazide_diuretics_codes = codelist_from_csv(
    "codelists/opensafely-thiazide-type-diuretic-medication.csv",
    system="snomed",
    column="id",
)

diuretic_codes = combine_codelists(
loop_diuretics_codes,
thiazide_diuretics_codes
)

oral_steroids = codelist_from_csv(
    "codelists/nhsd-oral-steroid-drugs-pra-dmd.csv",
    system="snomed",
    column="dmd_id",
)

nsaids = codelist_from_csv(
    "codelists/pincer-nsaid.csv",
    system="snomed",
    column="id",
)

colchicine = codelist_from_csv(
    "local_codelists/markdrussell-colchicine-76b0ac19-dmd.csv",
    system="snomed",
    column="dmd_id",
)

flare_treatment = combine_codelists(
oral_steroids,
nsaids,
colchicine
)

tophi_codes = codelist_from_csv(
    "codelists/user-markdrussell-gouty-tophi.csv", system="snomed", column="code",
)

# Admissions
gout_admission = codelist_from_csv(
    "codelists/user-markdrussell-gout-admissions.csv",
    system="icd10",
    column="code",
)  

# Flare codes
gout_flare = codelist_from_csv(
    "codelists/user-markdrussell-gout-flaresattacks.csv",
    system="snomed",
    column="code",
)