log using miguel_roland_rep, replace
set more off

cd "C:\Users\johnd\OneDrive\Desktop\sose21\Miguel_roland"
use MR2011_replication.dta, clear

*1(a)

//Panel A Table 1//
*two new variables

gen ordnance= General_Purpose + Cluster_Bomb + Missile + Rocket + Cannon_Artillery
label variable ordnance "total US bombs, missiles, and rockets"

gen ordnancekm2= ordnance/area_tot_km2
label variable ordnancekm2 "total US bombs, missiles, and rockets per km2"
estpost summarize ordnancekm2 ordnance General_Purpose Cluster_Bomb Missile Rocket Cannon_Artillery Incendiary WP Ammunition


esttab, title("Summary statistics — U.S. ordnance data, 1965–75") posthead("Panel A: district-level data") noobs modelwidth(10) varwidth(50) ///
cell((mean(label(Mean)fmt(%9.1f)) sd(label(S.D.)fmt(%9.1f)) max(label(Max)fmt(%9.1f)) count(label(Obs)fmt(%9.0g)))) nonumber ///
coeflabel(ordnance "total US bombs, missiles, and rockets" ordnancekm2 "total US bombs, missiles, and rockets per km2" ///
General_Purpose "General purpose bombs" Cluster_Bomb "Cluster bombs" Missile "Missiles" Rocket "Rockets" Cannon_Artillery "Cannon artillery" ///
Incendiary "Incendiaries" WP "White Phosphorous" Ammunition "Ammunition(000's of rounds)")

*correlation pairwise
*pwcorr General_Purpose Cluster_Bomb Missile Rocket Cannon_Artillery Incendiary WP Ammunition [fweight=pop_tot], star(.05)

estpost corr General_Purpose Cluster_Bomb Missile Rocket Cannon_Artillery Incendiary WP Ammunition [fweight=pop_tot]
esttab ., varwidth(20) modelwidth(15) compress noobs b(2) not nonumbers star(* .10 ** .05 *** .01)

*1(b)

sum ordnancekm2
list districtname provincename if ordnancekm2==r(min)
list districtname provincename if ordnancekm2==r(max)

summarize ordnancekm2 if provincename=="Ha Noi (City)"
display r(sum)

summarize ordnancekm2 if provincename=="Ho Chi Minh (City)"
display r(sum)

summarize ordnancekm2 if provincename=="Quang Tri"
display r(sum)

*(iv)

sum ordnancekm2 if north_lat < 17.0   ///was done differently in tutorial. I think total ordnance and total km2 (>or< 17°) used to calculate ordnancekm2 separately.
display r(sum)

sum ordnancekm2 if north_lat > 17.0
display r(sum)

*(c)
graph twoway (scatter ordnancekm2 north_lat), xline(17.0)

*(d)
egen allordnance = rowtotal(Ammunition Cannon_Artillery Chemical Cluster_Bomb Flare Fuel_Air_Explosive General_Purpose Grenade Incendiary Mine Missile Other Rocket Submunition Torpedo Unknown UnlabeledUSAF A AAC AC ACC AP COM COMM CVT HC HCC HCP HCPD HCVT HE HECVT HEPD HP HVTF ILL ILLUM ILUM MK MK07 MK10 MK12 MK7 MK70 MK8 P P0 RAGON RAP SHRKE UNLABELEDUSN VC VT VTN VTNSD VTSD W WP)
gen allordnancekm2 = allordnance/area_tot_km2
gen unreported_ordnancekm2 = allordnancekm2 - ordnancekm2
display sum(unreported_ordnancekm2)

*correlation 
pwcorr allordnancekm2 ordnancekm2 [fweight=pop_tot], sig

*2.(a)
*i) 
reg poverty_p0 ordnancekm2, robust
outreg2 using reg1.xls, replace depvar
*ii)
reg popdensity1999 ordnancekm2, robust
outreg2 
*iii)
reg elec_rate ordnancekm2, robust
outreg2
*iv
reg lit_rate ordnancekm2, robust
outreg2

*other regressions

reg poverty_p0 ordnancekm2 if south==1, robust
outreg2 using reg2.xls, replace title(dependent variable: estimated poverty rate 1999) ctitle(ex-south)
reg poverty_p0 ordnancekm2 if south!=1, robust
outreg2 using reg2.xls, ctitle(ex-north)
reg poverty_p0 ordnancekm2 if popdensity6061<200, robust
outreg2 using reg2.xls, ctitle(rural)
reg poverty_p0 ordnancekm2 if popdensity6061>200, robust
outreg2 using reg2.xls, ctitle(urban)
reg poverty_p0 ordnancekm2 c.ordnancekm2#c.ordnancekm2, robust
outreg2 using reg2.xls, ctitle(square bombing)
sort ordnancekm2

xtile topten = ordnancekm2, nq(10)
list districtname topten, sepby(topten)
gen toptenpercentile = 0
replace toptenpercentile =1 if topten==10
reg poverty_p0 ordnancekm2 i.toptenpercentile, robust
outreg2 using reg2.xls, ctitle(top10percent)

gen popdensity6061_100 = popdensity6061/100
reg poverty_p0 ordnancekm2 popdensity6061_100 i.south area_251_500m area_501_1000m area_over_1000m pre_avg tmp_avg north_lat soil_1 soil_3 soil_6 soil_7 soil_8 soil_9 soil_10 soil_11 soil_12 soil_14 soil_24 soil_26 soil_33 soil_34 soil_35 soil_39 soil_40 soil_41, vce(cluster province)
outreg2 using reg3.xls, replace nocons dec(4) drop(soil*) addtext(District soil controls, YES) ctitle(OLS)

*fixed effects model(standard errors slightly higher) 
*you get exact standard errors if you just use dummies for province
 
xtset province
xtreg poverty_p0 ordnancekm2 popdensity6061_100 south area_251_500m area_501_1000m area_over_1000m pre_avg tmp_avg north_lat soil_1 soil_3 soil_6 soil_7 soil_8 soil_9 soil_10 soil_11 soil_12 soil_14 soil_24 soil_26 soil_33 soil_34 soil_35 soil_39 soil_40 soil_41, fe vce(cluster province)
*outreg2 using reg3.xls, replace nocons dec(4) drop(soil*) addtext(District soil controls, YES, Province fixed effects, YES) ctitle(OLS)

*omit quang tri province
reg poverty_p0 ordnancekm2 popdensity6061_100 south area_251_500m area_501_1000m area_over_1000m pre_avg tmp_avg north_lat soil_1 soil_3 soil_6 soil_7 soil_8 soil_9 soil_10 soil_11 soil_12 soil_14 soil_24 soil_26 soil_33 soil_34 soil_35 soil_39 soil_40 soil_41 if provincename!="Quang Tri", vce(cluster province)

*Ivreg(2sls)

gen abs_dis_17 = abs(17 - north_lat)

*first-stage
reg ordnancekm2 abs_dis_17 popdensity6061 i.south area_251_500m area_501_1000m area_over_1000m pre_avg tmp_avg north_lat soil_1 soil_3 soil_6 soil_7 soil_8 soil_9 soil_10 soil_11 soil_12 soil_14 soil_24 soil_26 soil_33 soil_34 soil_35 soil_39 soil_40 soil_41, vce(cluster province)
outreg2 using first_stage.xls, replace dec(4) nocons drop(soil*) addtext(District soil controls, YES)
predict ordnancekm2_hat

*second stage
reg poverty_p0 ordnancekm2_hat popdensity6061_100 south area_251_500m area_501_1000m area_over_1000m pre_avg tmp_avg north_lat soil_1 soil_3 soil_6 soil_7 soil_8 soil_9 soil_10 soil_11 soil_12 soil_14 soil_24 soil_26 soil_33 soil_34 soil_35 soil_39 soil_40 soil_41, vce(cluster province)



*alternate way (standard errors slightly higher)
ivregress 2sls poverty_p0 popdensity6061_100 south area_251_500m area_501_1000m area_over_1000m pre_avg tmp_avg north_lat soil_1 soil_3 soil_6 soil_7 soil_8 soil_9 soil_10 soil_11 soil_12 soil_14 soil_24 soil_26 soil_33 soil_34 soil_35 soil_39 soil_40 soil_41 (ordnancekm2=abs_dis_17), vce(cluster province)




