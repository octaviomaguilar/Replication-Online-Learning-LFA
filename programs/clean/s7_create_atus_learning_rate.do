cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/replication_educ_lfp_oma"
global data "$home/data"
global cps "$data/cps"
global bls "$data/bls"
global crosswalk "$data/crosswalks"
global atus "$data/atus"
global figures "$home/figures"

*******
**(1)**
*******
/* create ATUS dataset for men who online learn */
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
**(2)**
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
**(3)**
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
	collapse (sum) education online_educ_atus [fw=wt20], by(year)
	tempfile 2020
	save `2020', replace
restore
	
collapse (sum) education online_educ_atus [fw=wt06], by(year)
append using `2020'

gen online_educ_rate = online_educ_atus/ education

sort year 

keep year  online_educ_rate
rename online_educ_rate online_total

save "$atus/atus_educ_total_year.dta", replace


