* This file contains additional regressions used to construct Table 4 in the paper.
* Please replace the directory pathway "C:\Users\johnd\PycharmProjects\pythonproject\master_thesis\notebooks" according to your project setup.

use "C:\Users\johnd\PycharmProjects\pythonproject\master_thesis\notebooks\balanced_panel_with_high_score_changes.dta", clear

* ESG Ownership and rating change characteristics

*check if treatment effect changes over time (generate dummy variable for post 2016 rating changes)

gen post_2016 = 0
replace post_2016 = 1 if cohort_up > 684 
replace post_2016 = 1 if cohort_down > 684

*joint specification (12 month-lag)
reghdfe esg_ownership_percent  bin_before_up time_to_treatment_up_73-time_to_treatment_up_83 time_to_treatment_up_85-time_to_treatment_up_96 time_to_treatment_up_98-time_to_treatment_up_109 bin_after_up bin_before_down time_to_treatment_down_73-time_to_treatment_down_83 time_to_treatment_down_85-time_to_treatment_down_96 time_to_treatment_down_98-time_to_treatment_down_109 bin_after_down time_to_treatment_up_97##post_2016 time_to_treatment_down_97##post_2016, absorb(year_month ID) ///
vce(cluster year_month ID) constant 

eststo post_2016_m12

quietly estadd local firmfe "Yes", replace
quietly estadd local monthfe "Yes", replace
quietly estadd local pre "Yes", replace
quietly estadd local post "Yes", replace
quietly estadd local r2 = e(r2_a), replace

*check if size of numerical rating influences ownership (using dummy variable High ESG score change)

*joint specification (12 month-lag)
reghdfe esg_ownership_percent  bin_before_up time_to_treatment_up_73-time_to_treatment_up_83 time_to_treatment_up_85-time_to_treatment_up_96 time_to_treatment_up_98-time_to_treatment_up_109 bin_after_up bin_before_down time_to_treatment_down_73-time_to_treatment_down_83 time_to_treatment_down_85-time_to_treatment_down_96 time_to_treatment_down_98-time_to_treatment_down_109 bin_after_down time_to_treatment_up_97##high_esg_score_change time_to_treatment_down_97##high_esg_score_change, absorb(year_month ID) ///
vce(cluster year_month ID) constant 

eststo high_score_m12

quietly estadd local firmfe "Yes", replace
quietly estadd local monthfe "Yes", replace
quietly estadd local pre "Yes", replace
quietly estadd local post "Yes", replace
quietly estadd local r2 = e(r2_a), replace


#delimit ;
esttab post_2016_m12 high_score_m12 using "C:\Users\johnd\PycharmProjects\pythonproject\master_thesis\notebooks\msci_results\post_2016_high_esg_m12.tex", 
replace se star(* 0.10 ** 0.05 *** 0.01)
s(firmfe monthfe pre post r2 N,
	label("Firm FE" "Month FE" "Pre-event leads" "Post-event lags" "Adjusted R-squared" "N"));
#delimit cr
