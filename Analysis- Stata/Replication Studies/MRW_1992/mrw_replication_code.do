/*1. Real world data falls in line with predictions of solow model. Rate of savings and population growth affect the steady state level of income per worker. Higher savings rate leads to higher income per worker levels and higher population growth rate leads to lower levels of income per worker. 
The coefficients of savings rate and population growth have a lower value once they account for accumulation of human capital in their augmented solow model. This implies that savings and population growth rate are correlated with human capital accumulation.
The implied alpha and beta have  a value of approx. 1/3 which fits with prior data.

2.	Model assumes factors are paid their marginal products. Share of capital in national income is roughly 1/3rd.*/



log using mrw_replication, replace
set more off

cd "C:\Users\johnd\OneDrive\Desktop\mrw\tut1\data\"

insheet using pwt61_data.csv, delimiter(",") names
*saveold pwt61_data, replace

keep if year==1960|year==1985

keep country countryisocode year pop rgdpl kg ki
reshape wide pop rgdpl kg ki, i(countryisocode) j(year)

*avg growth rate of population 
gen n = exp(ln(pop1985/pop1960)/25)-1

*n+g+d variable
gen g_d = 0.05
gen n_g_d = n + g_d

*average investment share of GDP (1960 and 1985)
gen inv_y= (ki1960 + ki1985)/200

*converting to ln
gen ln_gdp_percap1985= ln(rgdpl1985)
gen ln_inv_y= ln(inv_y)
gen ln_ngd= ln(n_g_d)

* create country list
generate intermediate = (country== "Algeria"  | country=="Argentina"  | country=="Australia" | country=="Austria" | country=="Bangladesh" | country=="Belgium" | country=="Bolivia" | country=="Botswana" | country=="Brazil" | country=="Cameroon" | country=="Canada" | country=="Chile" | country=="Colombia" | country=="Costa Rica" | country=="Cote d'Ivoire" | country=="Denmark" | country=="Dominican Republic" | country=="Ecuador" | country=="El Salvador" | country=="Ethiopia" | country=="Finland" | country=="France" | country=="Germany" | country=="Greece" | country=="Guatemala" | country=="Haiti" | country=="Honduras" | country=="Hong Kong" | country=="India" | country=="Indonesia" | country=="Ireland" | country=="Israel" | country=="Italy" | country=="Jamaica" | country=="Japan" | country=="Jordan" | country=="Kenya" | country=="Korea, Republic of"  | country=="Madagascar" | country=="Malawi" | country=="Malaysia" | country=="Mali" | country=="Mexico" | country=="Morocco" | country=="Netherlands" | country=="New Zealand" | country=="Nicaragua" | country=="Nigeria" | country=="Norway" | country=="Pakistan" | country=="Panama" | country=="Paraguay" | country=="Peru" | country=="Philippines" | country=="Portugal" | country=="Senegal" | country=="Singapore" | country=="South Africa" | country=="Spain" | country=="Sri Lanka" | country=="Sweden" | country=="Switzerland" | country=="Syria" | country=="Tanzania" | country=="Thailand" | country=="Trinidad &Tobago" | country=="Tunisia" | country=="Turkey" | country=="United Kingdom" | country=="United States" | country=="Uruguay" | country=="Venezuela" | country=="Zambia" | country=="Zimbabwe")

generate oecd = (country=="Australia" | country=="Austria" | country=="Belgium" | country=="Canada" | country=="Denmark" | country=="Finland" | country=="France" | country=="Germany" | country=="Greece" | country=="Ireland" | country=="Italy" | country=="Japan" | country=="Netherlands" | country=="New Zealand" | country=="Norway" | country=="Portugal" | country=="Spain" | country=="Sweden" | country=="Switzerland" | country=="Turkey" | country=="United Kingdom" | country=="United States")

**run OLS regression**

reg ln_gdp_percap1985 ln_inv_y ln_ngd if oecd, robust
outreg2 using "task_1_reg.xls" , replace dec(2) se
test _b[ln_inv_y] + _b[ln_ngd]=0

reg ln_gdp_percap1985 ln_inv_y ln_ngd if intermediate, robust
outreg2
test _b[ln_inv_y] + _b[ln_ngd]=0

*restricted reg
*gen restricted = ln_inv_y - ln_ngd (this works as well)

constraint 1 ln_inv_y + ln_ngd =0
cnsreg ln_gdp_percap1985 ln_inv_y ln_ngd if intermediate, constraint(1) robust
*alpha
nlcom (alpha_inter:_b[ln_inv_y]/(1 + _b[ln_inv_y])), post
test _b[alpha_inter]=1/3

cnsreg ln_gdp_percap1985 ln_inv_y ln_ngd if oecd, constraint(1) robust
*alpha
nlcom (alpha_oecd:_b[ln_inv_y]/(1 + _b[ln_inv_y])), post
test _b[alpha_oecd]=1/3


**CONVERGENCE**

gen ln_difference_gdp = ln(rgdpl1985)-ln(rgdpl1960)
gen ln_initial_gdp = ln(rgdpl1960)

*reg (unconditional)

reg ln_difference_gdp ln_initial_gdp if oecd, robust

reg ln_difference_gdp ln_initial_gdp if intermediate, robust

*reg(conditional)
reg ln_difference_gdp ln_initial_gdp ln_inv_y ln_ngd if oecd, robust
predict y_hatoecd if e(sample)

reg ln_difference_gdp ln_initial_gdp ln_inv_y ln_ngd if intermediate, robust
predict y_hatinter if e(sample)


*restricted

cnsreg ln_difference_gdp ln_initial_gdp ln_inv_y ln_ngd if oecd, constraint(1) robust

*lambda
nlcom (lambdaoecd:ln(_b[ln_initial_gdp]+1)/(-25)), post
test _b[lambdaoecd]=0.04

cnsreg ln_difference_gdp ln_initial_gdp ln_inv_y ln_ngd if intermediate, constraint(1) robust

*lambda
nlcom (lambdainter:ln(_b[ln_initial_gdp]+1)/(-25)), post
test _b[lambdainter]=0.04

/*plot (fig.1)
graph twoway (scatter y_hatoecd ln_initial_gdp) (lfit y_hatoecd ln_initial_gdp)
graph save fig1oecd, replace

graph twoway (scatter y_hatinter ln_initial_gdp) (lfit y_hatinter ln_initial_gdp)
graph save fig1inter, replace*/

**adding human capital data**
*preserve

*clear
*use country ls lh WBcode year using "C:\Users\johnd\OneDrive\Desktop\mrw\tut1\data\BL2013_MF1599_v2.2.dta" if year==1960
*rename WBcode countryisocode

*saveold barrolee_mrwrep_sample, replace

*restore

*merge files

merge 1:1 country countryisocode using "C:\Users\johnd\OneDrive\Desktop\mrw\tut1\data\barrolee_mrwrep_sample.dta"

*regression
*school enrolment in 1960 used as proxy for initial human capital levels
gen ln_school= ln((ls+lh)/100)

reg ln_difference_gdp ln_initial_gdp ln_inv_y ln_ngd ln_school if oecd, robust
nlcom (alpha_final:_b[ln_inv_y]/(1 + _b[ln_inv_y])), post
test _b[alpha_final]=1/3

reg ln_difference_gdp ln_initial_gdp ln_inv_y ln_ngd ln_school if oecd, robust
nlcom (lambdafinal:ln(_b[ln_initial_gdp]+1)/(-25)), post
test _b[lambdafinal]=0.02



reg ln_difference_gdp ln_initial_gdp ln_inv_y ln_ngd ln_school if intermediate, robust
nlcom (alpha_final2:_b[ln_inv_y]/(1 + _b[ln_inv_y])), post
test _b[alpha_final2]=1/3

reg ln_difference_gdp ln_initial_gdp ln_inv_y ln_ngd ln_school if intermediate, robust
nlcom (lambdafinal2:ln(_b[ln_initial_gdp]+1)/(-25)), post
test _b[lambdafinal2]=0.02

*now parameter estimates of alpha and lambda are much closer to the augmented model.



log close
type mrw_replication.smcl

