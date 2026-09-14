/********************************************************************
Revision Knee Network analysis
File: 09_complexity_by_network.do
Purpose: Summarise RKCC/PIES complexity factors by network.

Run from 00_master.do. This script expects project path globals to
have been defined by the master file.
********************************************************************/

version 19.0
set more off

clear
capture log close

use "$data_derived/cleandataset.dta", clear

*--------------------------------------------------------------*
* Keep calendar years of interest
*--------------------------------------------------------------*

keep if inlist(year, 2024, 2025)

*--------------------------------------------------------------*
* Create overlapping case-category columns
*
* Every observation is included in "All cases", then additionally
* appears in each category for which its indicator is present.
*--------------------------------------------------------------*

gen long original_case = _n

expand 8
bysort original_case: gen byte case_type = _n

keep if case_type == 1 | /// All cases
        (case_type == 2 & rkcc == 1) | ///
        (case_type == 3 & rkcc == 2) | ///
        (case_type == 4 & rkcc == 3) | ///
        (case_type == 5 & ptcomorbid == 1) | ///
        (case_type == 6 & infection == 1) | ///
        (case_type == 7 & extensor == 1) | ///
        (case_type == 8 & softtissue == 1)

label define case_type_lbl ///
    1 "All cases" ///
    2 "RKCC = 1" ///
    3 "RKCC = 2" ///
    4 "RKCC = 3" ///
    5 "Patient comorbidity" ///
    6 "Infection" ///
    7 "Extensor mechanism" ///
    8 "Soft tissue", replace

label values case_type case_type_lbl
label variable case_type "Case category"

*--------------------------------------------------------------*
* Store all network levels for final hierarchical layout
*--------------------------------------------------------------*

levelsof network, local(networks)

*--------------------------------------------------------------*
* Start a fresh results collection
*--------------------------------------------------------------*

collect clear

*--------------------------------------------------------------*
* National MRC figures
*
* Percentages sum to 100% within each case category and year
* across MRC categories.
*--------------------------------------------------------------*

table (mrc) (case_type year), ///
    statistic(frequency) ///
    statistic(percent, across(mrc)) ///
    name(Table)
*--------------------------------------------------------------*
* Trust figures within each network
*
* Percentages sum to 100% within each network, case category
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
    nformat(%9.0f) ///
    name(Table)

collect style cell result[percent], ///
    nformat(%5.1f) ///
    sformat("(%s%%)") ///
    name(Table)

*--------------------------------------------------------------*
* Define displayed statistic: n (%)
*--------------------------------------------------------------*

collect composite define n_percent = frequency percent, ///
    delimiter(" ") ///
    trim ///
    name(Table)

*--------------------------------------------------------------*
* Arrange rows and columns
*
* Rows:
*   National MRC categories, followed by networks and trusts.
*
* Columns:
*   Case category, then calendar year, with n (%) displayed.
*--------------------------------------------------------------*

collect layout ///
    (mrc network[`networks']#trust) ///
    (case_type#year#result[n_percent]), ///
    name(Table)

*--------------------------------------------------------------*
* Hide redundant composite-result header
*--------------------------------------------------------------*

collect style header result[n_percent], level(hide) ///
    name(Table)

*--------------------------------------------------------------*
* Preview table
*--------------------------------------------------------------*

collect preview

collect export "$tables/complexitybynetworkv2.xlsx", replace name(Table)