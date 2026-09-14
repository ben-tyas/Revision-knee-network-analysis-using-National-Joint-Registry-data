clear all
capture log close

cd "C:\Users\btyas\OneDrive\Documents\Revision network analysis"
use "cleandataset.dta", clear
log using "alertsites.txt", replace



*******************************************************
* 1. TOTAL NUMBER OF TRUSTS AND HOSPITALS
*******************************************************

egen tag_trust = tag(network trust)
count if tag_trust
local ntrusts = r(N)

egen tag_hospital = tag(network trust hospital)
count if tag_hospital
local nhospitals = r(N)

drop tag_trust tag_hospital


*******************************************************
* 2. TRUSTS WITH <20 OBSERVATIONS PER YEAR
*    FOR AT LEAST 3 CONSECUTIVE YEARS
*******************************************************

preserve

contract network trust year, freq(n)

sort network trust year

gen lowvolume = n < 20

* Identify third year of a run of at least 3 consecutive low-volume years
by network trust (year): gen three_consecutive = ///
    lowvolume == 1 & ///
    lowvolume[_n-1] == 1 & ///
    lowvolume[_n-2] == 1 & ///
    year == year[_n-1] + 1 & ///
    year[_n-1] == year[_n-2] + 1

* Count UNIQUE trusts meeting the definition
egen tag_lowvolume_trust = tag(network trust) if three_consecutive
count if tag_lowvolume_trust
local n_lowvolume_trusts = r(N)

* Create variables describing qualifying 3-year period
by network trust (year): gen year1 = year[_n-2] if three_consecutive
by network trust (year): gen year2 = year[_n-1] if three_consecutive
by network trust (year): gen year3 = year       if three_consecutive

by network trust (year): gen n_year1 = n[_n-2] if three_consecutive
by network trust (year): gen n_year2 = n[_n-1] if three_consecutive
by network trust (year): gen n_year3 = n        if three_consecutive

keep if three_consecutive

keep network trust year1 year2 year3 ///
    n_year1 n_year2 n_year3

export excel using "low_volume_units.xlsx", ///
    sheet("Trusts") firstrow(variables) replace

restore


*******************************************************
* 3. HOSPITALS WITH <20 OBSERVATIONS PER YEAR
*    FOR AT LEAST 3 CONSECUTIVE YEARS
*******************************************************

preserve

drop if missing(hospital)

contract network trust hospital year, freq(n)

sort network trust hospital year

gen lowvolume = n < 20

* Identify third year of a run of at least 3 consecutive low-volume years
by network trust hospital (year): gen three_consecutive = ///
    lowvolume == 1 & ///
    lowvolume[_n-1] == 1 & ///
    lowvolume[_n-2] == 1 & ///
    year == year[_n-1] + 1 & ///
    year[_n-1] == year[_n-2] + 1

* Count UNIQUE hospitals meeting the definition
egen tag_lowvolume_hospital = ///
    tag(network trust hospital) if three_consecutive

count if tag_lowvolume_hospital
local n_lowvolume_hospitals = r(N)

* Create variables describing qualifying 3-year period
by network trust hospital (year): gen year1 = year[_n-2] if three_consecutive
by network trust hospital (year): gen year2 = year[_n-1] if three_consecutive
by network trust hospital (year): gen year3 = year       if three_consecutive

by network trust hospital (year): gen n_year1 = n[_n-2] if three_consecutive
by network trust hospital (year): gen n_year2 = n[_n-1] if three_consecutive
by network trust hospital (year): gen n_year3 = n        if three_consecutive

keep if three_consecutive

keep network trust hospital year1 year2 year3 ///
    n_year1 n_year2 n_year3

export excel using "low_volume_units.xlsx", ///
    sheet("Hospitals") firstrow(variables) sheetreplace

restore


*******************************************************
* 4. SUMMARY SHEET
*******************************************************

putexcel set "low_volume_units.xlsx", ///
    sheet("Summary") modify

putexcel A1 = "Measure" B1 = "Number"

putexcel A2 = "Total number of trusts" ///
         B2 = `ntrusts'

putexcel A3 = "Low-volume trusts" ///
         B3 = `n_lowvolume_trusts'

putexcel A4 = "Total number of hospitals" ///
         B4 = `nhospitals'

putexcel A5 = "Low-volume hospitals" ///
         B5 = `n_lowvolume_hospitals'
		 
log close