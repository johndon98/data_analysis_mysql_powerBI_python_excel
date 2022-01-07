*This file contains code(data prep and tables) for the seminar paper titled 'Colonial rule, Social Capital and Households in Kerala' 

macro drop _all
capture log close
clear all

set more off
set linesize 255

*Read in data and cleaning

use "HH Kerala 2012.dta",clear
move TR2 TR1
tab TR2, gen(problem_solve)
move problem_solve1 TR2
move problem_solve2 TR2
move SN2B1 SN2A2
move SN2C1 SN2A2
move SN2D1 SN2A2
move SN2E1 SN2A2
move SN2F1 SN2A2
move SN2G1 SN2A2
move SN2H1 SN2A2
move SN2I1 SN2A2
move SN2J1 SN2A2
move SN2K1 SN2A2

*Create new variables for acquaintances and memberships (independent variables in subsequent regression) 

egen acq = rowtotal( SN2A1 SN2B1 SN2C1 SN2D1 SN2E1 SN2F1 SN2G1 SN2H1 SN2I1 SN2J1 SN2K1)
egen member = rowtotal( ME1 ME2 ME3 ME4 ME5 ME6 ME7 ME8 ME9 ME10 ME11 ME12 ME14)

*this variable (acquaintances outside local network) was not included in analysis
egen acq_out = rowtotal( SN2A2 SN2B2 SN2C2 SN2D2 SN2E2 SN2F2 SN2G2 SN2H2 SN2I2 SN2J2 SN2K2 )    

*Create dummy variable for indicating whether state was previously under direct or indirect british rule

gen british = 0
move british HS3D
replace british = 1 if DISTRICT==3202
replace british = 1 if DISTRICT==3204
replace british = 1 if DISTRICT==3205
replace british = 1 if DISTRICT==3206

rename member membership
rename acq acquaintance

replace TR2 = 0 if TR2==2

*setting up survey data for analysis, includes probability weights and strata 

svyset IDPSU [pw = WT], strata(DISTRICT)
svydescribe

drop in 571 if ID11==6
drop in 970 if ID11==8

*logit regression

svy: logit TR2 member acq british HHEDUC i.ID11 i.ID13 i.CI11
margins, dydx(member)
margins, dydx(acq)
margins british, at(acq==(0(1)11)) vce(uncond)
marginsplot, legend(rows(1))

*summary (refer summary table in paper)

sum member acq british TR2 DB1A DB9C NPERSONS HHEDUC ID11 sc logincomepc CI11 URBAN2011

*baseline regression (no controls)

svy: probit TR2 member acq i.british
margins, dydx(*) post

*baseline regression without (ST caste group)

svy,subpop(caste): probit TR2 membership acquaintance i.british
margins, dydx(*) post

*regression including all controls

svy: probit TR2 member acq i.british HHEDUC i.ID11 NPERSONS logincomepc i.sc i.CI3 i.CI11
margins, dydx(*) post

*without the control variables court police

svy: probit TR2 member acq i.british HHEDUC i.ID11 NPERSONS logincomepc i.sc
margins, dydx(*) post


*esttab, se eqlabels(none) mlabels(none) nobaselevels nolabel varlabels(1.british british)

*table command
esttab m1 m2 m3, se eqlabels(none) mlabels(none) nobaselevels nolabel varlabels(1.british british 1.sc sc 2.ID11 muslim HHEDUC education) drop(3.ID11 NPERSONS logincomepc 1.URBAN2011 2.CI11 3.CI11) star(* .10 ** .05 *** .01)

