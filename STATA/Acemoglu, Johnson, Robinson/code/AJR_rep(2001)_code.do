*Tutorial 3 - AJR(2001)

log using ajr_replication, replace
set more off

cd "C:\Users\johnd\OneDrive\Desktop\sose21\ajr(2001)"

*load data
use AJR2001_replication.dta, clear

*3.a)
*graph (fig.1 in AJR)

twoway (scatter logpgp95 logem4, mstyle(none) mlabel(shortnam) mlabgap(-3) ysc(r(4 10))ylabel(#4))|| (lfit logpgp95 logem4) if excolony==1

*Comments: strong negative relationship, colonies where europeans faced higher mortality rates have lower gdp per capita today.
*can spot same values for many countries, imputed from neighbours.

*4.a)

gen mortality_level = exp(logem4)
summarize mortality_level

/*b) Reasons for extremely high mortality rates: measurement errors, associated with african nations hence could be due to their disease environment like malaria,
data could have been collected during an epidemic, soldiers are replaced so it gets high if many die quickly*/

/*5.a) Their focus is on how property rights affect economic performance. For this data on investment risk maybe a reasonable proxy.
They argue that expropriation risk is related to all other institutional features (footnote.3), 
datasource specializes in assesing risk for foreign investors(not sure how this is capturing true quality of institutions as a whole in a country)*/


*b)graph(fig.2 AJR) 

graph twoway (scatter logpgp95 avexpr, mstyle(none) mlabel(shortnam) mlabgap(-3) ysc(r(4 10)) ylabel(#4))|| (lfit logpgp95 avexpr) if excolony==1

*Comment: countries with higher avg. protection against expropriation, have higher gdp per capita. 

*c)column 1, table 2(AJR)

reg logpgp95 avexpr if excolony!=.  /*SUR is missing, excluding that replicates result*/

*d)i)basesample

gen basesample = 0
replace basesample = 1 if excolony==1 & logem4!=. & avexpr!=. & logpgp95!=.

*ii)

reg logpgp95 avexpr if basesample==1 

*Comment: results similar to the one using whole world sample.

*iii) MEX UGA

predict gdp_hat if e(sample)

list shortnam avexpr logpgp95 gdp_hat if shortnam=="MEX"| shortnam=="UGA"  /*not sure if this is the right approach*/

*predicted difference in log points(gdp)
display 100*(8.576186) - 100*(6.986133)
display exp(8.576186 - 6.986133)-1       /*approx. 4 fold*/

*actual difference in log points
display 100*(8.943768) - 100*(6.966024)
display exp(8.943768 - 6.966024) -1      /*approx. 6 fold*/     


*display exp((delta x)*0.94) - 1        /* exact %change in gdp ; display exp(difference in log points)-1 should give same answer*/
*display exp((7.5 - 4.45)*0.52) - 1     /* 3.87, approx. 4 fold increase*/


*6)
*a) graph (fig.3 AJR)
graph twoway (scatter avexpr logem4, mstyle(none) mlabel(shortnam) mlabgap(-3))|| (lfit avexpr logem4) if excolony==1

*Comment: Negative relationship. Higher mortality rates associated with lower protection against expropriation/worse institutions today.

*b)

*panel A Table 3
gen eurodes = euro1900/100

foreach i in cons00a democ00a eurodes logem4{
reg avexpr `i' if basesample==1
outreg2 using table3.xls, replace dec(2) nocons
}
reg avexpr cons1 indtime if basesample==1
outreg2

*Comment: association between early and present-day institutions. same holds for democracy index.(basically trying to prove persistence of institutions)


*c)i)
*2sls

ivregress 2sls logpgp95 (avexp=logem4) if basesample==1, first
*comment: first-stage provides evidence for mortality as strong instrument for institutions. 
*2nd stage - institutions have strong causal effect on economic performance.


*c)ii) MEX UGA
predict iv_hat if e(sample)

list shortnam logpgp95 avexpr gdp_hat iv_hat if shortnam=="UGA"| shortnam=="MEX"

*predicted difference in log points(gdp)
display 100*(8.991762)-100*(6.116002)
display exp(8.991762 - 6.116002)-1
*actual difference
display exp(8.943768 - 6.966024) -1           /*approx. 6 fold difference*/


/* exact %change in gdp*/
display exp((7.5 - 4.454545)*0.94) - 1       /* approx. 16 fold; is it supposed to be this high? */

*iii)




*d)
*i)original from Hall and Jones (1999)
reg logpgp95 latitude 

pwcorr latitude avexpr, sig

reg logpgp95 avexpr latitude 

*e)malaria

reg logpgp95 malfal94 if basesample==1

*ii)column 1, table 7
ivregress 2sls logpgp95 malfal94 (avexp=logem4) if basesample==1, first


//Albouy(2012)//

*1)
*a)same as in AJR
 
ivregress 2sls logpgp95 (avexpr=logem4) if basesample==1, first

ivregress 2sls logpgp95 latitude (avexpr=logem4) if basesample==1, first     

*b) sample of 64 countries

ivregress 2sls logpgp95 (avexpr=logem4) if basesample==1, first vce(cluster logem4)

*control for distance from equator
ivregress 2sls logpgp95 latitude (avexpr=logem4) if basesample==1, first vce(cluster logem4)  /*coef remain same, se slightly higher*/ 

*c) restricted sample of 28 countries

ivregress 2sls logpgp95 (avexpr=logem4) if source0==1, first vce(cluster logem4)

*control for distance from equator
ivregress 2sls logpgp95 latitude (avexpr=logem4) if source0==1, first vce(cluster logem4)  

*comment: weak instrument leading to small se.

*d) controlling for campaign and slave

*64 countries
ivregress 2sls logpgp95 campaign slave (avexpr=logem4) if basesample==1, first vce(cluster logem4)

*control for distance from equator
ivregress 2sls logpgp95 latitude campaign slave (avexpr=logem4) if basesample==1, first vce(cluster logem4) 
  
 
*28 countries
ivregress 2sls logpgp95 campaign slave (avexpr=logem4) if source0==1, first vce(cluster logem4)

*control for distance from equator
ivregress 2sls logpgp95 latitude campaign slave (avexpr=logem4) if source0==1, first vce(cluster logem4) 
 


//AJR(2012) reply//

*1.a)


*b) capping at 250

gen capped_level = mortality_level 
replace capped_level =250 if mortality_level>250
replace capped_level = .  if mortality_level==.

gen new_logem4 = ln(capped_level)

*64 countries
ivregress 2sls logpgp95 (avexpr=new_logem4) if basesample==1, first vce(cluster new_logem4)

*control for distance from equator
ivregress 2sls logpgp95 latitude (avexpr=new_logem4) if basesample==1, first vce(cluster new_logem4) 

*28 countries
ivregress 2sls logpgp95 (avexpr=new_logem4) if source0==1, first vce(cluster new_logem4)

*control for distance from equator
ivregress 2sls logpgp95 latitude (avexpr=new_logem4) if source0==1, first vce(cluster new_logem4)  


*c) Gambia's high institutional score and high mortality level makes it weird. 


*d)dropping Gambia

*64 countries
ivregress 2sls logpgp95 (avexpr=new_logem4) if basesample==1 & shortnam!= "GMB", first vce(cluster new_logem4)

*control for distance from equator
ivregress 2sls logpgp95 latitude (avexpr=new_logem4) if basesample==1 & shortnam!= "GMB", first vce(cluster new_logem4) 

*28 countries

ivregress 2sls logpgp95 (avexpr=new_logem4) if source0==1 & shortnam!= "GMB", first vce(cluster new_logem4)

*control for distance from equator
ivregress 2sls logpgp95 latitude (avexpr=new_logem4) if source0==1 & shortnam!= "GMB", first vce(cluster new_logem4)  























