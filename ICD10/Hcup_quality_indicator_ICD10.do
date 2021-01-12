capture program drop quality 
program quality

local keep KEY DSHOSPID HOSPID DRG MDC FEMALE SEX AGE RACE RACE_X YEAR DQTR PAY1  			///
DISPUNIFORM PointOfOriginUB04 I10_DX1 I10_DX2 I10_DX3 I10_DX4 I10_DX5      			///
I10_DX6 I10_DX7 I10_DX8 I10_DX9 I10_DX10 I10_DX11 I10_DX12 I10_DX13 I10_DX14  		///
I10_DX15 I10_DX16 I10_DX17 I10_DX18 I10_DX19 I10_DX20 I10_DX21 I10_DX22 		    ///
I10_DX23 I10_DX24 I10_DX25 I10_DX26 I10_DX27 I10_DX28 I10_DX29 I10_DX30  			///
I10_DX31 I10_DX32 I10_DX33 I10_DX34 I10_DX35 I10_PR1 I10_PR2 I10_PR3 I10_PR4  		///
I10_PR5 I10_PR6 I10_PR7 I10_PR8 I10_PR9  I10_PR10 I10_PR11 I10_PR12 I10_PR13  		///
I10_PR14 I10_PR15 I10_PR16 I10_PR17 I10_PR18 I10_PR19 I10_PR20 I10_PR21 I10_PR22  	///
I10_PR23 I10_PR24 I10_PR25 I10_PR26 I10_PR27 I10_PR28 I10_PR29 I10_PR30 DX1 DX2  	///
DX3 DX4 DX5 DX6 DX7 DX8 DX9 DX10 DX11 DX12 DX13 DX14 DX15 DX16 DX17 DX18 DX19  		///
DX20 DX21 DX22 DX23 DX24 DX25 DX26 DX27 DX28 DX29 DX30 DX31 DX32 DX33 DX34  		///
DX35 PR1 PR2 PR3 PR4 PR5 PR6 PR7 PR8 PR9 PR10 PR11 PR12 PR13 PR14 PR15 PR16  		///
PR17 PR18 PR19 PR20 PR21 PR22 PR23 PR24 PR25 PR26 PR27 PR28 PR29 PR30 
ds 
local vars `r(varlist)'
local tokeep : list vars & keep
display "`tokeep'"
keep `tokeep'

set varabbrev off
foreach var in PR I10_PR {
	capture confirm variable `var'1, exact
	if !_rc {
	display "`var'1 exists"
	local PR "`var'"
	}
	else {
	display "`var'1 does not exist"
	}	
}
foreach var in DX I10_DX {
	capture confirm variable `var'1, exact
	if !_rc {
	display "`var'1 exists"
	local DX "`var'"
	}
	else {
	display "`var'1 does not exist"
	}	
}

capture confirm variable DRG, exact
if !_rc {
display "DRG exists"
local DRG "DRG"
}
else {
display "DRG does not exist"
}

capture confirm variable RACE, exact
if !_rc {
	display "RACE exists"
	capture drop RACE_X
}
else {
	rename RACE_X RACE
}
set varabbrev on 
 * -------------------------------------------------------------- ;
 * --- INPATIENT QUALITY INDICATOR (IQI) NAMING CONVENTION:   --- ;
 * --- THE FIRST LETTER IDENTIFIES THE INPATIENT QUALITY      --- ;
 * --- INDICATOR AS ONE OF THE FOLLOWING:
 *               (T) NUMERATOR ("TOP")
 * --- THE SECOND LETTER IDENTIFIES THE IQI AS A PROVIDER (P) --- ;
 * --- LEVEL INDICATOR.  THE NEXT TWO CHARACTERS ARE ALWAYS   --- ;
 * --- 'IQ'. THE LAST TWO DIGITS ARE THE INDICATOR NUMBER     --- ;
 * --- (WITHIN THAT SUBTYPE).                                 --- ;
 * -------------------------------------------------------------- ;
label var FEMALE "Sex of the patient"
label var KEY "Unique record identifier"
 * ------------------------------------------------------------------------ ;
 * -- DELETE RECORDS WITH MISSING VALUES FOR AGE, SEX, DX1, DQTR, & YEAR -- ;
 * -- DELETE NON ADULT RECORDS                                           -- ;
 * ------------------------------------------------------------------------ ;

drop if FEMALE < 0 | AGE < 0 
drop if AGE < 18 & MDC != 14 
drop if missing(`DX'1) | DQTR == . | YEAR == .

 * --------------------------------------------------------------------- ;
 * --- DEFINE MDC ------------------------------------------------------ ;
 * --------------------------------------------------------------------- ;
 * --- The software assumes MDC is available on the input file.       -- ;
 * --- If MDC is not available, assign using the CMS MS-DRG Grouper.  -- ;
 * --------------------------------------------------------------------- ;

gen MDCNEW = MDC if MDC>= 1 & MDC<=25
replace MDCNEW = . if MDC< 1 & MDC>25

 * -------------------------------------------------------------- ;
 * --- DEFINE ICD-10-CM VERSION -------------------------------- ;
 * ------------------------------------------------------------- ;

 gen ICDVER = 0

 replace ICDVER = 33 if YEAR == 2015 & DQTR == 4
 replace ICDVER = 33 if YEAR == 2016 & DQTR < 4 & DQTR != .
 replace ICDVER = 34 if YEAR == 2016 & DQTR == 4
 replace ICDVER = 34 if YEAR == 2017 & DQTR < 4 & DQTR != .
 replace ICDVER = 35 if YEAR == 2017 & DQTR == 4
 replace ICDVER = 35 if YEAR == 2018 & DQTR < 4 & DQTR != .
 replace ICDVER = 36 if YEAR == 2018 & DQTR == 4
 replace ICDVER = 36 if YEAR == 2019 & DQTR < 4 & DQTR != .
*else ICDVER = 36; *Defaults to last version for discharges outside coding updates.;
label var ICDVER "ICD-10-CM VERSION"

 * ------------------------------------------------------------- ;
 * --- DEFINE STRATIFIER: PAYER CATEGORY ----------------------- ;
 * ------------------------------------------------------------- ;

 gen PAYCAT = PAY1
 label var PAYCAT "Patient Primary Payer"

 * ------------------------------------------------------------- ;
 * --- DEFINE STRATIFIER: RACE CATEGORY ------------------------ ;
 * ------------------------------------------------------------- ;

gen RACECAT = RACE 
label var RACECAT "Race Categories"

 * -------------------------------------------------------------- ;
 * --- DEFINE STRATIFIER: AGE CATEGORY  ------------------------- ;
 * -------------------------------------------------------------- ;

recode AGE (0/17 = 0) (18/39 = 1) (40/64 = 2) (65/74 = 3),  gen(AGECAT)
replace AGECAT = 4 if AGECAT >= 75
label var AGECAT "Age Categories"

 * -------------------------------------------------------------- ;
 * --- DEFINE STRATIFIER: SEX CATEGORY  ------------------------- ;
 * -------------------------------------------------------------- ;
gen SEXCAT = FEMALE 
replace SEXCAT = 0 if FEMALE < 1 & FEMALE > 2 
label var DSHOSPID "Hospital Identification Number"

* -------------------------------------------------------------- ;
 * --- DEFINE PROVIDER LEVEL MORTALITY INDICATORS --------------- ;
 * -------------------------------------------------------------- ;
gen TPIQ08 = 0 
gen TPIQ09 = 0 
gen TPIQ09_WITH_CANCER = 0 
gen TPIQ09_WITHOUT_CANCER = 0 
gen TPIQ11 = 0 
gen TPIQ11_OPEN_RUPTURED = 0 
gen TPIQ11_OPEN_UNRUPTURED = 0 
gen TPIQ11_ENDO_RUPTURED = 0 
gen TPIQ11_ENDO_UNRUPTURED = 0 
gen TPIQ12 = 0 
gen TPIQ15 = 0 
gen TPIQ16 = 0 
gen TPIQ17 = 0 
gen TPIQ17_HEMSTROKE_SUBARACH = 0 
gen TPIQ17_HEMSTROKE_INTRACER = 0 
gen TPIQ17_ISCHEMSTROKE = 0 
gen TPIQ18 = 0 
gen TPIQ19 = 0 
gen TPIQ20 = 0 

label var TPIQ08 "IQI 08 Esophageal Resection Mortality Rate (Numerator)"
label var TPIQ09 "IQI 09 Pancreatic Resection Mortality Rate (Numerator)"
label var TPIQ09_WITH_CANCER "IQI 09 Pancreatic Resection Mortality Rate Stratum : Presence of Pancreatic Cancer (Numerator)"
label var TPIQ09_WITHOUT_CANCER "IQI 09 Pancreatic Resection Mortality Rate Stratum: Absence of Pancreatic Cancer (Numerator)"
label var TPIQ11 "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate (Numerator)"
label var TPIQ11_OPEN_RUPTURED "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate Stratum_OPEN_RUPTURED: Open Repair of Ruptured AAA (Numerator)"
label var TPIQ11_OPEN_UNRUPTURED "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate Stratum_OPEN_UNRUPTURED: Open Repair of Unruptured AAA (Numerator)"
label var TPIQ11_ENDO_RUPTURED "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate Stratum_ENDO_RUPTURED: Endovascular Repair of Ruptured AAA (Numerator)"
label var TPIQ11_ENDO_UNRUPTURED "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate Stratum_ENDO_UNRUPTURED: Endovascular Repair of Unruptured AAA (Numerator)"
label var TPIQ12 "IQI 12 Coronary Artery Bypass Graft (CABG) Mortality Rate (Numerator)"
label var TPIQ15 "IQI 15 Acute Myocardial Infarction (AMI) Mortality Rate (Numerator)"
label var TPIQ16 "IQI 16 Heart Failure Mortality Rate (Numerator)"
label var TPIQ17 "IQI 17 Acute Stroke Mortality Rate (Numerator)"
label var TPIQ17_HEMSTROKE_SUBARACH "IQI 17 Acute Stroke Mortality Rate Stratum_HEMSTROKE_SUBARACH: Subarachnoid Hemorrhage (Numerator)"
label var TPIQ17_HEMSTROKE_INTRACER "IQI 17 Acute Stroke Mortality Rate Stratum_HEMSTROKE_INTRACER: Intracerebral Hemorrhage (Numerator)"
label var TPIQ17_ISCHEMSTROKE "IQI 17 Acute Stroke Mortality Rate Stratum_ISCHEMSTROKE: Ischemic Stroke (Numerator)"
label var TPIQ18 "IQI 18 Gastrointestinal Hemorrhage Mortality Rate (Numerator)"
label var TPIQ19 "IQI 19 Hip Fracture Mortality Rate (Numerator)"
label var TPIQ20 "IQI 20 Pneumonia Mortality Rate (Numerator)"

 * -------------------------------------------------------------- ;
 * --- DEFINE ADDITIONAL PROVIDER LEVEL MORTALITY INDICATORS ---- ;
 * -------------------------------------------------------------- ;

gen TPIQ30 = 0
gen TPIQ31 = 0
gen TPIQ32 = 0

label var TPIQ30 "IQI 30 Percutaneous Coronary Intervention (PCI) Mortality Rate (Numerator)"
label var TPIQ31 "IQI 31 Carotid Endarterectomy Mortality Rate (Numerator)"
label var TPIQ32 "IQI 32 Acute Myocardial Infarction (AMI) Mortality Rate, Without Transfer Cases (Numerator)"

* -------------------------------------------------------------- ;
 * --- DEFINE PROVIDER LEVEL UTILIZATION INDICATORS ------------- ;
 * -------------------------------------------------------------- ;

gen TPIQ21 = 0
gen TPIQ22 = 0

label var TPIQ21 "IQI 21 Cesarean Delivery Rate, Uncomplicated (Numerator)"
label var TPIQ22 "IQI 22 Vaginal Birth After Cesarean (VBAC) Delivery Rate, Uncomplicated (Numerator)"

 * -------------------------------------------------------------- ;
 * --- DEFINE ADDITIONAL PROVIDER LEVEL UTILIZATION INDICATORS -- ;
 * -------------------------------------------------------------- ;

gen TPIQ33 = 0
gen TPIQ34 = 0

label var TPIQ33 "IQI 33 Primary Cesarean Delivery Rate, Uncomplicated (Numerator)"
label var TPIQ34 "IQI 34 Vaginal Birth After Cesarean (VBAC) Rate, All (Numerator)" 

 * ----------------------------------------------------- ;
 * --- CONSTRUCT PROVIDER LEVEL MORTALITY INDICATORS --- ;
 * ----------------------------------------------------- ;

 * ----------------------------------------------------- ;
 * --- IQI 08 : ESOPHAGEAL RESECTION MORTALITY RATE	 --- ;
 * ----------------------------------------------------- ;

* FORMAT FOR Esophageal resection procedure codes */	
gen PRESOPP_PR = 0 
forval i = 1/30 {
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11074"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11076"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11079"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1107A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1107B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D110ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D113J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11474"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11476"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11479"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1147A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1147B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D114ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11874"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11876"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D11879"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1187A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1187B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D118ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12074"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12076"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12079"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1207A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1207B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D120ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D123J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12474"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12476"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12479"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1247A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1247B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D124ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12874"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12876"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D12879"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1287A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1287B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D128ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13074"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13076"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13079"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1307A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1307B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D130ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D133J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13474"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13476"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13479"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1347A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1347B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D134ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13874"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13876"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D13879"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1387A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1387B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D138ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15074"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15076"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15079"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1507A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1507B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D150ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D153J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15474"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15476"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15479"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1547A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1547B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D154ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15874"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15876"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D15879"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1587A"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D1587B"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158J4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158J6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158J9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158JA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158JB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158K4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158K6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158K9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158KA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158KB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158Z4"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158Z6"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158Z9"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158ZA"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0D158ZB"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB10ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB13ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB17ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB20ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB23ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB27ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB30ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB33ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB37ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB50ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB53ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DB57ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT10ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT14ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT17ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT18ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT20ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT24ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT27ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT28ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT30ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT34ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT37ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT38ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT50ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT54ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT57ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DT58ZZ"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DX60Z5"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DX64Z5"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DX80Z5"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DX84Z5"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DXE0Z5"  
	capture replace PRESOPP_PR = 1 if `PR'`i' == "0DXE4Z5"  
}
label var PRESOPP_PR "FORMAT FOR Esophageal resection procedure codes"
* FORMAT FOR Esophageal cancer diagnosis codes */
gen PRESOPD_DX = 0
forval i = 1/35 {
	capture replace PRESOPD_DX = 1 if `DX'`i' == "C153"
	capture replace PRESOPD_DX = 1 if `DX'`i' == "C154"
	capture replace PRESOPD_DX = 1 if `DX'`i' == "C155"
	capture replace PRESOPD_DX = 1 if `DX'`i' == "C158"
	capture replace PRESOPD_DX = 1 if `DX'`i' == "C159"
}
label var PRESOPD_DX "FORMAT FOR Esophageal cancer diagnosis codes"
* FORMAT FOR Gastrointestinal-related cancer diagnosis codes */
gen PRESO2D_DX = 0
forval i = 1/35 {
	capture replace PRESO2D_DX = 1 if `DX'`i' == "C160" 
	capture replace PRESO2D_DX = 1 if `DX'`i' == "C49A1"
	capture replace PRESO2D_DX = 1 if `DX'`i' == "C7880"
	capture replace PRESO2D_DX = 1 if `DX'`i' == "C7889"
	capture replace PRESO2D_DX = 1 if `DX'`i' == "D001" 
	capture replace PRESO2D_DX = 1 if `DX'`i' == "D378" 
	capture replace PRESO2D_DX = 1 if `DX'`i' == "D379" 
}	
label var PRESO2D_DX "FORMAT FOR Gastrointestinal-related cancer diagnosis codes"
* FORMAT FOR Esophageal resection procedure codes */
gen PRESO2P_PR = 0
forval i = 1/30 {
	capture replace PRESO2P_PR = 1 if `PR'`i' == "0DT60ZZ"
	capture replace PRESO2P_PR = 1 if `PR'`i' == "0DT64ZZ"
	capture replace PRESO2P_PR = 1 if `PR'`i' == "0DT67ZZ"
	capture replace PRESO2P_PR = 1 if `PR'`i' == "0DT68ZZ"
}
label var PRESO2P_PR "FORMAT FOR Esophageal resection procedure codes"
replace TPIQ08 = 1 if DISPUNIFORM == 20 & (MDC != 14 &  ///
		((PRESOPP_PR == 1 &  ( PRESOPD_DX == 1 | PRESO2D_DX == 1 ) ) ///
		| (PRESO2P_PR == 1 & PRESOPD_DX == 1))) ///
	
 * ---------------------------------------------------- ;
 * --- IQI 09 : PANCREATIC RESECTION MORTALITY RATE --- ;
 * ---------------------------------------------------- ;

* FORMAT FOR Total pancreatic resection procedure codes 
gen PRPANCP_PR = 0
forval i = 1/30 {
	capture replace PRPANCP_PR = 1 if `PR'`i' == "0FTG0ZZ"
	capture replace PRPANCP_PR = 1 if `PR'`i' == "0FTG4ZZ"
}
label var PRPANCP_PR "FORMAT FOR Total pancreatic resection procedure codes"
* FORMAT FOR Partial pancreatic resection procedure codes 
gen PRPAN3P_PR = 0 
forval i = 1/30 {
	capture replace PRPAN3P_PR = 1 if `PR'`i' == "0FBG0ZZ" 
	capture replace PRPAN3P_PR = 1 if `PR'`i' == "0FBG3ZZ" 
	capture replace PRPAN3P_PR = 1 if `PR'`i' == "0FBG4ZZ" 
	capture replace PRPAN3P_PR = 1 if `PR'`i' == "0FBG8ZZ" 
}
label var PRPAN3P_PR "FORMAT FOR Partial pancreatic resection procedure codes"
* FORMAT FOR Pancreatic cancer diagnosis codes
gen PRPANCD_DX = 0 
forval i = 1/35 {
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C170"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C240"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C241"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C250"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C251"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C252"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C253"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C254"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C257"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C258"
	capture replace PRPANCD_DX = 1 if `DX'`i' == "C259"
}
label var PRPANCD_DX "FORMAT FOR Pancreatic cancer diagnosis codes"
* FORMAT FOR Acute pancreatitis diagnosis codes
gen PRPAN2D_DX = 0
forval i = 1/35 {
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "B252" 
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "B263" 
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K850" 
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8501"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8502"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K851" 
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8511"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8512"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K852" 
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8521"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8522"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K853" 
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8531"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8532"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K858" 
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8581"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8582"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K859" 
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8591"
	capture replace PRPAN2D_DX = 1 if `DX'`i' == "K8592"
}
label var PRPAN2D_DX "FORMAT FOR Acute pancreatitis diagnosis codes"
replace TPIQ09 = 0 if (MDC ! = 14  													///
					   & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 )) 			
replace TPIQ09 = 1 if DISPUNIFORM == 20 											///
					   & (MDC ! = 14 												///
					   & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))

replace TPIQ09_WITH_CANCER = 0    if PRPANCD_DX == 1 								///
								     & (MDC ! = 14 									///
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 )) 		
replace TPIQ09_WITH_CANCER = 1    if DISPUNIFORM == 20 								///
								     & PRPANCD_DX == 1 								///
								     & (MDC ! = 14 									///
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))	
replace TPIQ09_WITHOUT_CANCER = 0 if PRPANCD_DX == 0 								///
									 & (MDC ! = 14 									///
									 & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))						
replace TPIQ09_WITHOUT_CANCER = 1 if DISPUNIFORM == 20 								///
									 & PRPANCD_DX == 0 								///
									 & (MDC ! = 14 									///
									 & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))
	
* ---------------------------------------------- ;
* --- EXCLUDE ACUTE PANCREATITIS             --- ;
* ---------------------------------------------- ;

replace TPIQ09 = . 			      if PRPAN2D_DX == 1  								///
								     & (MDC ! = 14  								///
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))
replace TPIQ09_WITH_CANCER = .    if PRPAN2D_DX == 1  								///
								     & (MDC ! = 14 								    /// 
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))
replace TPIQ09_WITHOUT_CANCER = . if PRPAN2D_DX == 1  								///
								     & (MDC ! = 14  								///
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))

 * ---------------------------------------------------------------------- ;
 * --- IQI 11 : ABDOMINAL AORTIC ANEURYSM (AAA) REPAIR MORTALITY RATE --- ;
 * ---------------------------------------------------------------------- ;

* FORMAT FOR Ruptured abdominal aortic aneurysm (AAA) diagnosis codes
gen PRAAARD_DX = 0
forval i = 1/35 {
	capture replace PRAAARD_DX = 1 if `DX'`i' == "I713"
}
label var PRAAARD_DX "FORMAT FOR Ruptured abdominal aortic aneurysm (AAA) diagnosis codes"
* FORMAT FOR Unruptured abdominal aortic (AAA) aneurysm diagnosis codes */
gen PRAAA2D_DX = 0
forval i = 1/35 {
	capture replace PRAAA2D_DX = 1 if `DX'`i' == "I714"
}
label var PRAAA2D_DX "FORMAT FOR Unruptured abdominal aortic (AAA) aneurysm diagnosis codes"
* FORMAT FOR Open abdominal aortic aneurysm (AAA) repair procedure codes
gen PRAAARP_PR = 0
forval i = 1/30 {
	capture replace PRAAARP_PR = 1 if `PR'`i' == "0410090"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "0410096"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "0410097"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "0410098"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "0410099"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009B"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009C"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009D"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009F"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009G"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009H"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009J"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009K"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009Q"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "041009R"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100A0"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100A6"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100A7"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100A8"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100A9"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AB"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AC"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AD"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AF"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AG"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AH"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AJ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AK"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AQ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100AR"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100J0"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100J6"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100J7"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100J8"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100J9"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JB"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JC"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JD"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JF"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JG"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JH"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JJ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JK"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JQ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100JR"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100K0"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100K6"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100K7"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100K8"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100K9"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KB"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KC"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KD"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KF"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KG"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KH"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KJ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KK"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KQ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100KR"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100Z0"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100Z6"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100Z7"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100Z8"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100Z9"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZB"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZC"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZD"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZF"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZG"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZH"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZJ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZK"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZQ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04100ZR"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04500ZZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04B00ZZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04H00DZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04L00DZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04L00ZZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04Q00ZZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04R007Z"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04R00JZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04R00KZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04U007Z"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04U00JZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04U00KZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00D6"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00DJ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00DZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00E6"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00EZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00F6"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00FZ"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00Z6"
	capture replace PRAAARP_PR = 1 if `PR'`i' == "04V00ZZ"
}
label var PRAAARP_PR "FORMAT FOR Open abdominal aortic aneurysm (AAA) repair procedure codes"
* FORMAT FOR Endovascular abdominal aortic (AAA) aneurysm repair procedure codes */
gen PRAAA2P_PR = 0 
forval i = 1/30 {
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "0410490"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "0410496"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "0410497"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "0410498"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "0410499"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049B"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049C"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049D"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049F"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049G"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049H"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049J"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049K"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049Q"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "041049R"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104A0"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104A6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104A7"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104A8"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104A9"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AB"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AC"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AD"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AF"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AG"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AH"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AJ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AK"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AQ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104AR"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104J0"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104J6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104J7"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104J8"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104J9"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JB"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JC"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JD"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JF"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JG"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JH"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JJ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JK"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JQ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104JR"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104K0"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104K6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104K7"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104K8"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104K9"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KB"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KC"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KD"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KF"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KG"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KH"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KJ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KK"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KQ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104KR"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104Z0"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104Z6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104Z7"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104Z8"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104Z9"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZB"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZC"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZD"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZF"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZG"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZH"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZJ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZK"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZQ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04104ZR"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04503ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04504ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04B03ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04B04ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04H03DZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04H04DZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04L03DJ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04L03DZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04L03ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04L04DZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04L04ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04Q03ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04Q04ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04R047Z"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04R04JZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04R04KZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04U037Z"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04U03JZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04U03KZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04U047Z"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04U04JZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04U04KZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03D6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03DJ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03DZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03E6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03EZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03F6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03FZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03Z6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V03ZZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04D6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04DJ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04DZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04E6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04EZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04F6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04FZ"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04Z6"
	capture replace PRAAA2P_PR = 1 if `PR'`i' == "04V04ZZ"
}
label var PRAAA2P_PR "FORMAT FOR Endovascular abdominal aortic (AAA) aneurysm repair procedure codes"
replace TPIQ11 = 0 if MDC ! = 14   													///
					  & (PRAAARD_DX == 1 | PRAAA2D_DX == 1) 						///
		 			  & (PRAAARP_PR == 1 | PRAAA2P_PR == 1) 

replace TPIQ11 = 1 if DISPUNIFORM == 20 & MDC ! = 14 						        ///
										 & (PRAAARD_DX == 1 | PRAAA2D_DX == 1) 		///
										 & (PRAAARP_PR == 1 | PRAAA2P_PR == 1) 


* --- IN-HOSP MORT AAA REPAIR (STRATIFICATION)                        --- ;
* --- stratification priority according to prior probability of death --- ;
*** IQI 11 Stratum_OPEN_RUPTURED : OPEN REPAIR- RUPTURED  
replace TPIQ11_OPEN_RUPTURED = 0 if MDC != 14 										///
									& PRAAARP_PR == 1 								///
									& PRAAARD_DX == 1 	
replace TPIQ11_OPEN_RUPTURED = 1 if DISPUNIFORM == 20								///
									& MDC ! = 14 									///
									& PRAAARP_PR == 1 		    					///
									& PRAAARD_DX == 1			

** IQI 11 Stratum_ENDO_RUPTURED : ENDOVASCULAR REPAIR - RUPTURED
replace TPIQ11_ENDO_RUPTURED = 0 if MDC != 14										///
									& PRAAA2P_PR == 1 								///	
									& PRAAARD_DX == 1 				
	
replace TPIQ11_ENDO_RUPTURED = 1 if DISPUNIFORM == 20 								///
									& MDC != 14										///
									& PRAAA2P_PR == 1 								///	
									& PRAAARD_DX == 1 				
** IQI 11 Stratum_OPEN_UNRUPTURED : OPEN REPAIR- UNRUPTURED  
replace TPIQ11_OPEN_UNRUPTURED = 0 if MDC != 14 			 				        ///
									  & PRAAARP_PR == 1 			 				///
									  & PRAAA2D_DX == 1

replace TPIQ11_OPEN_UNRUPTURED = 1 if DISPUNIFORM == 20 							///
									  & MDC != 14 									///
									  & PRAAARP_PR == 1 							///
									  & PRAAA2D_DX == 1  
** IQI 11 Stratum_ENDO_UNRUPTURED : ENDOVASCULAR REPAIR  - UNRUPTURED
replace TPIQ11_ENDO_UNRUPTURED = 0 if MDC != 14										///
									  & PRAAA2P_PR == 1 							///
									  & PRAAA2D_DX == 1 

replace TPIQ11_ENDO_UNRUPTURED = 1 if DISPUNIFORM == 20 							///
									  & MDC != 14 									///
									  & PRAAA2P_PR == 1 							///
									  & PRAAA2D_DX == 1  	
	
 * ------------------------------------------------------------------- ;
 * --- IQI 12 : CORONARY ARTERY BYPASS GRAFT (CABG) MORTALITY RATE --- ;
 * --------------------------------------*---------------------------- ;

* FORMAT FOR Coronary artery bypass graft (CABG) procedure codes
gen PRCABGP_PR = 0
forval i = 1/30 {
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0210083"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0210088"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0210089"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021008C"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021008F"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021008W"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0210093"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0210098"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0210099"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021009C"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021009F"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021009W"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100A3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100A8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100A9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100AC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100AF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100AW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100J3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100J8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100J9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100JC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100JF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100JW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100K3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100K8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100K9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100KC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100KF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100KW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100Z3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100Z8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100Z9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100ZC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02100ZF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0211083"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0211088"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0211089"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021108C"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021108F"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021108W"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0211093"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0211098"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0211099"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021109C"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021109F"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021109W"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110A3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110A8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110A9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110AC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110AF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110AW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110J3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110J8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110J9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110JC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110JF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110JW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110K3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110K8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110K9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110KC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110KF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110KW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110Z3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110Z8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110Z9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110ZC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02110ZF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0212083"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0212088"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0212089"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021208C"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021208F"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021208W"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0212093"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0212098"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0212099"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021209C"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021209F"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021209W"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120A3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120A8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120A9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120AC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120AF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120AW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120J3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120J8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120J9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120JC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120JF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120JW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120K3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120K8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120K9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120KC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120KF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120KW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120Z3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120Z8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120Z9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120ZC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02120ZF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0213083"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0213088"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0213089"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021308C"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021308F"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021308W"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0213093"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0213098"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "0213099"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021309C"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021309F"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "021309W"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130A3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130A8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130A9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130AC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130AF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130AW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130J3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130J8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130J9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130JC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130JF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130JW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130K3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130K8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130K9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130KC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130KF"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130KW"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130Z3"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130Z8"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130Z9"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130ZC"
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02130ZF"
}
label var PRCABGP_PR "FORMAT FOR Coronary artery bypass graft (CABG) procedure codes"
replace TPIQ12 = 0 				   if (MDC ! = 14  									///
									  & AGE >= 40 & PRCABGP_PR == 1)
	
replace TPIQ12 = 1 				   if DISPUNIFORM == 20  							///
					  				  & (MDC ! = 14 								///
					  				  & AGE >= 40 & PRCABGP_PR == 1)

 * ----------------------------------------------------------------- ;
 * --- IQI 15 : ACUTE MYOCARDIAL INFARCTION (AMI) MORTALITY RATE --- ;
 * ----------------------------------------------------------------- ;
	* FORMAT FOR Acute myocardial infarction (AMI) diagnosis codes */
gen MRTAMID_DX = 0
replace MRTAMID_DX = 1 if `DX'1 == "I2101"
replace MRTAMID_DX = 1 if `DX'1 == "I2102"
replace MRTAMID_DX = 1 if `DX'1 == "I2109"
replace MRTAMID_DX = 1 if `DX'1 == "I2111"
replace MRTAMID_DX = 1 if `DX'1 == "I2119"
replace MRTAMID_DX = 1 if `DX'1 == "I2121"
replace MRTAMID_DX = 1 if `DX'1 == "I2129"
replace MRTAMID_DX = 1 if `DX'1 == "I213"
replace MRTAMID_DX = 1 if `DX'1 == "I214"
replace MRTAMID_DX = 1 if `DX'1 == "I219"
replace MRTAMID_DX = 1 if `DX'1 == "I21A1"
replace MRTAMID_DX = 1 if `DX'1 == "I21A9"
replace MRTAMID_DX = 1 if `DX'1 == "I220"
replace MRTAMID_DX = 1 if `DX'1 == "I221"
replace MRTAMID_DX = 1 if `DX'1 == "I222"
replace MRTAMID_DX = 1 if `DX'1 == "I228"
replace MRTAMID_DX = 1 if `DX'1 == "I229"

label var MRTAMID_DX "FORMAT FOR Acute myocardial infarction (AMI) diagnosis codes"

replace TPIQ15 = 0 if MDC ! = 14 & MRTAMID_DX == 1									
replace TPIQ32 = 0 if MDC ! = 14 & MRTAMID_DX == 1									

replace TPIQ15 = 1 if DISPUNIFORM == 20 											/// 
					  & MDC ! = 14 & MRTAMID_DX == 1
replace TPIQ32 = 1 if DISPUNIFORM == 20 											/// 
					  & MDC ! = 14 & MRTAMID_DX == 1

* Exclusion for cases in hospice care at admission
replace TPIQ15 = . if PointOfOriginUB04 == "F"  									/// 
					  & MDC ! = 14 & MRTAMID_DX == 1
replace TPIQ32 = . if PointOfOriginUB04 == "F"  									/// 
					  & MDC ! = 14 & MRTAMID_DX == 1

 * --------------------------------------------- ;
 * --- IQI 16 : HEART FAILURE MORTALITY RATE --- ;
 * --------------------------------------------- ;

* FORMAT FOR Heart failure diagnosis codes
gen MRTCHFD_DX = 0
replace MRTCHFD_DX = 1 if `DX'1 == "I0981"
replace MRTCHFD_DX = 1 if `DX'1 == "I110"
replace MRTCHFD_DX = 1 if `DX'1 == "I130"
replace MRTCHFD_DX = 1 if `DX'1 == "I132"
replace MRTCHFD_DX = 1 if `DX'1 == "I501"
replace MRTCHFD_DX = 1 if `DX'1 == "I5020"
replace MRTCHFD_DX = 1 if `DX'1 == "I5021"
replace MRTCHFD_DX = 1 if `DX'1 == "I5022"
replace MRTCHFD_DX = 1 if `DX'1 == "I5023"
replace MRTCHFD_DX = 1 if `DX'1 == "I5030"
replace MRTCHFD_DX = 1 if `DX'1 == "I5031"
replace MRTCHFD_DX = 1 if `DX'1 == "I5032"
replace MRTCHFD_DX = 1 if `DX'1 == "I5033"
replace MRTCHFD_DX = 1 if `DX'1 == "I5040"
replace MRTCHFD_DX = 1 if `DX'1 == "I5041"
replace MRTCHFD_DX = 1 if `DX'1 == "I5042"
replace MRTCHFD_DX = 1 if `DX'1 == "I5043"
replace MRTCHFD_DX = 1 if `DX'1 == "I50810"
replace MRTCHFD_DX = 1 if `DX'1 == "I50811"
replace MRTCHFD_DX = 1 if `DX'1 == "I50812"
replace MRTCHFD_DX = 1 if `DX'1 == "I50813"
replace MRTCHFD_DX = 1 if `DX'1 == "I50814"
replace MRTCHFD_DX = 1 if `DX'1 == "I5082"
replace MRTCHFD_DX = 1 if `DX'1 == "I5083"
replace MRTCHFD_DX = 1 if `DX'1 == "I5084"
replace MRTCHFD_DX = 1 if `DX'1 == "I5089"
replace MRTCHFD_DX = 1 if `DX'1 == "I509"
label var MRTCHFD_DX "FORMAT FOR Heart failure diagnosis codes"
* FORMAT FOR Heart transplant procedure codes
gen HEARTTRP_PR = 0
forval i = 1/30 {
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA0QZ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA0RJ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA0RS" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA0RZ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA3QZ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA3RJ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA3RS" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA3RZ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA4QZ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA4RJ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA4RS" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02HA4RZ" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02YA0Z0" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02YA0Z1" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "02YA0Z2" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "5A02116" 
	capture replace PRCABGP_PR = 1 if  `PR'`i' == "5A02216" 
}
label var HEARTTRP_PR "FORMAT FOR Heart transplant procedure codes"

replace TPIQ16 = 0 if (MDC ! = 14 & MRTCHFD_DX == 1)
replace TPIQ16 = 1 if DISPUNIFORM == 20  			  								///
					  & (MDC ! = 14 & MRTCHFD_DX == 1)

* Exclude any procedure code for heart transplant
replace TPIQ16 = . if HEARTTRP_PR == 1  			  								///
					  & (MDC ! = 14 & MRTCHFD_DX == 1)
* Exclusion for cases in hospice care at admission ;					 
replace TPIQ16 = . if PointOfOriginUB04 == "F"  	  								///
					  & (MDC ! = 14 & MRTCHFD_DX == 1)

 * -------------------------------------------- ;
 * --- IQI 17 : ACUTE STROKE MORTALITY RATE --- ;
 * -------------------------------------------- ;

* FORMAT FOR Subarachnoid hemorrhage diagnosis codes
gen MRTCV2A_DX = 0 
replace MRTCV2A_DX = 1 if `DX'1 == "I6000"
replace MRTCV2A_DX = 1 if `DX'1 == "I6001"
replace MRTCV2A_DX = 1 if `DX'1 == "I6002"
replace MRTCV2A_DX = 1 if `DX'1 == "I6010"
replace MRTCV2A_DX = 1 if `DX'1 == "I6011"
replace MRTCV2A_DX = 1 if `DX'1 == "I6012"
replace MRTCV2A_DX = 1 if `DX'1 == "I602"
replace MRTCV2A_DX = 1 if `DX'1 == "I6020"
replace MRTCV2A_DX = 1 if `DX'1 == "I6021"
replace MRTCV2A_DX = 1 if `DX'1 == "I6022"
replace MRTCV2A_DX = 1 if `DX'1 == "I6030"
replace MRTCV2A_DX = 1 if `DX'1 == "I6031"
replace MRTCV2A_DX = 1 if `DX'1 == "I6032"
replace MRTCV2A_DX = 1 if `DX'1 == "I604"
replace MRTCV2A_DX = 1 if `DX'1 == "I6050"
replace MRTCV2A_DX = 1 if `DX'1 == "I6051"
replace MRTCV2A_DX = 1 if `DX'1 == "I6052"
replace MRTCV2A_DX = 1 if `DX'1 == "I606"
replace MRTCV2A_DX = 1 if `DX'1 == "I607"
replace MRTCV2A_DX = 1 if `DX'1 == "I608"
replace MRTCV2A_DX = 1 if `DX'1 == "I609"
label var MRTCV2A_DX "FORMAT FOR Subarachnoid hemorrhage diagnosis codes"
* FORMAT FOR Intracerebral hemorrhage diagnosis codes
gen MRTCV3D_DX = 0 
replace MRTCV3D_DX = 1 if `DX'1 == "I610" 
replace MRTCV3D_DX = 1 if `DX'1 == "I611" 
replace MRTCV3D_DX = 1 if `DX'1 == "I612" 
replace MRTCV3D_DX = 1 if `DX'1 == "I613" 
replace MRTCV3D_DX = 1 if `DX'1 == "I614" 
replace MRTCV3D_DX = 1 if `DX'1 == "I615" 
replace MRTCV3D_DX = 1 if `DX'1 == "I616" 
replace MRTCV3D_DX = 1 if `DX'1 == "I618" 
replace MRTCV3D_DX = 1 if `DX'1 == "I619" 
replace MRTCV3D_DX = 1 if `DX'1 == "I6200"
replace MRTCV3D_DX = 1 if `DX'1 == "I6201"
replace MRTCV3D_DX = 1 if `DX'1 == "I6202"
replace MRTCV3D_DX = 1 if `DX'1 == "I6203"
replace MRTCV3D_DX = 1 if `DX'1 == "I621" 
replace MRTCV3D_DX = 1 if `DX'1 == "I629" 
label var  MRTCV3D_DX "FORMAT FOR Intracerebral hemorrhage diagnosis codes"
* FORMAT FOR Ischemic stroke diagnosis codes
gen MRTCV4D_DX = 0 
replace MRTCV4D_DX = 1 if `DX'1 == "I6300"
replace MRTCV4D_DX = 1 if `DX'1 == "I63011"
replace MRTCV4D_DX = 1 if `DX'1 == "I63012"
replace MRTCV4D_DX = 1 if `DX'1 == "I63013"
replace MRTCV4D_DX = 1 if `DX'1 == "I63019"
replace MRTCV4D_DX = 1 if `DX'1 == "I6302"
replace MRTCV4D_DX = 1 if `DX'1 == "I63031"
replace MRTCV4D_DX = 1 if `DX'1 == "I63032"
replace MRTCV4D_DX = 1 if `DX'1 == "I63033"
replace MRTCV4D_DX = 1 if `DX'1 == "I63039"
replace MRTCV4D_DX = 1 if `DX'1 == "I6309"
replace MRTCV4D_DX = 1 if `DX'1 == "I6310"
replace MRTCV4D_DX = 1 if `DX'1 == "I63111"
replace MRTCV4D_DX = 1 if `DX'1 == "I63112"
replace MRTCV4D_DX = 1 if `DX'1 == "I63113"
replace MRTCV4D_DX = 1 if `DX'1 == "I63119"
replace MRTCV4D_DX = 1 if `DX'1 == "I6312"
replace MRTCV4D_DX = 1 if `DX'1 == "I63131"
replace MRTCV4D_DX = 1 if `DX'1 == "I63132"
replace MRTCV4D_DX = 1 if `DX'1 == "I63133"
replace MRTCV4D_DX = 1 if `DX'1 == "I63139"
replace MRTCV4D_DX = 1 if `DX'1 == "I6319"
replace MRTCV4D_DX = 1 if `DX'1 == "I6320"
replace MRTCV4D_DX = 1 if `DX'1 == "I63211"
replace MRTCV4D_DX = 1 if `DX'1 == "I63212"
replace MRTCV4D_DX = 1 if `DX'1 == "I63213"
replace MRTCV4D_DX = 1 if `DX'1 == "I63219"
replace MRTCV4D_DX = 1 if `DX'1 == "I6322"
replace MRTCV4D_DX = 1 if `DX'1 == "I63231"
replace MRTCV4D_DX = 1 if `DX'1 == "I63232"
replace MRTCV4D_DX = 1 if `DX'1 == "I63233"
replace MRTCV4D_DX = 1 if `DX'1 == "I63239"
replace MRTCV4D_DX = 1 if `DX'1 == "I6329"
replace MRTCV4D_DX = 1 if `DX'1 == "I6330"
replace MRTCV4D_DX = 1 if `DX'1 == "I63311"
replace MRTCV4D_DX = 1 if `DX'1 == "I63312"
replace MRTCV4D_DX = 1 if `DX'1 == "I63313"
replace MRTCV4D_DX = 1 if `DX'1 == "I63319"
replace MRTCV4D_DX = 1 if `DX'1 == "I63321"
replace MRTCV4D_DX = 1 if `DX'1 == "I63322"
replace MRTCV4D_DX = 1 if `DX'1 == "I63323"
replace MRTCV4D_DX = 1 if `DX'1 == "I63329"
replace MRTCV4D_DX = 1 if `DX'1 == "I63331"
replace MRTCV4D_DX = 1 if `DX'1 == "I63332"
replace MRTCV4D_DX = 1 if `DX'1 == "I63333"
replace MRTCV4D_DX = 1 if `DX'1 == "I63339"
replace MRTCV4D_DX = 1 if `DX'1 == "I63341"
replace MRTCV4D_DX = 1 if `DX'1 == "I63342"
replace MRTCV4D_DX = 1 if `DX'1 == "I63343"
replace MRTCV4D_DX = 1 if `DX'1 == "I63349"
replace MRTCV4D_DX = 1 if `DX'1 == "I6339"
replace MRTCV4D_DX = 1 if `DX'1 == "I6340"
replace MRTCV4D_DX = 1 if `DX'1 == "I63411"
replace MRTCV4D_DX = 1 if `DX'1 == "I63412"
replace MRTCV4D_DX = 1 if `DX'1 == "I63413"
replace MRTCV4D_DX = 1 if `DX'1 == "I63419"
replace MRTCV4D_DX = 1 if `DX'1 == "I63421"
replace MRTCV4D_DX = 1 if `DX'1 == "I63422"
replace MRTCV4D_DX = 1 if `DX'1 == "I63423"
replace MRTCV4D_DX = 1 if `DX'1 == "I63429"
replace MRTCV4D_DX = 1 if `DX'1 == "I63431"
replace MRTCV4D_DX = 1 if `DX'1 == "I63432"
replace MRTCV4D_DX = 1 if `DX'1 == "I63433"
replace MRTCV4D_DX = 1 if `DX'1 == "I63439"
replace MRTCV4D_DX = 1 if `DX'1 == "I63441"
replace MRTCV4D_DX = 1 if `DX'1 == "I63442"
replace MRTCV4D_DX = 1 if `DX'1 == "I63443"
replace MRTCV4D_DX = 1 if `DX'1 == "I63449"
replace MRTCV4D_DX = 1 if `DX'1 == "I6349"
replace MRTCV4D_DX = 1 if `DX'1 == "I6350"
replace MRTCV4D_DX = 1 if `DX'1 == "I63511"
replace MRTCV4D_DX = 1 if `DX'1 == "I63512"
replace MRTCV4D_DX = 1 if `DX'1 == "I63513"
replace MRTCV4D_DX = 1 if `DX'1 == "I63519"
replace MRTCV4D_DX = 1 if `DX'1 == "I63521"
replace MRTCV4D_DX = 1 if `DX'1 == "I63522"
replace MRTCV4D_DX = 1 if `DX'1 == "I63523"
replace MRTCV4D_DX = 1 if `DX'1 == "I63529"
replace MRTCV4D_DX = 1 if `DX'1 == "I63531"
replace MRTCV4D_DX = 1 if `DX'1 == "I63532"
replace MRTCV4D_DX = 1 if `DX'1 == "I63533"
replace MRTCV4D_DX = 1 if `DX'1 == "I63539"
replace MRTCV4D_DX = 1 if `DX'1 == "I63541"
replace MRTCV4D_DX = 1 if `DX'1 == "I63542"
replace MRTCV4D_DX = 1 if `DX'1 == "I63543"
replace MRTCV4D_DX = 1 if `DX'1 == "I63549"
replace MRTCV4D_DX = 1 if `DX'1 == "I6359"
replace MRTCV4D_DX = 1 if `DX'1 == "I636"
replace MRTCV4D_DX = 1 if `DX'1 == "I638"
replace MRTCV4D_DX = 1 if `DX'1 == "I6381"
replace MRTCV4D_DX = 1 if `DX'1 == "I6389"
replace MRTCV4D_DX = 1 if `DX'1 == "I639"
label var MRTCV4D_DX "FORMAT FOR Ischemic stroke diagnosis codes"

replace TPIQ17 = 0 if MDC ! = 14  													///
					 & (MRTCV2A_DX == 1 											///
					  | MRTCV3D_DX == 1 											///
					  | MRTCV4D_DX == 1)
	
replace TPIQ17 = 1 if DISPUNIFORM == 20												///
					 & MDC ! = 14  													///
					 & (MRTCV2A_DX == 1 											///
					  | MRTCV3D_DX == 1 											///
					  | MRTCV4D_DX == 1)	

   * --- ACUTE STROKE MORTALITY (STRATIFICATION)                         --- ;
   * --- Stratification priority according to prior probability of death --- ;

   * IQI 17 Stratum_HEMSTROKE_INTRACER :  INTRACEREBRAL HEMORRHAGIC STROKE */

replace TPIQ17_HEMSTROKE_INTRACER = 0 if MDC ! = 14 	   							///
										 & MRTCV3D_DX == 1 

replace TPIQ17_HEMSTROKE_INTRACER = 1 if DISPUNIFORM == 20 							///
										 & MDC ! = 14 	   							///
										 & MRTCV3D_DX == 1 

* IQI 17 Stratum_HEMSTROKE_SUBARACH : SUBARACHNOID HEMORRHAGE  										
	
replace TPIQ17_HEMSTROKE_SUBARACH = 0 if MDC ! = 14 	   							///
										 & MRTCV2A_DX == 1 

replace TPIQ17_HEMSTROKE_SUBARACH = 1 if DISPUNIFORM == 20 							///
										 & MDC ! = 14 	   							///
										 & MRTCV2A_DX == 1 
	
* IQI 17 Stratum_ISCHEMSTROKE : ISCHEMIC HEMORRHAGIC STROKE
replace TPIQ17_ISCHEMSTROKE = 0 if MDC ! = 14 										///
										 & MRTCV4D_DX == 1 

replace TPIQ17_ISCHEMSTROKE = 1 if DISPUNIFORM == 20 								///
										 & MDC ! = 14 	   							///
										 & MRTCV4D_DX == 1 

* Exclusion for cases in hospice care at admission ;	

replace TPIQ17 = . if PointOfOriginUB04 == "F"
replace TPIQ17_HEMSTROKE_SUBARACH = . if PointOfOriginUB04 == "F"
replace TPIQ17_HEMSTROKE_INTRACER = . if PointOfOriginUB04 == "F"
replace TPIQ17_ISCHEMSTROKE = . if PointOfOriginUB04 == "F"
	
 * ----------------------------------------------------------- ;
 * --- IQI 18 : GASTROINTESTINAL HEMORRHAGE MORTALITY RATE --- ;
 * ----------------------------------------------------------- ;

* FORMAT FOR Gastrointestinal hemorrhage diagnosis codes */
gen MRTGIHD_DX = 0 
replace MRTGIHD_DX = 1 if `DX'1 == "I8501"
replace MRTGIHD_DX = 1 if `DX'1 == "I8511"
replace MRTGIHD_DX = 1 if `DX'1 == "K2211"
replace MRTGIHD_DX = 1 if `DX'1 == "K226"
replace MRTGIHD_DX = 1 if `DX'1 == "K250"
replace MRTGIHD_DX = 1 if `DX'1 == "K252"
replace MRTGIHD_DX = 1 if `DX'1 == "K254"
replace MRTGIHD_DX = 1 if `DX'1 == "K256"
replace MRTGIHD_DX = 1 if `DX'1 == "K260"
replace MRTGIHD_DX = 1 if `DX'1 == "K262"
replace MRTGIHD_DX = 1 if `DX'1 == "K264"
replace MRTGIHD_DX = 1 if `DX'1 == "K266"
replace MRTGIHD_DX = 1 if `DX'1 == "K270"
replace MRTGIHD_DX = 1 if `DX'1 == "K272"
replace MRTGIHD_DX = 1 if `DX'1 == "K274"
replace MRTGIHD_DX = 1 if `DX'1 == "K276"
replace MRTGIHD_DX = 1 if `DX'1 == "K280"
replace MRTGIHD_DX = 1 if `DX'1 == "K282"
replace MRTGIHD_DX = 1 if `DX'1 == "K284"
replace MRTGIHD_DX = 1 if `DX'1 == "K286"
replace MRTGIHD_DX = 1 if `DX'1 == "K2901"
replace MRTGIHD_DX = 1 if `DX'1 == "K2921"
replace MRTGIHD_DX = 1 if `DX'1 == "K2931"
replace MRTGIHD_DX = 1 if `DX'1 == "K2941"
replace MRTGIHD_DX = 1 if `DX'1 == "K2951"
replace MRTGIHD_DX = 1 if `DX'1 == "K2961"
replace MRTGIHD_DX = 1 if `DX'1 == "K2971"
replace MRTGIHD_DX = 1 if `DX'1 == "K2981"
replace MRTGIHD_DX = 1 if `DX'1 == "K2991"
replace MRTGIHD_DX = 1 if `DX'1 == "K31811"
replace MRTGIHD_DX = 1 if `DX'1 == "K3182"
replace MRTGIHD_DX = 1 if `DX'1 == "K50011"
replace MRTGIHD_DX = 1 if `DX'1 == "K50111"
replace MRTGIHD_DX = 1 if `DX'1 == "K50811"
replace MRTGIHD_DX = 1 if `DX'1 == "K50911"
replace MRTGIHD_DX = 1 if `DX'1 == "K51011"
replace MRTGIHD_DX = 1 if `DX'1 == "K51211"
replace MRTGIHD_DX = 1 if `DX'1 == "K51311"
replace MRTGIHD_DX = 1 if `DX'1 == "K51411"
replace MRTGIHD_DX = 1 if `DX'1 == "K51511"
replace MRTGIHD_DX = 1 if `DX'1 == "K51811"
replace MRTGIHD_DX = 1 if `DX'1 == "K51911"
replace MRTGIHD_DX = 1 if `DX'1 == "K5521"
replace MRTGIHD_DX = 1 if `DX'1 == "K5701"
replace MRTGIHD_DX = 1 if `DX'1 == "K5711"
replace MRTGIHD_DX = 1 if `DX'1 == "K5713"
replace MRTGIHD_DX = 1 if `DX'1 == "K5721"
replace MRTGIHD_DX = 1 if `DX'1 == "K5731"
replace MRTGIHD_DX = 1 if `DX'1 == "K5733"
replace MRTGIHD_DX = 1 if `DX'1 == "K5741"
replace MRTGIHD_DX = 1 if `DX'1 == "K5751"
replace MRTGIHD_DX = 1 if `DX'1 == "K5753"
replace MRTGIHD_DX = 1 if `DX'1 == "K5781"
replace MRTGIHD_DX = 1 if `DX'1 == "K5791"
replace MRTGIHD_DX = 1 if `DX'1 == "K5793"
replace MRTGIHD_DX = 1 if `DX'1 == "K625"
replace MRTGIHD_DX = 1 if `DX'1 == "K6381"
replace MRTGIHD_DX = 1 if `DX'1 == "K920"
replace MRTGIHD_DX = 1 if `DX'1 == "K921"
replace MRTGIHD_DX = 1 if `DX'1 == "K922"
label var MRTGIHD_DX "FORMAT FOR Gastrointestinal hemorrhage diagnosis codes"

* FORMAT FOR Esophageal varices with bleeding */
gen FTR6GV_DX = 0

forval i = 2/35 {
	capture replace FTR6GV_DX = 1 if `DX'`i' == "I8511"
}
label var FTR6GV_DX "FORMAT FOR Esophageal varices with bleeding"
* FORMAT FOR Qualifying diagnoses associated with a diagnosis of esophageal varicies with bleeding */
gen FTR6QD_DX = 0
replace FTR6QD_DX = 1 if `DX'1 == "B180"
replace FTR6QD_DX = 1 if `DX'1 == "B181"
replace FTR6QD_DX = 1 if `DX'1 == "B182"
replace FTR6QD_DX = 1 if `DX'1 == "B188"
replace FTR6QD_DX = 1 if `DX'1 == "B189"
replace FTR6QD_DX = 1 if `DX'1 == "B190"
replace FTR6QD_DX = 1 if `DX'1 == "B1910"
replace FTR6QD_DX = 1 if `DX'1 == "B1911"
replace FTR6QD_DX = 1 if `DX'1 == "B1920"
replace FTR6QD_DX = 1 if `DX'1 == "B1921"
replace FTR6QD_DX = 1 if `DX'1 == "B199"
replace FTR6QD_DX = 1 if `DX'1 == "B651"
replace FTR6QD_DX = 1 if `DX'1 == "B652"
replace FTR6QD_DX = 1 if `DX'1 == "B658"
replace FTR6QD_DX = 1 if `DX'1 == "B659"
replace FTR6QD_DX = 1 if `DX'1 == "C220"
replace FTR6QD_DX = 1 if `DX'1 == "C221"
replace FTR6QD_DX = 1 if `DX'1 == "C222"
replace FTR6QD_DX = 1 if `DX'1 == "C223"
replace FTR6QD_DX = 1 if `DX'1 == "C224"
replace FTR6QD_DX = 1 if `DX'1 == "C227"
replace FTR6QD_DX = 1 if `DX'1 == "C228"
replace FTR6QD_DX = 1 if `DX'1 == "C229"
replace FTR6QD_DX = 1 if `DX'1 == "C787"
replace FTR6QD_DX = 1 if `DX'1 == "C7B02"
replace FTR6QD_DX = 1 if `DX'1 == "C861"
replace FTR6QD_DX = 1 if `DX'1 == "D015"
replace FTR6QD_DX = 1 if `DX'1 == "D376"
replace FTR6QD_DX = 1 if `DX'1 == "I81"
replace FTR6QD_DX = 1 if `DX'1 == "I820"
replace FTR6QD_DX = 1 if `DX'1 == "K7011"
replace FTR6QD_DX = 1 if `DX'1 == "K702"
replace FTR6QD_DX = 1 if `DX'1 == "K7030"
replace FTR6QD_DX = 1 if `DX'1 == "K7031"
replace FTR6QD_DX = 1 if `DX'1 == "K7040"
replace FTR6QD_DX = 1 if `DX'1 == "K7041"
replace FTR6QD_DX = 1 if `DX'1 == "K709"
replace FTR6QD_DX = 1 if `DX'1 == "K710"
replace FTR6QD_DX = 1 if `DX'1 == "K7110"
replace FTR6QD_DX = 1 if `DX'1 == "K7111"
replace FTR6QD_DX = 1 if `DX'1 == "K712"
replace FTR6QD_DX = 1 if `DX'1 == "K713"
replace FTR6QD_DX = 1 if `DX'1 == "K714"
replace FTR6QD_DX = 1 if `DX'1 == "K7150"
replace FTR6QD_DX = 1 if `DX'1 == "K7151"
replace FTR6QD_DX = 1 if `DX'1 == "K716"
replace FTR6QD_DX = 1 if `DX'1 == "K717"
replace FTR6QD_DX = 1 if `DX'1 == "K718"
replace FTR6QD_DX = 1 if `DX'1 == "K719"
replace FTR6QD_DX = 1 if `DX'1 == "K7200"
replace FTR6QD_DX = 1 if `DX'1 == "K7201"
replace FTR6QD_DX = 1 if `DX'1 == "K7210"
replace FTR6QD_DX = 1 if `DX'1 == "K7211"
replace FTR6QD_DX = 1 if `DX'1 == "K7290"
replace FTR6QD_DX = 1 if `DX'1 == "K7291"
replace FTR6QD_DX = 1 if `DX'1 == "K730"
replace FTR6QD_DX = 1 if `DX'1 == "K731"
replace FTR6QD_DX = 1 if `DX'1 == "K732"
replace FTR6QD_DX = 1 if `DX'1 == "K738"
replace FTR6QD_DX = 1 if `DX'1 == "K739"
replace FTR6QD_DX = 1 if `DX'1 == "K740"
replace FTR6QD_DX = 1 if `DX'1 == "K741"
replace FTR6QD_DX = 1 if `DX'1 == "K742"
replace FTR6QD_DX = 1 if `DX'1 == "K743"
replace FTR6QD_DX = 1 if `DX'1 == "K744"
replace FTR6QD_DX = 1 if `DX'1 == "K745"
replace FTR6QD_DX = 1 if `DX'1 == "K7460"
replace FTR6QD_DX = 1 if `DX'1 == "K7469"
replace FTR6QD_DX = 1 if `DX'1 == "K751"
replace FTR6QD_DX = 1 if `DX'1 == "K752"
replace FTR6QD_DX = 1 if `DX'1 == "K753"
replace FTR6QD_DX = 1 if `DX'1 == "K754"
replace FTR6QD_DX = 1 if `DX'1 == "K7581"
replace FTR6QD_DX = 1 if `DX'1 == "K7589"
replace FTR6QD_DX = 1 if `DX'1 == "K759"
replace FTR6QD_DX = 1 if `DX'1 == "K760"
replace FTR6QD_DX = 1 if `DX'1 == "K761"
replace FTR6QD_DX = 1 if `DX'1 == "K762"
replace FTR6QD_DX = 1 if `DX'1 == "K763"
replace FTR6QD_DX = 1 if `DX'1 == "K765"
replace FTR6QD_DX = 1 if `DX'1 == "K766"
replace FTR6QD_DX = 1 if `DX'1 == "K767"
replace FTR6QD_DX = 1 if `DX'1 == "K7681"
replace FTR6QD_DX = 1 if `DX'1 == "K7689"
replace FTR6QD_DX = 1 if `DX'1 == "K769"
replace FTR6QD_DX = 1 if `DX'1 == "K77"
replace FTR6QD_DX = 1 if `DX'1 == "K830"
replace FTR6QD_DX = 1 if `DX'1 == "K9182"
replace FTR6QD_DX = 1 if `DX'1 == "Q265"
replace FTR6QD_DX = 1 if `DX'1 == "Q266"
replace FTR6QD_DX = 1 if `DX'1 == "T8642"
replace FTR6QD_DX = 1 if `DX'1 == "T8643"
replace FTR6QD_DX = 1 if `DX'1 == "T8649"
label var FTR6QD_DX "FORMAT FOR Qualifying diagnoses associated with a diagnosis of esophageal varicies with bleeding"

* FORMAT FOR Liver transplant procedure codes */
gen LIVERTRP_PR = 0
forval i = 1/30 {
	capture replace LIVERTRP_PR = 1 if  `PR'`i' == "0FY00Z0"
	capture replace LIVERTRP_PR = 1 if  `PR'`i' == "0FY00Z1"
	capture replace LIVERTRP_PR = 1 if  `PR'`i' == "0FY00Z2"
}
label var LIVERTRP_PR "FORMAT FOR Liver transplant procedure codes"

replace TPIQ18 = 0 if MDC != 14 							///
					  & ( MRTGIHD_DX == 1 					///
					  | (FTR6GV_DX == 1 & FTR6QD_DX == 1 ))

replace TPIQ18 = 1 if DISPUNIFORM == 20						///
					  & MDC != 14 							///
					  & ( MRTGIHD_DX == 1 					///
					  | (FTR6GV_DX == 1 & FTR6QD_DX == 1 ))

* Exclusion for cases in hospice care at admission ;

replace TPIQ18 = . if PointOfOriginUB04 == "F"				///
					  & MDC != 14 							///
					  & ( MRTGIHD_DX == 1 					///
					  | (FTR6GV_DX == 1 & FTR6QD_DX == 1 ))

* Exclusion for liver transplant
replace TPIQ18 = . if LIVERTRP_PR == 1						///
					  & MDC != 14 							///
					  & ( MRTGIHD_DX == 1 					///
					  | (FTR6GV_DX == 1 & FTR6QD_DX == 1 ))

 * -------------------------------------------- ;
 * --- IQI 19 : HIP FRACTURE MORTALITY RATE --- ;
 * -------------------------------------------- ;

 * FORMAT FOR Hip fracture diagnosis codes */
gen MTHIPFD_DX = 0 
replace MTHIPFD_DX = 1 if `DX'1 == "M80051A"
replace MTHIPFD_DX = 1 if `DX'1 == "M80052A"
replace MTHIPFD_DX = 1 if `DX'1 == "M80059A"
replace MTHIPFD_DX = 1 if `DX'1 == "M80851A"
replace MTHIPFD_DX = 1 if `DX'1 == "M80852A"
replace MTHIPFD_DX = 1 if `DX'1 == "M80859A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72001A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72001B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72001C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72002A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72002B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72002C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72009A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72009B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72009C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72011A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72011B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72011C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72012A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72012B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72012C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72019A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72019B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72019C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72031A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72031B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72031C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72032A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72032B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72032C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72033A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72033B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72033C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72034A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72034B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72034C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72035A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72035B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72035C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72036A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72036B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72036C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72041A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72041B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72041C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72042A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72042B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72042C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72043A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72043B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72043C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72044A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72044B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72044C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72045A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72045B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72045C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72046A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72046B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72046C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72051A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72051B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72051C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72052A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72052B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72052C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72059A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72059B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72059C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72061A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72061B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72061C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72062A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72062B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72062C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72063A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72063B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72063C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72064A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72064B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72064C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72065A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72065B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72065C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72066A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72066B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72066C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72091A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72091B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72091C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72092A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72092B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72092C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72099A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72099B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72099C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72101A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72101B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72101C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72102A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72102B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72102C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72109A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72109B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72109C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72111A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72111B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72111C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72112A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72112B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72112C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72113A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72113B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72113C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72114A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72114B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72114C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72115A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72115B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72115C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72116A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72116B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72116C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72121A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72121B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72121C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72122A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72122B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72122C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72123A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72123B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72123C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72124A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72124B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72124C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72125A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72125B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72125C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72126A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72126B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72126C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72131A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72131B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72131C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72132A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72132B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72132C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72133A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72133B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72133C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72134A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72134B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72134C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72135A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72135B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72135C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72136A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72136B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72136C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72141A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72141B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72141C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72142A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72142B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72142C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72143A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72143B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72143C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72144A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72144B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72144C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72145A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72145B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72145C"
replace MTHIPFD_DX = 1 if `DX'1 == "S72146A"
replace MTHIPFD_DX = 1 if `DX'1 == "S72146B"
replace MTHIPFD_DX = 1 if `DX'1 == "S72146C"
replace MTHIPFD_DX = 1 if `DX'1 == "S7221XA"
replace MTHIPFD_DX = 1 if `DX'1 == "S7221XB"
replace MTHIPFD_DX = 1 if `DX'1 == "S7221XC"
replace MTHIPFD_DX = 1 if `DX'1 == "S7222XA"
replace MTHIPFD_DX = 1 if `DX'1 == "S7222XB"
replace MTHIPFD_DX = 1 if `DX'1 == "S7222XC"
replace MTHIPFD_DX = 1 if `DX'1 == "S7223XA"
replace MTHIPFD_DX = 1 if `DX'1 == "S7223XB"
replace MTHIPFD_DX = 1 if `DX'1 == "S7223XC"
replace MTHIPFD_DX = 1 if `DX'1 == "S7224XA"
replace MTHIPFD_DX = 1 if `DX'1 == "S7224XB"
replace MTHIPFD_DX = 1 if `DX'1 == "S7224XC"
replace MTHIPFD_DX = 1 if `DX'1 == "S7225XA"
replace MTHIPFD_DX = 1 if `DX'1 == "S7225XB"
replace MTHIPFD_DX = 1 if `DX'1 == "S7225XC"
replace MTHIPFD_DX = 1 if `DX'1 == "S7226XA"
replace MTHIPFD_DX = 1 if `DX'1 == "S7226XB"
replace MTHIPFD_DX = 1 if `DX'1 == "S7226XC"
label var MTHIPFD_DX "FORMAT FOR Hip fracture diagnosis codes"
* FORMAT FOR Periprosthetic fracture diagnosis codes
gen MTHIP2D_DX = 0
forval i = 1/35 {
	capture replace MTHIP2D_DX = 1 if `DX'`i' == "M9701XA"
	capture replace MTHIP2D_DX = 1 if `DX'`i' == "M9702XA"
	capture replace MTHIP2D_DX = 1 if `DX'`i' == "T84040A"
	capture replace MTHIP2D_DX = 1 if `DX'`i' == "T84041A"
}
label var MTHIP2D_DX "FORMAT FOR Periprosthetic fracture diagnosis codes"

replace TPIQ19 = 0 if MDC ! = 14  				 ///
					  & AGE >= 65  				 ///
					  & MTHIPFD_DX == 1 
replace TPIQ19 = 1 if DISPUNIFORM == 20  		 ///
					  & MDC ! = 14  	 		 ///
					  & AGE >= 65  		 		 ///
					  & MTHIPFD_DX == 1 
* Exclude periprosthetic fracture;					  
replace TPIQ19 = . if MTHIP2D_DX == 1   	     ///
					  & MDC ! = 14  		     ///
					  & AGE >= 65  			     ///
					  & MTHIPFD_DX == 1 
* Exclusion for cases in hospice care at admission
replace TPIQ19 = . if PointOfOriginUB04 == "F"   ///
					  & MDC ! = 14  			 ///
					  & AGE >= 65  				 ///
					  & MTHIPFD_DX == 1 
	
 * ----------------------------------------- ;
 * --- IQI 20 : PNEUMONIA MORTALITY RATE --- ;
 * ----------------------------------------- ;	

* FORMAT FOR Pneumonia diagnosis codes */
gen MTPNEUD_DX = 0
replace MTPNEUD_DX = 1 if `DX'1 == "A0222"
replace MTPNEUD_DX = 1 if `DX'1 == "A212"
replace MTPNEUD_DX = 1 if `DX'1 == "A221"
replace MTPNEUD_DX = 1 if `DX'1 == "A3701"
replace MTPNEUD_DX = 1 if `DX'1 == "A3711"
replace MTPNEUD_DX = 1 if `DX'1 == "A3781"
replace MTPNEUD_DX = 1 if `DX'1 == "A3791"
replace MTPNEUD_DX = 1 if `DX'1 == "A420"
replace MTPNEUD_DX = 1 if `DX'1 == "A430"
replace MTPNEUD_DX = 1 if `DX'1 == "A481"
replace MTPNEUD_DX = 1 if `DX'1 == "B012"
replace MTPNEUD_DX = 1 if `DX'1 == "B052"
replace MTPNEUD_DX = 1 if `DX'1 == "B250"
replace MTPNEUD_DX = 1 if `DX'1 == "B371"
replace MTPNEUD_DX = 1 if `DX'1 == "B380"
replace MTPNEUD_DX = 1 if `DX'1 == "B381"
replace MTPNEUD_DX = 1 if `DX'1 == "B382"
replace MTPNEUD_DX = 1 if `DX'1 == "B390"
replace MTPNEUD_DX = 1 if `DX'1 == "B391"
replace MTPNEUD_DX = 1 if `DX'1 == "B392"
replace MTPNEUD_DX = 1 if `DX'1 == "B440"
replace MTPNEUD_DX = 1 if `DX'1 == "B583"
replace MTPNEUD_DX = 1 if `DX'1 == "B59"
replace MTPNEUD_DX = 1 if `DX'1 == "B7781"
replace MTPNEUD_DX = 1 if `DX'1 == "J09X1"
replace MTPNEUD_DX = 1 if `DX'1 == "J1000"
replace MTPNEUD_DX = 1 if `DX'1 == "J1001"
replace MTPNEUD_DX = 1 if `DX'1 == "J1008"
replace MTPNEUD_DX = 1 if `DX'1 == "J1100"
replace MTPNEUD_DX = 1 if `DX'1 == "J1108"
replace MTPNEUD_DX = 1 if `DX'1 == "J120"
replace MTPNEUD_DX = 1 if `DX'1 == "J121"
replace MTPNEUD_DX = 1 if `DX'1 == "J122"
replace MTPNEUD_DX = 1 if `DX'1 == "J123"
replace MTPNEUD_DX = 1 if `DX'1 == "J1281"
replace MTPNEUD_DX = 1 if `DX'1 == "J1289"
replace MTPNEUD_DX = 1 if `DX'1 == "J129"
replace MTPNEUD_DX = 1 if `DX'1 == "J13"
replace MTPNEUD_DX = 1 if `DX'1 == "J14"
replace MTPNEUD_DX = 1 if `DX'1 == "J150"
replace MTPNEUD_DX = 1 if `DX'1 == "J151"
replace MTPNEUD_DX = 1 if `DX'1 == "J1520"
replace MTPNEUD_DX = 1 if `DX'1 == "J15211"
replace MTPNEUD_DX = 1 if `DX'1 == "J15212"
replace MTPNEUD_DX = 1 if `DX'1 == "J1529"
replace MTPNEUD_DX = 1 if `DX'1 == "J153"
replace MTPNEUD_DX = 1 if `DX'1 == "J154"
replace MTPNEUD_DX = 1 if `DX'1 == "J155"
replace MTPNEUD_DX = 1 if `DX'1 == "J156"
replace MTPNEUD_DX = 1 if `DX'1 == "J157"
replace MTPNEUD_DX = 1 if `DX'1 == "J158"
replace MTPNEUD_DX = 1 if `DX'1 == "J159"
replace MTPNEUD_DX = 1 if `DX'1 == "J160"
replace MTPNEUD_DX = 1 if `DX'1 == "J168"
replace MTPNEUD_DX = 1 if `DX'1 == "J17"
replace MTPNEUD_DX = 1 if `DX'1 == "J180"
replace MTPNEUD_DX = 1 if `DX'1 == "J181"
replace MTPNEUD_DX = 1 if `DX'1 == "J188"
replace MTPNEUD_DX = 1 if `DX'1 == "J189"
label var MTPNEUD_DX "FORMAT FOR Pneumonia diagnosis codes"

replace TPIQ20 = 0 if MDC ! = 14   						///
					  & MTPNEUD_DX == 1 
replace TPIQ20 = 1 if DISPUNIFORM == 20   				///
					  & MDC ! = 14   					///
					  & MTPNEUD_DX == 1  
* Exclusion for cases in hospice care at admission
replace TPIQ20 = . if PointOfOriginUB04 == "F"   		///
					  & DISPUNIFORM == 20   			///
					  & MDC ! = 14 & MTPNEUD_DX == 1 

* --- CONSTRUCT ADDITIONAL PROVIDER LEVEL MORTALITY INDICATORS - ;

 * ------------------------------------------------------------------------ ;
 * --- IQI 30 : PERCUTANEOUS CORONARY INTERVENTION (PCI) MORTALITY RATE --- ;
 * ------------------------------------------------------------------------ ;

* FORMAT FOR Percutaneous coronary intervention (PCI) procedure codes */
gen PRPTCAP_PR = 0
forval i = 1/30 {
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0270346"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027034Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0270356"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027035Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0270366"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027036Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0270376"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027037Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703D6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703DZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703E6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703EZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703F6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703FZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703G6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703GZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703Z6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02703ZZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0270446"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027044Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0270456"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027045Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0270466"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027046Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0270476"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027047Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704D6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704DZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704E6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704EZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704F6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704FZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704G6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704GZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704Z6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02704ZZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0271346"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027134Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0271356"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027135Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0271366"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027136Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0271376"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027137Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713D6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713DZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713E6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713EZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713F6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713FZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713G6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713GZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713Z6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02713ZZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0271446"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027144Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0271456"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027145Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0271466"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027146Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0271476"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027147Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714D6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714DZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714E6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714EZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714F6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714FZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714G6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714GZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714Z6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02714ZZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0272346"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027234Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0272356"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027235Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0272366"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027236Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0272376"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027237Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723D6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723DZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723E6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723EZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723F6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723FZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723G6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723GZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723Z6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02723ZZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0272446"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027244Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0272456"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027245Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0272466"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027246Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0272476"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027247Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724D6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724DZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724E6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724EZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724F6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724FZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724G6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724GZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724Z6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02724ZZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0273346"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027334Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0273356"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027335Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0273366"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027336Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0273376"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027337Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733D6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733DZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733E6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733EZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733F6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733FZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733G6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733GZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733Z6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02733ZZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0273446"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027344Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0273456"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027345Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0273466"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027346Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "0273476"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "027347Z"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734D6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734DZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734E6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734EZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734F6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734FZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734G6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734GZ"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734Z6"
	capture replace PRPTCAP_PR = 1 if `PR'`i' == "02734ZZ"
}
label var PRPTCAP_PR "FORMAT FOR Percutaneous coronary intervention (PCI) procedure codes"
replace TPIQ30 = 0 if MDC ! = 14   						///
					  & AGE >= 40   					///
					  & PRPTCAP_PR == 1  				
replace TPIQ30 = 1 if DISPUNIFORM == 20   				///
					  & MDC ! = 14   					///
					  & AGE >= 40   					///
					  & PRPTCAP_PR == 1	  				
		
 * ------------------------------------------------------ ;
 * --- IQI 31 : CAROTID ENDARTERECTOMY MORTALITY RATE --- ;
 * ------------------------------------------------------ ;

 * FORMAT FOR Carotid endarterectomy procedure codes */
gen PRCEATP_PR = 0 
forval i = 1/30 {
	capture replace PRCEATP_PR = 1 if `PR'`i' == "03CH0Z6"
	capture replace PRCEATP_PR = 1 if `PR'`i' == "03CH0ZZ"
	capture replace PRCEATP_PR = 1 if `PR'`i' == "03CJ0Z6"
	capture replace PRCEATP_PR = 1 if `PR'`i' == "03CJ0ZZ"
	capture replace PRCEATP_PR = 1 if `PR'`i' == "03CK0Z6"
	capture replace PRCEATP_PR = 1 if `PR'`i' == "03CK0ZZ"
	capture replace PRCEATP_PR = 1 if `PR'`i' == "03CL0Z6"
	capture replace PRCEATP_PR = 1 if `PR'`i' == "03CL0ZZ"
}
label var PRCEATP_PR "FORMAT FOR Carotid endarterectomy procedure codes"

replace TPIQ31 = 0 if MDC ! = 14 & PRCEATP_PR == 1 
replace TPIQ31 = 1 if DISPUNIFORM == 20 & MDC ! = 14 & PRCEATP_PR == 1 
	
 * --- CONSTRUCT PROVIDER LEVEL UTILIZATION INDICATORS ---------- ;

 * --------------------------------------------------------- ;
 * --- IQI 21 : CESAREAN SECTION DELIVERY, UNCOMPLICATED --- ;
 * --------------------------------------------------------- ;

	
* FORMAT FOR Outcome of delivery diagnosis codes */
gen DELOCMD_DX = 0
forval i = 1/35 {
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z370" 
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z371" 
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z372" 
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z373" 
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z374" 
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3750"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3751"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3752"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3753"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3754"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3759"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3760"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3761"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3762"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3763"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3764"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z3769"
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z377" 
	capture replace DELOCMD_DX = 1 if `DX'`i' == "Z379" 
}
label var DELOCMD_DX "FORMAT FOR Outcome of delivery diagnosis codes"
* FORMAT FOR Cesarean delivery MS-DRG codes 
gen PRCSE2G_DRG = 0
replace PRCSE2G_DRG = 1 if `DRG' == 765
replace PRCSE2G_DRG = 1 if `DRG' == 766
label var PRCSE2G_DRG "FORMAT FOR Cesarean delivery MS-DRG codes"
* FORMAT FOR Cesarean delivery procedure codes 
gen PRCSECP_PR = 0
forval i = 1/30 {
	capture replace PRCSECP_PR = 1 if `PR'`i' == "10D00Z0"
	capture replace PRCSECP_PR = 1 if `PR'`i' == "10D00Z1"
	capture replace PRCSECP_PR = 1 if `PR'`i' == "10D00Z2"
}
label var PRCSECP_PR "FORMAT FOR Cesarean delivery procedure codes "

* FORMAT FOR Hysterotomy procedure codes */
gen PRCSE2P_PR = 0
forval i = 1/30 {
	capture replace PRCSE2P_PR = 1 if `PR'`i' == "10A00ZZ"
	capture replace PRCSE2P_PR = 1 if `PR'`i' == "10A03ZZ"
	capture replace PRCSE2P_PR = 1 if `PR'`i' == "10A04ZZ"
}
label var PRCSE2P_PR "FORMAT FOR Hysterotomy procedure codes"

* FORMAT FOR Abnormal presentation, fetal death, and multiple gestation diagnosis codes */
gen PRCSECD_DX = 0 
forval i = 1/35 {
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30001" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30002" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30003" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30009" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30011" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30012" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30013" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30019" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30021" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30022" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30023" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30029" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30031" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30032" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30033" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30039" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30041" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30042" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30043" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30049" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30091" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30092" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30093" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30099" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30101" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30102" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30103" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30109" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30111" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30112" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30113" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30119" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30121" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30122" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30123" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30129" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30131" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30132" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30133" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30139" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30191" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30192" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30193" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30199" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30201" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30202" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30203" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30209" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30211" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30212" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30213" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30219" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30221" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30222" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30223" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30229" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30231" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30232" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30233" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30239" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30291" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30292" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30293" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30299" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30801" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30802" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30803" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30809" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30811" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30812" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30813" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30819" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30821" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30822" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30823" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30829" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30831" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30832" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30833" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30839" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30891" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30892" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30893" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O30899" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3090" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3091" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3092" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3093" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3110X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3110X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3110X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3110X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3110X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3110X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3110X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3111X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3111X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3111X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3111X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3111X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3111X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3111X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3112X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3112X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3112X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3112X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3112X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3112X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3112X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3113X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3113X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3113X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3113X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3113X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3113X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3113X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3120X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3120X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3120X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3120X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3120X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3120X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3120X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3121X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3121X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3121X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3121X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3121X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3121X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3121X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3122X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3122X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3122X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3122X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3122X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3122X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3122X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3123X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3123X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3123X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3123X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3123X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3123X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O3123X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X10" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X11" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X12" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X13" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X14" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X15" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X19" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X20" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X21" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X22" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X23" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X24" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X25" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X29" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X30" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X31" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X32" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X33" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X34" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X35" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X39" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X90" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X91" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X92" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X93" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X94" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X95" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O318X99" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O321XX0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O321XX1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O321XX2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O321XX3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O321XX4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O321XX5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O321XX9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O322XX0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O322XX1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O322XX2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O322XX3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O322XX4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O322XX5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O322XX9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O323XX0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O323XX1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O323XX2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O323XX3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O323XX4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O323XX5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O323XX9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O329XX0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O329XX1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O329XX2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O329XX3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O329XX4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O329XX5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O329XX9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O364XX0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O364XX1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O364XX2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O364XX3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O364XX4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O364XX5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O364XX9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6010X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6010X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6010X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6010X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6010X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6010X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6010X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6012X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6012X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6012X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6012X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6012X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6012X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6012X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6013X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6013X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6013X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6013X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6013X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6013X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6013X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6014X0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6014X1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6014X2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6014X3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6014X4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6014X5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O6014X9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O632" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O641XX0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O641XX1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O641XX2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O641XX3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O641XX4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O641XX5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O641XX9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O642XX0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O642XX1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O642XX2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O642XX3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O642XX4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O642XX5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O642XX9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O643XX0" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O643XX1" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O643XX2" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O643XX3" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O643XX4" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O643XX5" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O643XX9" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O661" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "O666" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z371" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z372" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z373" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z374" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3750" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3751" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3752" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3753" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3754" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3759" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3760" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3761" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3762" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3763" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3764" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z3769" 
	capture replace PRCSECD_DX = 1 if `DX'`i' == "Z377" 
}
label var PRCSECD_DX "FORMAT FOR Abnormal presentation, fetal death, and multiple gestation diagnosis codes"

replace TPIQ21 = 0 if DELOCMD_DX == 1
replace TPIQ21 = 1 if DELOCMD_DX == 1 							 ///
					  & (PRCSE2G_DRG == 1  						 ///
					  | (PRCSECP_PR == 1 & PRCSE2P_PR != 1))	 
	
replace TPIQ21 = . if DELOCMD_DX == 1 							 ///
					  & PRCSECD_DX == 1

 * --------------------------------------------------------------------------------- ;
 * --- IQI 22 : VAGINAL BIRTH AFTER CESAREAN (VBAC) DELIVERY RATE, UNCOMPLICATED --- ;
 * --------------------------------------------------------------------------------- ;
* FORMAT FOR Previous Cesarean delivery diagnosis codes */
gen PRVBACD_DX = 0
forval i = 1/35 {
	capture replace PRVBACD_DX = 1 if `DX'`i' == "O3421" 
	capture replace PRVBACD_DX = 1 if `DX'`i' == "O34211"
	capture replace PRVBACD_DX = 1 if `DX'`i' == "O34212"
	capture replace PRVBACD_DX = 1 if `DX'`i' == "O34219"
	capture replace PRVBACD_DX = 1 if `DX'`i' == "O6641" 
}	
label var PRVBACD_DX "FORMAT FOR Previous Cesarean delivery diagnosis codes"
	
	
* FORMAT FOR Vaginal delivery procedure codes */
gen VAGDELP_PR = 0
forval i = 1/30 {
	capture replace VAGDELP_PR = 1 if `PR'`i' == "10D07Z3"
	capture replace VAGDELP_PR = 1 if `PR'`i' == "10D07Z4"
	capture replace VAGDELP_PR = 1 if `PR'`i' == "10D07Z5"
	capture replace VAGDELP_PR = 1 if `PR'`i' == "10D07Z6"
	capture replace VAGDELP_PR = 1 if `PR'`i' == "10D07Z7"
	capture replace VAGDELP_PR = 1 if `PR'`i' == "10D07Z8"
	capture replace VAGDELP_PR = 1 if `PR'`i' == "10E0XZZ"
}
label var VAGDELP_PR "FORMAT FOR Vaginal delivery procedure codes"

replace TPIQ22 = 0 if DELOCMD_DX == 1 			///
					  & PRVBACD_DX == 1   
replace TPIQ34 = 0 if DELOCMD_DX == 1  			///
					  & PRVBACD_DX == 1 

replace TPIQ22 = 1 if DELOCMD_DX == 1 			/// 
					  & PRVBACD_DX == 1 		///
					  & VAGDELP_PR == 1
replace TPIQ34 = 1 if DELOCMD_DX == 1 			/// 
					  & PRVBACD_DX == 1 		///
					  & VAGDELP_PR == 1
	
replace TPIQ22 = . if DELOCMD_DX == 1 			///
					  & PRVBACD_DX == 1 	    ///
					  & PRCSECD_DX == 1
	
 * -------------------------------------------------------------- ;
 * --- IQI 33 : PRIMARY CESAREAN DELIVERY RATE, UNCOMPLICATED --- ;
 * -------------------------------------------------------------- ;

replace TPIQ33 = 0 if DELOCMD_DX == 1
replace TPIQ33 = 1 if DELOCMD_DX == 1 							 ///
					  & (PRCSE2G_DRG == 1  						 ///
					  | (PRCSECP_PR == 1 & PRCSE2P_PR != 1))	 

replace TPIQ33 = . if DELOCMD_DX == 1 							 ///
					  & (PRCSECD_DX == 1 | PRVBACD_DX == 1)

 * -------------------------------------------------------------- ;
 * --- EXCLUDE CASES WITH MISSING VALUES FOR DISP OR ASOURCE  --- ;
 * -------------------------------------------------------------- ;
replace TPIQ08  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ09  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ09_WITH_CANCER = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ09_WITHOUT_CANCER = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ11  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ11_OPEN_RUPTURED = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ11_OPEN_UNRUPTURED = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ11_ENDO_RUPTURED = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ11_ENDO_UNRUPTURED = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ12  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ15  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ16  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ17  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ17_HEMSTROKE_SUBARACH = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ17_HEMSTROKE_INTRACER = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ17_ISCHEMSTROKE = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ18  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ19  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ20  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ30  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ31  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)
replace TPIQ32  = . if DISPUNIFORM < 0 | missing(DISPUNIFORM)

replace TPIQ32 = . if missing(PointOfOriginUB04)
	
 * -------------------------------------------------------------- ;
 * --- EXCLUDE TRANSFERS ---------------------------------------- ;
 * -------------------------------------------------------------- ;

* --- TRANSFER FROM ANOTHER ACUTE CARE HOSPITAL ---------------- 
replace TPIQ32 = . if PointOfOriginUB04 == "4" 
* --- TRANSFER TO ANOTHER ACUTE CARE HOSPITAL ------------------
replace TPIQ08   = . if DISPUNIFORM == 2
replace TPIQ09   = . if DISPUNIFORM == 2
replace TPIQ09_WITH_CANCER  = . if DISPUNIFORM == 2
replace TPIQ09_WITHOUT_CANCER  = . if DISPUNIFORM == 2
replace TPIQ11   = . if DISPUNIFORM == 2
replace TPIQ11_OPEN_RUPTURED  = . if DISPUNIFORM == 2
replace TPIQ11_OPEN_UNRUPTURED  = . if DISPUNIFORM == 2
replace TPIQ11_ENDO_RUPTURED  = . if DISPUNIFORM == 2
replace TPIQ11_ENDO_UNRUPTURED  = . if DISPUNIFORM == 2
replace TPIQ12   = . if DISPUNIFORM == 2
replace TPIQ15   = . if DISPUNIFORM == 2
replace TPIQ16   = . if DISPUNIFORM == 2
replace TPIQ17   = . if DISPUNIFORM == 2
replace TPIQ17_HEMSTROKE_SUBARACH  = . if DISPUNIFORM == 2
replace TPIQ17_HEMSTROKE_INTRACER  = . if DISPUNIFORM == 2
replace TPIQ17_ISCHEMSTROKE  = . if DISPUNIFORM == 2
replace TPIQ18   = . if DISPUNIFORM == 2
replace TPIQ19   = . if DISPUNIFORM == 2
replace TPIQ20   = . if DISPUNIFORM == 2
replace TPIQ30   = . if DISPUNIFORM == 2
replace TPIQ31   = . if DISPUNIFORM == 2
replace TPIQ32   = . if DISPUNIFORM == 2
	
	
 * -------------------------------------------------------------- ;
 * --- IDENTIFY TRANSFERS --------------------------------------- ;
 * -------------------------------------------------------------- ;
gen TRNSFER = 0
replace TRNSFER = 1 if PointOfOriginUB04 == "4" 
label var TRNSFER "Transfer from Another Acute Care Hospital"
end 
quality 












