cap cls
clear all
set more off

global home "/mq/scratch/m1oma00/oma_projects/unemployment"
global data "$home/data"
global cps "$data/cps"
global ipums "$data/ipums_cps"
 
use "$ipums/ipums_cps_clean_25march2024.dta", clear

*******
**(1)**
*******
/* LF Flows: 2019-2020  */
cls
forval i = 2/16 {
	preserve
	keep if year == 2019 | year == 2020

	reghdfe lf_to_nlf treat_2019 female kids fam_size child_under_`i' i.female#c.treat_2019 i.female#c.child_under_`i' c.treat_2019#c.child_under_`i' i.female#c.child_under_`i'#c.treat_2019 age married i.i.race ib5.inc_q i.education onet_wfh wfh2019 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
restore
}

/* LF flows: 2021-2022*/
cls
forval i = 2/16 {
	preserve
	keep if year == 2021 | year == 2022

	reghdfe lf_to_nlf treat_2021 female kids fam_size child_under_`i' i.female#c.treat_2021 i.female#c.child_under_`i' c.treat_2021#c.child_under_`i' i.female#c.child_under_`i'#c.treat_2021 age married i.race ib5.inc_q i.education onet_wfh wfh2021 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
restore
}

*******
**(2)**
*******
/* Job keeping: 2019-2020  */
cls
forval i = 2/16 {
	preserve
	keep if year == 2019 | year == 2020

	reghdfe emp_to_emp treat_2019 female kids fam_size child_under_`i' i.female#c.treat_2019 i.female#c.child_under_`i' c.treat_2019#c.child_under_`i' i.female#c.child_under_`i'#c.treat_2019 age married i.race ib5.inc_q i.education onet_wfh wfh2019 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
restore
}

/*  Job keeping: 2021-2022*/
cls
forval i = 2/16 {
	preserve
	keep if year == 2021 | year == 2022

	reghdfe emp_to_emp treat_2021 female kids fam_size child_under_`i' i.female#c.treat_2021 i.female#c.child_under_`i' c.treat_2021#c.child_under_`i' i.female#c.child_under_`i'#c.treat_2021 age married i.race ib5.inc_q i.education wfh2021 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
restore
}

