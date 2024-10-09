cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/replication_educ_lfp_oma"
global data "$home/data"
global cps "$data/cps"
global bls "$data/bls"
global crosswalk "$data/crosswalks"

*******
**(1)**
*******
/* figure 1 */ 
use "$cps/cps_naics2_educ.dta", clear

*bar graph of change in online training pre pandemic. 
graph hbar (mean) naics2_online_educ2019, over(title,sort(naics2_online_educ2019) descending) bar(1, color(blue)) ///
yline(0.247913, lcolor(red)) ///
ytitle("Weighted Proportion, %") ///
blabel(bar, format(%3.2f)) 

*bar graph of change in online training post pandemic. 
graph hbar (mean) naics2_online_educ2021, over(title,sort(naics2_online_educ2021) descending) bar(1, color(blue)) ///
yline(0.2964892, lcolor(red)) ///
ytitle("Weighted Proportion, %") ///
blabel(bar, format(%3.2f)) 

*bar graph of change in online training post pandemic. 
graph hbar (mean) naics2_online_educ2023, over(title,sort(naics2_online_educ2023) descending) bar(1, color(blue)) ///
yline(0.2964892, lcolor(red)) ///
ytitle("Weighted Proportion, %") ///
blabel(bar, format(%3.2f)) 

*bar graph of change in online training pre-post pandemic. 
graph hbar (mean) delta_educ_naics, over(title,sort(delta_educ_naics) descending) bar(1, color(blue)) ///
yline(0.0, lcolor(red)) ///
ytitle("Percent Change") ///
blabel(bar, format(%3.2f)) 

*******
**(3)**
*******
/* figure 2 */
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
	twoway scatter online_educ2021 any_term_occ2 , mlabel(occ2) || lfit online_educ2021 any_term_occ2 , legend(off) subtitle("r `corr'", size(small)) ytitle("Online Education") xtitle("On-the-Job Training")
restore

*******
**(3)**
*******
/* figure 3 */
use "$cps/cps_descriptives.dta", clear
keep if age >16 & age < 55

gen in_lf = 1 if inlist(lf,1,2,3,4)
replace in_lf = 0 if inlist(lf,5,6,7)

egen istate_year = group(state year)
egen inaics2_year = group(naics2 year)

*create education figure
reghdfe educ_content male ib1.race ib1.ieducation ib8.hh_inc married age[aw=pwsswgt], absorb(istate_year inaics2_year) cluster(hrhhid)
coefplot, keep(*.ieducation) vertical base rename(1.ieducation="Less Highschool" 2.ieducation="Highschool" 3.ieducation="Associate's" 4.ieducation="Bachelor's" 5.ieducation="Graduate") mcolor("106 208 200") ciopts(lcolor("118 152 160")) yline(0,lcolor("106 208 200") lpattern(dash)) graphregion(fcolor(white) ifcolor(white) ilcolor(white)) xscale(lcolor("0 51 102")) yscale(lcolor("0 51 102")) xlabel(, angle(45))

*******
**(4)**
*******
/* figure 4 */
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
coefplot, keep(*.quartile) vertical base rename(1.quartile="Quartile 1" 2.quartile="Quartile 2" 3.quartile="Quartile 3" 4.quartile="Quartile 4") mcolor("106 208 200") ciopts(lcolor("118 152 160")) yline(0,lcolor("106 208 200") lpattern(dash)) graphregion(fcolor(white) ifcolor(white) ilcolor(white)) xscale(lcolor("0 51 102")) yscale(lcolor("0 51 102")) xlabel(, angle(45))

*******
**(4)**
*******
/* figure 5 */
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
	twoway scatter online_educ2021 onet_wfh , mlabel(occ2) || lfit online_educ2021 onet_wfh , legend(off) subtitle("r `corr'", size(small)) ytitle("Online Education") xtitle("WFH Ability")

restore

*Panel B
merge m:1 occ2 using "$data/wfh/acs_wfh.dta", keep(3) nogen
preserve
	keep title occ2 online_educ2021 wfh2021
	duplicates drop
	replace occ2 = title 
	corr online_educ2021 wfh2021
	local corr : di %5.3g r(rho) 
	twoway scatter online_educ2021 wfh2021 , mlabel(occ2) || lfit online_educ2021 wfh2021 , legend(off) subtitle("r `corr'", size(small)) ytitle("Online Education") xtitle("Work-From-Home")
restore

*Panel A (appendix)
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
	twoway scatter  remote2021 online_educ2021 , mlabel(occ2) || lfit  remote2021 online_educ2021 , legend(off) subtitle("r `corr'", size(small)) ytitle("Remote Job Posting") xtitle("Online Education")
restore

*Panel B & C (appendix):
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
	twoway scatter percent_some online_educ2021_naics2  , mlabel(naics2) || lfit percent_some online_educ2021_naics2 , legend(off) subtitle("r `corr'", size(small)) ytitle("Some Employees Work From Home") xtitle("Online Education")
restore

*Panel C
preserve
	keep title naics2 percent_all online_educ2021_naics2 
	replace naics2 = title if inlist(naics2,"55","54","51","56","72","62","11","52")
	duplicates drop

	corr online_educ2021_naics2 percent_all
	local corr : di %5.3g r(rho) 
	twoway scatter percent_all online_educ2021_naics2  , mlabel(naics2) || lfit percent_all online_educ2021_naics2 , legend(off) subtitle("r `corr'", size(small)) ytitle("All Employees Work From Home") xtitle("Online Education")
restore

*******
**(5)**
*******
/* figure 6 */
*Run blocks 5.1-5.4
*Blocks 5.1-5.3 create the data needed for plotting, and block 5.4 creates the figure. 
*******
**(5.1)**
*******
/* create ATUS dataset for menwho online learn */
use "$atus/atus_00011.dta", clear

*drop bad data quality
keep if dataqual == 200

*Restrict to employees aged 20-64
keep if age >= 18 & age <= 54
keep if empstat == 1 

keep if inlist(activity,060101, 060102)

*create a year month variable
gen ym = ym(year,month)
format ym %tm

*create quarterly variable: 
* Calculate the quarter based on month
gen quarter = ceil(month / 3)

* Create the quarterly date variable
gen qtr = yq(year, quarter)
format qtr %tq

keep if sex == 1
preserve
	* sum the duration of online learning across all respondents. 
	collapse (sum) duration, by(cpsidp year sex)

	keep cpsidp year sex
	gen education = 1
	
	tempfile education
	save "`education'"
restore 

merge m:1 cpsidp year sex using `education'
drop _merge 

*take the sum of time spent working for each individual
collapse (sum) duration (first) education wt06 wt20, by(cpsidp sex year where)

gen online_educ_atus = 0 
replace online_educ_atus = 1 if inlist(where, 101, 103, 109)

replace wt06 = round(wt06)
replace wt20 = round(wt20)

preserve 
	keep if year == 2020 
	collapse (sum) education online_educ_atus [fw=wt20], by(year sex)
	tempfile 2020
	save `2020', replace
restore
	
collapse (sum) education online_educ_atus [fw=wt06], by(year sex)
append using `2020'

gen online_educ_rate = online_educ_atus/ education

sort year sex

keep year sex online_educ_rate
rename online_educ_rate online_male

save "$atus/atus_male_educ_year.dta", replace

*******
**(5.2)**
*******
/* create ATUS dataset for women who online learn */
use "$atus/atus_00011.dta", clear

*drop bad data quality
keep if dataqual == 200

*Restrict to employees aged 20-64
keep if age >= 18 & age <= 54
keep if empstat == 1 

keep if inlist(activity,060101, 060102)

*create a year month variable
gen ym = ym(year,month)
format ym %tm

*create quarterly variable: 
* Calculate the quarter based on month
gen quarter = ceil(month / 3)

* Create the quarterly date variable
gen qtr = yq(year, quarter)
format qtr %tq

keep if sex == 2
preserve
	* sum the duration of online learning across all respondents. 
	collapse (sum) duration, by(cpsidp year sex)

	keep cpsidp year sex
	gen education = 1
	
	tempfile education
	save "`education'"
restore 

merge m:1 cpsidp year sex using `education'
drop _merge 

*take the sum of time spent working for each individual
collapse (sum) duration (first) education wt06 wt20, by(cpsidp sex year where)

gen online_educ_atus = 0 
replace online_educ_atus = 1 if inlist(where, 101, 103, 109)

replace wt06 = round(wt06)
replace wt20 = round(wt20)

preserve 
	keep if year == 2020 
	collapse (sum) education online_educ_atus [fw=wt20], by(year sex)
	tempfile 2020
	save `2020', replace
restore
	
collapse (sum) education online_educ_atus [fw=wt06], by(year sex)
append using `2020'

gen online_educ_rate = online_educ_atus/ education

sort year sex

keep year sex online_educ_rate
rename online_educ_rate online_female

save "$atus/atus_female_educ_year.dta", replace

*******
**(5.3)**
*******
/* create ATUS dataset for the total who online learn */
use "$atus/atus_00011.dta", clear

*drop bad data quality
keep if dataqual == 200

*Restrict to employees aged 20-64
keep if age >= 18 & age <= 54
keep if empstat == 1 

keep if inlist(activity,060101, 060102)

*create a year month variable
gen ym = ym(year,month)
format ym %tm

*create quarterly variable: 
* Calculate the quarter based on month
gen quarter = ceil(month / 3)

* Create the quarterly date variable
gen qtr = yq(year, quarter)
format qtr %tq

preserve
	* sum the duration of online learning across all respondents. 
	collapse (sum) duration, by(cpsidp year)

	keep cpsidp year 
	gen education = 1
	
	tempfile education
	save "`education'"
restore 

merge m:1 cpsidp year  using `education'
drop _merge 

*take the sum of time spent working for each individual
collapse (sum) duration (first) education wt06 wt20, by(cpsidp  year where)

gen online_educ_atus = 0 
replace online_educ_atus = 1 if inlist(where, 101, 103, 109)

replace wt06 = round(wt06)
replace wt20 = round(wt20)

preserve 
	keep if year == 2020 
	collapse (sum) education online_educ_atus [fw=wt20], by(year )
	tempfile 2020
	save `2020', replace
restore
	
collapse (sum) education online_educ_atus [fw=wt06], by(year )
append using `2020'

gen online_educ_rate = online_educ_atus/ education

sort year 

keep year  online_educ_rate
rename online_educ_rate online_total

save "$atus/atus_educ_total_year.dta", replace

*******
**(5.4)**
*******
*plot across gender and for the overall sample:
use "$atus/atus_female_educ_year.dta", clear
merge 1:1 year using "$atus/atus_male_educ_year.dta", keep(3) nogen
merge 1:1 year using "$atus/atus_educ_total_year.dta", keep(3) nogen
drop sex

*only plot 2003-2021:
drop if year == 2022
foreach x in online_total online_male online_female {
	replace `x' = `x'*100
}
twoway line online_total year, xtitle("Year") ytitle("Online Learning Rate (%)") xlabel(2003(5)2023)
twoway line online_male online_female year, xtitle("Year") ytitle("Online Learning Rate (%)") legend(label(1 "Male") label(2 "Female")) xlabel(2003(5)2023)
twoway line online_male online_female online_total year, xtitle("Year") ytitle("Online Learning Rate (%)") legend(label(1 "Male") label(2 "Female") label(3 "Total")) xlabel(2003(5)2023)



*********
**(A.1)**
*********
/* Appendix Figure */

use "$cps/cps_descriptives.dta", clear
keep if age >16 & age < 55

/* appendix figure */
graph bar (mean) educ_content [aw=pwsswgt] if year == 2019, over(age) bar(1, color(blue)) ytitle(`"Weighted Average, %"')
graph bar (mean) educ_content [aw=pwsswgt] if year == 2021, over(age) bar(1, color(blue)) ytitle(`"Weighted Average, %"')
