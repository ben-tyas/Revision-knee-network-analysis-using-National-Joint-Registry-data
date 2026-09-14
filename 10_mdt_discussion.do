/********************************************************************
Revision Knee Network analysis
File: 10_mdt_discussion.do
Purpose: Summarise local and regional/infection MDT discussion.

Run from 00_master.do. This script expects project path globals to
have been defined by the master file.
********************************************************************/

version 19.0
set more off

clear
capture log close

use "$data_derived/cleandataset.dta", clear
*--------------------------------------------------------------*
* MDT distribution table:
* National results followed by Local and Regional MDT results
* grouped together within each network
* Calendar years: 2024 and 2025
*--------------------------------------------------------------*

preserve

*--------------------------------------------------------------*
* Restrict to calendar years of interest
*--------------------------------------------------------------*

keep if inlist(year, 2024, 2025)

*--------------------------------------------------------------*
* Create overlapping column groups
*
* Each original case is retained in "All cases", and is also
* included in its relevant RKCC and indication group(s).
*--------------------------------------------------------------*

gen long original_case = _n

expand 5
bysort original_case: gen byte case_type = _n

keep if case_type == 1 | /// All cases
        (case_type == 2 & rkcc == 1) | ///
        (case_type == 3 & rkcc == 2) | ///
        (case_type == 4 & rkcc == 3) | ///
        (case_type == 5 & indication == 1)

label define case_type_lbl ///
    1 "All cases" ///
    2 "RKCC = 1" ///
    3 "RKCC = 2" ///
    4 "RKCC = 3" ///
    5 "Infected cases", replace

label values case_type case_type_lbl
label variable case_type "Case category"

*--------------------------------------------------------------*
* Create a numeric network identifier with value labels
*
* This works whether network is currently a string or numeric
* variable. Network code 0 is reserved for national results.
*--------------------------------------------------------------*

egen int network_id = group(network), label

local network_label : value label network_id

levelsof network_id, local(networks)

label define report_network_lbl ///
    0 "National", replace

foreach n of local networks {

    local network_name : label `network_label' `n'

    label define report_network_lbl ///
        `n' `"`network_name'"', add
}

*--------------------------------------------------------------*
* Duplicate data:
*
* geography = 1 gives the national result;
* geography = 2 gives the relevant network-specific result.
*--------------------------------------------------------------*

expand 2
bysort original_case case_type: gen byte geography = _n

gen int report_network = 0

replace report_network = network_id if geography == 2

label values report_network report_network_lbl
label variable report_network "Network"

*--------------------------------------------------------------*
* Reshape Local MDT and Regional MDT into one common MDT
* section variable.
*
* This is what allows Local and Regional MDT results to be
* displayed together within every network.
*--------------------------------------------------------------*

rename localmdt    mdt_local
rename regionalmdt mdt_regional

reshape long mdt_, ///
    i(original_case case_type geography) ///
    j(mdt_type) string

rename mdt_ mdt_response
label values mdt_response yesno
*--------------------------------------------------------------*
* Label MDT section
*--------------------------------------------------------------*

gen byte mdt_section = .

replace mdt_section = 1 if mdt_type == "local"
replace mdt_section = 2 if mdt_type == "regional"

label define mdt_section_lbl ///
    1 "Discussed in local MDT" ///
    2 "Discussed in regional/infection MDT", replace

label values mdt_section mdt_section_lbl
label variable mdt_section "MDT discussion"

drop mdt_type

*--------------------------------------------------------------*
* Start a fresh collection
*--------------------------------------------------------------*

collect clear

*--------------------------------------------------------------*
* Create table
*
* Percentages sum to 100% within each:
*   network/national section
*   MDT section
*   case category
*   calendar year
*--------------------------------------------------------------*

table (report_network mdt_section mdt_response) ///
      (case_type year), ///
    statistic(frequency) ///
    statistic(percent, across(mdt_response)) ///
    name(Table)

*--------------------------------------------------------------*
* Format component statistics
*--------------------------------------------------------------*

collect style cell result[frequency], ///
    nformat(%9.0f) ///
    name(Table)

collect style cell result[percent], ///
    nformat(%5.1f) ///
    sformat("(%s%%)") ///
    name(Table)

*--------------------------------------------------------------*
* Combine statistics as n (%)
*--------------------------------------------------------------*

collect composite define n_percent = frequency percent, ///
    delimiter(" ") ///
    trim ///
    name(Table)

*--------------------------------------------------------------*
* Arrange rows and columns
*
* Rows will be ordered:
* National
*     Local MDT
*     Regional/infection MDT
* Birmingham
*     Local MDT
*     Regional/infection MDT
* Bristol
*     Local MDT
*     Regional/infection MDT
* etc.
*--------------------------------------------------------------*

collect layout ///
    (report_network#mdt_section#mdt_response) ///
    (case_type#year#result[n_percent]), ///
    name(Table)

*--------------------------------------------------------------*
* Hide redundant n (%) result heading
*--------------------------------------------------------------*

collect style header result[n_percent], level(hide) ///
    name(Table)

*--------------------------------------------------------------*
* Preview table
*--------------------------------------------------------------*

collect preview

restore
collect export "$tables/mdtdiscussion.xlsx", replace name(Table)