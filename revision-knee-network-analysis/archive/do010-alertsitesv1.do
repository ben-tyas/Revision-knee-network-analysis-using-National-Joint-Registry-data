clear all
capture log close

cd "C:\Users\btyas\OneDrive\Documents\Revision network analysis"
use "cleandataset.dta", clear

log using "alertsites.txt", replace

*******************************************************
* 1. TOTAL NUMBER OF TRUSTS AND HOSPITALS
*******************************************************

* Unique trusts
egen tag_trust = tag(network trust)
count if tag_trust
display "Total number of trusts = " r(N)

* Unique hospitals
egen tag_hospital = tag(network trust hospital)
count if tag_hospital
display "Total number of hospitals = " r(N)

drop tag_trust tag_hospital


*******************************************************
* 2. TRUSTS WITH <=20 OBSERVATIONS PER YEAR
*    FOR AT LEAST 3 CONSECUTIVE YEARS
*******************************************************

preserve

* Count observations within each trust-year
contract network trust year, freq(n)

sort network trust year

* Identify years with <=20 observations
gen lowvolume = n <= 20

* Identify the third year of any run of 3 consecutive low-volume years
by network trust (year): gen three_consecutive = ///
    lowvolume == 1 & ///
    lowvolume[_n-1] == 1 & ///
    lowvolume[_n-2] == 1 & ///
    year == year[_n-1] + 1 & ///
    year[_n-1] == year[_n-2] + 1

* Store the three years and annual counts
by network trust (year): gen year1 = year[_n-2] if three_consecutive
by network trust (year): gen year2 = year[_n-1] if three_consecutive
by network trust (year): gen year3 = year       if three_consecutive

by network trust (year): gen n_year1 = n[_n-2] if three_consecutive
by network trust (year): gen n_year2 = n[_n-1] if three_consecutive
by network trust (year): gen n_year3 = n        if three_consecutive

list network trust year1 year2 year3 ///
    n_year1 n_year2 n_year3 ///
    if three_consecutive, noobs sepby(network trust)

restore


*******************************************************
* 3. HOSPITALS WITH <=20 OBSERVATIONS PER YEAR
*    FOR AT LEAST 3 CONSECUTIVE YEARS
*******************************************************

preserve

* Exclude missing hospital identifiers if required
drop if missing(hospital)

* Count observations within each hospital-year
contract network trust hospital year, freq(n)

sort network trust hospital year

* Identify years with <=20 observations
gen lowvolume = n <= 20

* Identify the third year of any run of 3 consecutive low-volume years
by network trust hospital (year): gen three_consecutive = ///
    lowvolume == 1 & ///
    lowvolume[_n-1] == 1 & ///
    lowvolume[_n-2] == 1 & ///
    year == year[_n-1] + 1 & ///
    year[_n-1] == year[_n-2] + 1

* Store the three years and annual counts
by network trust hospital (year): gen year1 = year[_n-2] if three_consecutive
by network trust hospital (year): gen year2 = year[_n-1] if three_consecutive
by network trust hospital (year): gen year3 = year       if three_consecutive

by network trust hospital (year): gen n_year1 = n[_n-2] if three_consecutive
by network trust hospital (year): gen n_year2 = n[_n-1] if three_consecutive
by network trust hospital (year): gen n_year3 = n        if three_consecutive

list network trust hospital year1 year2 year3 ///
    n_year1 n_year2 n_year3 ///
    if three_consecutive, noobs sepby(network trust hospital)

restore

log close