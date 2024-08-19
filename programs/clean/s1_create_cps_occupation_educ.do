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

drop if prdtocc1 == -1 | prdtocc1 == 23
drop if prdtocc1 == . 
keep if prtage >= 16 & prtage < 55
keep if prempnot == 1
drop if peedtrai == -1

gen employed =1 if prempnot==1
gen online_educ = peedtrai

*merge in occ cps to occ oes xwalk
tostring prdtocc1, gen(cps_occ)

merge m:1 cps_occ using "$crosswalk/occxwalk.dta"
drop _m 

gen occ2 = oes_occ
replace online_educ = 0 if online_educ == 2

collapse (mean) online_educ [aw=pwsswgt], by(occ2)
sort occ2

rename online_educ online_educ2019
tempfile educ2019
save `educ2019', replace

*2. 2021: employed
import delimited "$cps/nov21pub.csv", clear

drop if prdtocc1 == -1 | prdtocc1 == 23
drop if prdtocc1 == . 
keep if prtage >= 16 & prtage < 55
keep if prempnot == 1
drop if peedtrai == -1

gen online_educ = peedtrai

*merge in occ cps to occ oes xwalk
tostring prdtocc1, gen(cps_occ)

merge m:1 cps_occ using "$crosswalk/occxwalk.dta"
drop _m 

gen occ2 = oes_occ
replace online_educ = 0 if online_educ == 2

collapse (mean) online_educ [aw=pwsswgt], by(occ2)
sort occ2

*3. merge the two
rename online_educ online_educ2021
merge 1:1 occ2 using `educ2019'
drop _m
gen delta_educ = online_educ2021-online_educ2019
keep occ2 delta online_educ2021 online_educ2019

gen oes_occ = occ2
merge 1:1 oes_occ using "$crosswalk/occxwalk.dta"
drop oes_occ _m cps_occ

save "$cps/cps_occupation_educ.dta", replace
