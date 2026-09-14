/********************************************************************
Revision Knee Network analysis
Master do-file

Run this file from the repository root directory.
Stata version: 19.0
********************************************************************/

version 19.0
clear all
set more off
capture log close

* Project directories ------------------------------------------------
global project      "`c(pwd)'"
global code         "$project/code"
global data_raw     "$project/data/raw"
global data_derived "$project/data/derived"
global output       "$project/output"
global tables       "$output/tables"
global logs         "$output/logs"

* Create writable output directories if required ---------------------
capture mkdir "$data_derived"
capture mkdir "$output"
capture mkdir "$tables"
capture mkdir "$logs"

* Input check ---------------------------------------------------------
capture confirm file "$data_raw/Raw data.dta"
if _rc {
    display as error "Required input file not found: $data_raw/Raw data.dta"
    display as error "The raw NJR dataset is not distributed with this repository."
    exit 601
}

* Analysis workflow ---------------------------------------------------
do "$code/01_clean_data.do"
do "$code/02_surgeon_volumes.do"
do "$code/03_overall_numbers.do"
do "$code/04_unit_volumes_2024_2025.do"
do "$code/05_procedure_types.do"
do "$code/06_procedure_types_septic_elective.do"
do "$code/07_indications.do"
do "$code/08_rkcc.do"
do "$code/09_complexity_by_network.do"
do "$code/10_mdt_discussion.do"
do "$code/11_low_volume_units.do"

display as result "Revision Knee Network analysis complete."
