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
*Appendix table 1:
/* Employment flows: 2019*/
preserve
	keep if year == 2019
	reg emp_to_emp treat_2019 female age married i.i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight]
	estimates store a
restore

/* Employment flows: 2020*/
preserve
	keep if year == 2020
	reg emp_to_emp treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight]
	estimates store b
restore

/* Employment flows: 2021*/
preserve
	keep if year == 2021 
	reg emp_to_emp treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight]
	estimates store c
restore

/* Employment flows: 2022*/
preserve
	keep if year == 2022
	reg emp_to_emp treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight]
	estimates store d	
restore

/* LF flows: 2019*/
preserve
	keep if year == 2019 
	reg lf_to_nlf treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019[aw=weight]
	estimates store e
restore

/* LF flows: 2020*/
preserve
	keep if year == 2020
	reg lf_to_nlf treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019[aw=weight]
	estimates store f
restore

/* LF flows: 2021*/
preserve
	keep if year == 2021 
	reg lf_to_nlf treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight]
	estimates store g
restore

/* LF flows: 2022*/
preserve
	keep if year == 2022
	reg lf_to_nlf treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight]
	estimates store h
restore

*export results to document:
#delimit;
esttab a b c d e f g h using "$tables/appendix_tableA1.rtf", replace
nodepvar nonumbers label collabels(none) noobs legend 
title({\b Table A1.} {\i ATE: Probability of Job Keeping & LF Exit})
mtitle("Job K.19" "Job K.20" "Job K.21" "Job K.22" "LF Exit.19" "LF Exit.20" "LF Exit.21" "LF Exit.22")
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
note("All columns include a set of controls as described in section 3.6.")
;
#delimit cr

****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
*Appendix table 2:
/* Employment flows: 2019*/
preserve
	keep if year == 2019
	reg emp_to_emp treat_2019 female
	estimates store a 
	reg emp_to_emp treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight]
	estimates store b
	reg emp_to_emp treat_2019 female i.female#c.treat_2019 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight] 
	estimates store c 
restore

/* Employment flows: 2020*/
preserve
	keep if year == 2020
	reg emp_to_emp treat_2019 female
	estimates store d
	reg emp_to_emp treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019 [aw=weight]
	estimates store e
	reg emp_to_emp treat_2019 female i.female#c.treat_2019 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019[aw=weight] 
	estimates store f
restore

/* Employment flows: 2021*/
preserve
	keep if year == 2021 
	reg emp_to_emp treat_2021 female
	estimates store g
	reg emp_to_emp treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight]
	estimates store h
	reg emp_to_emp treat_2021 female i.female#c.treat_2021 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021[aw=weight] 
	estimates store i
restore

/* Employment flows: 2022*/
preserve
	keep if year == 2022
	reg emp_to_emp treat_2021 female
	estimates store j
	reg emp_to_emp treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight]
	estimates store k
	reg emp_to_emp treat_2021 female i.female#c.treat_2021 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021[aw=weight] 
	estimates store l
restore

*export results to document:
#delimit;
esttab a b c d e f g h i j k l using "$tables/appendix_tableA2.rtf", replace
nodepvar nonumbers label collabels(none) noobs legend 
title({\b Table A2.} {\i ATE: Probability of Job Keeping})
mtitle("Job K.19a" "Job K.19b" "Job K.19c" "Job K.20a" "Job K.20b" "Job K.20c" "Job K.21a" "Job K.21b" "Job K.21c" "Job K.22a" "Job K.22b" "Job K.22c")
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
note("All columns include a set of controls as described in section 3.6.")
;
#delimit cr

****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
*Appendix table 3:

/* LF flows: 2019*/
preserve
	keep if year == 2019 
	reg lf_to_nlf treat_2019 female
	estimates store a
	reg lf_to_nlf treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019[aw=weight]
	estimates store b
	reg lf_to_nlf treat_2019 female i.female#c.treat_2019 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019[aw=weight] 
	estimates store c
restore

/* LF flows: 2020*/
preserve
	keep if year == 2020
	reg lf_to_nlf treat_2019 female
	estimates store d
	reg lf_to_nlf treat_2019 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019[aw=weight]
	estimates store e
	reg lf_to_nlf treat_2019 female i.female#c.treat_2019 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2019[aw=weight] 
	estimates store f
restore

/* LF flows: 2021*/
preserve
	keep if year == 2021 
	reg lf_to_nlf treat_2021 female
	estimates store g
	reg lf_to_nlf treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021 [aw=weight]
	estimates store h
	reg lf_to_nlf treat_2021 female i.female#c.treat_2021 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021[aw=weight] 
	estimates store i
restore

/* LF flows: 2022*/
preserve
	keep if year == 2022
	reg lf_to_nlf treat_2021 female
	estimates store j
	reg lf_to_nlf treat_2021 female age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size [aw=weight]
	estimates store k
	reg lf_to_nlf treat_2021 female i.female#c.treat_2021 age married i.race c.kids ib5.inc_q i.education onet_wfh fam_size wfh2021[aw=weight] 
	estimates store l
restore

*export results to document:
#delimit;
esttab a b c d e f g h i j k l using "$tables/appendix_tableA3.rtf", replace
nodepvar nonumbers label collabels(none) noobs legend 
title({\b Table A3.} {\i HTE: Probability of LF Exit})
mtitle("LF Exit.19a" "LF Exit.19b" "LF Exit.19c" "LF Exit.20a" "LF Exit.20b" "LF Exit.20c" "LF Exit.21a" "LF Exit.21b" "LF Exit.21c" "LF Exit.22a" "LF Exit.22b" "LF Exit.22c")
b(%9.3f) se(%9.3f) 
varlabels(
treat_2019 "Education_2019"
treat_2021 "Education_2021"
i.female#c.treat_2021 "Education*Female"
i.female#c.treat_2019 "Education*Female"
_cons "Constant" 
)
drop(*0.* *age* *married* *ib1.female#c.treat_2021* *race* *kids* *inc_q* *education* *onet_wfh* *fam_size* *wfh2021* *wfh2019*,relax)substitute(\_ _)
scalar(
"N Observations"
)
sfmt(%9.0fc %9.0fc %9.3f)
note("All columns include a set of controls as described in section 3.6.")
;
#delimit cr

****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
*Appendix table 4:
preserve
	keep if year == 2019
	reg emp_to_emp treat_2019 female kids fam_size child_under_8 i.female#c.treat_2019 i.female#c.child_under_8 c.treat_2019#c.child_under_8 i.female#c.child_under_8#c.treat_2019 age married i.race ib5.inc_q i.education onet_wfh wfh2019 [aw=weight] 
	estimates store a
restore

/* Employment flows: 2020*/
preserve
	keep if year == 2020
	reg emp_to_emp treat_2019 female kids fam_size child_under_8 i.female#c.treat_2019 i.female#c.child_under_8 c.treat_2019#c.child_under_8 i.female#c.child_under_8#c.treat_2019 age married i.race ib5.inc_q i.education onet_wfh wfh2019 [aw=weight] 
	estimates store b
restore

/* Employment flows: 2021*/
preserve
	keep if year == 2021
	reg emp_to_emp treat_2021 female kids fam_size child_under_8 i.female#c.treat_2021 i.female#c.child_under_8 c.treat_2021#c.child_under_8 i.female#c.child_under_8#c.treat_2021 age married i.race ib5.inc_q i.education onet_wfh wfh2021 [aw=weight] 
	estimates store c
restore

/* Employment flows: 2022*/
preserve
	keep if year == 2022
	reg emp_to_emp treat_2021 female kids fam_size child_under_8 i.female#c.child_under_8 i.female#c.treat_2021 c.treat_2021#c.child_under_8 i.female#c.child_under_8#c.treat_2021 age married i.race ib5.inc_q i.education onet_wfh wfh2021 [aw=weight] 
	estimates store d
restore

*export results to document:
#delimit;
esttab a b c d using "$tables/appendix_tableA4.rtf", replace
nodepvar nonumbers label collabels(none) noobs legend 
title({\b Table A4.} {\i ATE: Probability of Job Keeping})
mtitle("Job K.19" "Job K.20" "Job K.21" "Job K.22")
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
note("All columns include a set of controls as described in section 3.6.")
;
#delimit cr


****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************************
*Appendix table 5:
/* LF flows: 2019*/
preserve
	keep if year == 2019
	reg lf_to_nlf treat_2019 female kids fam_size child_under_8 i.female#c.treat_2019 i.female#c.child_under_8 c.treat_2019#c.child_under_8 i.female#c.child_under_8#c.treat_2019 age married i.race ib5.inc_q i.education onet_wfh [aw=weight] 
	estimates store a
restore

/* LF flows: 2020*/
preserve
	keep if year == 2020
	reg lf_to_nlf treat_2019 female kids fam_size child_under_8 i.female#c.treat_2019 i.female#c.child_under_8 c.treat_2019#c.child_under_8 i.female#c.child_under_8#c.treat_2019 age married i.race ib5.inc_q i.education onet_wfh [aw=weight] 
	estimates store b
restore

/* LF flows: 2021*/
preserve
	keep if year == 2021
	reg lf_to_nlf treat_2021 female kids fam_size child_under_8 i.female#c.treat_2021 i.female#c.child_under_8 c.treat_2021#c.child_under_8 i.female#c.child_under_8#c.treat_2021 age married i.race ib5.inc_q i.education onet_wfh  [aw=weight] 
	estimates store c
restore

/* LF flows: 2022*/
preserve
	keep if year == 2022
	reg lf_to_nlf treat_2021 female kids fam_size child_under_8 i.female#c.treat_2021 i.female#c.child_under_8 c.treat_2021#c.child_under_8 i.female#c.child_under_8#c.treat_2021 age married i.race ib5.inc_q i.education onet_wfh  [aw=weight] 
	estimates store d
restore

*export results to document:
#delimit;
esttab a b c d using "$tables/appendix_tableA5.rtf", replace
nodepvar nonumbers label collabels(none) noobs legend 
title({\b Table A5.} {\i ATE: Probability of LF Exit})
mtitle("LF Exit.19" "LF Exit.20" "LF Exit.21" "LF Exit.22")
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
note("All columns include a set of controls as described in section 3.6.")
;
#delimit cr
