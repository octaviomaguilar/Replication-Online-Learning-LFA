cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/replication_educ_lfp_oma"
global data "$home/data"
global cps "$data/cps"
global bls "$data/bls"
global crosswalk "$data/crosswalks"
global tables "$home/tables"

use "$ipums/ipums_cps_clean_25march2024.dta", clear

****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
/* Table 4 */ 

*OLS Pooled: Emp Flows

/* Employment flows: 2019-2020*/
preserve
	keep if year == 2019 | year == 2020
	reghdfe emp_to_emp treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store a
restore

/* LF flows: 2019-2020*/
preserve
	keep if year == 2019 | year == 2020
	reghdfe lf_to_nlf treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store b
restore

/* Employment flows: 2021-2022*/
preserve
	keep if year == 2021 | year == 2022
	reghdfe emp_to_emp treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store c
restore

/* LF flows: 2021-2022*/
preserve
	keep if year == 2021 | year == 2022
	reghdfe lf_to_nlf treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store d
restore

*export results to document:
#delimit;
esttab a b c d using "$tables/table4.rtf", replace
nodepvar nonumbers label collabels(none) noobs legend 
title({\b Table 4.} {\i ATE: Probability of Job Keeping & LF Exit})
mtitle("Job K. 2019-2020" "LF Exit 2019-2020" "Job K. 2021-2022" "LF Exit 2021-2022")
b(%9.3f) se(%9.3f) 
varlabels(
treat_2019 "Education_2019"
treat_2021 "Education_2021"
_cons "Constant" 
)
drop(*0.* *female* *age* *married* *race* *kids* *inc_q* *education* *onet_wfh* *fam_size* *wfh2021* *wfh2019*,relax)substitute(\_ _)
scalar(
"N Observations"
)
sfmt(%9.0fc %9.0fc %9.3f)
note("All columns include state-year and industry-year FE. All columns include a set of controls as described in section 3.6. Standard errors clustered at the occupation-year level.")
;
#delimit cr

****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
/* Table 5 */ 

/* Employment flows: 2019-2020*/
preserve
	keep if year == 2019 | year == 2020
	reghdfe emp_to_emp treat_2019 female i.female#c.treat_2019 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store a
restore

/* LF flows: 2019-2020*/
preserve
	keep if year == 2019 | year == 2020
	reghdfe lf_to_nlf treat_2019 female i.female#c.treat_2019 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store b
restore

/* Employment flows: 2021-2022*/
preserve
	keep if year == 2021 | year == 2022
	reghdfe emp_to_emp treat_2021 female i.female#c.treat_2021 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021  [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store c
restore

/* LF flows: 2021-2022*/
preserve
	keep if year == 2021 | year == 2022
	reghdfe lf_to_nlf treat_2021 female i.female#c.treat_2021 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year) 
	estimates store d
restore

*export results to document:
#delimit;
esttab a b c d using "$tables/table5.rtf", replace
nodepvar nonumbers label collabels(none) noobs legend 
title({\b Table 5.} {\i HTE: Probability of Job Keeping & LF Exit})
mtitle("Job K. 2019-2020" "LF Exit 2019-2020" "Job K. 2021-2022" "LF Exit 2021-2022")
b(%9.3f) se(%9.3f) 
varlabels(
treat_2019 "Education_2019"
treat_2021 "Education_2021"
i.female#c.treat_2021 "Education*Female"
i.female#c.treat_2019 "Education*Female"
_cons "Constant" 
)
drop(*0.* *age* *married* *race* *kids* *inc_q* *education* *onet_wfh* *fam_size* *wfh2021* *wfh2019*,relax)substitute(\_ _)
scalar(
"N Observations"
)
sfmt(%9.0fc %9.0fc %9.3f)
note("All columns include state-year and industry-year FE. All columns include a set of controls as described in section 3.6. Standard errors clustered at the occupation-year level.")
;
#delimit cr

****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
/* Table 6 */ 

/* Job keeping: 2019-2020  */
preserve
	keep if year == 2019 | year == 2020
	reghdfe emp_to_emp treat_2019 female kids fam_size child_under_8 i.female#c.treat_2019 i.female#c.child_under_8 c.treat_2019#c.child_under_8 i.female#c.child_under_8#c.treat_2019 age married i.race ib5.inc_q i.education onet_wfh wfh2019 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store a
restore

/* LF Flows: 2019-2020  */
preserve
	keep if year == 2019 | year == 2020
	reghdfe lf_to_nlf treat_2019 female kids fam_size child_under_8 i.female#c.treat_2019 i.female#c.child_under_8 c.treat_2019#c.child_under_8 i.female#c.child_under_8#c.treat_2019 age married i.i.race ib5.inc_q i.education onet_wfh wfh2019 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store b
restore

/*  Job keeping: 2021-2022*/
preserve
	keep if year == 2021 | year == 2022
	reghdfe emp_to_emp treat_2021 female kids fam_size child_under_8 i.female#c.treat_2021 i.female#c.child_under_8 c.treat_2021#c.child_under_8 i.female#c.child_under_8#c.treat_2021 age married i.race ib5.inc_q i.education wfh2021 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store c
restore

/* LF flows: 2021-2022*/
preserve
	keep if year == 2021 | year == 2022
	reghdfe lf_to_nlf treat_2021 female kids fam_size child_under_8 i.female#c.treat_2021 i.female#c.child_under_8 c.treat_2021#c.child_under_8 i.female#c.child_under_8#c.treat_2021 age married i.race ib5.inc_q i.education onet_wfh wfh2021 [aw=weight] , absorb(Istate_year inaics2_year) cluster(iocc2_year)
	estimates store d
restore


*export results to document:
#delimit;
esttab a b c d using "$tables/table_6.rtf", replace
nodepvar nonumbers label collabels(none) noobs legend 
title({\b Table 6.} {\i HTE: Differential Impact of Having Children Under Eight})
mtitle("Job K.19" "LF Exit.19" "Job K.21" "LF Exit.21")
b(%9.3f) se(%9.3f) 
varlabels(
treat_2019 "Education_2019"
treat_2021 "Education_2021"
i.female#c.treat_2021 "Education*Female"
i.female#c.treat_2019 "Education*Female"
i.female#c.child_under_8 "Female*Child"
c.treat_2021#c.child_under_8 "Education*Child"
i.female#c.child_under_8#c.treat_2021 "Education*Female*Child"
_cons "Constant" 
)
drop(*0.* *age* *married* *race* *ib1.female#c.treat_2021* *ib1.female#c.child_under_8* *ib1.female#c.child_under_8#c.treat_2021* *kids* *inc_q* *education* *onet_wfh* *fam_size* *wfh2021* *wfh2019*,relax)substitute(\_ _)
scalar(
"N Observations"
)
sfmt(%9.0fc %9.0fc %9.3f)
note("All columns include state-year and industry-year FE. All columns include a set of controls as described in section 3.6. Standard errors clustered at the occupation-year level.")
;
#delimit cr
