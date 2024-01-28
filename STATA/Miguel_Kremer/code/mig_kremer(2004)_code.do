*Replication - Miguel and Kremer(2004)

clear all

*set working directory
cd "C:\Users\johnd\OneDrive\Desktop\sose21\Dev\miguel_kremer(2004)"

log using ".\code\migkrem_2004_rep.log", replace
set more off 

*load data
use ".\data\namelist.dta", clear

keep if visit== 981
drop if dupid==2

merge 1:1 pupid using ".\data\pupq.dta"

*e)
gen days_present = (20 - absdays_98_6)/20
gen sick_often = fallsick_98_37==3
replace sick_often =. if fallsick_98_37==.
gen child_clean = clean_98_15==1
replace child_clean =. if clean_98_15==.

*f) Table1
preserve
collapse (mean)sex elg98 stdgap yrbirth days_present bloodst_98_58 sick_often malaria_98_48 child_clean wgrp* (count)count=pupid, by (schid)

*Panel A
bysort wgrp:summarize sex elg98 stdgap yrbirth [aw=count]

*checking difference between groups, basecategory here is wgrp3
local replace replace
foreach i in sex elg98 stdgap yrbirth {
	quietly:reg `i' ib3.wgrp [aw=count]
	outreg2 using ".\output\table1_panelA.xlsx", dec(2) `replace'
	local replace
}

restore

*Panel B
preserve
drop if pupdate_98_1=="" &  schid_98_2==.  /*keeping only 1998 pupils*/

collapse (mean)sex elg98 stdgap yrbirth days_present bloodst_98_58 sick_often malaria_98_48 child_clean wgrp* (count)count=pupid, by (schid)

bysort wgrp:summarize days_present bloodst_98_58 sick_often malaria_98_48 child_clean [aw=count] if std>=3|std<=8

*checking difference between groups, basecategory here is wgrp3
local replace replace
foreach i in days_present bloodst_98_58 sick_often malaria_98_48 child_clean {
	quietly:reg `i' ib3.wgrp [aw=count] if std>=3|std<=8
	outreg2 using ".\output\table1_panelB.xlsx", dec(2) `replace'
	local replace
}
restore

*g)Panel C
use ".\data\schoolvar.dta", clear

bysort wgrp:summarize distlake pup_pop latr_pup z_inf98 pop1_3km_updated pop1_6km_updated popT_3km_updated popT_6km_updated

*checking difference between groups, basecategory here is wgrp3
local replace replace
foreach i in distlake pup_pop latr_pup z_inf98 pop1_3km_updated pop1_6km_updated popT_3km_updated popT_6km_updated {
	quietly:reg `i' ib3.wgrp 
	outreg2 using ".\output\table1_panelC.xlsx", dec(2) `replace'
	local replace
}

*Table 3

use ".\data\comply.dta", clear

duplicates report pupid     
duplicates tag pupid, generate(duplicate)
drop if duplicate>0
duplicates report pupid

save ".\data\comply_new.dta", replace

use ".\data\namelist.dta", clear

keep if visit== 981
drop if dupid==2

merge 1:1 pupid using ".\data\comply_new.dta"

*top panel (grade 1-8)
bysort wgrp: tab any98 if elg98==1                   /*& inrange(std98v1,1,8)*/                                    

bysort wgrp: tab any98 if elg98==0                  /*& inrange(std98v1,1,8)*/                           

*middle panel (grade 1-7)
bysort wgrp: tab any99 if elg99==1 & inrange(std98v1,1,7)

bysort wgrp: tab any99 if elg99==0 & inrange(std98v1,1,7)

*bottom panel (grade 1-7, enrolled in 1999)
drop if (totprs99==0|totprs99==.)       /*dropping those not present in 1999 visit*/
bysort wgrp: tab any99 if elg99==1 & inrange(std98v1,1,7)

bysort wgrp: tab any99 if elg99==0 & inrange(std98v1,1,7) 

*Table 5

use ".\data\namelist.dta", clear

keep if visit== 981
drop if dupid==2

merge 1:1 pupid using ".\data\wormed.dta"
drop if _merge!=3
drop if any_ics99==.

*Panel A

bysort wgrp: sum any_ics98 any_ics99  /*if inrange(std98v1,3,8)*/
*Group1-Group2
reg any_ics98 ib2.wgrp, vce(cluster schid) 
reg any_ics99 ib2.wgrp, vce(cluster schid)

*proportion anemic
gen anemia=0
replace anemia=1 if hb<100
replace anemia=. if hb==.

bysort wgrp: sum anemia 
reg anemia ib2.wgrp, vce(cluster schid)

*panel C

use ".\data\namelist.dta", clear

keep if visit== 981
drop if dupid==2

merge 1:1 pupid using ".\data\pupq.dta"

gen child_clean = clean_99_13==1
replace child_clean =. if clean_99_13==.
gen wear_shoes = shoes_99_10==1|shoes_99_10==2
replace wear_shoes=. if shoes_99_10==.

bysort wgrp: sum child_clean wear_shoes dayswat_99_36 if wgrp==1|wgrp==2
reg child_clean ib2.wgrp, vce(cluster schid)
reg wear_shoes ib2.wgrp, vce(cluster schid)
reg dayswat_99_36 ib2.wgrp, vce(cluster schid)

*Table 6

use ".\data\namelist.dta", clear

keep if visit== 981
drop if dupid==2

merge 1:1 pupid using ".\data\comply_new.dta"
rename _merge _mergecomply
merge 1:1 pupid using ".\data\wormed.dta"
rename _merge _mergewormed

drop if elg98==.|any_ics99==.

*panel B
*eligible

sum any_ics99 if wgrp==1 & elg98==1 & any98==1
sum any_ics99 if wgrp==1 & elg98==1 & any98==0

sum any_ics99 if wgrp==2 & elg98==1 & any99==1
sum any_ics99 if wgrp==2 & elg98==1 & any99==0

reg any_ics99 wgrp1 if ((wgrp==1 & any98==1)|(wgrp==2 & any99==1)) & elg98==1, vce(cluster schid)
reg any_ics99 wgrp1 if ((wgrp==1 & any98==0)|(wgrp==2 & any99==0)) & elg98==1, vce(cluster schid)

*non-eligible
sum any_ics99 if wgrp==1 & elg98==0 & any98==1
sum any_ics99 if wgrp==1 & elg98==0 & any98==0

sum any_ics99 if wgrp==2 & elg98==0 & any99==1
sum any_ics99 if wgrp==2 & elg98==0 & any99==0

reg any_ics99 wgrp1 if ((wgrp==1 & any98==1) | (wgrp==2 & any99==1)) & elg98==0, vce(cluster schid)
reg any_ics99 wgrp1 if ((wgrp==1 & any98==0) | (wgrp==2 & any99==0)) & elg98==0, vce(cluster schid)


*Table 7
use ".\data\namelist.dta", clear

keep if visit== 981
drop if dupid==2

merge 1:1 pupid using ".\data\wormed.dta"
keep if _merge!=1
rename _merge _mergeworm

merge 1:1 pupid using ".\data\comply_new.dta"
keep if _merge!=1
rename _merge _mergecomply

merge m:1 schid using ".\data\schoolvar.dta"
rename _merge _mergeschvar

*those treated when offered
gen select=0
replace select=1 if (wgrp==1 & any98==1) | (wgrp==2 & any99==1)
replace select=. if (any98==. & any99==.)
gen wgrp1_select = wgrp1*select

gen pop1_3km_1000 = pop1_3km_original/1000
gen pop1_36k_1000 = pop1_36k_original/1000
gen popT_3km_1000 = popT_3km_original/1000
gen popT_36k_1000 = popT_36k_original/1000

dprobit any_ics99 wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 if (wgrp==1|wgrp==2), vce(cluster schid)
outreg2 using ".\output\table7.xlsx", dec(2) replace

dprobit any_ics99 wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 select wgrp1_select if (wgrp==1|wgrp==2), vce(cluster schid)

save ".\data\table7_repdata.dta", replace

*using weights

use ".\data\namelist.dta", clear

keep if visit== 981
drop if dupid==2

collapse (count)count=pupid, by (schid)

merge 1:m schid using ".\data\table7_repdata.dta"

egen ndata=count(pupid), by(schid)

gen weights = count/ndata

dprobit any_ics99 wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 if (wgrp==1|wgrp==2) [pw=weights], vce(cluster schid)

dprobit any_ics99 wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 select wgrp1_select if (wgrp==1|wgrp==2) [pw=weights], vce(cluster schid)


*controls
dprobit any_ics99 wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 obs sap1 sap2 sap3 sap4 std mk96_s if (wgrp==1|wgrp==2) [pw=weights], vce(cluster schid)

dprobit any_ics99 wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 select wgrp1_select obs sap1 sap2 sap3 sap4 std mk96_s if (wgrp==1|wgrp==2) [pw=weights], vce(cluster schid)

*schisto
dprobit sm99_who wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 obs sap1 sap2 sap3 sap4 std mk96_s if (wgrp==1|wgrp==2) [pw=weights], vce(cluster schid)


dprobit sm99_who wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 select wgrp1_select obs sap1 sap2 sap3 sap4 std mk96_s if (wgrp==1|wgrp==2) [pw=weights], vce(cluster schid)

*geo-helminth
dprobit any_geo99_original wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 obs sap1 sap2 sap3 sap4 std mk96_s if (wgrp==1|wgrp==2) [pw=weights], vce(cluster schid)


dprobit any_geo99_original wgrp1 pop1_3km_1000 pop1_36k_1000 popT_3km_1000 popT_36k_1000 select wgrp1_select obs sap1 sap2 sap3 sap4 std mk96_s if (wgrp==1|wgrp==2) [pw=weights], vce(cluster schid)


*close log
log close
