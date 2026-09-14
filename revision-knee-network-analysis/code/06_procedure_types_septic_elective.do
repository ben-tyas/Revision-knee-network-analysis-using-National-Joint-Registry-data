/********************************************************************
Revision Knee Network analysis
File: 06_procedure_types_septic_elective.do
Purpose: Summarise procedure types for septic elective cases.

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
keep if septicelective==1

*--------------------------------------------------------------*
* Create three versions of each observation:
* 1 = All cases
* 2 = MRC category
* 3 = Network category
*--------------------------------------------------------------*

gen long original_case = _n

expand 3
bysort original_case: gen byte column_section = _n

label define column_section_lbl ///
    1 "All" ///
    2 "MRC category" ///
    3 "Network category", replace

label values column_section column_section_lbl
label variable column_section "Column group"

* Convert labelled numeric variables to text for column headings
decode mrc, gen(mrc_text)
decode network, gen(network_text)

* Variable holding the individual column heading within each group
gen str120 column_member = ""

replace column_member = "All cases" if column_section == 1
replace column_member = mrc_text if column_section == 2
replace column_member = network_text if column_section == 3

* Remove duplicated records where MRC or network is missing
keep if column_section == 1 | ///
    (column_section == 2 & !missing(mrc)) | ///
    (column_section == 3 & !missing(network))

*--------------------------------------------------------------*
* Create table
*
* Rows: calendar year, then procedure type
* Columns: All cases, MRC categories, then network categories
*
* Percentages sum to 100% down procedure types within each
* year and column.
*--------------------------------------------------------------*

collect clear

table (year proctype) (column_section column_member), ///
    statistic(frequency) ///
    statistic(percent, across(proctype)) ///
    name(Table)

*--------------------------------------------------------------*
* Format n and percentage
*--------------------------------------------------------------*

collect style cell result[frequency], ///
    nformat(%9.0fc) ///
    name(Table)

collect style cell result[percent], ///
    nformat(%5.1f) ///
    sformat("(%s%%)") ///
    name(Table)

* Create composite result: n (x.x%)
collect composite define n_percent = frequency percent, ///
    delimiter(" ") ///
    trim ///
    name(Table)

*--------------------------------------------------------------*
* Arrange the table
*--------------------------------------------------------------*

collect layout ///
    (year#proctype) ///
    (column_section#column_member#result[n_percent]), ///
    name(Table)

* Hide the composite-statistic heading
collect style header result[n_percent], level(hide) ///
    name(Table)

collect preview

collect export "$tables/proceduretype_by_mrc_network_septicelectivecasesv2.xlsx", replace name(Table)