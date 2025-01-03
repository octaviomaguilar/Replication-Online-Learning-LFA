cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/replication_educ_lfp_oma"
global data "$home/data"
global cps "$data/cps"
global bls "$data/bls"
global crosswalk "$data/crosswalks"
global ipums "$data/ipums_cps"

*******
**(1)**
*******
/* table 1: */ 
use "$cps/cps_descriptives.dta", clear
keep if age >16 & age < 55

*creating age quintiles
xtile age_quintile = age, nq(5)

*LF recode:
replace lf = 1 if lf == 1 | lf == 2
replace lf = 2 if lf == 3 | lf == 4
replace lf = 3 if inlist(lf,5,6,7)

*share of online education:
tab educ_content if year == 2019
tab educ_content if year == 2021
tab educ_content

*shares for all labor force statuses:
tab lf if educ_content == 1 & year == 2019
tab lf if educ_content == 1 & year == 2021
tab lf if educ_content == 1

*shares by age quintile
tab age_quintile if educ_content == 1 & year == 2019
tab age_quintile if educ_content == 1 & year == 2021
tab age_quintile if educ_content == 1

*shares by race
tab race if educ_content == 1 & year == 2019
tab race if educ_content == 1 & year == 2021
tab race if educ_content == 1

*shares by gender: in the paper it is reported as (1-male).
tab male if educ_content == 1 & year == 2019
tab male if educ_content == 1 & year == 2021
tab male if educ_content == 1 

*******
**(2)**
*******
/* table 2: */ 
use "$cps/cps_occupation_educ.dta", clear
keep title occ2 online_educ2019 online_educ2021 delta_educ
foreach x in online_educ2019 online_educ2021 delta_educ {
	replace `x' = `x'*100
}

format %9.3f online_educ2019 online_educ2021 delta_educ 
list, noobs abbreviate(12) sepby(occ2)

*******
**(3)**
*******
/* table 3: */ 
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

*column 1 table 3:
sum emp_to_emp
foreach x in age fam_size kids eldest_child education wage female married      {
	sum `x' if emp_to_emp == 1
}
tab race if emp_to_emp == 1 

*columns 2 table 3:
sum lf_to_nlf

foreach x in age fam_size kids eldest_child education wage female married      {
	sum `x' if lf_to_nlf == 1
}
tab race if lf_to_nlf == 1 


*column 3 table 3:
use "$ipums/ipums_cps_clean_job_switch.dta", clear
sum job_switcher

foreach x in age fam_size kids eldest_child education wage female married      {
	sum `x' if job_switcher == 1
}
tab race if job_switcher == 1 

