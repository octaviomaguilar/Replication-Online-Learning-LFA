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
*Creating delta online training:

*1. 2019: employed
import delimited "$cps/nov19pub.csv", clear

drop if prdtind1 == -1 | prdtind1 == 52 | prdtind1 == .
keep if prtage >= 16 & prtage < 55
keep if prempnot == 1
drop if peedtrai == -1

gen employed =1 if prempnot==1
gen online_educ = 0 
replace online_educ = 1 if peedtrai == 1 

*merge in occ cps to occ oes xwalk
tostring prdtind1, gen(cps_naics)
tostring gcfip, gen(fips)
rename hryear4 year

merge m:1 cps_naics using "$crosswalk/cps_naics_xwalk.dta", keep(3) nogen

collapse (mean) online_educ [aw=pwsswgt], by(naics2 year)
sort naics2

rename online_educ naics2_online_educ2019
tempfile educ2019
save `educ2019', replace

*2. 2021: employed
import delimited "$cps/nov21pub.csv", clear

drop if prdtind1 == -1 | prdtind1 == 52 | prdtind1 == .
keep if prtage >= 16 & prtage < 55
keep if prempnot == 1
drop if peedtrai == -1

gen employed =1 if prempnot==1
gen online_educ = 0 
replace online_educ = 1 if peedtrai == 1 

*merge in occ cps to occ oes xwalk
tostring prdtind1, gen(cps_naics)
tostring gestfips, gen(fips)
rename hryear4 year

merge m:1 cps_naics using "$crosswalk/cps_naics_xwalk.dta", keep(3) nogen

collapse (mean) online_educ [aw=pwsswgt], by(naics2 year)
sort naics2

*3. merge the two
rename online_educ naics2_online_educ2021
merge 1:1 naics2 using `educ2019', keep(3) nogen

*merge in official naics titles
merge m:1 naics2 using "$crosswalk/cps_naics2_titles.dta", keep(3) nogen

drop year
gen delta_educ_naics = naics2_online_educ2021-naics2_online_educ2019

save "$cps/cps_naics2_educ.dta", replace
