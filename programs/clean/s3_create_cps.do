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
/* import 2019 cps data */
import delimited "$cps/nov19pub.csv", clear

*Keep variables of interest 
keep hrhhid hryear4 hrmonth gereg gtmetsta prtage pemaritl pesex peeduca ptdtrace ptdtrace prcitshp prcitshp puretot pemlr pudis pehrusl1 pehrusl1 pehrusl2 pehrftpt pehrrsn2 prcivlf hetvbox pevideo peedtrai hepscon2 hepscon1 henotv1 pruntype prdtocc1 prdtocc2 prdtind1 peio1icd pwsswgt hrintsta prpertyp prempnot hefaminc gcfip hrintsta prpertyp prfamrel prfamtyp hrhtype
save "$cps/cps_2019.dta", replace

/* import 2021 cps data */
import delimited "$cps/nov21pub.csv", clear

rename gestfips gcfip
keep hrhhid hryear4 hrmonth gereg gtmetsta prtage pemaritl pesex peeduca ptdtrace ptdtrace prcitshp prcitshp puretot pemlr pudis pehrusl1 pehrusl1 pehrusl2 pehrftpt pehrrsn2 prcivlf hetvbox pevideo peedtrai hepscon2 hepscon1 henotv1 pruntype prdtocc1 prdtocc2 prdtind1 peio1icd pwsswgt prempnot hefaminc gcfip pxedtrai hrintsta prpertyp prfamrel prfamtyp hrhtype
append using "$cps/cps_2019.dta"

*******
**(1)**
*******
/*pemlr: MONTHLY LABOR FORCE RECODE 
1 EMPLOYED-AT WORK
2 EMPLOYED-ABSENT
3 UNEMPLOYED-ON LAYOFF
4 UNEMPLOYED-LOOKING
5 NOT IN LABOR FORCE-RETIRED
6 NOT IN LABOR FORCE-DISABLED
7 NOT IN LABOR FORCE-OTHER
*/
*response of -1 is "blank".
/*PRUNTYPE: REASON FOR UNEMPLOYMENT
1 JOB LOSER/ON LAYOFF
2 OTHER JOB LOSER
3 TEMPORARY JOB ENDED
4 JOB LEAVER
5 RE-ENTRANT
6 NEW-ENTRANT
*/

/* Interview characteristics */
rename hrintsta interview_status
rename prpertyp interview_person
rename hrmonth interview_month
rename prfamrel interview_responder
rename prfamtyp family_type 
rename hrhtype household_type

*keeping valid interview status and adult civial HH members. 
keep if interview_status == 1 
keep if interview_person == 2 

*keeping primary family units
*keep if family_type == 1

*keeping reliable HH types
keep if inlist(household_type,1,3,4,6,7)

*restrictions
rename gcfip state
tostring state, gen(state_str)
rename hryear4 year
rename prtage age 
keep if age >= 16

drop if peedtrai == -1 

*drop faulty responses for monthly labor force recode.
drop if pemlr == -1

*gen employed
gen employed = 1 if pemlr==1 | pemlr==2
replace employed = 0 if employed == .

*gen unemployed
gen unemployed = 1 if pemlr==3 | pemlr==4
replace unemployed = 0 if unemployed == .

/* Control */ 
generate control = employed

/* Treatment 1: Involuntary workforce exit */ 
generate treatment1 = 0 
replace treatment1 = 1 if pruntype == 1 | pruntype == 2 
tab treatment1 

/*Treatment 2: Voluntary workforce exit */ 
generate treatment2 = 0 
replace treatment2= 1 if pruntype == 3 | pruntype ==4 
tab treatment2 

/*Treatment 3: Entrant */
generate treatment3 = 0 
replace treatment3= 1 if pruntype == 5 | pruntype == 6
tab treatment3 

*Note pxedtrai is only available starting in 2021. 
/*Subscription to educational content*/ 
generate educ_content = 0 
replace educ_content = 1 if peedtrai == 1 
*| pxedtrai == 1 

*checking control and treatment groups: 
foreach x in control unemployed treatment1 treatment2 treatment3 educ_content  {
	tab `x'
}

foreach x in control unemployed treatment1 treatment2 treatment3 educ_content { 
	tab `x' year
}

*UER: 3.3% pre-covid and 3.8% post covid.

*******
**(2)**
*******
*covariate recode:

/*Time trend */ 
generate y2021 = 0 
replace y2021 = 1 if year == 2021

/*Demographic */ 
//1/ Region: 1-Northeast , 2-Midwest , 3-South, 4-West
	generate region = gereg
//2/ Marial status: married
	generate married =0 
	replace married = 1 if pemaritl == 1 | pemaritl == 2
//3/ Gender: Male binary
	generate male = 0 
	replace male = 1 if pesex == 1 
//4/ Education status: 1-less than high school, 2-hs diploma, 3-associate degree, 4-bacherlor degree, 5-graduate school 
	generate educ= 1 
	replace educ= 1 if peeduca == 31 | peeduca == 32 | peeduca == 33 | peeduca == 34 | peeduca == 35 | peeduca == 36 | peeduca == 37 | peeduca == 38 
	replace educ= 2 if peeduca == 39 | peeduca == 40 
	replace educ= 3 if peeduca == 41 | peeduca == 42 
	replace educ= 4 if peeduca == 43 
	replace educ= 5 if peeduca == 44 | peeduca == 45 | peeduca == 46 
	tab educ 
//5/ Race: 1-white, 2-black, 3-asian, 4-others and NA 
	generate race = 0
	replace race = 1 if ptdtrace == 1 
	replace race = 2 if ptdtrace == 2
	replace race = 3 if ptdtrace == 4
	replace race = 4 if inlist(ptdtrace,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26)
	tab race 
	
	generate white = 0 
	replace white = 1 if race ==1 
	
	generate black = 0 
	replace black = 1 if race ==2 

//Type of workers: 
gen blue_collar = 1 if inlist(prdtocc1,13,14,15,18,19,20,21,22)
replace blue_collar = 0 if blue_collar == .

gen white_collar = 1 if inlist(prdtocc1,1,2,3,4,5,6,7,8,9,10,11,12,16,17)
replace white_collar = 0 if white_collar == . 
		
*HDFE group variables
tostring prdtind1, replace
gen naics2 = substr(prdtind1,1,2)

egen iregion = group(region)
egen inaics2 = group(naics2)
egen ieducation = group(educ)
egen irace = group(race)
egen iincome = group(hefaminc)
egen occ2 = group(prdtocc1)
egen istate = group(state)

*recode income
gen hh_inc = 0 
replace hh_inc = 1 if inlist(iincome,1,2,3,4,5,6)
*replace hh_inc = 2 if inlist(income,4,5,6)
replace hh_inc = 2 if inlist(iincome,7,8)
replace hh_inc = 3 if inlist(iincome,9,10)
replace hh_inc = 4 if inlist(iincome,11)
replace hh_inc = 5 if inlist(iincome,12)
replace hh_inc = 6 if inlist(iincome,13)
replace hh_inc = 7 if inlist(iincome,14)
replace hh_inc = 8 if inlist(iincome,15,16)

rename pemlr lf_status 

*save data that will be used for descriptive analysis:
save "$cps/cps_descriptives.dta", replace

/* Drop not in labor force */ 
drop if lf_status==5 | lf_status==6 | lf_status==7

*keeping only variables of interest. 
keep hrhhid interview_month year employed unemployed control treatment1 treatment2 treatment3 educ_content y2021 region married male educ race white black naics2 iregion inaics2 ieducation irace iincome occ2 prdtocc1 pwsswgt state state_str istate white_collar blue_collar hh_inc age lf_status


*check for missing values
mdesc

*merge in online education shares by 2-digit occupation
tostring occ2, replace
merge m:1 occ2 using "$cps/cps_occupation_educ", keep(3) nogen

*save as clean dataset
save "$cps/cps_clean_25march2024.dta", replace
