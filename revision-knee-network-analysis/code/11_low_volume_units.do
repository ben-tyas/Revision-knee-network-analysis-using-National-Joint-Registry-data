/********************************************************************
Revision Knee Network analysis
File: 11_low_volume_units.do
Purpose: Identify trusts and hospitals with <20 revisions in each of 2023–2025.

Run from 00_master.do. This script expects project path globals to
have been defined by the master file.
********************************************************************/

version 19.0
set more off

clear
capture log close

use "$data_derived/cleandataset.dta", clear
log using "$logs/alertsites.txt", replace


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
* 2. TRUSTS WITH <20 REVISIONS IN EACH OF
*    2023, 2024 AND 2025
*******************************************************

preserve

keep if inlist(year, 2023, 2024, 2025)

contract network trust year, freq(n)

* Reshape so each trust has one row
reshape wide n, i(network trust) j(year)

* Replace missing years with zero revisions
foreach y in 2023 2024 2025 {
    replace n`y' = 0 if missing(n`y')
}

* Define low volume
gen lowvolume = ///
    n2023 < 20 & ///
    n2024 < 20 & ///
    n2025 < 20

* Count low-volume trusts
count if lowvolume
local n_lowvolume_trusts = r(N)

* Keep qualifying trusts only
keep if lowvolume

keep network trust n2023 n2024 n2025

export excel using "$tables/low_volume_units.xlsx", ///
    sheet("Trusts") firstrow(variables) replace

restore


*******************************************************
* 3. HOSPITALS WITH <20 REVISIONS IN EACH OF
*    2023, 2024 AND 2025
*******************************************************

preserve

drop if missing(hospital)

keep if inlist(year, 2023, 2024, 2025)

contract network trust hospital year, freq(n)

* Reshape so each hospital has one row
reshape wide n, i(network trust hospital) j(year)

* Replace missing years with zero revisions
foreach y in 2023 2024 2025 {
    replace n`y' = 0 if missing(n`y')
}

* Define low volume
gen lowvolume = ///
    n2023 < 20 & ///
    n2024 < 20 & ///
    n2025 < 20

* Count low-volume hospitals
count if lowvolume
local n_lowvolume_hospitals = r(N)

* Keep qualifying hospitals only
keep if lowvolume

keep network trust hospital n2023 n2024 n2025

export excel using "$tables/low_volume_units.xlsx", ///
    sheet("Hospitals") firstrow(variables) sheetreplace

restore


*******************************************************
* 4. SUMMARY SHEET
*******************************************************

putexcel set "$tables/low_volume_units.xlsx", ///
    sheet("Summary") modify

putexcel A1 = "Measure" B1 = "Number"

putexcel A2 = "Total number of trusts" ///
         B2 = `ntrusts'

putexcel A3 = "Trusts with <20 revisions in 2023, 2024 and 2025" ///
         B3 = `n_lowvolume_trusts'

putexcel A4 = "Total number of hospitals" ///
         B4 = `nhospitals'

putexcel A5 = "Hospitals with <20 revisions in 2023, 2024 and 2025" ///
         B5 = `n_lowvolume_hospitals'
		 
log close