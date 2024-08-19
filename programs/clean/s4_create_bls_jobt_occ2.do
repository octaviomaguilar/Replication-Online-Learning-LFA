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
import excel "/mq/scratch/m1oma00/oma_projects/replication_educ_lfp_oma/data/bls/education_2021.xlsx", sheet("Table 5.4") firstrow

gen occ2 = substr(B,1,2)
drop if occ2 == ""
rename NationalEmploymentMatrix title

gen none = 1 if Typicalonthejobtrainingneed == "None"
gen short_term = 1 if Typicalonthejobtrainingneed == "Short-term on-the-job training"
gen moderate_term = 1 if Typicalonthejobtrainingneed == "Moderate-term on-the-job training"
gen long_term = 1 if Typicalonthejobtrainingneed == "Long-term on-the-job training"

gen any_term = 1 if Typicalonthejobtrainingneed == "Short-term on-the-job training" | Typicalonthejobtrainingneed == "Moderate-term on-the-job training" | Typicalonthejobtrainingneed == "Long-term on-the-job training"

foreach x in short_term moderate_term long_term any_term none{
	replace `x' = 0 if `x' == .
}

gen education = . 
replace education = 1 if Typicaleducationneededforent == "High school diploma or equivalent" | Typicaleducationneededforent == "No formal educational credential"
replace education = 2 if Typicaleducationneededforent == "Postsecondary nondegree award" | Typicaleducationneededforent == "Some college, no degree"
replace education = 3 if Typicaleducationneededforent == "Associate's degree"
replace education = 4 if Typicaleducationneededforent == "Bachelor's degree"
replace education = 5 if Typicaleducationneededforent == "Doctoral or professional degree" | Typicaleducationneededforent == "Master's degree"

gen attainment = . 
replace attainment = 1 if education == 1 | education == 2 | education == 3
replace attainment = 2 if education == 4 | education == 5

*******
**(2)**
*******
preserve
	collapse (mean) short_term, by(occ2)
	rename short_term short_term_occ2
	tempfile f
	save `f', replace
restore

merge m:1 occ2 using `f', keep(3) nogen

preserve
	collapse (mean) moderate_term, by(occ2)
	rename moderate_term moderate_term_occ2
	tempfile f
	save `f', replace
restore

merge m:1 occ2 using `f', keep(3) nogen

preserve
	collapse (mean) long_term, by(occ2)
	rename long_term long_term_occ2
	tempfile f
	save `f', replace
restore

merge m:1 occ2 using `f', keep(3) nogen

preserve
	collapse (mean) none, by(occ2)
	rename none none_occ2
	tempfile f
	save `f', replace
restore

merge m:1 occ2 using `f', keep(3) nogen

preserve
	collapse (mean) any_term , by(occ2)
	rename any_term any_term_occ2
	tempfile f
	save `f', replace
restore

*******
**(3)**
*******
keep occ2 short_term_occ2 moderate_term_occ2 long_term_occ2 none_occ2
duplicates drop
rename occ2 oes_occ 

merge 1:1 oes_occ using "$crosswalk/occxwalk.dta", keep(3) keepusing(title) nogen
rename oes_occ occ2 

*merge in any term late to avoid duplicates issue
merge m:1 occ2 using `f', keep(3) nogen

*save 2021 training assingment data
save "$bls/bls_training_assignment_2021.dta", replace

*******
**(4)**
*******
*checking the distribution across term lengths: NOT included in the paper. 
graph hbar (mean) short_term, over(title,sort(short_term) descending) bar(1, color(blue)) ///
yline(0.22, lcolor(red)) ///
ytitle("Weighted Proportion, %") ///
blabel(bar, format(%3.2f)) 

graph hbar (mean) moderate_term_occ2, over(title,sort(moderate_term_occ2) descending) bar(1, color(blue)) ///
yline(0.22, lcolor(red)) ///
ytitle("Weighted Proportion, %") ///
blabel(bar, format(%3.2f)) 

graph hbar (mean) long_term_occ2, over(title,sort(long_term_occ2) descending) bar(1, color(blue)) ///
yline(0.22, lcolor(red)) ///
ytitle("Weighted Proportion, %") ///
blabel(bar, format(%3.2f)) 

graph hbar (mean) none_occ2, over(title,sort(none_occ2) descending) bar(1, color(blue)) ///
yline(0.3445122, lcolor(red)) ///
ytitle("Proportion, %") ///
blabel(bar, format(%3.2f)) 

graph hbar (mean) any_term_occ2, over(title,sort(any_term_occ2) descending) bar(1, color(blue)) ///
yline(0.6554878, lcolor(red)) ///
ytitle("Proportion, %") ///
blabel(bar, format(%3.2f)) 

