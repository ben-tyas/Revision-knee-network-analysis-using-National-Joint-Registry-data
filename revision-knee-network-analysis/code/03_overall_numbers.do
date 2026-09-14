/********************************************************************
Revision Knee Network analysis
File: 03_overall_numbers.do
Purpose: Export annual procedure counts by network, trust, and hospital.

Run from 00_master.do. This script expects project path globals to
have been defined by the master file.
********************************************************************/

version 19.0
set more off

clear
capture log close

use "$data_derived/cleandataset.dta", clear

levelsof network, local(networks)
table (network trust hospital) (year), ///
    statistic(frequency)

collect layout (network[`networks']#trust#hospital) (year) (result), name(Table)

collect preview
	
collect export "$tables/overallnumbers.xlsx", replace