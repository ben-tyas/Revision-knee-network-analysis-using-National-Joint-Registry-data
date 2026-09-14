clear all
capture log close
cd "C:\Users\btyas\OneDrive\Documents\Revision network analysis"
use "cleandataset.dta"

log using "surgeonvolumes.txt", replace text

//Surgeon volume
* Total number of procedures per surgeon within each year
bysort LeadSurgeonID year: egen totalvolume = count(LeadSurgeonID)

* Number of elective procedures per surgeon within each year
bysort LeadSurgeonID year: egen electivevolume = total(elective == 1)

* Number of emergency procedures per surgeon within each year
bysort LeadSurgeonID year: egen emergencyvolume = total(emergency == 1)

* Flag surgeon-years in which every procedure was emergency.
generate allemergency = totalvolume == emergencyvolume & totalvolume > 0

* Tag each surgeon once within each calendar year
egen tag_surgeon_year = tag(LeadSurgeonID year)


//Display counts and proportions for each year nationally

foreach y in 2024 2025 {

    display "--------------------------------------------------"
    display "Year: `y'"

    * Total number of unique surgeons
    quietly count if year == `y' & tag_surgeon_year
    display "Total unique surgeons: " r(N)

    * Unique surgeons with total annual volume >=15
    quietly count if year == `y' & tag_surgeon_year & totalvolume >= 15
    display "Unique surgeons with total volume >=15: " r(N)

    * Unique surgeons with elective annual volume >=9
    quietly count if year == `y' & tag_surgeon_year & electivevolume >= 9
    display "Unique surgeons with elective volume >=9: " r(N)

    * Unique surgeons whose procedures were all emergencies
    quietly count if year == `y' & tag_surgeon_year & allemergency == 1
    display "Unique surgeons with exclusively emergency procedures: " r(N)

*Proportion of all revisions undertaken by surgeons with total annual volume >=15
    quietly count if year == `y'
    local allrevisions = r(N)

    quietly count if year == `y' & totalvolume >= 15
    local highvolrevisions = r(N)

    local prop_highvol = 100 * `highvolrevisions' / `allrevisions'

    display "Revisions undertaken by surgeons with total volume >=15: " ///
        `highvolrevisions' " of " `allrevisions' ///
        " (" %5.1f `prop_highvol' "%)"

*Proportion of elective revisions undertaken by surgeons with elective annual volume >=9
    quietly count if year == `y' & elective == 1
    local allelectiverevisions = r(N)

    quietly count if year == `y' & elective == 1 & electivevolume >= 9
    local highvolelectiverevisions = r(N)

    local prop_highvolelective = ///
        100 * `highvolelectiverevisions' / `allelectiverevisions'

    display "Elective revisions undertaken by surgeons with elective volume >=9: " ///
        `highvolelectiverevisions' " of " `allelectiverevisions' ///
        " (" %5.1f `prop_highvolelective' "%)"

    display " "
}


//Display counts and proportions for each year for each network
levelsof network,local(networks)

foreach n of local networks {
	display "===================================================="
	display "Network: `n'"

foreach y in 2024 2025 {

    display "--------------------------------------------------"
    display "Year: `y'"

    * Total number of unique surgeons
    quietly count if year == `y' & tag_surgeon_year
    display "Total unique surgeons: " r(N)

    * Unique surgeons with total annual volume >=15
    quietly count if year == `y' & tag_surgeon_year & totalvolume >= 15
    display "Unique surgeons with total volume >=15: " r(N)

    * Unique surgeons with elective annual volume >=9
    quietly count if year == `y' & tag_surgeon_year & electivevolume >= 9
    display "Unique surgeons with elective volume >=9: " r(N)

    * Unique surgeons whose procedures were all emergencies
    quietly count if year == `y' & tag_surgeon_year & allemergency == 1
    display "Unique surgeons with exclusively emergency procedures: " r(N)

*Proportion of all revisions undertaken by surgeons with total annual volume >=15
    quietly count if year == `y'
    local allrevisions = r(N)

    quietly count if year == `y' & totalvolume >= 15
    local highvolrevisions = r(N)

    local prop_highvol = 100 * `highvolrevisions' / `allrevisions'

    display "Revisions undertaken by surgeons with total volume >=15: " ///
        `highvolrevisions' " of " `allrevisions' ///
        " (" %5.1f `prop_highvol' "%)"

*Proportion of elective revisions undertaken by surgeons with elective annual volume >=9
    quietly count if year == `y' & elective == 1
    local allelectiverevisions = r(N)

    quietly count if year == `y' & elective == 1 & electivevolume >= 9
    local highvolelectiverevisions = r(N)

    local prop_highvolelective = ///
        100 * `highvolelectiverevisions' / `allelectiverevisions'

    display "Elective revisions undertaken by surgeons with elective volume >=9: " ///
        `highvolelectiverevisions' " of " `allelectiverevisions' ///
        " (" %5.1f `prop_highvolelective' "%)"

    display " "
}
}

log close



