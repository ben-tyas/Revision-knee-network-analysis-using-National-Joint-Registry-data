/********************************************************************
Revision Knee Network analysis
File: 02_surgeon_volumes.do
Purpose: Calculate national and network-level annual surgeon-volume metrics.

Run from 00_master.do. This script expects project path globals to
have been defined by the master file.
********************************************************************/

version 19.0
set more off

clear
capture log close

use "$data_derived/cleandataset.dta", clear

log using "$logs/surgeonvolumes.txt", replace text

*--------------------------------------------------------------*
* National annual surgeon volumes: calculated across ALL networks
*--------------------------------------------------------------*

* Total procedures per surgeon per year, irrespective of network
bysort LeadSurgeonID year: egen totalvolume = count(LeadSurgeonID)

* Total elective procedures per surgeon per year, irrespective of network
bysort LeadSurgeonID year: egen electivevolume = total(elective == 1)

* Total emergency procedures per surgeon per year, irrespective of network
bysort LeadSurgeonID year: egen emergencyvolume = total(emergency == 1)

* Surgeon classified as exclusively emergency nationally that year
generate allemergency = totalvolume == emergencyvolume & totalvolume > 0

* Tag each surgeon once nationally within each year
egen tag_surgeon_year = tag(LeadSurgeonID year)

* Tag each surgeon once within each network and year
* This is used only for counting unique surgeons within a network.
egen tag_surgeon_network_year = tag(network LeadSurgeonID year)

*--------------------------------------------------------------*
* Report national activity first
*--------------------------------------------------------------*

display "=================================================="
display "NATIONAL FIGURES"
display "=================================================="

foreach y in 2024 2025 {

    display "--------------------------------------------------"
    display "Year: `y'"

    * Total number of revision procedures nationally
    quietly count if year == `y'
    local allrevisions = r(N)
    display "Total number of revision procedures: " `allrevisions'

    * Total unique surgeons nationally
    quietly count if year == `y' & tag_surgeon_year
    display "Total unique surgeons: " r(N)

    * Unique surgeons whose activity was exclusively emergency
    quietly count if year == `y' & tag_surgeon_year ///
        & allemergency == 1
    display "Unique surgeons with exclusively emergency activity: " r(N)
	
    * Unique surgeons with national total annual volume >=15
    quietly count if year == `y' & tag_surgeon_year ///
        & totalvolume >= 15
    display "Unique surgeons with total volume >=15: " r(N)

    * Unique surgeons with national elective annual volume >=9
    quietly count if year == `y' & tag_surgeon_year ///
        & electivevolume >= 9
    display "Unique surgeons with elective volume >=9: " r(N)

    * Revisions undertaken by surgeons with total annual volume >=15
    quietly count if year == `y' & totalvolume >= 15
    local highvolrevisions = r(N)

    if `allrevisions' > 0 {
        local prop_highvol = ///
            100 * `highvolrevisions' / `allrevisions'

        display "Revisions by surgeons with total volume >=15: " ///
            `highvolrevisions' " of " `allrevisions' ///
            " ("%4.1f `prop_highvol' "%)"
    }

    * Elective revisions undertaken by surgeons with elective annual volume >=9
    quietly count if year == `y' & elective == 1
    local allelectiverevisions = r(N)

    quietly count if year == `y' & elective == 1 ///
        & electivevolume >= 9
    local highvolelectiverevisions = r(N)

    if `allelectiverevisions' > 0 {
        local prop_highvolelective = ///
            100 * `highvolelectiverevisions' / `allelectiverevisions'

        display "Elective revisions by surgeons with elective volume >=9: " ///
            `highvolelectiverevisions' " of " `allelectiverevisions' ///
            " ("%4.1f `prop_highvolelective' "%)"
    }

    display " "
}

*--------------------------------------------------------------*
* Identify all non-missing network values
*--------------------------------------------------------------*

levelsof network if !missing(network), local(networks)

* Get the value-label name attached to network
local network_vallabel : value label network

*--------------------------------------------------------------*
* Report activity separately by network and year
*--------------------------------------------------------------*

foreach n of local networks {

    local network_name : label `network_vallabel' `n'

    display "=================================================="
    display "Network: `network_name'"

    foreach y in 2024 2025 {

        display "--------------------------------------------------"
        display "Year: `y'"

        * Total number of revision procedures for that year
        quietly count if network == `n' & year == `y'
        local allrevisions = r(N)
        display "Total number of revision procedures: " `allrevisions'

        * Total unique surgeons undertaking procedures in this network
        quietly count if network == `n' & year == `y' ///
            & tag_surgeon_network_year
        display "Total unique surgeons: " r(N)

        * Unique surgeons working in this network whose national
        * activity that year was exclusively emergency
        quietly count if network == `n' & year == `y' ///
            & tag_surgeon_network_year & allemergency == 1
        display "Unique surgeons with exclusively emergency activity: " r(N)
		
        * Unique surgeons working in this network whose national
        * annual total volume was >=15
        quietly count if network == `n' & year == `y' ///
            & tag_surgeon_network_year & totalvolume >= 15
        display "Unique surgeons with national total volume >=15: " r(N)

        * Unique surgeons working in this network whose national
        * annual elective volume was >=9
        quietly count if network == `n' & year == `y' ///
            & tag_surgeon_network_year & electivevolume >= 9
        display "Unique surgeons with national elective volume >=9: " r(N)

        * Proportion of all revisions in this network undertaken
        * by surgeons with national annual total volume >=15
        quietly count if network == `n' & year == `y' ///
            & totalvolume >= 15
        local highvolrevisions = r(N)

        if `allrevisions' > 0 {
            local prop_highvol = ///
                100 * `highvolrevisions' / `allrevisions'

            display "Revisions by surgeons with national total volume >=15: " ///
                `highvolrevisions' " of " `allrevisions' ///
                " (" %4.1f `prop_highvol' "%)"
        }

        * Proportion of elective revisions in this network undertaken
        * by surgeons with national elective volume >=9
        quietly count if network == `n' & year == `y' & elective == 1
        local allelectiverevisions = r(N)

        quietly count if network == `n' & year == `y' ///
            & elective == 1 & electivevolume >= 9
        local highvolelectiverevisions = r(N)

        if `allelectiverevisions' > 0 {
            local prop_highvolelective = ///
                100 * `highvolelectiverevisions' / `allelectiverevisions'

            display "Elective revisions by surgeons with national elective volume >=9: " ///
                `highvolelectiverevisions' " of " `allelectiverevisions' ///
                " (" %4.1f `prop_highvolelective' "%)"
        }

        display " "
    }
}

log close