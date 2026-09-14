/********************************************************************
Revision Knee Network analysis
File: 01_clean_data.do
Purpose: Clean raw NJR extract and derive reporting variables.

Run from 00_master.do. This script expects project path globals to
have been defined by the master file.
********************************************************************/

version 19.0
set more off

clear
capture log close
use "$data_raw/Raw data.dta", clear

//Check for invalid/duplicate entries and date range
duplicates report ProcedureID
count if missing(OperationDate)
summarize OperationDate, meanonly
display "Earliest date: " %td r(min)
display "Latest date:   " %td r(max)

//Generate new vars
gen all=1

*Hospitals within trusts within networks
encode HospitalName, gen(hospital)

label list hospital

*Trusts
gen trust=.
do "$code/helpers/trust_labels.do"
label values trust trust

replace trust=1 if inlist(hospital, 2)
replace trust=2 if inlist(hospital, 5, 172)
replace trust=3 if inlist(hospital, 78, 130)
replace trust=4 if inlist(hospital, 7)
replace trust=5 if inlist(hospital, 55, 192, 216)
replace trust=6 if inlist(hospital, 11, 88)
replace trust=7 if inlist(hospital, 13)
replace trust=8 if inlist(hospital, 139)
replace trust=9 if inlist(hospital, 14)
replace trust=10 if inlist(hospital, 176, 222)
replace trust=11 if inlist(hospital, 21, 72)
replace trust=12 if inlist(hospital, 1, 183)
replace trust=13 if inlist(hospital, 28, 211)
replace trust=14 if inlist(hospital, 30)
replace trust=15 if inlist(hospital, 35)
replace trust=16 if inlist(hospital, 12, 40, 204)
replace trust=17 if inlist(hospital, 37)
replace trust=18 if inlist(hospital, 39, 129)
replace trust=19 if inlist(hospital, 10, 44, 96)
replace trust=20 if inlist(hospital, 89)
replace trust=21 if inlist(hospital, 76, 128, 218)
replace trust=22 if inlist(hospital, 20, 138)
replace trust=23 if inlist(hospital, 33, 48, 74)
replace trust=24 if inlist(hospital, 34, 47, 181)
replace trust=25 if inlist(hospital, 87)
replace trust=26 if inlist(hospital, 184)
replace trust=27 if inlist(hospital, 53, 66, 215)
replace trust=28 if inlist(hospital, 125, 187)
replace trust=29 if inlist(hospital, 56)
replace trust=30 if inlist(hospital, 29, 57)
replace trust=31 if inlist(hospital, 185)
replace trust=32 if inlist(hospital, 61, 174)
replace trust=33 if inlist(hospital, 9, 63, 145)
replace trust=34 if inlist(hospital, 64)
replace trust=35 if inlist(hospital, 70)
replace trust=36 if inlist(hospital, 23, 73)
replace trust=37 if inlist(hospital, 26, 169)
*Trust 38 is Isle of Man secondary healthcare (Nobles)- no cases from this hospital in dataset
replace trust=39 if inlist(hospital, 170)
replace trust=40 if inlist(hospital, 75)
replace trust=41 if inlist(hospital, 77)
replace trust=42 if inlist(hospital, 79, 115, 123)
replace trust=43 if inlist(hospital, 81)
replace trust=44 if inlist(hospital, 31, 149)
replace trust=45 if inlist(hospital, 25, 82)
replace trust=46 if inlist(hospital, 127, 133, 202)
replace trust=47 if inlist(hospital, 18, 191, 201)
replace trust=48 if inlist(hospital, 24, 110)
replace trust=49 if inlist(hospital, 50, 90, 195)
replace trust=50 if inlist(hospital, 91, 104, 198, 223)
replace trust=51 if inlist(hospital, 93)
replace trust=52 if inlist(hospital, 166, 217, 114)
replace trust=53 if inlist(hospital, 85)
replace trust=54 if inlist(hospital, 42, 118, 119)
replace trust=55 if inlist(hospital, 8, 15, 19, 164)
replace trust=56 if inlist(hospital, 95)
replace trust=57 if inlist(hospital, 102)
replace trust=58 if inlist(hospital, 165)
replace trust=59 if inlist(hospital, 38, 210)
replace trust=60 if inlist(hospital, 203, 205)
replace trust=61 if inlist(hospital, 69, 116)
replace trust=62 if inlist(hospital, 107)
replace trust=63 if inlist(hospital, 49, 147, 156)
replace trust=64 if inlist(hospital, 43, 59, 160)
replace trust=65 if inlist(hospital, 106, 109, 206)
replace trust=66 if inlist(hospital, 111, 112, 132)
replace trust=67 if inlist(hospital, 113)
replace trust=68 if inlist(hospital, 124)
replace trust=69 if inlist(hospital, 134)
replace trust=70 if inlist(hospital, 137)
replace trust=71 if inlist(hospital, 141, 171)
replace trust=72 if inlist(hospital, 99, 103, 143)
replace trust=73 if inlist(hospital, 152)
replace trust=74 if inlist(hospital, 154, 177, 178)
replace trust=75 if inlist(hospital, 157)
replace trust=76 if inlist(hospital, 108, 144)
replace trust=77 if inlist(hospital, 80, 101)
replace trust=78 if inlist(hospital, 150, 188)
replace trust=79 if inlist(hospital, 98, 224)
replace trust=80 if inlist(hospital, 52, 186)
replace trust=81 if inlist(hospital, 162, 179)
replace trust=82 if inlist(hospital, 208)
replace trust=83 if inlist(hospital, 168)
replace trust=84 if inlist(hospital, 175)
replace trust=85 if inlist(hospital, 46)
replace trust=86 if inlist(hospital, 182)
replace trust=87 if inlist(hospital, 155)
replace trust=88 if inlist(hospital, 68, 97)
replace trust=89 if inlist(hospital, 51, 194)
replace trust=90 if inlist(hospital, 121)
replace trust=91 if inlist(hospital, 189)
replace trust=92 if inlist(hospital, 135)
replace trust=93 if inlist(hospital, 6, 27, 105, 190)
replace trust=94 if inlist(hospital, 193)
replace trust=95 if inlist(hospital, 148)
replace trust=96 if inlist(hospital, 100, 22)
replace trust=97 if inlist(hospital, 196)
replace trust=98 if inlist(hospital, 197)
replace trust=99 if inlist(hospital, 60, 86, 117)
replace trust=100 if inlist(hospital, 199)
replace trust=101 if inlist(hospital, 163)
replace trust=102 if inlist(hospital, 58, 65, 94, 126, 158, 161)
replace trust=103 if inlist(hospital, 17, 214)
replace trust=104 if inlist(hospital, 71, 200)
replace trust=105 if inlist(hospital, 45, 140, 120)
replace trust=106 if inlist(hospital, 41)
replace trust=107 if inlist(hospital, 122, 153, 173, 180, 220)
replace trust=108 if inlist(hospital, 131, 142)
replace trust=109 if inlist(hospital, 83, 84)
replace trust=110 if inlist(hospital, 54, 146, 213)
replace trust=111 if inlist(hospital, 36, 151)
replace trust=112 if inlist(hospital, 92)
replace trust=113 if inlist(hospital, 62, 207)
replace trust=114 if inlist(hospital, 209, 167)
replace trust=115 if inlist(hospital, 212)
replace trust=116 if inlist(hospital, 4, 32)
replace trust=117 if inlist(hospital, 3, 219)
replace trust=118 if inlist(hospital, 136, 221)
replace trust=119 if inlist(hospital, 67)
replace trust=120 if inlist(hospital, 16, 159, 225)

*Networks
label define network 1 "NE South Tees" 2 "Leeds" 3 "Sheffield" 4 "NE Newcastle" 5 "Exeter" 6 "Bristol" 7 "Oxford" 8 "Portsmouth" 9 "Norfolk & Norwich" 10 "Colchester" 11 "Nottingham" 12 "Leicester" 13 "Coventry" 14 "Derby" 15 "Birmingham" 16 "Oswestry" 17 "NW Wrightington" 18 "NW Liverpool" 19 "Kent" 20 "SWLEOC" 21 "London Guys & St Thomas" 22 "London Imperial" 23 "London Stanmore" 24 "London Barts"
gen network=.
label values network network

replace network=1 if inlist(trust, 16, 34, 60, 80, 81, 120)
replace network=2 if inlist(trust, 1, 9, 11, 36, 45, 54)
replace network=3 if inlist(trust, 4, 14, 19, 64, 76, 92)
replace network=4 if inlist(trust, 28, 59, 65, 89)
replace network=5 if inlist(trust, 79, 98, 71, 72, 106)
replace network=6 if inlist(trust, 103, 58, 74, 30)
replace network=7 if inlist(trust, 10, 27, 31, 67, 70, 56)
replace network=8 if inlist(trust, 39, 101, 75, 33, 105, 68)
replace network=9 if inlist(trust, 57, 91, 61, 40, 12)
replace network=10 if inlist(trust, 115, 55, 90, 23)
replace network=11 if inlist(trust, 66, 77, 99)
replace network=12 if inlist(trust, 41, 62, 109)
replace network=13 if inlist(trust, 29, 82, 104, 117)
replace network=14 if inlist(trust, 108)
replace network=15 if inlist(trust, 87, 95, 96, 102, 112)
replace network=16 if inlist(trust, 69, 78, 111, 119)
replace network=17 if inlist(trust, 50, 118, 110, 86, 84, 7, 63, 44, 8, 22, 20)
replace network=18 if inlist(trust, 52, 113, 47, 38, 53, 15, 116, 52)
replace network=19 if inlist(trust, 107, 21, 49, 24, 51)
replace network=20 if inlist(trust, 26, 2, 73, 43, 83, 85, 17)
replace network=21 if inlist(trust, 18, 46, 42, 32)
replace network=22 if inlist(trust, 13, 37, 48, 88)
replace network=23 if inlist(trust, 114, 100, 97, 94, 93, 25, 6)
replace network=24 if inlist(trust, 3, 5, 35)

*MRCs
label define centretype 0 "Revision unit/Primary arthroplasty centre" 1 "Major revision centre"
generate mrc=0
label values mrc centretype
replace mrc=1 if inlist(trust, 80, 45, 76, 65, 89, 72, 58, 67, 68, 57, 23, 109, 66, 104, 108, 95, 69, 21, 47, 118, 26, 32, 37, 94, 5)

*Calendar year
gen year=year(OperationDate)
format year %ty

*Procedure types
encode ProcedureTypeDetails if inlist(year, 2024, 2025), gen(proctype)

*Indications
gen indication=.
label define indication 1 "Infection" 2 "Malalignment" 3 "Aseptic loosening" 4 "Wear and implant breakage" 5 "Instability" 6 "Fracture" 7 "Progressive arthritis" 8 "Stiffness" 9 "Unexplained pain" 10 "Other" 11 "Not recorded"
label values indication indication

replace indication=10 if regexm(RevIndicationSmmary, "(?i)(discrepancy|other)") 
replace indication=9 if regexm(RevIndicationSmmary, "(?i)pain")
replace indication=8 if regexm(RevIndicationSmmary, "(?i)stiffness")
replace indication=7 if regexm(RevIndicationSmmary, "(?i)(progressive|chondral)")
replace indication=6 if regexm(RevIndicationSmmary, "(?i)periprosthetic")
replace indication=5 if regexm(RevIndicationSmmary, "(?i)(instability|subluxation)")
replace indication=4 if regexm(RevIndicationSmmary, "(?i)(polyethylene|dissociation|implant)")
replace indication=3 if regexm(RevIndicationSmmary, "(?i)(loosening|lysis)")
replace indication=2 if regexm(RevIndicationSmmary, "(?i)(malalignment)")
replace indication=1 if regexm(RevIndicationSmmary, "(?i)(infection)")
replace indication=11 if indication==.

*Pre-specified subgroups
gen dair=.
replace dair=1 if inlist(year, 2024, 2025) & regexm(PatientProcedureName, "Debridement")

gen fracture=.
replace fracture=1 if inlist(year, 2024, 2025) & indication==6

gen emergency=.
replace emergency=1 if inlist(year, 2024, 2025) & ((indication==1 & dair==1)|indication==6)

gen elective=. 
replace elective=1 if emergency!=1 & inlist(year, 2024, 2025)

gen asepticelective=.
replace asepticelective=1 if inlist(year, 2024, 2025) & elective==1 & indication!=1 & indication!=6

gen septicelective=.
replace septicelective=1 if inlist(year, 2024, 2025) & elective==1 & indication==1

*RKCC grade
gen rkcc=.
label define rkcc 1 "RKCC 1" 2 "RKCC 2" 3 "RKCC 3" 4 "Not recorded"
label values rkcc rkcc

replace rkcc=1 if ComplexityRevisionLevel=="R1" & inlist(year, 2024, 2025)
replace rkcc=2 if ComplexityRevisionLevel=="R2" & inlist(year, 2024, 2025)
replace rkcc=3 if ComplexityRevisionLevel=="R3" & inlist(year, 2024, 2025)
replace rkcc=4 if ComplexityRevisionLevel=="NULL" & inlist(year, 2024, 2025)

//PIES complexity factors
*Patient factors
gen ptcomorbid=.
label define ptcomorbid 1 "A- Uncompromised" 2 "B- Compromised" 3 "C- Substantially compromised" 4 "Not recorded"
label values ptcomorbid ptcomorbid

replace ptcomorbid=1 if Patientcomormiities=="A" & inlist(year, 2024, 2025)
replace ptcomorbid=2 if Patientcomormiities=="B" & inlist(year, 2024, 2025)
replace ptcomorbid=3 if Patientcomormiities=="C" & inlist(year, 2024, 2025)
replace ptcomorbid=4 if Patientcomormiities=="NULL" & inlist(year, 2024, 2025)

*Infection
label define yesno 0 "No" 1 "Yes" 2 "Not recorded"
gen infection=.
label values infection yesno
replace infection=1 if Infection=="Yes" & inlist(year, 2024, 2025)
replace infection=0 if Infection=="No" & inlist(year, 2024, 2025)
replace infection=2 if inlist(year, 2024, 2025) & Infection=="NULL"

*Extensor mechanism
gen extensor=.
label values extensor yesno
replace extensor=0 if ExtensorMechanismCompromise=="No" & inlist(year, 2024, 2025)
replace extensor=1 if ExtensorMechanismCompromise=="Yes" & inlist(year, 2024, 2025)
replace extensor=2 if ExtensorMechanismCompromise=="NULL" & inlist(year, 2024, 2025)

*Soft tissue
gen softtissue=.
label values softtissue yesno
replace softtissue=0 if SoftTissueCompromiseId=="No" & inlist(year, 2024, 2025)
replace softtissue=1 if SoftTissueCompromiseId=="Yes" & inlist(year, 2024, 2025)
replace softtissue=2 if SoftTissueCompromiseId=="NULL" & inlist(year, 2024, 2025)

//MDT discussion
gen localmdt=.
label values localmdt yesno
replace localmdt=0 if LocalMDT=="No" & inlist(year, 2024, 2025)
replace localmdt=1 if LocalMDT=="Yes" & inlist(year, 2024, 2025)
replace localmdt=2 if LocalMDT!="Yes"&LocalMDT!="No"&inlist(year, 2024, 2025)

gen regionalmdt=.
label values regionalmdt yesno

replace regionalmdt=1 if (RegionalMDT=="Yes"|InfectionMDT=="Yes") & inlist(year, 2024, 2025)
replace regionalmdt=0 if RegionalMDT=="No"&InfectionMDT=="No" & inlist(year, 2024, 2025)
replace regionalmdt=2 if regionalmdt==. & inlist(year, 2024, 2025)
tab1 regionalmdt

label variable all "Total cases"
label variable hospital "Hospital"
label variable trust "Trust" 
label variable network "Network"
label variable mrc "National figures"
label variable year "Calendar year"
label variable proctype "Procedure type"
label variable indication "Indication for revision"
label variable rkcc "Revision knee complexity classification" 
label variable ptcomorbid "Patient comorbidities"
label variable infection "Infection"
label variable extensor "Extensor mechanism compromise"
label variable softtissue "Soft tissue compromise"
label variable localmdt "Discussed in local MDT"
label variable regionalmdt "Discussed in regional/infection MDT"

*drop 2026 cases
drop if year==2026

//Sort networks alphabetically
decode network, gen(network_name)
encode network_name, gen(temp)
drop network network_name
rename temp network

save "$data_derived/cleandataset.dta", replace