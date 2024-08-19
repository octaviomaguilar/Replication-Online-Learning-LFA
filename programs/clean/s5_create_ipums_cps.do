cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/replication_educ_lfp_oma"
global data "$home/data"
global cps "$data/cps"
global bls "$data/bls"
global crosswalk "$data/crosswalks"
global ipums "$data/ipums_cps"

use "$ipums/cps_00005.dta", clear

*drop information we don't need
drop cpsid month_1 month_2 asecflag_1 asecflag_2 pernum_1 pernum_2 cpsidv_1 cpsidv_2 cpsidp kidcneed_1 kidcneed_2 ftotval_1 ftotval_2 inctot_1 inctot_2 indly_2 indly_1 occly_2 occly_1 asecoverp_2 asecoverp_1 classwly_1 classwly_2 classwkr_1 classwkr_2 relate_1 popstat_1 incwage_2 ind_2 famsize_2 yngch_2 eldch_2

*******
**(1)**
*******
*set age restrictions. Note, results are robust to a non-restricted sample as well. 
drop if age_1 < 16 | age_1 > 54
gen year = year_1

*drop top coded income 
drop if hhincome_1 >= 3299997

*cleaning occupation and industry information
foreach x in occ_1 ind_1 {
	tostring `x', replace
	drop if `x' == "0"
}
replace ind_1 = substr(ind_1,1,3)
*convert 2010 IPUMS occ to 2018 IPUMS occ 
merge m:1 occ_1 using "$crosswalk/update_occ1.dta", keepusing(temp)
replace occ_1 = temp if _m == 3
drop _m temp

*merge in 2018 IPUMS occ to 2018 OCC SOC crosswalk
merge m:1 occ_1 using "$crosswalk/ipums_occsoc_xwalk.dta", keep(3) keepusing(SOC2018) nogen
drop occ_1

*create occ2 to be the first two strings of OCC-SOC
gen occ2 = substr(SOC2018,1,2)

*merge in online education shares by 2-digit occupation
merge m:1 occ2 using "$cps/cps_occupation_educ", keep(3) nogen

*merge in dingel & nieman (2020) wfh difficulty by 2-digit occupation
merge m:1 occ2 using "$data/wfh/onet_dingel_wfhdiff.dta", keep(3) nogen

gen state = statefip_1
tostring state, replace

*merge in state crosswalk to get two letter FIPS
tostring state, replace
replace state = "0" + state if length(state) == 1
merge m:1 state using "$crosswalk/state_xwalk.dta", keep(3) nogen
rename temp state_str

*merge in naics xwalk
merge m:1 ind_1 using "$crosswalk/ipums_cps_naics_xwalk.dta", keep(3) nogen
drop ind_1

*******
**(2)**
*******
*cleaning general demographic questions
gen age = age_1
gen ln_wage = ln(incwage_1)
replace ln_wage = 0 if ln_wage == . 
rename incwage_1 wage

*create a post-pandemic dummy
gen pandemic = 1 if year >= 2020
replace pandemic = 0 if pandemic == .

gen female = 1 if sex_1 == 2
replace female = 0 if female == .

gen male = 1 if sex_1 == 1
replace male = 0 if male == . 

gen married = 1 if inlist(marst_1,1,2)
replace married = 0 if inlist(marst_1,3,4,5,6)

gen race = 1 if race_1 == 100
replace race = 2 if race_1 == 200 
replace race = 3 if race_1 == 651
replace race = 4 if inlist(race_1,652,300,801,802,803,804,805,806,807,808,809,810,811,812,813,814,816,817,819,820,830)

gen education = 0
replace education = 1 if inlist(educ_1,40,60,20,50,30,2,10,71)
replace education = 2 if inlist(educ_1,73,81)
replace education = 3 if inlist(educ_1,91,92)
replace education = 4 if inlist(educ_1,111)
replace education = 5 if inlist(educ_1,123,124)
replace education = 6 if inlist(educ_1,125)

egen ieducation = group(educ_1)
egen inaics2 = group(naics2)
egen istate = group(statefip_1)
egen ichild = group(nchild_1)
gen income = hhincome_1
gen weight = asecwt_1
gen kids = nchild_1
gen fam_size = famsize_1
gen youngest_child = yngch_1
replace youngest_child = 1 if youngest_child == 0 
replace youngest_child = 0 if youngest_child == 99
gen eldest_child = eldch_1
replace eldest_child = 1 if eldest_child == 0 
replace eldest_child = 0 if eldest_child == 99

*creating income quintiles
xtile inc_q = income, nq(5)

*creating fixed effects
egen Istate_year = group(statefip_1 year)
egen inaics2_year = group(naics2 year)
egen iocc2_year = group(occ2 year)
egen istate_naics2 = group(naics2 statefip_1)

*female pandemic interaction
gen female_pandemic = female*pandemic 
gen male_pandemic = male*pandemic

*generate child under the age of 1 through 16
forval i = 2/16 {
	gen child_under_`i' = 1 if eldest_child < `i' & eldest_child > 0
	replace child_under_`i' = 0 if eldest_child == 0
}

*********
**(2.1)**
*********
*creating different inflow and outflow groups. The base group is those which whom the status did not change. 
/* Employment flows */
*1.) from employed to unemploye(base group are those employed in both periods)
gen emp_to_unemp = 1 if empstat_1 == 10 & empstat_2 == 21
replace emp_to_unemp = 0 if empstat_1 == 10 & empstat_2 == 10

*2.) from unemployed to employed (base group are those unemployed in both periods)
gen unemp_to_emp = 1 if empstat_1 == 21 & empstat_2 == 10
replace unemp_to_emp = 0 if empstat_1 == 21 & empstat_2 == 21

*3.) from employed to employed (retained employment) (base group are those who change employment or labor market status in the second period)
gen emp_to_emp = 1 if empstat_1 == 10 & empstat_2 == 10 
replace emp_to_emp = 0 if empstat_1 == 10 & empstat_2 == 21 | labforce_2 == 1 

*4.) from unemployed to exiting the labor force (base group are those unemployed in both periods )
gen unemp_to_nlf = 1 if empstat_1 == 21 & labforce_2 == 1 
replace unemp_to_nlf = 0 if empstat_1 == 21 & empstat_2 == 21

*********
**(2.2)**
*********
/* Labor force flows */
*1.) from out of labor force to into the labor force (base group are those not in the labor force in both periods)
gen nlf_to_lf = 1 if labforce_1 == 1 & labforce_2 == 2 
replace nlf_to_lf = 0 if labforce_1 == 1 & labforce_2 == 1 

*2.) from in the labor force to out of the labor force (base group are those in the labor force in both periods)
gen lf_to_nlf = 1 if labforce_1 == 2 & labforce_2 == 1
replace lf_to_nlf = 0 if labforce_1 == 2 & labforce_2 == 2

*********
**(2.3)**
*********
/* Employment flows for specific unemployment groups*/

*1.) from employed to laid off (base group are those employed in both periods)
gen emp_to_involuntary = 1 if empstat_1 == 10 & inlist(whyunemp_2,1,2,3)
replace emp_to_involuntary = 0 if empstat_1 == 10 & empstat_2 == 10

*2.) from employed to quit (base group are those employed in both periods)
gen emp_to_voluntary = 1 if empstat_1 == 10 & whyunemp_2 == 4
replace emp_to_voluntary = 0 if empstat_1 == 10 & empstat_2 == 10

*3.) from laid off to employed (base group are those who inv. exit in both periods)
gen involuntary_to_emp = 1 if inlist(whyunemp_1,1,2,3) & empstat_2 == 10
replace involuntary_to_emp = 0 if inlist(whyunemp_1,1,2,3) & inlist(whyunemp_2,1,2,3)

*4.) from quit to employed (base group are those vol. exit in both periods)
gen voluntary_to_emp = 1 if whyunemp_1 == 4 & empstat_2 == 10
replace voluntary_to_emp = 0 if whyunemp_1 == 4 & whyunemp_2 == 4

*5.) from re-entrant to employed  (base group are those who are entrants in both periods)
gen entrant_to_emp = 1 if whyunemp_1 == 5 & empstat_2 == 10
replace entrant_to_emp = 0 if whyunemp_1 == 5 & whyunemp_2 == 5

*save as a full dataset 2017-2022. 
save "$ipums/ipums_clean_2017_2022.dta", replace

*********
**(2.4)**
*********
*creating a 2019-2022 dataset:
keep if year >= 2019 

*creating online education quintiles: 2019 and 2021
xtile quartile = online_educ2021, nq(4)

xtile quartile_2019 = online_educ2019, nq(4)
xtile quartile_2021 = online_educ2021, nq(4)

*creating treatment groups to be above the median quartile of online education:
gen treat_2019 = 1 if inlist(quartile_2019,3,4)
replace treat_2019 = 0 if inlist(quartile_2019,1,2)

gen treat_2021 = 1 if inlist(quartile_2021,3,4)
replace treat_2021 = 0 if inlist(quartile_2021,1,2)

*merge in lightcast data
merge m:1 occ2 using "$data/wfh/lightcast_telework.dta", keep(3) nogen

*merge in work-from-home by 2-digit occupation
merge m:1 occ2 using "$data/wfh/acs_wfh.dta", keep(3) nogen

*saving the dataset
save "$ipums/ipums_cps_clean_25march2024.dta", replace
