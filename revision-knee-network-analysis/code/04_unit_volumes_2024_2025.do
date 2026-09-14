/********************************************************************
Revision Knee Network analysis
File: 04_unit_volumes_2024_2025.do
Purpose: Summarise 2024–2025 activity by case category and unit.

Run from 00_master.do. This script expects project path globals to
have been defined by the master file.
********************************************************************/

version 19.0
set more off

clear
capture log close

use "$data_derived/cleandataset.dta", clear

* Keep calendar years of interest
keep if inlist(year, 2024, 2025)

*--------------------------------------------------------------*
* Create overlapping case-category columns
* Every case appears in "All cases", and additionally in each
* subgroup for which its relevant indicator equals 1.
*--------------------------------------------------------------*

gen long original_case = _n

expand 7
bysort original_case: gen byte case_type = _n

keep if case_type == 1 | ///
    (case_type == 2 & elective == 1) | ///
    (case_type == 3 & asepticelective == 1) | ///
    (case_type == 4 & septicelective == 1) | ///
    (case_type == 5 & emergency == 1) | ///
    (case_type == 6 & dair == 1) | ///
    (case_type == 7 & fracture == 1)

label define case_type_lbl ///
    1 "All cases" ///
    2 "All elective" ///
    3 "Aseptic elective" ///
    4 "Septic elective" ///
    5 "All emergencies" ///
    6 "DAIRs" ///
    7 "Fractures", replace

label values case_type case_type_lbl
label variable case_type "Case category"

* Store all network levels for the final hierarchical layout
levelsof network, local(networks)

* Start a fresh results collection
collect clear

*--------------------------------------------------------------*
* National MRC figures
* Percentages sum to 100% within each case category and year.
*--------------------------------------------------------------*

table (mrc) (case_type year), ///
    statistic(frequency) ///
    statistic(percent, across(mrc)) ///
    name(Table)

*--------------------------------------------------------------*
* Trust figures within each network
* Percentages sum to 100% within each network, case category,
* and calendar year.
*--------------------------------------------------------------*

table (network trust) (case_type year), ///
    statistic(frequency) ///
    statistic(percent, across(trust)) ///
    append ///
    name(Table)

*--------------------------------------------------------------*
* Format the two component statistics
*--------------------------------------------------------------*

collect style cell result[frequency], ///
    nformat(%9.0fc) ///
    name(Table)

collect style cell result[percent], ///
    nformat(%5.1f) ///
    sformat("(%s%%)") ///
    name(Table)

*--------------------------------------------------------------*
* Define the displayed statistic: n (x.x%)
*--------------------------------------------------------------*

collect composite define n_percent = frequency percent, ///
    delimiter(" ") ///
    trim ///
    name(Table)

*--------------------------------------------------------------*
* Arrange rows and columns
*--------------------------------------------------------------*

collect layout ///
    (mrc network[`networks']#trust) ///
    (case_type#year#result[n_percent]), ///
    name(Table)

* Hide the otherwise redundant composite-result label
collect style header result[n_percent], level(hide) ///
    name(Table)

collect preview

collect export "$tables/unitvolumes24_25_rawv2.xlsx", replace name(Table)