cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/replication_educ_lfp_oma"
global data "$home/data"
global cps "$data/cps"
global bls "$data/bls"
global crosswalk "$data/crosswalks"
global ipums "$data/ipums_cps"
global figures "$home/figures"

*******
**(1)**
*******
*Figure 1

use "$atus/atus_educ_total_year.dta", clear
replace online_total = online_total*100

twoway line online_total year, lcolor(black) xtitle("Year") ytitle("Online Learning Rate (%)") xlabel(2003(5)2023)
graph export "$figures/figure1.eps", replace


*******
**(2)**
*******
/* figure 2 */ 
use "$cps/cps_naics2_educ.dta", clear

*bar graph of change in online training pre pandemic. 
graph hbar (mean) naics2_online_educ2019, over(title,sort(naics2_online_educ2019) descending) bar(1, color(blue)) ///
yline(0.247913, lcolor(red)) ///
ytitle("Weighted Proportion, %") ///
ylabel(, format(%9.2f)) ///
blabel(bar, format(%3.2f)) 
graph export "$figures/figure2a.eps", replace

*bar graph of change in online training post pandemic. 
graph hbar (mean) naics2_online_educ2021, over(title,sort(naics2_online_educ2021) descending) bar(1, color(blue)) ///
yline(0.2964892, lcolor(red)) ///
ytitle("Weighted Proportion, %") ///
ylabel(, format(%9.2f)) ///
blabel(bar, format(%3.2f)) 
graph export "$figures/figure2b.eps", replace

*******
**(3)**
*******
/* figure 3 */
use "$ipums/ipums_cps_clean_25march2024.dta", clear

*keeping only 2019 & 2021
keep if year == 2019 | year == 2021

*merge in BLS training assignment data 
merge m:1 occ2 using "$bls/bls_training_assignment_2021.dta", keep(3) nogen

*O*NET training 2021 and wfh
preserve
	keep occ2 online_educ2021 any_term_occ2 title
	duplicates drop
	replace occ2 = title if inlist(occ2,"11","17","25","21","15","47","37","35","13")
	replace occ2 = title if occ2 == "19" | occ2 == "31"
	corr online_educ2021 any_term_occ2
	local corr : di %5.3g r(rho) 
	twoway scatter online_educ2021 any_term_occ2 , mlabel(occ2) || lfit online_educ2021 any_term_occ2 , legend(off) subtitle("r `corr'", size(small)) ytitle("Online Learning") xtitle("On-the-Job Training") ylabel(, format(%9.2f)) xlabel(, format(%9.2f)) ///
	*graph export "$figures/figure3.eps", replace


restore

*******
**(4)**
*******
/* figure 4 : the figure used in text is the R script output (see figures programs folder)*/
use "$cps/cps_descriptives.dta", clear
keep if age >16 & age < 55

gen in_lf = 1 if inlist(lf,1,2,3,4)
replace in_lf = 0 if inlist(lf,5,6,7)

egen istate_year = group(state year)
egen inaics2_year = group(naics2 year)

*create education figure
reghdfe educ_content male ib1.race ib1.ieducation ib8.hh_inc married age[aw=pwsswgt], absorb(istate_year inaics2_year) cluster(hrhhid)
coefplot, keep(*.ieducation) vertical base rename(1.ieducation="Less Highschool" 2.ieducation="Highschool" 3.ieducation="Associate's" 4.ieducation="Bachelor's" 5.ieducation="Graduate") mcolor("106 208 200") ciopts(lcolor("118 152 160")) yline(0,lcolor("106 208 200") lpattern(dash)) graphregion(fcolor(white) ifcolor(white) ilcolor(white)) xscale(lcolor("0 51 102")) yscale(lcolor("0 51 102")) xlabel(, angle(45)) ylabel(, format(%9.2f)) 

*******
**(5)**
*******
/* figure 5 : the figure used in text is the R script output (see figures programs folder)*/
use "$ipums/ipums_cps_clean_25march2024.dta", clear

/*************
INFLATION ADJUST
*************/
foreach i of varlist wage {
replace `i' = `i' *  1.04296109540458 if year == 2017
replace `i' = `i' *   1.018128936 if year == 2018
replace `i' = `i' * 1 if year == 2019
replace `i' = `i' *  0.987641840997718 if year == 2020
replace `i' = `i' *  0.94346359409987 if year == 2021
replace `i' = `i' *  0.873686759 if year == 2022
}

keep if year == 2019 | year == 2021

gen log_wage = ln(wage)
reghdfe wage i.quartile female age married ib1.race ib1.ichild ib5.inc_q ib1.education onet_wfh [aw=weight], absorb(Istate_year inaics2_year)

reghdfe log_wage i.quartile female age married ib1.race ib1.ichild ib5.inc_q ib1.education wfh2021 [aw=weight], absorb(Istate_year inaics2_year)
coefplot, keep(*.quartile) vertical base rename(1.quartile="Quartile 1" 2.quartile="Quartile 2" 3.quartile="Quartile 3" 4.quartile="Quartile 4") mcolor("106 208 200") ciopts(lcolor("118 152 160")) yline(0,lcolor("106 208 200") lpattern(dash)) graphregion(fcolor(white) ifcolor(white) ilcolor(white)) xscale(lcolor("0 51 102")) yscale(lcolor("0 51 102")) xlabel(, angle(45)) ylabel(, format(%9.2f)) 

*******
**(6)**
*******
/* figure 6 */
use "$ipums/ipums_cps_clean_25march2024.dta", clear
*keeping only 2019 & 2021
keep if year == 2019 | year == 2021

*Panel A
preserve
	keep title occ2 online_educ2021 onet_wfh
	duplicates drop
	replace occ2 = title if inlist(occ2,"13","11","23","17","19","41","29","35","53")
	corr online_educ2021 onet_wfh
	local corr : di %5.3g r(rho) 
	twoway scatter online_educ2021 onet_wfh , mlabel(occ2) || lfit online_educ2021 onet_wfh , legend(off) subtitle("r `corr'", size(small)) ytitle("Online Learning") xtitle("WFH Ability") xlabel(, format(%9.2f))  ylabel(, format(%9.2f)) 
	*graph export "$figures/figure6A.eps", replace

restore

*Panel B
merge m:1 occ2 using "$data/wfh/acs_wfh.dta", keep(3) nogen
preserve
	keep title occ2 online_educ2021 wfh2021
	duplicates drop
	replace occ2 = title 
	corr online_educ2021 wfh2021
	local corr : di %5.3g r(rho) 
	twoway scatter online_educ2021 wfh2021 , mlabel(occ2) || lfit online_educ2021 wfh2021 , legend(off) subtitle("r `corr'", size(small)) ytitle("Online Learning") xtitle("Work-From-Home") xlabel(, format(%9.2f))  ylabel(, format(%9.2f))  
	*graph export "$figures/figure6B.eps", replace

restore

*******
**(7)**
*******
/* figure 7 */
use "$atus/atus_female_educ_year.dta", clear
merge 1:1 year using "$atus/atus_male_educ_year.dta", keep(3) nogen
merge 1:1 year using "$atus/atus_educ_total_year.dta", keep(3) nogen
drop sex

foreach x in online_total online_male online_female {
	replace `x' = `x'*100
}

twoway line online_male online_female online_total year, ///
    xtitle("Year") ///
    ytitle("Online Learning Rate (%)") ///
    legend(label(1 "Male") label(2 "Female") label(3 "Total")) ///
    xlabel(2003(5)2023) ///
    lcolor(blue pink black)
*graph export "$figures/figure7.eps", replace

*********
**(A.1)**
*********
/* Appendix Figure 1*/

use "$cps/cps_descriptives.dta", clear
keep if age >16 & age < 55

graph bar (mean) educ_content [aw=pwsswgt] if year == 2019, over(age) bar(1, color(blue)) ytitle(`"Weighted Average, %"') ylabel(, format(%9.2f)) 
*graph export "$figures/appendix_figure_A1_a.eps", replace

graph bar (mean) educ_content [aw=pwsswgt] if year == 2021, over(age) bar(1, color(blue)) ytitle(`"Weighted Average, %"') ylabel(, format(%9.2f)) 
*graph export "$figures/appendix_figure_A1_b.eps", replace

*********
**(A.2)**
*********
/* Appendix Figure 2*/
use "$ipums/ipums_cps_clean_25march2024.dta", clear
*keeping only 2019 & 2021
keep if year == 2019 | year == 2021

*Panel A
preserve
	*merge in lightcast
	merge m:1 occ2 using "$data/wfh/lightcast_telework.dta", keep(3) nogen
	*egen broad_def_2021 = rmean(hybrid2021 remote2021)
	keep title occ2 online_educ2021 remote2021 
	duplicates drop
	replace occ2 = title if inlist(occ2,"15","13","23","43","17","29","49","47")
	replace occ2 = title if occ2 == "35"
	corr remote2021 online_educ2021
	local corr : di %5.3g r(rho) 
	twoway scatter  remote2021 online_educ2021 , mlabel(occ2) || lfit  remote2021 online_educ2021 , legend(off) subtitle("r `corr'", size(small)) ytitle("Remote Job Posting") xtitle("Online Learning") xlabel(, format(%9.2f))  ylabel(, format(%9.2f)) 
	*graph export "$figures/appendix_figure_A2_a.eps", replace

restore

*Panel B & C:
import excel "/mq/scratch/m1oma00/oma_projects/replication_educ_lfp_oma/data/bls/naics2_telework.xlsx", sheet("Sheet1") firstrow clear
drop if percent_some == .
merge 1:1 naics2 using "$cps/cps_naics2_educ.dta", keep(3)

replace percent_some = percent_some/100
replace percent_all = percent_all/100 

preserve
	keep naics2 percent_some percent_all
	save "$bls/bls_naics2_telework.dta", replace
restore

rename naics2_online_educ2021 online_educ2021_naics2

*Panel B
preserve
	keep title naics2 percent_some online_educ2021_naics2 
	replace naics2 = title if inlist(naics2,"61","55","62","52","72","51","48-49","23","54")
	duplicates drop

	corr online_educ2021_naics2 percent_some
	local corr : di %5.3g r(rho) 
	twoway scatter percent_some online_educ2021_naics2  , mlabel(naics2) || lfit percent_some online_educ2021_naics2 , legend(off) subtitle("r `corr'", size(small)) ytitle("Some Employees Work From Home") xtitle("Online Learning") xlabel(, format(%9.2f))  ylabel(, format(%9.2f)) 
	*graph export "$figures/appendix_figure_A2_b.eps", replace

restore

*Panel C
preserve
	keep title naics2 percent_all online_educ2021_naics2 
	replace naics2 = title if inlist(naics2,"55","54","51","56","72","62","11","52")
	duplicates drop

	corr online_educ2021_naics2 percent_all
	local corr : di %5.3g r(rho) 
	twoway scatter percent_all online_educ2021_naics2  , mlabel(naics2) || lfit percent_all online_educ2021_naics2 , legend(off) subtitle("r `corr'", size(small)) ytitle("All Employees Work From Home") xtitle("Online Learning") xlabel(, format(%9.2f))  ylabel(, format(%9.2f)) 
	*graph export "$figures/appendix_figure_A2_b.eps", replace

restore


