/* This do file analyses funds which are not index/ ETF.
All variables follow their definitions.
Please replace the directory pathway "C:\Users\johnd\PycharmProjects\pythonproject\master_thesis\notebooks" according to your project setup.
*/

use "C:\Users\johnd\PycharmProjects\pythonproject\master_thesis\notebooks\final_table_trimmed_for_outliers_msci_excluding_index_etf.dta", clear
set matsize 5000

*Preliminaries

xtset ID year_month
bys ID: gen N = _N       //keep a balanced sample, N==85 has the highest frequency
keep if N==85

bys ID: egen cohort_up = min(treatment_date_up) // fill in the date of first upgrade within an ID
bys ID: egen cohort_down = min(treatment_date_down) // fill in the date of first downgrade within an ID

gen time_to_treatment_up = year_month - cohort_up
gen time_to_treatment_down = year_month - cohort_down

bys ID: egen flag = min(time_to_treatment_up)
drop if flag >= 0 & flag != . // drop those first upgrade happened before or during 2013-12
drop if flag == . 
drop flag

bys ID: egen flag_down = min(time_to_treatment_down)
drop if flag >= 0 & flag != . // drop those first downgrade happened before or during 2013-12
drop if flag == . 
drop flag

* cohorts are based on initial treatment dates, dates are in 3-digit format.

* if we only look at a relative time period of -12 leads and 24 lags, then we need to either trim/bin the other relative periods
* Uncomment to trim, i.e. drop those lags and leads exceeding -12 and 24.

*drop if time_to_treatment_up < -12 | time_to_treatment_up > 24
*drop if time_to_treatment_down < -12 | time_to_treatment_down > 24

*here we bin the leads less than -12 and lags more than 24

gen bin_before_up = 0
replace bin_before_up = 1 if time_to_treatment_up < -12

gen bin_after_up = 0
replace bin_after_up = 1 if time_to_treatment_up > 24

gen bin_before_down = 0
replace bin_before_down = 1 if time_to_treatment_down < -12

gen bin_after_down = 0
replace bin_after_down = 1 if time_to_treatment_down > 24

* Generate calendar and event time and cohort dummies
xi i.year_month
tab time_to_treatment_up, gen(time_to_treatment_up_)
tab time_to_treatment_down, gen(time_to_treatment_down_)


*TWFE binned specification 

*joint specification
reghdfe esg_ownership_percent  bin_before_up time_to_treatment_up_73-time_to_treatment_up_83 time_to_treatment_up_85-time_to_treatment_up_109 bin_after_up bin_before_down time_to_treatment_down_73-time_to_treatment_down_83 time_to_treatment_down_85-time_to_treatment_down_109 bin_after_down, absorb(year_month ID) ///
vce(cluster year_month ID) noconstant 

eststo up_down_hdfe_joint_spec
esttab up_down_hdfe_joint_spec using "C:\Users\johnd\PycharmProjects\pythonproject\master_thesis\notebooks\msci_results\up_down_hdfe_joint_spec_msci_no_index_etf.csv", ci wide plain replace

