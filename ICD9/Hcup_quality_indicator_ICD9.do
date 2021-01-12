 * -------------------------------------------------------------- ;
 * --- INPATIENT QUALITY INDICATOR (IQI) NAMING CONVENTION:   --- ;
 * --- THE FIRST LETTER IDENTIFIES THE INPATIENT QUALITY      --- ;
 * --- INDICATOR AS ONE OF THE FOLLOWING:
 *               (T) NUMERATOR ("TOP")
 *               (P) POPULATION ("POP")
 * --- THE SECOND LETTER IDENTIFIES THE IQI AS A PROVIDER (P) --- ;
 * --- OR AN AREA (A) LEVEL INDICATOR.  THE                   --- ;
 * --- NEXT TWO CHARACTERS ARE ALWAYS 'IQ'. THE LAST TWO      --- ;
 * --- DIGITS ARE THE INDICATOR NUMBER (WITHIN THAT SUBTYPE). --- ;
 * -------------------------------------------------------------- ;


keep KEY DSHOSPID DRG MDC FEMALE AGE RACE YEAR DQTR PAY1 PAY2 LOS PSTCO DISP* PointOfOrigin* DX1* DX2* DX3* PR1* PR2* PR3* DXPOA*

* -------------------------------------------------------------- ;
* --- DEFINE MDC                        ------------------------ ;
* -------------------------------------------------------------- ;

capture gen DRGVER = 0 
capture replace DRGVER = 25 if YEAR == 2007 & DQTR == 4     
capture replace DRGVER = 25 if YEAR == 2008 & DQTR < 4 & DQTR != .
capture replace DRGVER = 26 if YEAR == 2008 & DQTR == 4     
capture replace DRGVER = 26 if YEAR == 2009 & DQTR < 4 & DQTR != .
capture replace DRGVER = 27 if YEAR == 2009 & DQTR == 4 	 
capture replace DRGVER = 27 if YEAR == 2010 & DQTR < 4 & DQTR != .
capture replace DRGVER = 28 if YEAR == 2010 & DQTR == 4 	 
capture replace DRGVER = 28 if YEAR == 2011 & DQTR < 4 & DQTR != .
capture replace DRGVER = 29 if YEAR == 2011 & DQTR == 4 	 
capture replace DRGVER = 29 if YEAR == 2012 & DQTR < 4 & DQTR != .
capture replace DRGVER = 30 if YEAR == 2012 & DQTR == 4 	 
capture replace DRGVER = 30 if YEAR == 2013 & DQTR < 4 & DQTR != .
capture replace DRGVER = 31 if YEAR == 2013 & DQTR == 4     
capture replace DRGVER = 31 if YEAR == 2014 & DQTR < 4 & DQTR != .
capture replace DRGVER = 32 if YEAR == 2014 & DQTR == 4     
capture replace DRGVER = 32 if YEAR == 2015 & DQTR < 4 & DQTR != .
capture replace DRGVER = 33 if YEAR == 2015 & DQTR == 4     
capture replace DRGVER = 33 if YEAR == 2016 & DQTR < 4 & DQTR != .

gen MDCNEW = MDC if MDC>= 1 & MDC<=25
capture replace MDCNEW = . if MDC< 1 & MDC>25

* ------------------------------------------------------------------------- ;
* --- DELETE RECORDS WITH MISSING VALUES FOR AGE, SEX, DX1, DQTR, & YEAR -- ;
* --- DELETE NON ADULT RECORDS                         -------------------- ;
* ------------------------------------------------------------------------- ;

drop if FEMALE < 0 | AGE < 0 
drop if AGE < 18 & MDC != 14 
drop if missing(DX1) | DQTR == . | YEAR == .


* -------------------------------------------------------------- ;
* --- DEFINE ICD-9-CM VERSION           ------------------------ ;
* -------------------------------------------------------------- ;

gen ICDVER = 0 
capture replace ICDVER = 25 if YEAR == 2007 & DQTR == 4     
capture replace ICDVER = 25 if YEAR == 2008 & DQTR < 4 & DQTR != .
capture replace ICDVER = 26 if YEAR == 2008 & DQTR == 4     
capture replace ICDVER = 26 if YEAR == 2009 & DQTR < 4 & DQTR != .
capture replace ICDVER = 27 if YEAR == 2009 & DQTR == 4 	 
capture replace ICDVER = 27 if YEAR == 2010 & DQTR < 4 & DQTR != .
capture replace ICDVER = 28 if YEAR == 2010 & DQTR == 4 	 
capture replace ICDVER = 28 if YEAR == 2011 & DQTR < 4 & DQTR != .
capture replace ICDVER = 29 if YEAR == 2011 & DQTR == 4 	 
capture replace ICDVER = 29 if YEAR == 2012 & DQTR < 4 & DQTR != .
capture replace ICDVER = 30 if YEAR == 2012 & DQTR == 4 	 
capture replace ICDVER = 30 if YEAR == 2013 & DQTR < 4 & DQTR != .
capture replace ICDVER = 31 if YEAR == 2013 & DQTR == 4     
capture replace ICDVER = 31 if YEAR == 2014 & DQTR < 4 & DQTR != .
capture replace ICDVER = 32 if YEAR == 2014 & DQTR == 4 
capture replace ICDVER = 32 if YEAR == 2015 & DQTR < 4 & DQTR != .

* ------------------------------------------------------------- ;
* --- DEFINE STRATIFIER: PAYER CATEGORY ----------------------- ;
* ------------------------------------------------------------- ;

 gen PAYCAT = PAY1 if PAY1 <=5 
 capture replace PAYCAT = 6 if PAY1 >5
 label var PAYCAT "Patient Primary Payer"

* ------------------------------------------------------------- ;
* --- DEFINE STRATIFIER: RACE CATEGORY ------------------------ ;
* ------------------------------------------------------------- ;

gen RACECAT = RACE if RACE <=5
capture replace RACECAT = 6 if RACE > 5
label var RACECAT "Race Categories"


gen DUALCAT = 0
capture replace DUALCAT = 1 if (PAY1 == 1 & PAY2 == 2) | (PAY1 == 2 & PAY2 == 1)
label var DUALCAT "PATIENT DUAL ELIGIBLE"

* -------------------------------------------------------------- ;
* --- DEFINE STRATIFIER: AGE CATEGORY  ------------------------- ;
* -------------------------------------------------------------- ;

recode AGE (0/17 = 0) (18/39 = 1) (40/64 = 2) (65/74 = 3),  gen(AGECAT)
capture replace AGECAT = 4 if AGECAT >= 75
label var AGECAT "Age Categories"

* -------------------------------------------------------------- ;
* --- DEFINE STRATIFIER: SEX CATEGORY  ------------------------- ;
* -------------------------------------------------------------- ;
gen SEXCAT = FEMALE 
capture replace SEXCAT = 0 if FEMALE < 1 & FEMALE > 2 
label var SEXCAT "Sex Categories"
label var DSHOSPID "Hospital Identification Number"

* -------------------------------------------------------------- ;
* --- DEFINE PROVIDER LEVEL MORTALITY INDICATORS --------------- ;
* -------------------------------------------------------------- ;
gen TPIQ08 = 0 
gen TPIQ09 = 0 
gen TPIQ09A = 0 
gen TPIQ09B = 0 
gen TPIQ11 = 0 
gen TPIQ11A = 0 
gen TPIQ11B = 0 
gen TPIQ11C = 0 
gen TPIQ11D = 0 
gen TPIQ12 = 0 
gen TPIQ15 = 0 
gen TPIQ16 = 0 
gen TPIQ17 = 0 
gen TPIQ17A = 0 
gen TPIQ17B = 0 
gen TPIQ17C = 0 
gen TPIQ18 = 0 
gen TPIQ19 = 0 
gen TPIQ20 = 0 
gen TPIQ30 = 0
gen TPIQ31 = 0
gen TPIQ32 = 0

label var TPIQ08 "IQI 08 Esophageal Resection Mortality Rate (Numerator)"
label var TPIQ09 "IQI 09 Pancreatic Resection Mortality Rate (Numerator)"
label var TPIQ09A "IQI 09 Pancreatic Resection Mortality Rate Stratum : Presence of Pancreatic Cancer (Numerator)"
label var TPIQ09B "IQI 09 Pancreatic Resection Mortality Rate Stratum: Absence of Pancreatic Cancer (Numerator)"
label var TPIQ11 "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate (Numerator)"
label var TPIQ11A "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate Stratum_OPEN_RUPTURED: Open Repair of Ruptured AAA (Numerator)"
label var TPIQ11B "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate Stratum_OPEN_UNRUPTURED: Open Repair of Unruptured AAA (Numerator)"
label var TPIQ11C "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate Stratum_ENDO_RUPTURED: Endovascular Repair of Ruptured AAA (Numerator)"
label var TPIQ11D "IQI 11 Abdominal Aortic Aneurysm (AAA) Repair Mortality Rate Stratum_ENDO_UNRUPTURED: Endovascular Repair of Unruptured AAA (Numerator)"
label var TPIQ12 "IQI 12 Coronary Artery Bypass Graft (CABG) Mortality Rate (Numerator)"
label var TPIQ15 "IQI 15 Acute Myocardial Infarction (AMI) Mortality Rate (Numerator)"
label var TPIQ16 "IQI 16 Heart Failure Mortality Rate (Numerator)"
label var TPIQ17 "IQI 17 Acute Stroke Mortality Rate (Numerator)"
label var TPIQ17A "IQI 17 Acute Stroke Mortality Rate Stratum_HEMSTROKE_SUBARACH: Subarachnoid Hemorrhage (Numerator)"
label var TPIQ17B "IQI 17 Acute Stroke Mortality Rate Stratum_HEMSTROKE_INTRACER: Intracerebral Hemorrhage (Numerator)"
label var TPIQ17C "IQI 17 Acute Stroke Mortality Rate Stratum_ISCHEMSTROKE: Ischemic Stroke (Numerator)"
label var TPIQ18 "IQI 18 Gastrointestinal Hemorrhage Mortality Rate (Numerator)"
label var TPIQ19 "IQI 19 Hip Fracture Mortality Rate (Numerator)"
label var TPIQ20 "IQI 20 Pneumonia Mortality Rate (Numerator)"
label var TPIQ30 "IQI 30 Percutaneous Coronary Intervention (PCI) Mortality Rate (Numerator)"
label var TPIQ31 "IQI 31 Carotid Endarterectomy Mortality Rate (Numerator)"
label var TPIQ32 "IQI 32 Acute Myocardial Infarction (AMI) Mortality Rate, Without Transfer Cases (Numerator)"

 * -------------------------------------------------------------- ;
 * --- DEFINE PROVIDER LEVEL UTILIZATION INDICATORS ------------- ;
 * -------------------------------------------------------------- ;

gen TPIQ21 = 0
gen TPIQ22 = 0
gen TPIQ23 = 0
gen TPIQ24 = 0
gen TPIQ25 = 0
gen TPIQ33 = 0
gen TPIQ34 = 0

label var TPIQ21 "IQI 21 Cesarean Delivery Rate, Uncomplicated (Numerator)"
label var TPIQ22 "IQI 22 Vaginal Birth After Cesarean (VBAC) Delivery Rate, Uncomplicated (Numerator)"
label var TPIQ23 "Laparoscopic Cholecystectomy Rate (Numerator)"
label var TPIQ24 "Incidental Appendectomy in the Elderly Rate (Numerator)"
label var TPIQ25 "Bilateral Cardiac Catheterization Rate (Numerator)"
label var TPIQ33 "Primary Cesarean Delivery Rate, Uncomplicated (Numerator)"
label var TPIQ34 "Vaginal Birth After Cesarean (VBAC) Rate, All (Numerator)"

 * ----------------------------------------------------- ;
 * --- CONSTRUCT PROVIDER LEVEL MORTALITY INDICATORS --- ;
 * ----------------------------------------------------- ;

* FORMAT FOR Esophageal resection procedure codes
gen PRESOPP_IQI_PR = 0
forval i = 1/30 {
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "424"   /* ESOPHAGECTOMY */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4240"  /* ESOPHAGECTOMY NOS */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4241"  /* PARTIAL ESOPHAGECTOMY */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4242"  /* TOTAL ESOPHAGECTOMY */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "425"   /* THORAC ESOPHAG ANAST */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4251"  /* THORAC ESOPHAGOESOPHAGOS */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4252"  /* THORAC ESOPHAGOGASTROST */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4253"  /* THORAC SM BOWEL INTERPOS */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4254"  /* THORAC ESOPHAGOENTER NEC */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4255"  /* THORAC LG BOWEL INTERPOS */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4256"  /* THORAC ESOPHAGOCOLOS NEC */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4258"  /* THORAC INTERPOSITION NEC */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4259"  /* THORAC ESOPHAG ANAST NEC */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "426"   /* STERN ESOPHAG ANAST */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4261"  /* STERN ESOPHAGOESOPHAGOST */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4262"  /* STERN ESOPHAGOGASTROSTOM */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4263"  /* STERN SM BOWEL INTERPOS */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4264"  /* STERN ESOPHAGOENTER NEC */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4265"  /* STERN LG BOWEL INTERPOS */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4266"  /* STERN ESOPHAGOCOLOS NEC */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4268"  /* STERN INTERPOSITION NEC */
	capture replace PRESOPP_IQI_PR = 1 if PR`i' == "4269"  /* STERN ESOPHAG ANAST NEC */
}
label var PRESOPP_IQI_PR "FORMAT FOR Esophageal resection procedure codes"

* FORMAT FOR Esophageal cancer diagnosis codes */
gen PRESOPD_DX = 0
forval i = 1/35 {
	capture replace PRESOPD_DX = 1 if DX`i' == "1500"  /* MAL NEO CERVICAL ESOPHAG */
	capture replace PRESOPD_DX = 1 if DX`i' == "1501"  /* MAL NEO THORACIC ESOPHAG */
	capture replace PRESOPD_DX = 1 if DX`i' == "1502"  /* MAL NEO ABDOMIN ESOPHAG */
	capture replace PRESOPD_DX = 1 if DX`i' == "1503"  /* MAL NEO UPPER 3RD ESOPH */
	capture replace PRESOPD_DX = 1 if DX`i' == "1504"  /* MAL NEO MIDDLE 3RD ESOPH */
	capture replace PRESOPD_DX = 1 if DX`i' == "1505"  /* MAL NEO LOWER 3RD ESOPH */
	capture replace PRESOPD_DX = 1 if DX`i' == "1508"  /* MAL NEO ESOPHAGUS NEC */
	capture replace PRESOPD_DX = 1 if DX`i' == "1509"  /* MAL NEO ESOPHAGUS NOS */
}
label var PRESOPD_DX "FORMAT FOR Esophageal cancer diagnosis codes"

* FORMAT FOR Gastrointestinal-related cancer diagnosis codes */
gen PRESO2D_DX = 0
forval i = 1/35 {
	capture replace PRESO2D_DX = 1 if DX`i' == "1510" /* MAL NEO STOMACH CARDIA */
	capture replace PRESO2D_DX = 1 if DX`i' == "1978" /* SEC MAL NEO GI NEC */
	capture replace PRESO2D_DX = 1 if DX`i' == "2301" /* CA IN SITU ESOPHAGUS */
	capture replace PRESO2D_DX = 1 if DX`i' == "2355" /* UNC BEHAV NEO GI NEC */
}
label var PRESO2D_DX "FORMAT FOR Gastrointestinal-related cancer diagnosis codes"

* FORMAT FOR Esophageal resection procedure codes */

gen PRESO2P_PR = 0
forval i = 1/30 {
	capture replace PRESO2P_PR = 1 if PR`i' == "4399" /* TOTAL GASTRECTOMY NEC */
}
label var PRESO2P_PR "FORMAT FOR Esophageal resection procedure codes"

capture replace TPIQ08 = 1 if DISPUNIFORM == 20 & (MDC != 14 &  ///
		((PRESOPP_IQI_PR == 1 &  ( PRESOPD_DX == 1 | PRESO2D_DX == 1 ) ) ///
		| (PRESO2P_PR == 1 & PRESOPD_DX == 1))) ///

 * -------------------------------------------------- ; 
 * --- IQI 09 : IN-HOSP MORT PANCREATIC RESECTION --- ;
 * -------------------------------------------------- ;
* FORMAT FOR Total pancreatic resection procedure codes 
gen PRPANCP_PR = 0
forval i = 1/30 {
	capture replace PRPANCP_PR = 1 if PR`i' == "526" /* TOTAL PANCREATECTOMY */
	capture replace PRPANCP_PR = 1 if PR`i' == "527" /* RAD PANCREATICODUODENECT */
}
label var PRPANCP_PR "FORMAT FOR Total pancreatic resection procedure codes"


* FORMAT FOR Partial pancreatic resection procedure codes	
gen PRPAN3P_PR = 0
forval i = 1/30 {
	capture replace PRPAN3P_PR = 1 if PR`i' == "5251" /* Proximal pancreatectomy */
	capture replace PRPAN3P_PR = 1 if PR`i' == "5252" /* Distal pancreatectomy */
	capture replace PRPAN3P_PR = 1 if PR`i' == "5253" /* Rad subtot pancreatectom */
	capture replace PRPAN3P_PR = 1 if PR`i' == "5259" /* Partial pancreatect NEC */
}
label var PRPAN3P_PR "FORMAT FOR Partial pancreatic resection procedure codes"


* FORMAT FOR Pancreatic cancer diagnosis codes
gen PRPANCD_DX = 0
forval i = 1/35 {

	capture replace PRPANCD_DX  = 1 if DX`i' == "1520"  /* MALIGNANT NEOPL DUODENUM */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1561"  /* MAL NEO EXTRAHEPAT DUCTS */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1562"  /* MAL NEO AMPULLA OF VATER */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1570"  /* MAL NEO PANCREAS HEAD */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1571"  /* MAL NEO PANCREAS BODY */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1572"  /* MAL NEO PANCREAS TAIL */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1573"  /* MAL NEO PANCREATIC DUCT */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1574"  /* MAL NEO ISLET LANGERHANS */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1578"  /* MALIG NEO PANCREAS NEC */
	capture replace PRPANCD_DX  = 1 if DX`i' == "1579"  /*-MALIG NEO PANCREAS NOS-*/

}
label var PRPANCD_DX "FORMAT FOR Pancreatic cancer diagnosis codes"


* FORMAT FOR Acute pancreatitis diagnosis codes
gen PRPAN2D_DX = 0
forval i = 1/35 {
	capture replace PRPAN2D_DX = 1 if DX`i' == "5770"  /* Acute pancreatitis */
	capture replace PRPAN2D_DX = 1 if DX`i' == "0723"  /* Mumps Pancreatitis */
}
label var PRPAN2D_DX "FORMAT FOR Acute pancreatitis diagnosis codes"

capture replace TPIQ09 = 0 if (MDC ! = 14  													///
					   & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 )) 			
capture replace TPIQ09 = 1 if DISPUNIFORM == 20 											///
					   & (MDC ! = 14 												///
					   & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))

capture replace TPIQ09A = 0 			  if PRPANCD_DX == 1 								///
								     & (MDC ! = 14 									///
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 )) 		
capture replace TPIQ09A = 1 			  if DISPUNIFORM == 20 								///
								     & PRPANCD_DX == 1 								///
								     & (MDC ! = 14 									///
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))	
capture replace TPIQ09B = 0 			  if PRPANCD_DX == 0 								///
									 & (MDC ! = 14 									///
									 & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))		
capture replace TPIQ09B = 1 			  if DISPUNIFORM == 20 								///
									 & PRPANCD_DX == 0 								///
									 & (MDC ! = 14 									///
									 & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))
	
* ---------------------------------------------- ;
* --- EXCLUDE ACUTE PANCREATITIS             --- ;
* ---------------------------------------------- ;

capture replace TPIQ09 = . 			      if PRPAN2D_DX == 1  								///
								     & (MDC ! = 14  								///
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))
capture replace TPIQ09A = . 			  if PRPAN2D_DX == 1  								///
								     & (MDC ! = 14 								    /// 
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))
capture replace TPIQ09B = . 			  if PRPAN2D_DX == 1  								///
								     & (MDC ! = 14  								///
								     & (PRPANCP_PR == 1 | PRPAN3P_PR == 1 ))

 * -------------------------------------------------- ;
 * --- IQI 11 : IN-HOSP MORT AAA REPAIR           --- ;
 * -------------------------------------------------- ;

* FORMAT FOR Ruptured abdominal aortic aneurysm (AAA) diagnosis codes
gen PRAAARD_DX = 0
forval i = 1/35 {
	capture replace PRAAARD_DX = 1 if DX`i' == "4413"  /* RUPT ABD AORTIC ANEURYSM */
}
label var PRAAARD_DX "FORMAT FOR Ruptured abdominal aortic aneurysm (AAA) diagnosis codes"


* FORMAT FOR Unruptured abdominal aortic (AAA) aneurysm diagnosis codes
gen PRAAA2D_DX = 0
forval i = 1/35 {
	capture replace PRAAA2D_DX = 1 if DX`i' ==  "4414"  /* ABDOM AORTIC ANEURYSM */
}
label var PRAAA2D_DX "FORMAT FOR Unruptured abdominal aortic (AAA) aneurysm diagnosis codes"


* FORMAT FOR Open abdominal aortic aneurysm (AAA) repair procedure codes
gen PRAAARP_PR = 0
forval i = 1/30 {
	capture replace PRAAARP_PR = 1 if PR`i' == "3834"  /* AORTA RESECTION & ANAST */
	capture replace PRAAARP_PR = 1 if PR`i' == "3844"  /* RESECT ABDM AORTA W REPL */
	capture replace PRAAARP_PR = 1 if PR`i' == "3864"  /* EXCISION OF AORTA */
}
label var PRAAARP_PR "FORMAT FOR Open abdominal aortic aneurysm (AAA) repair procedure codes"

* FORMAT FOR Endovascular abdominal aortic (AAA) aneurysm repair procedure codes */
gen PRAAA2P_PR = 0
forval i = 1/30 {
	capture replace PRAAA2P_PR = 1 if PR`i' == "3971" /* ENDO IMPL GRFT ABD AORTA */
	capture replace PRAAA2P_PR = 1 if PR`i' == "3977" /* TEMPORARY (PARTIAL) THERAPEUTIC ENDOVASCULAR OCCLSUION OF VESSEL */
	capture replace PRAAA2P_PR = 1 if PR`i' == "3978" /* ENDOVASCULAR IMPLANTATION OF BRANCHING OF FENESTRATED GRAFT(S) IN AORTA */
}
label var PRAAA2P_PR "FORMAT FOR Endovascular abdominal aortic (AAA) aneurysm repair procedure codes"

capture replace TPIQ11 = 0 if MDC ! = 14   													///
					  & (PRAAARD_DX == 1 | PRAAA2D_DX == 1) 						///
		 			  & (PRAAARP_PR == 1 | PRAAA2P_PR == 1) 

capture replace TPIQ11 = 1 if DISPUNIFORM == 20 & MDC ! = 14 						        ///
										 & (PRAAARD_DX == 1 | PRAAA2D_DX == 1) 		///
										 & (PRAAARP_PR == 1 | PRAAA2P_PR == 1) 


* --- IN-HOSP MORT AAA REPAIR (STRATIFICATION)                        --- ;
* --- stratification priority according to prior probability of death --- ;
*** IQI 11 Stratum_OPEN_RUPTURED : OPEN REPAIR- RUPTURED  
capture replace TPIQ11A = 0 			 if MDC != 14 										///
									& PRAAARP_PR == 1 								///
									& PRAAARD_DX == 1 	
capture replace TPIQ11A = 1 			 if DISPUNIFORM == 20								///
									& MDC ! = 14 									///
									& PRAAARP_PR == 1 		    					///
									& PRAAARD_DX == 1			

** IQI 11 Stratum_ENDO_RUPTURED : ENDOVASCULAR REPAIR - RUPTURED
capture replace TPIQ11B = 0 			 if MDC != 14										///
									& PRAAA2P_PR == 1 								///	
									& PRAAARD_DX == 1 				
	
capture replace TPIQ11B = 1 			 if DISPUNIFORM == 20 								///
									& MDC != 14										///
									& PRAAA2P_PR == 1 								///	
									& PRAAARD_DX == 1 				
** IQI 11 Stratum_OPEN_UNRUPTURED : OPEN REPAIR- UNRUPTURED  
capture replace TPIQ11C = 0 			   if MDC != 14 			 				        ///
									  & PRAAARP_PR == 1 			 				///
									  & PRAAA2D_DX == 1

capture replace TPIQ11C = 1 			   if DISPUNIFORM == 20 							///
									  & MDC != 14 									///
									  & PRAAARP_PR == 1 							///
									  & PRAAA2D_DX == 1  
** IQI 11 Stratum_ENDO_UNRUPTURED : ENDOVASCULAR REPAIR  - UNRUPTURED
capture replace TPIQ11D = 0 			   if MDC != 14										///
									  & PRAAA2P_PR == 1 							///
									  & PRAAA2D_DX == 1 

capture replace TPIQ11D = 1 			   if DISPUNIFORM == 20 							///
									  & MDC != 14 									///
									  & PRAAA2P_PR == 1 							///
									  & PRAAA2D_DX == 1  	
 * -------------------------------------------------- ;
 * --- IQI 12 : IN-HOSP MORT CABG                 --- ;
 * -------------------------------------------------- ;
* FORMAT FOR Coronary artery bypass graft (CABG) procedure codes
gen PRCABGP_PR = 0
forval i = 1/30 {
	capture replace PRCABGP_PR = 1 if PR`i' == "3610"   /* AORTOCORONARY BYPASS NOS */
	capture replace PRCABGP_PR = 1 if PR`i' == "3611"   /* AORTOCOR BYPAS-1 COR ART */
	capture replace PRCABGP_PR = 1 if PR`i' == "3612"   /* AORTOCOR BYPAS-2 COR ART */
	capture replace PRCABGP_PR = 1 if PR`i' == "3613"   /* AORTOCOR BYPAS-3 COR ART */
	capture replace PRCABGP_PR = 1 if PR`i' == "3614"   /* AORTCOR BYPAS-4+ COR ART */
	capture replace PRCABGP_PR = 1 if PR`i' == "3615"   /* 1 INT MAM-COR ART BYPASS */
	capture replace PRCABGP_PR = 1 if PR`i' == "3616"   /* 2 INT MAM-COR ART BYPASS */
	capture replace PRCABGP_PR = 1 if PR`i' == "3617"   /* ABD-CORON ART BYPASS */
	capture replace PRCABGP_PR = 1 if PR`i' == "3619"   /* HRT REVAS BYPS ANAS NEC */
}
label var PRCABGP_PR "FORMAT FOR Coronary artery bypass graft (CABG) procedure codes"

capture replace TPIQ12 = 0 				   if (MDC ! = 14  									///
									  & AGE >= 40 & PRCABGP_PR == 1)
	
capture replace TPIQ12 = 1 				   if DISPUNIFORM == 20  							///
					  				  & (MDC ! = 14 								///
					  				  & AGE >= 40 & PRCABGP_PR == 1)


 * -------------------------------------------------- ;
 * --- IQI 15 : IN-HOSP MORT AMI                  --- ;
 * -------------------------------------------------- ;

 * FORMAT FOR Acute myocardial infarction (AMI) diagnosis codes */
gen MRTAMID_DX = 0
capture replace  MRTAMID_DX = 1 if DX1 == "41000"  /* AMI ANTEROLATERAL, UNSPEC */
capture replace  MRTAMID_DX = 1 if DX1 == "41001"  /* AMI ANTEROLATERAL, INIT */
capture replace  MRTAMID_DX = 1 if DX1 == "41010"  /* AMI ANTERIOR WALL, UNSPEC */
capture replace  MRTAMID_DX = 1 if DX1 == "41011"  /* AMI ANTERIOR WALL, INIT */
capture replace  MRTAMID_DX = 1 if DX1 == "41020"  /* AMI INFEROLATERAL, UNSPEC */
capture replace  MRTAMID_DX = 1 if DX1 == "41021"  /* AMI INFEROLATERAL, INIT */
capture replace  MRTAMID_DX = 1 if DX1 == "41030"  /* AMI INFEROPOST, UNSPEC */
capture replace  MRTAMID_DX = 1 if DX1 == "41031"  /* AMI INFEROPOST, INITIAL */
capture replace  MRTAMID_DX = 1 if DX1 == "41040"  /* AMI INFERIOR WALL, UNSPEC */
capture replace  MRTAMID_DX = 1 if DX1 == "41041"  /* AMI INFERIOR WALL, INIT */
capture replace  MRTAMID_DX = 1 if DX1 == "41050"  /* AMI LATERAL NEC, UNSPEC */
capture replace  MRTAMID_DX = 1 if DX1 == "41051"  /* AMI LATERAL NEC, INITIAL */
capture replace  MRTAMID_DX = 1 if DX1 == "41060"  /* TRUE POST INFARCT, UNSPEC */
capture replace  MRTAMID_DX = 1 if DX1 == "41061"  /* TRUE POST INFARCT, INIT */
capture replace  MRTAMID_DX = 1 if DX1 == "41070"  /* SUBENDO INFARCT, UNSPEC */
capture replace  MRTAMID_DX = 1 if DX1 == "41071"  /* SUBENDO INFARCT, INITIAL */
capture replace  MRTAMID_DX = 1 if DX1 == "41080"  /* AMI NEC, UNSPECIFIED */
capture replace  MRTAMID_DX = 1 if DX1 == "41081"  /* AMI NEC, INITIAL */
capture replace  MRTAMID_DX = 1 if DX1 == "41090"  /* AMI NOS, UNSPECIFIED */
capture replace  MRTAMID_DX = 1 if DX1 == "41091"  /* AMI NOS, INITIAL */
label var MRTAMID_DX "FORMAT FOR Acute myocardial infarction (AMI) diagnosis codes"

capture replace TPIQ15 = 0 if MDC ! = 14 & MRTAMID_DX == 1									
capture replace TPIQ32 = 0 if MDC ! = 14 & MRTAMID_DX == 1									

capture replace TPIQ15 = 1 if DISPUNIFORM == 20 											/// 
					  & MDC ! = 14 & MRTAMID_DX == 1
capture replace TPIQ32 = 1 if DISPUNIFORM == 20 											/// 
					  & MDC ! = 14 & MRTAMID_DX == 1

* -------------------------------------------------- ;
* --- IQI 16 : IN-HOSP MORT CHF                  --- ;
* -------------------------------------------------- ;

* FORMAT FOR Heart failure diagnosis codes
gen MRTCHFD_DX = 0

capture replace MRTCHFD_DX = 1 if DX1 == "39891"  /* RHEUMATIC HEART FAILURE */
capture replace MRTCHFD_DX = 1 if DX1 == "40201"  /* MAL HYPERT HRT DIS W CHF */
capture replace MRTCHFD_DX = 1 if DX1 == "40211"  /* BENIGN HYP HRT DIS W CHF */
capture replace MRTCHFD_DX = 1 if DX1 == "40291"  /* HYPERTEN HEART DIS W CHF */
capture replace MRTCHFD_DX = 1 if DX1 == "40401"  /* MAL HYPER HRT/REN W CHF */
capture replace MRTCHFD_DX = 1 if DX1 == "40403"  /* MAL HYP HRT/REN W CHF&RF */
capture replace MRTCHFD_DX = 1 if DX1 == "40411"  /* BEN HYPER HRT/REN W CHF */
capture replace MRTCHFD_DX = 1 if DX1 == "40413"  /* BEN HYP HRT/REN W CHF&RF */
capture replace MRTCHFD_DX = 1 if DX1 == "40491"  /* HYPER HRT/REN NOS W CHF */
capture replace MRTCHFD_DX = 1 if DX1 == "40493"  /* HYP HT/REN NOS W CHF&RF */
capture replace MRTCHFD_DX = 1 if DX1 == "4280"  /* CONGESTIVE HEART FAILURE */
capture replace MRTCHFD_DX = 1 if DX1 == "4281"  /* LEFT HEART FAILURE */
capture replace MRTCHFD_DX = 1 if DX1 == "42820"  /* SYSTOLIC HRT FAILURE NOS */
capture replace MRTCHFD_DX = 1 if DX1 == "42821"  /* AC SYSTOLIC HRT FAILURE */
capture replace MRTCHFD_DX = 1 if DX1 == "42822"  /* CHR SYSTOLIC HRT FAILURE */
capture replace MRTCHFD_DX = 1 if DX1 == "42823"  /* AC ON CHR SYST HRT FAIL */
capture replace MRTCHFD_DX = 1 if DX1 == "42830"  /* DIASTOLC HRT FAILURE NOS */
capture replace MRTCHFD_DX = 1 if DX1 == "42831"  /* AC DIASTOLIC HRT FAILURE */
capture replace MRTCHFD_DX = 1 if DX1 == "42832"  /* CHR DIASTOLIC HRT FAIL */
capture replace MRTCHFD_DX = 1 if DX1 == "42833"  /* AC ON CHR DIAST HRT FAIL */
capture replace MRTCHFD_DX = 1 if DX1 == "42840"  /* SYST/DIAST HRT FAIL NOS */
capture replace MRTCHFD_DX = 1 if DX1 == "42841"  /* AC SYST/DIASTOL HRT FAIL */
capture replace MRTCHFD_DX = 1 if DX1 == "42842"  /* CHR SYST/DIASTL HRT FAIL */
capture replace MRTCHFD_DX = 1 if DX1 == "42843"  /* AC/CHR SYST/DIA HRT FAIL */
capture replace MRTCHFD_DX = 1 if DX1 == "4289"  /* HEART FAILURE NOS */
label var MRTCHFD_DX "FORMAT FOR Heart failure diagnosis codes"

* FORMAT FOR Heart transplant procedure codes

gen HTRPLVAP_PR = 0
forval i = 1/30 {
	capture replace HTRPLVAP_PR = 1 if PR`i' == "336"   /* Combined heart-lung transplantation */
	capture replace HTRPLVAP_PR = 1 if PR`i' == "3751"   /* Heart transplantation */
	capture replace HTRPLVAP_PR = 1 if PR`i' == "3760"   /* Implantation or insertion of biventricular external heart assist system */
	capture replace HTRPLVAP_PR = 1 if PR`i' == "3762"   /* Insertion of temporary non-implantable extracorporeal circulatory assist device */
	capture replace HTRPLVAP_PR = 1 if PR`i' == "3765"   /* Implant of single ventricular (extracorporeal) external heart assist system */
	capture replace HTRPLVAP_PR = 1 if PR`i' == "3766"   /* Insertion of implantable heart assist system */
	capture replace HTRPLVAP_PR = 1 if PR`i' == "3768"   /* Insertion of percutaneous external heart assist device */
}

label var HTRPLVAP_PR "FORMAT FOR Heart transplant procedure codes"

capture replace TPIQ16 = 0 if (MDC ! = 14 & MRTCHFD_DX == 1)
capture replace TPIQ16 = 1 if DISPUNIFORM == 20  			  								///
					  & (MDC ! = 14 & MRTCHFD_DX == 1)

* Exclude any procedure code for heart transplant
capture replace TPIQ16 = . if HTRPLVAP_PR == 1  			  								///
					  & (MDC ! = 14 & MRTCHFD_DX == 1)



* -------------------------------------------------- ;
* --- IQI 17 : IN-HOSP MORT STROKE               --- ;
* -------------------------------------------------- ;

* FORMAT FOR Subarachnoid hemorrhage diagnosis codes
gen MRTCV2D_DX = 0
capture replace MRTCV2D_DX = 1 if DX1 == "430"  /* SUBARACHNOID HEMORRHAGE */
capture replace MRTCV2D_DX = 1 if DX1 == "431"  /* INTRACEREBRAL HEMORRHAGE */
capture replace MRTCV2D_DX = 1 if DX1 == "4320"  /* NONTRAUM EXTRADURAL HEM */
capture replace MRTCV2D_DX = 1 if DX1 == "4321"  /* SUBDURAL HEMORRHAGE */
capture replace MRTCV2D_DX = 1 if DX1 == "4329"  /* INTRACRANIAL HEMORR NOS */
capture replace MRTCV2D_DX = 1 if DX1 == "43301"  /* BASI ART OCCL W/ INFARCT */
capture replace MRTCV2D_DX = 1 if DX1 == "43311"  /* CAROTD OCCL W/ INFRCT */
capture replace MRTCV2D_DX = 1 if DX1 == "43321"  /* VERTB ART OCCL W/ INFRCT */
capture replace MRTCV2D_DX = 1 if DX1 == "43331"  /* MULT PRECER OCCL W/ INFRCT */
capture replace MRTCV2D_DX = 1 if DX1 == "43381"  /* PRECER OCCL NEC W/ INFRCT */
capture replace MRTCV2D_DX = 1 if DX1 == "43391"  /* PRECER OCCL NOS W/ INFRCT */
capture replace MRTCV2D_DX = 1 if DX1 == "43401"  /* CERE THROMBOSIS W/ INFRCT */
capture replace MRTCV2D_DX = 1 if DX1 == "43411"  /* CERE EMBOLISM W/ INFRCT */
capture replace MRTCV2D_DX = 1 if DX1 == "43491"  /* CEREB OCCL NOS W/ INFRCT */
label var MRTCV2D_DX "FORMAT FOR Subarachnoid hemorrhage diagnosis codes"


* FORMAT FOR Intracerebral hemorrhage diagnosis codes
gen MRTCV3D_DX = 0 
capture replace MRTCV3D_DX = 1 if DX1 == "431"  /* INTRACEREBRAL HEMORRHAGE */
capture replace MRTCV3D_DX = 1 if DX1 == "4320"  /* NONTRAUM EXTRADURAL HEM */
capture replace MRTCV3D_DX = 1 if DX1 == "4321"  /* SUBDURAL HEMORRHAGE */
capture replace MRTCV3D_DX = 1 if DX1 == "4329"  /* INTRACRANIAL HEMORR NOS */
label var  MRTCV3D_DX "FORMAT FOR Intracerebral hemorrhage diagnosis codes"


gen MRTCV4D_DX = 0 
capture replace MRTCV4D_DX = 1 if DX1 == "43301" /* BASI ART OCCL W/ INFARCT */
capture replace MRTCV4D_DX = 1 if DX1 == "43311" /* CAROTD OCCL W/ INFRCT */
capture replace MRTCV4D_DX = 1 if DX1 == "43321" /* VERTB ART OCCL W/ INFRCT */
capture replace MRTCV4D_DX = 1 if DX1 == "43331" /* MULT PRECER OCCL W/ INFRCT */
capture replace MRTCV4D_DX = 1 if DX1 == "43381" /* PRECER OCCL NEC W/ INFRCT */
capture replace MRTCV4D_DX = 1 if DX1 == "43391" /* PRECER OCCL NOS W/ INFRCT */
capture replace MRTCV4D_DX = 1 if DX1 == "43401" /* CERE THROMBOSIS W/ INFRCT */
capture replace MRTCV4D_DX = 1 if DX1 == "43411" /* CERE EMBOLISM W/ INFRCT */
capture replace MRTCV4D_DX = 1 if DX1 == "43491" /* CEREB OCCL NOS W/ INFRCT */
label var MRTCV4D_DX "FORMAT FOR Ischemic stroke diagnosis codes"

/* SUBARACHNOID HEMORRHAGE */
gen MRTCV2A_DX = 0
capture replace MRTCV2A_DX = 1 if DX1 == "430"
label var MRTCV2A_DX "SUBARACHNOID HEMORRHAGE diagnosis code"

capture replace TPIQ17 = 0 if MDC ! = 14  													///
					 & (ICDVER >= 25 												///
					 & MRTCV2D_DX == 1)							
											
	
capture replace TPIQ17 = 1 if DISPUNIFORM == 20												///
					 & (MDC ! = 14  												///
					 & (ICDVER >= 25 											    ///
					  & MRTCV2D_DX == 1 ))											


* --- ACUTE STROKE MORTALITY (STRATIFICATION)                         --- ;
* --- Stratification priority according to prior probability of death --- ;

* IQI 17 Stratum_HEMSTROKE_INTRACER :  INTRACEREBRAL HEMORRHAGIC STROKE */

capture replace TPIQ17B = 0 				  if MDC ! = 14 	   							///
										 & MRTCV3D_DX == 1 

capture replace TPIQ17B = 1 				  if DISPUNIFORM == 20 							///
										 & MDC ! = 14 	   							///
										 & MRTCV3D_DX == 1 

* IQI 17 Stratum_HEMSTROKE_SUBARACH : SUBARACHNOID HEMORRHAGE  										
	
capture replace TPIQ17A = 0 				  if MDC ! = 14 	   							///
										 & MRTCV2A_DX == 1 

capture replace TPIQ17A = 1 				  if DISPUNIFORM == 20 							///
										 & MDC ! = 14 	   							///
										 & MRTCV2A_DX == 1 
	
* IQI 17 Stratum_ISCHEMSTROKE : ISCHEMIC HEMORRHAGIC STROKE
capture replace TPIQ17C = 0 				  if MDC ! = 14 								///
										 & MRTCV4D_DX == 1 

capture replace TPIQ17C = 1 				  if DISPUNIFORM == 20 							///
										 & MDC ! = 14 	   							///
										 & MRTCV4D_DX == 1 


* -------------------------------------------------- ;
* --- IQI 18 : IN-HOSP MORT GI HEMORRHAGE        --- ;
* -------------------------------------------------- ;
* FORMAT FOR Gastrointestinal hemorrhage diagnosis codes */
gen MRTGIHD_DX = 0 

capture replace MRTGIHD_DX = 1 if DX1 == "4560"  /* ESOPHAG VARICES W BLEED */
capture replace MRTGIHD_DX = 1 if DX1 == "45620"  /* ESOPHAG VARICES CLASS ELSEWHERE W BLEED */
capture replace MRTGIHD_DX = 1 if DX1 == "5307"  /* MALLORY-WEISS SYNDROME */
capture replace MRTGIHD_DX = 1 if DX1 == "53021"  /* ULCER ESOPHAGUS W BLEED */
capture replace MRTGIHD_DX = 1 if DX1 == "53082"  /* ESOPHAGEAL HEMORRHAGE */
capture replace MRTGIHD_DX = 1 if DX1 == "53100"  /* AC STOMACH ULCER W HEM */
capture replace MRTGIHD_DX = 1 if DX1 == "53101"  /* AC STOMAC ULC W HEM-OBST */
capture replace MRTGIHD_DX = 1 if DX1 == "53120"  /* AC STOMAC ULC W HEM/PERF */
capture replace MRTGIHD_DX = 1 if DX1 == "53121"  /* AC STOM ULC HEM/PERF-OBS */
capture replace MRTGIHD_DX = 1 if DX1 == "53140"  /* CHR STOMACH ULC W HEM */
capture replace MRTGIHD_DX = 1 if DX1 == "53141"  /* CHR STOM ULC W HEM-OBSTR */
capture replace MRTGIHD_DX = 1 if DX1 == "53160"  /* CHR STOMACH ULC HEM/PERF */
capture replace MRTGIHD_DX = 1 if DX1 == "53161"  /* CHR STOM ULC HEM/PERF-OB */
capture replace MRTGIHD_DX = 1 if DX1 == "53200"  /* AC DUODENAL ULCER W HEM */
capture replace MRTGIHD_DX = 1 if DX1 == "53201"  /* AC DUODEN ULC W HEM-OBST */
capture replace MRTGIHD_DX = 1 if DX1 == "53220"  /* AC DUODEN ULC W HEM/PERF */
capture replace MRTGIHD_DX = 1 if DX1 == "53221"  /* AC DUOD ULC HEM/PERF-OBS */
capture replace MRTGIHD_DX = 1 if DX1 == "53240"  /* CHR DUODEN ULCER W HEM */
capture replace MRTGIHD_DX = 1 if DX1 == "53241"  /* CHR DUODEN ULC HEM-OBSTR */
capture replace MRTGIHD_DX = 1 if DX1 == "53260"  /* CHR DUODEN ULC HEM/PERF */
capture replace MRTGIHD_DX = 1 if DX1 == "53261"  /* CHR DUOD ULC HEM/PERF-OB */
capture replace MRTGIHD_DX = 1 if DX1 == "53300"  /* AC PEPTIC ULCER W HEMORR */
capture replace MRTGIHD_DX = 1 if DX1 == "53301"  /* AC PEPTIC ULC W HEM-OBST */
capture replace MRTGIHD_DX = 1 if DX1 == "53320"  /* AC PEPTIC ULC W HEM/PERF */
capture replace MRTGIHD_DX = 1 if DX1 == "53321"  /* AC PEPT ULC HEM/PERF-OBS */
capture replace MRTGIHD_DX = 1 if DX1 == "53340"  /* CHR PEPTIC ULCER W HEM */
capture replace MRTGIHD_DX = 1 if DX1 == "53341"  /* CHR PEPTIC ULC W HEM-OBS */
capture replace MRTGIHD_DX = 1 if DX1 == "53360"  /* CHR PEPT ULC W HEM/PERF */
capture replace MRTGIHD_DX = 1 if DX1 == "53361"  /* CHR PEPT ULC HEM/PERF-OB */
capture replace MRTGIHD_DX = 1 if DX1 == "53400"  /* AC MARGINAL ULCER W HEM */
capture replace MRTGIHD_DX = 1 if DX1 == "53401"  /* AC MARGIN ULC W HEM-OBST */
capture replace MRTGIHD_DX = 1 if DX1 == "53420"  /* AC MARGIN ULC W HEM/PERF */
capture replace MRTGIHD_DX = 1 if DX1 == "53421"  /* AC MARG ULC HEM/PERF-OBS */
capture replace MRTGIHD_DX = 1 if DX1 == "53440"  /* CHR MARGINAL ULCER W HEM */
capture replace MRTGIHD_DX = 1 if DX1 == "53441"  /* CHR MARGIN ULC W HEM-OBS */
capture replace MRTGIHD_DX = 1 if DX1 == "53460"  /* CHR MARGIN ULC HEM/PERF */
capture replace MRTGIHD_DX = 1 if DX1 == "53461"  /* CHR MARG ULC HEM/PERF-OB */
capture replace MRTGIHD_DX = 1 if DX1 == "53501"  /* ACUTE GASTRITIS W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "53511"  /* ATRPH GASTRITIS W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "53521"  /* GSTR MCSL HYPRT W HMRG */
capture replace MRTGIHD_DX = 1 if DX1 == "53531"  /* ALCHL GSTRITIS W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "53541"  /* OTH SPF GASTRT W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "53551"  /* GSTR/DDNTS NOS W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "53561"  /* DUODENITIS W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "53783"  /* ANGIO STM/DUDN W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "53784"  /* DIEULAFOY LES,STOM&DUOD */
capture replace MRTGIHD_DX = 1 if DX1 == "56202"  /* DVRTCLO SML INT W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "56203"  /* DVRTCLI SML INT W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "56212"  /* DVRTCLO COLON W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "56213"  /* DVRTCLI COLON W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "5693 "  /* RECTAL & ANAL HEMORRHAGE */
capture replace MRTGIHD_DX = 1 if DX1 == "56985"  /* ANGIO INTES W HMRHG */
capture replace MRTGIHD_DX = 1 if DX1 == "56986"  /* DIEULAFOY LES, INTESTINE */
capture replace MRTGIHD_DX = 1 if DX1 == "5780 "  /* HEMATEMESIS */
capture replace MRTGIHD_DX = 1 if DX1 == "5781 "  /* BLOOD IN STOOL */
capture replace MRTGIHD_DX = 1 if DX1 == "5789 "  /* GASTROINTEST HEMORR NOS */
label var MRTGIHD_DX "FORMAT FOR Gastrointestinal hemorrhage diagnosis codes"

* FORMAT FOR Liver transplant procedure codes */
gen LIVERTRP_PR = 0
forval i = 1/30 {
	capture replace LIVERTRP_PR = 1 if PR`i' == "5051" /* Auxiliary liver transplant  */
	capture replace LIVERTRP_PR = 1 if PR`i' == "5059" /* Other transplant of liver   */
}
label var LIVERTRP_PR "FORMAT FOR Liver transplant procedure codes"

capture replace TPIQ18 = 0 if MDC != 14 							///
					  &  MRTGIHD_DX == 1					

capture replace TPIQ18 = 1 if DISPUNIFORM == 20						///
					  & (MDC != 14 							///
					  & MRTGIHD_DX == 1) 				

* Exclusion for liver transplant
capture replace TPIQ18 = . if LIVERTRP_PR == 1						

* -------------------------------------------------- ;
* --- IQI 19 : IN-HOSP MORT HIP FRACTURE         --- ;
* -------------------------------------------------- ;

 * FORMAT FOR Hip fracture diagnosis codes */
gen MTHIPFD_DX = 0 
capture replace MTHIPFD_DX = 1 if DX1 == "82000" /* FX FEMUR INTRCAPS NOS-CL */
capture replace MTHIPFD_DX = 1 if DX1 == "82001" /* FX UP FEMUR EPIPHY-CLOS */
capture replace MTHIPFD_DX = 1 if DX1 == "82002" /* FX FEMUR, MIDCERVIC-CLOS */
capture replace MTHIPFD_DX = 1 if DX1 == "82003" /* FX BASE FEMORAL NCK-CLOS */
capture replace MTHIPFD_DX = 1 if DX1 == "82009" /* FX FEMUR INTRCAPS NEC-CL */
capture replace MTHIPFD_DX = 1 if DX1 == "82010" /* FX FEMUR INTRCAP NOS-OPN */
capture replace MTHIPFD_DX = 1 if DX1 == "82011" /* FX UP FEMUR EPIPHY-OPEN */
capture replace MTHIPFD_DX = 1 if DX1 == "82012" /* FX FEMUR, MIDCERVIC-OPEN */
capture replace MTHIPFD_DX = 1 if DX1 == "82013" /* FX BASE FEMORAL NCK-OPEN */
capture replace MTHIPFD_DX = 1 if DX1 == "82019" /* FX FEMUR INTRCAP NEC-OPN */
capture replace MTHIPFD_DX = 1 if DX1 == "82020" /* TROCHANTERIC FX NOS-CLOS */
capture replace MTHIPFD_DX = 1 if DX1 == "82021" /* INTERTROCHANTERIC FX-CL */
capture replace MTHIPFD_DX = 1 if DX1 == "82022" /* SUBTROCHANTERIC FX-CLOSE */
capture replace MTHIPFD_DX = 1 if DX1 == "82030" /* TROCHANTERIC FX NOS-OPEN */
capture replace MTHIPFD_DX = 1 if DX1 == "82031" /* INTERTROCHANTERIC FX-OPN */
capture replace MTHIPFD_DX = 1 if DX1 == "82032" /* SUBTROCHANTERIC FX-OPEN */
capture replace MTHIPFD_DX = 1 if DX1 == "8208" /* FX NECK OF FEMUR NOS-CL */
capture replace MTHIPFD_DX = 1 if DX1 == "8209" /* FX NECK OF FEMUR NOS-OPN */
label var MTHIPFD_DX "FORMAT FOR Hip fracture diagnosis codes"

* FORMAT FOR Periprosthetic fracture diagnosis codes
gen MTHIP2D_DX = 0
forval i = 1/35 {
	capture replace MTHIP2D_DX = 1 if DX`i' == "99644" /* PERIPROSTHETC FX-PROS JT */
}
label var MTHIP2D_DX "FORMAT FOR Periprosthetic fracture diagnosis codes"

capture replace TPIQ19 = 0 if MDC ! = 14  				 ///
					  & AGE >= 65  				 ///
					  & MTHIPFD_DX == 1 
capture replace TPIQ19 = 1 if DISPUNIFORM == 20  		 ///
					  & MDC ! = 14  	 		 ///
					  & AGE >= 65  		 		 ///
					  & MTHIPFD_DX == 1 
* Exclude periprosthetic fracture;					  
capture replace TPIQ19 = . if MTHIP2D_DX == 1   	     ///
					  & MDC ! = 14  		     ///
					  & AGE >= 65  			     ///
					  & MTHIPFD_DX == 1 
* -------------------------------------------------- ;
* --- IQI 20 : IN-HOSP MORT PNEUMONIA            --- ;
* -------------------------------------------------- ;

* FORMAT FOR Pneumonia diagnosis codes *
gen MTPNEUD_DX = 0
capture replace MTPNEUD_DX = 1 if DX1 == "00322" /* SALMONELLA PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "0212" /* PULMONARY TULAREMIA */
capture replace MTPNEUD_DX = 1 if DX1 == "0391" /* PULMONARY ACTINOMYCOSIS */
capture replace MTPNEUD_DX = 1 if DX1 == "0521" /* VARICELLA PNEUMONITIS */
capture replace MTPNEUD_DX = 1 if DX1 == "0551" /* POSTMEASLES PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "0730" /* ORNITHOSIS PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "1124" /* CANDIDIASIS OF LUNG */
capture replace MTPNEUD_DX = 1 if DX1 == "1140" /* PRIMARY COCCIDIOIDOMYCOS */
capture replace MTPNEUD_DX = 1 if DX1 == "1144" /* CHRONIC PULMON COCCIDIOIDOMYCOSIS  */
capture replace MTPNEUD_DX = 1 if DX1 == "1145" /* UNSPEC PULMON COCCIDIOIDOMYCOSIS  */
capture replace MTPNEUD_DX = 1 if DX1 == "11505" /* HISTOPLASM CAPS PNEUMON */
capture replace MTPNEUD_DX = 1 if DX1 == "11515" /* HISTOPLASM DUB PNEUMONIA  */
capture replace MTPNEUD_DX = 1 if DX1 == "11595" /* HISTOPLASMOSIS PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "1304" /* TOXOPLASMA PNEUMONITIS */
capture replace MTPNEUD_DX = 1 if DX1 == "1363" /* PNEUMOCYSTOSIS */
capture replace MTPNEUD_DX = 1 if DX1 == "4800" /* ADENOVIRAL PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "4801" /* RESP SYNCYT VIRAL PNEUM */
capture replace MTPNEUD_DX = 1 if DX1 == "4802" /* PARINFLUENZA VIRAL PNEUM */
capture replace MTPNEUD_DX = 1 if DX1 == "4803" /* PNEUMONIA DUE TO SARS */
capture replace MTPNEUD_DX = 1 if DX1 == "4808" /* VIRAL PNEUMONIA NEC */
capture replace MTPNEUD_DX = 1 if DX1 == "4809" /* VIRAL PNEUMONIA NOS */
capture replace MTPNEUD_DX = 1 if DX1 == "481" /* PNEUMOCOCCAL PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "4820" /* K. PNEUMONIAE PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "4821" /* PSEUDOMONAL PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "4822" /* H.INFLUENZAE PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48230" /* STREP PNEUMONIA UNSPEC */
capture replace MTPNEUD_DX = 1 if DX1 == "48231" /* GRP A STREP PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48232" /* GRP B STREP PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48239" /* OTH STREP PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "4824" /* STAPHYLOCOCCAL PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48240" /* STAPH PNEUMONIA UNSP */
capture replace MTPNEUD_DX = 1 if DX1 == "48241" /* METH SUS PNEUM D/T STAPH */
capture replace MTPNEUD_DX = 1 if DX1 == "48242" /* METH RES PNEU D/T STAPH */
capture replace MTPNEUD_DX = 1 if DX1 == "48249" /* STAPH PNEUMON OTH */
capture replace MTPNEUD_DX = 1 if DX1 == "48281" /* ANAEROBIC PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48282" /* E COLI PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48283" /* OTH GRAM NEG PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48284" /* LEGIONNAIRES DX */
capture replace MTPNEUD_DX = 1 if DX1 == "48289" /* BACT PNEUMONIA NEC */
capture replace MTPNEUD_DX = 1 if DX1 == "4829" /* BACTERIAL PNEUMONIA NOS */
capture replace MTPNEUD_DX = 1 if DX1 == "4830" /* MYCOPLASMA PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "4831" /* CHLAMYDIA PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "4838" /* OTH SPEC ORG PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "4841" /* PNEUM W CYTOMEG INCL DIS */
capture replace MTPNEUD_DX = 1 if DX1 == "4843" /* PNEUMONIA IN WHOOP COUGH */
capture replace MTPNEUD_DX = 1 if DX1 == "4845" /* PNEUMONIA IN ANTHRAX */
capture replace MTPNEUD_DX = 1 if DX1 == "4846" /* PNEUM IN ASPERGILLOSIS */
capture replace MTPNEUD_DX = 1 if DX1 == "4847" /* PNEUM IN OTH SYS MYCOSES */
capture replace MTPNEUD_DX = 1 if DX1 == "4848" /* PNEUM IN INFECT DIS NEC */
capture replace MTPNEUD_DX = 1 if DX1 == "485" /* BRONCOPNEUMONIA ORG NOS */
capture replace MTPNEUD_DX = 1 if DX1 == "486" /* PNEUMONIA, ORGANISM NOS */
capture replace MTPNEUD_DX = 1 if DX1 == "4870" /* INFLUENZA WITH PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48801" /* INFLUENZA D/T IDENTIFIED AVIAN INFLUENZA VIRUS */
capture replace MTPNEUD_DX = 1 if DX1 == "48811" /* INFLUENZA D/T IDENTIFIED 2009 H1N1 INFLUENZA VIRUS W/PNEUMONIA */
capture replace MTPNEUD_DX = 1 if DX1 == "48881" /* NOVEL INFLUENZA W/PNEUMONIA */
label var MTPNEUD_DX "FORMAT FOR Pneumonia diagnosis codes"

capture replace TPIQ20 = 0 if MDC ! = 14   						///
					  & MTPNEUD_DX == 1 
capture replace TPIQ20 = 1 if DISPUNIFORM == 20   				///
					  & MDC ! = 14   					///
					  & MTPNEUD_DX == 1  

* --- CONSTRUCT ADDITIONAL PROVIDER LEVEL MORTALITY INDICATORS - ;
* ------------------------------------------------------------------------ ;
* --- IQI 30 : PERCUTANEOUS CORONARY INTERVENTION (PCI) MORTALITY RATE --- ;
* ------------------------------------------------------------------------ ;

* FORMAT FOR Percutaneous coronary intervention (PCI) procedure codes */
gen PRPTCAP_PR = 0
forval i = 1/30 {
	capture replace PRPTCAP_PR = 1 if PR`i' == "0066" /* PTCA OR COR ATHERECTOMY */
	capture replace PRPTCAP_PR = 1 if PR`i' == "3601" /* PTCA-1 VESSEL W/O AGENT */
	capture replace PRPTCAP_PR = 1 if PR`i' == "3602" /* PTCA-1 VESSEL WITH AGNT */
	capture replace PRPTCAP_PR = 1 if PR`i' == "3605" /* PTCA-MULTIPLE VESSEL */
}
label var PRPTCAP_PR "FORMAT FOR Percutaneous coronary intervention (PCI) procedure codes"

capture replace TPIQ30 = 0 if MDC ! = 14   						///
					  & AGE >= 40   					///
					  & PRPTCAP_PR == 1  				
capture replace TPIQ30 = 1 if DISPUNIFORM == 20   				///
					  & MDC ! = 14   					///
					  & AGE >= 40   					///
					  & PRPTCAP_PR == 1	  				

* ------------------------------------------------------ ;
* --- IQI 31 : CAROTID ENDARTERECTOMY MORTALITY RATE --- ;
* ------------------------------------------------------ ;


 * FORMAT FOR Carotid endarterectomy procedure codes */
gen PRCEATP_PR = 0 
forval i = 1/30 {
	capture replace PRCEATP_PR = 1 if PR`i' == "3812"   /* HEAD & NECK ENDARTER NEC */
}
label var PRCEATP_PR "FORMAT FOR Carotid endarterectomy procedure codes"

capture replace TPIQ31 = 0 if MDC ! = 14 & PRCEATP_PR == 1 
capture replace TPIQ31 = 1 if DISPUNIFORM == 20 & MDC ! = 14 & PRCEATP_PR == 1 


 * --- CONSTRUCT PROVIDER LEVEL UTILIZATION INDICATORS ---------- ;

* -------------------------------------------------- ;
* --- IQI 21 : CESAREAN SECTION DELIVERY         --- ;
* -------------------------------------------------- ;


 /* All Births (Population at Risk): */
/* MS-DRG Codes: */
gen PRBRT2G_DRG = 0 
capture replace PRBRT2G_DRG = 1 if DRG == 765   /* Cesarean section w CC/MCC */
capture replace PRBRT2G_DRG = 1 if DRG == 766   /* Cesarean section w/o CC/MCC */
capture replace PRBRT2G_DRG = 1 if DRG == 767   /* Vaginal delivery w sterilization &/or D&C */
capture replace PRBRT2G_DRG = 1 if DRG == 768   /* Vaginal delivery w O.R. proc except steril &/or D&C */
capture replace PRBRT2G_DRG = 1 if DRG == 774   /* Vaginal delivery w complicating diagnoses */
capture replace PRBRT2G_DRG = 1 if DRG == 775   /* Vaginal delivery w/o complicating diagnoses */
label var PRBRT2G_DRG "FORMAT FOR Cesarean delivery MS-DRG codes"

/* C-Section (Outcome of Interest): */
gen PRCSE2G_DRG = 0
capture replace PRCSE2G_DRG  = 1 if DRG == 765 /* Cesarean section w CC/MCC */
capture replace PRCSE2G_DRG  = 1 if DRG == 766 /* Cesarean section w/o CC/MCC */
label var PRCSE2G_DRG " C-Section (Outcome of Interest) "

* FORMAT FOR Cesarean delivery procedure codes 
gen PRCSECP_PR = 0
forval i = 1/30 {
	capture replace PRCSECP_PR = 1 if PR`i' == "740"  /* CLASSICAL C-SECTION */
	capture replace PRCSECP_PR = 1 if PR`i' == "741"  /* LOW CERVICAL C-SECTION */
	capture replace PRCSECP_PR = 1 if PR`i' == "742"  /* EXTRAPERITONEAL C-SECT */
	capture replace PRCSECP_PR = 1 if PR`i' == "744"  /* CESAREAN SECTION NEC */
	capture replace PRCSECP_PR = 1 if PR`i' == "7499"  /* CESAREAN SECTION NOS */
}
label var PRCSECP_PR "FORMAT FOR Cesarean delivery procedure codes "

* FORMAT FOR Hysterotomy procedure codes */
gen PRCSE2P_PR = 0
forval i = 1/30 {
	capture replace PRCSE2P_PR = 1 if PR`i' == "7491" /* HYSTEROTOMY TO TERMIN PG */
}

* FORMAT FOR Abnormal presentation, fetal death, and multiple gestation diagnosis codes */
gen PRCSECD_DX = 0 
forval i = 1/35 {
	capture replace PRCSECD_DX = 1 if DX`i' == "64420" /* EARLY ONSET DELIV-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "64421" /* EARLY ONSET DELIVERY-DEL */
	capture replace PRCSECD_DX = 1 if DX`i' == "65100" /* TWIN PREGNANCY-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "65101" /* TWIN PREGNANCY-DELIVERED */
	capture replace PRCSECD_DX = 1 if DX`i' == "65103" /* TWIN PREGNANCY-ANTEPART */
	capture replace PRCSECD_DX = 1 if DX`i' == "65110" /* TRIPLET PREGNANCY-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "65111" /* TRIPLET PREGNANCY-DELIV */
	capture replace PRCSECD_DX = 1 if DX`i' == "65113" /* TRIPLET PREG-ANTEPARTUM */
	capture replace PRCSECD_DX = 1 if DX`i' == "65120" /* QUADRUPLET PREG-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "65121" /* QUADRUPLET PREG-DELIVER */
	capture replace PRCSECD_DX = 1 if DX`i' == "65123" /* QUADRUPLET PREG-ANTEPART */
	capture replace PRCSECD_DX = 1 if DX`i' == "65130" /* TWINS W FETAL LOSS-UNSP */
	capture replace PRCSECD_DX = 1 if DX`i' == "65131" /* TWINS W FETAL LOSS-DEL */
	capture replace PRCSECD_DX = 1 if DX`i' == "65133" /* TWINS W FETAL LOSS-ANTE */
	capture replace PRCSECD_DX = 1 if DX`i' == "65140" /* TRIPLETS W FET LOSS-UNSP */
	capture replace PRCSECD_DX = 1 if DX`i' == "65141" /* TRIPLETS W FET LOSS-DEL */
	capture replace PRCSECD_DX = 1 if DX`i' == "65143" /* TRIPLETS W FET LOSS-ANTE */
	capture replace PRCSECD_DX = 1 if DX`i' == "65150" /* QUADS W FETAL LOSS-UNSP */
	capture replace PRCSECD_DX = 1 if DX`i' == "65151" /* QUADS W FETAL LOSS-DEL */
	capture replace PRCSECD_DX = 1 if DX`i' == "65153" /* QUADS W FETAL LOSS-ANTE */
	capture replace PRCSECD_DX = 1 if DX`i' == "65160" /* MULT GES W FET LOSS-UNSP */
	capture replace PRCSECD_DX = 1 if DX`i' == "65161" /* MULT GES W FET LOSS-DEL */
	capture replace PRCSECD_DX = 1 if DX`i' == "65163" /* MULT GES W FET LOSS-ANTE */
	capture replace PRCSECD_DX = 1 if DX`i' == "65180" /* MULTI GESTAT NEC-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "65181" /* MULTI GESTAT NEC-DELIVER */
	capture replace PRCSECD_DX = 1 if DX`i' == "65183" /* MULTI GEST NEC-ANTEPART */
	capture replace PRCSECD_DX = 1 if DX`i' == "65190" /* MULTI GESTAT NOS-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "65191" /* MULT GESTATION NOS-DELIV */
	capture replace PRCSECD_DX = 1 if DX`i' == "65193" /* MULTI GEST NOS-ANTEPART */
	capture replace PRCSECD_DX = 1 if DX`i' == "65220" /* BREECH PRESENTAT-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "65221" /* BREECH PRESENTAT-DELIVER */
	capture replace PRCSECD_DX = 1 if DX`i' == "65223" /* BREECH PRESENT-ANTEPART */
	capture replace PRCSECD_DX = 1 if DX`i' == "65230" /* TRANSV/OBLIQ LIE-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "65231" /* TRANSVER/OBLIQ LIE-DELIV */
	capture replace PRCSECD_DX = 1 if DX`i' == "65233" /* TRANSV/OBLIQ LIE-ANTEPAR */
	capture replace PRCSECD_DX = 1 if DX`i' == "65240" /* FACE/BROW PRESENT-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "65241" /* FACE/BROW PRESENT-DELIV */
	capture replace PRCSECD_DX = 1 if DX`i' == "65243" /* FACE/BROW PRES-ANTEPART */
	capture replace PRCSECD_DX = 1 if DX`i' == "65260" /* MULT GEST MALPRESEN-UNSP */
	capture replace PRCSECD_DX = 1 if DX`i' == "65261" /* MULT GEST MALPRES-DELIV */
	capture replace PRCSECD_DX = 1 if DX`i' == "65263" /* MULT GES MALPRES-ANTEPAR */
	capture replace PRCSECD_DX = 1 if DX`i' == "65640" /* INTRAUTERINE DEATH-UNSP */
	capture replace PRCSECD_DX = 1 if DX`i' == "65641" /* INTRAUTER DEATH-DELIVER */
	capture replace PRCSECD_DX = 1 if DX`i' == "65643" /* INTRAUTER DEATH-ANTEPART */
	capture replace PRCSECD_DX = 1 if DX`i' == "66050" /* LOCKED TWINS-UNSPECIFIED */
	capture replace PRCSECD_DX = 1 if DX`i' == "66051" /* LOCKED TWINS-DELIVERED */
	capture replace PRCSECD_DX = 1 if DX`i' == "66053" /* LOCKED TWINS-ANTEPARTUM */
	capture replace PRCSECD_DX = 1 if DX`i' == "66230" /* DELAY DEL 2ND TWIN-UNSP */
	capture replace PRCSECD_DX = 1 if DX`i' == "66231" /* DELAY DEL 2ND TWIN-DELIV */
	capture replace PRCSECD_DX = 1 if DX`i' == "66233" /* DELAY DEL 2 TWIN-ANTEPAR */
	capture replace PRCSECD_DX = 1 if DX`i' == "66960" /* BREECH EXTR NOS-UNSPEC */
	capture replace PRCSECD_DX = 1 if DX`i' == "66961" /* BREECH EXTR NOS-DELIVER */
	capture replace PRCSECD_DX = 1 if DX`i' == "67810" /* FETAL CONJOIN TWINS-UNSP */
	capture replace PRCSECD_DX = 1 if DX`i' == "67811" /* FETAL CONJOIN TWINS-DEL */
	capture replace PRCSECD_DX = 1 if DX`i' == "67813" /* FETAL CONJOIN TWINS-ANTE */
	capture replace PRCSECD_DX = 1 if DX`i' == "7615 " /* MULT PREGNANCY AFF NB */
	capture replace PRCSECD_DX = 1 if DX`i' == "V271 " /* DELIVER-SINGLE STILLBORN */
	capture replace PRCSECD_DX = 1 if DX`i' == "V272 " /* DELIVER-TWINS, BOTH LIVE */
	capture replace PRCSECD_DX = 1 if DX`i' == "V273 " /* DEL-TWINS, 1 NB, 1 SB */
	capture replace PRCSECD_DX = 1 if DX`i' == "V274 " /* DELIVER-TWINS, BOTH SB */
	capture replace PRCSECD_DX = 1 if DX`i' == "V275 " /* DEL-MULT BIRTH, ALL LIVE */
	capture replace PRCSECD_DX = 1 if DX`i' == "V276 " /* DEL-MULT BRTH, SOME LIVE */
	capture replace PRCSECD_DX = 1 if DX`i' == "V277 " /* DEL-MULT BIRTH, ALL SB */
}
label var PRCSECD_DX "FORMAT FOR Abnormal presentation, fetal death, and multiple gestation diagnosis codes"

gen PRCSE3P_PR = 0
forval i = 1/30 { 
	capture replace PRCSE3P_PR = 1 if PR`i' == "7251"  /* PART BRCH EXTRAC W FORCP */
	capture replace PRCSE3P_PR = 1 if PR`i' == "7252"  /* PART BREECH EXTRACT NEC */
	capture replace PRCSE3P_PR = 1 if PR`i' == "7253"  /* TOT BRCH EXTRAC W FORCEP */
	capture replace PRCSE3P_PR = 1 if PR`i' == "7254"  /* TOT BREECH EXTRAC NEC */
}
capture replace TPIQ21 = 0 if PRBRT2G_DRG == 1
capture replace TPIQ21 = 1 if PRBRT2G_DRG == 1 							 ///
					  & (PRCSE2G_DRG == 1  						 ///
					  | (PRCSECP_PR == 1 & PRCSE2P_PR != 1))	 
	
capture replace TPIQ21 = . if PRBRT2G_DRG == 1 							 ///
					  & (PRCSECD_DX == 1 						 ///
					  | PRCSE3P_PR == 1)



* -------------------------------------------------- ;
* --- IQI 22 : VAGINAL BIRTH AFTER C-SECTION     --- ;
* -------------------------------------------------- ;
gen PRVBACD_DX = 0
forval i = 1/35 {
	capture replace PRVBACD_DX = 1 if DX`i' == "65420" /* PREV C-SECT NOS-UNSPEC */
	capture replace PRVBACD_DX = 1 if DX`i' == "65421" /* PREV C-SECT NOS-DELIVER */
	capture replace PRVBACD_DX = 1 if DX`i' == "65423" /* PREV C-SECT NOS-ANTEPART */
}
gen PRVAG2G_DRG = 0 
capture replace PRVAG2G_DRG = 1 if DRG == 767 /* Vaginal delivery w sterilization &/or D&C */
capture replace PRVAG2G_DRG = 1 if DRG == 768 /* Vaginal delivery w O.R. proc except steril &/or D&C */
capture replace PRVAG2G_DRG = 1 if DRG == 774 /* Vaginal delivery w complicating diagnoses */
capture replace PRVAG2G_DRG = 1 if DRG == 775 /* Vaginal delivery w/o complicating diagnoses */


capture replace TPIQ22 = 0 if PRBRT2G_DRG == 1 			///
					  & PRVBACD_DX == 1   
capture replace TPIQ34 = 0 if PRBRT2G_DRG == 1  		///
					  & PRVBACD_DX == 1 

capture replace TPIQ22 = 1 if PRBRT2G_DRG == 1 			/// 
					  & PRVBACD_DX == 1 		///
					  & PRVAG2G_DRG == 1
capture replace TPIQ34 = 1 if PRBRT2G_DRG == 1 			/// 
					  & PRVBACD_DX == 1 		///
					  & PRVAG2G_DRG == 1
	
capture replace TPIQ22 = . if (PRBRT2G_DRG == 1 		///
					  & PRVBACD_DX == 1) 	    ///
					  & (PRCSECD_DX == 1		///
					  | PRCSE3P_PR == 1)

* -------------------------------------------------- ;
* --- IQI 23 : LAPAROSCOPIC CHOLECYSTECTOMY      --- ;
* -------------------------------------------------- ;
/* Cholecystectomy (Population at Risk): */
gen PRLAP2P_PR = 0
forval i = 1/30 {
	capture replace PRLAP2P_PR = 1 if PR`i' == "5122" /* CHOLECYSTECTOMY */
	capture replace PRLAP2P_PR = 1 if PR`i' == "5123" /* LAPAROSCOPIC CHOLE */
}
label var PRLAP2P_PR "Cholecystectomy (Population at Risk) ICD-9-CM procedure codes"

/* Include Only: Uncomplicated Cholecystitis and/or Cholelithiasis */
/* ICD-9-CM Diagnosis Codes: */
gen PRLAPOD_DX = 0
forval i = 1/35 {
	capture replace PRLAPOD_DX = 1 if DX`i' == "57400" /* CHOLELITH W AC CHOLECYST */
	capture replace PRLAPOD_DX = 1 if DX`i' == "57401" /* CHOLELITH/AC GB INF-OBST */
	capture replace PRLAPOD_DX = 1 if DX`i' == "57410" /* CHOLELITH W CHOLECYS NEC */
	capture replace PRLAPOD_DX = 1 if DX`i' == "57411" /* CHOLELITH/GB INF NEC-OBS */
	capture replace PRLAPOD_DX = 1 if DX`i' == "57420" /* CHOLELITHIASIS NOS */
	capture replace PRLAPOD_DX = 1 if DX`i' == "57421" /* CHOLELITHIAS NOS W OBSTR */
	capture replace PRLAPOD_DX = 1 if DX`i' == "5750" /* ACUTE CHOLECYSTITIS */
	capture replace PRLAPOD_DX = 1 if DX`i' == "5751" /* CHOLECYSTITIS NEC */
	capture replace PRLAPOD_DX = 1 if DX`i' == "57510" /* CHOLECYSTITIS NOS */
	capture replace PRLAPOD_DX = 1 if DX`i' == "57511" /* CHRON CHOLECYSTITIS */
	capture replace PRLAPOD_DX = 1 if DX`i' == "57512" /* AC/CHR CHOLECYSTITIS */
}
label var PRLAPOD_DX "Include Only: Uncomplicated Cholecystitis and/or Cholelithiasis"
/* Laparoscopic Cholecystectomy (Outcome of Interest): */
gen PRLAPOP_PR = 0
forval i = 1/30 {
	capture replace PRLAPOP_PR = 0 if PR`i' == "5123" /* LAPAROSCOPIC CHOLE */
 }

capture replace TPIQ23 = 0 if MDC ! = 14 & PRLAP2P_PR == 1 & PRLAPOD_DX == 1
capture replace TPIQ23 = 1 if MDC ! = 14 & PRLAP2P_PR == 1 & PRLAPOD_DX == 1 & PRLAPOP_PR == 1

* -------------------------------------------------- ;
* --- IQI 24 : INCIDENTAL APPENDECTOMY           --- ;
* -------------------------------------------------- ;

/* Incidental Appendectomy (Population at Risk): */
/* ICD-9-CM Procedure Code: */
gen PRAPP2P_PR = 0
forval i = 1/30 {
	capture replace PRAPP2P_PR = 1 if PR`i' =="1711"  /* LAP DIR ING HERN-GRAFT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="1712"  /* LAP INDIR ING HERN-GRAFT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="1713"  /* LAP ING HERN-GRAFT NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="1721"  /* LAP BIL DIR ING HRN-GRFT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="1722"  /* LAP BI INDIR ING HRN-GRF */
	capture replace PRAPP2P_PR = 1 if PR`i' =="1723"  /* LAP BI DR/IND ING HRN-GR */
	capture replace PRAPP2P_PR = 1 if PR`i' =="1724"  /* LAP BIL ING HERN-GRF NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="412"   /* SPLENOTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4133"  /* OPEN BIOPSY OF SPLEEN */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4141"  /* MARSUPIALIZATION OF SPLENIC CYST */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4142"  /* EXCISION OF LESION OR TISSUE OF SPLEEN */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4143"  /* PARTIAL SPLENECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="415"   /* TOTAL SPLENECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4193"  /* EXCISION OF ACCESSORY SPLEEN */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4194"  /* TRANSPLANTATION OF SPLEEN */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4195"  /* REPAIR AND PLASTIC OPERATIONS ON SPLEEN */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4199"  /* OTHER OPERATIONS ON SPLEEN */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4240"  /* ESOPHAGECTOMY, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4241"  /* PARTIAL ESOPHAGECTOMY (HAS 1 CASE) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4242"  /* TOTAL ESOPHAGECTOMY (HASE 1 CASE) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4253"  /* INTRATHORACIC ESOPHAGEAL ANASTOMOSIS W/ INTERPOSITION OF SMALL BOWEL */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4254"  /* OTHER INTRATHORACIC ESOPHAGOENTEROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4255"  /* INTRATHORACIC ESOPHAGEAL ANASTOMOSIS W/ INTERPOSITION OF COLON */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4256"  /* OTHER INTRATHORACIC ESOPHAGOCOLOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4263"  /* ANTESTERNAL ESOPHAGEAL ANASTOMOSIS W/ INTERPOSITION OF SMALL BOWEL */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4264"  /* OTHER ANTESTERNAL ESOPHAGOENTEROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4265"  /* ANTESTERNAL ESOPHAGEAL ANASTOMOSIS W/ INTERPOSITION OF COLON */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4266"  /* OTHER ANTESTERNAL ESOPHAGOCOLOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4291"  /* LIGATION OF ESOPHAGEAL VARICES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="430"   /* GASTROTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="433"   /* PYLOROMYOTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4342"  /* LOCAL EXCISION OF OTHER LESION OR TISSUE OF STOMACH (HAS 10 CASES) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4349"  /* OTHER DESTRUCTION OF LESION OR TISSUE OF STOMACH (HAS 1 CASE) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="435"   /* PARTIAL GASTRECTOMY W/ ANASTOMOSIS TO ESOPHAGUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="436"   /* PARTIAL GASTRECTOMY W/ ANASTOMOSIS TO DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="437"   /* PARTIAL GASTRECTOMY W/ ANASTOMOSIS TO JEJUNUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4381"  /* PARTIAL GASTRECTOMY W/ JEJUNA TRANSPOSITION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4382"  /* LAPAROSCOPIC VERTICAL (SLEEVE) GASTRECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4389"  /* OTHER PARTIAL GASTRECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4391"  /* TOTAL GASTRECTOMY W/ INTESTINAL INTERPOSITION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4399"  /* OTHER TOTAL GASTRECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4400"  /* VAGOTOMY, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4401"  /* TRUNCAL VAGOTOMY (HAS ONE CASE) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4402"  /* HIGHLY SELECTIVE VAGOTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4403"  /* OTHER SELECTIVE VAGOTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4411"  /* TRANSABDOMINAL GASTROSCOPY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4415"  /* OPEN BIOPSY OF STOMACH (HAS ONE CASE) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4421"  /* DILATION OF PYLORUS BY INCISION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4429"  /* OTHER PYLOROPLASTY HAS 6 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4431"  /* HIGH GASTRIC BYPASS HAS 1 CASE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4438"  /* LAPAROSCOPIC GASTROENTEROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4439"  /* OTHER GASTROENTEROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4440"  /* SUTURE OF PEPTIC ULCER, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4441"  /* SUTURE OF GASTRIC ULCER SITE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4442"  /* SUTURE OF DUODENAL ULCER SITE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="445"   /* REVISION OF GASTRIC ANASTOMOSIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4461"  /* SUTURE OF LACERATION OF STOMACH */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4463"  /* CLOSURE OF OTHER GASTRIC FISTULA HAS 14 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4464"  /* GASTROPEXY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4465"  /* ESOPHAGOGASTROPLASTY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4466"  /* OTHER PROCEDURES FOR CREATION OF ESOPHAGOGASTRIC SPHINCTERIC COMPETENCE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4467"  /* LAPAROSCOPIC PROCEDURES FOR CREATION OF ESOPHAGOGASTRIC SPHINCTERIC COMPETENCE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4468"  /* LAPAROSCOPIC GASTROPLASTY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4469"  /* OTHER REPAIR OF STOMACH */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4491"  /* LIGATION OF GASTRIC VARICES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4492"  /* INTRAOPERATIVE MANIPULATION OF STOMACH */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4495"  /* LAPAROSCOPIC GASTRIC RESTRICTIVE PROCEDURE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4496"  /* LAPAROSCOPIC REVISION OF GASTRIC RESTRICTIVE PROCEDURE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4497"  /* LAPAROSCOPIC REVISION OF GASTRIC RESTRICTIVE DEVICES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4499"  /* GASTRIC OPERATION NEC (OCT 04) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4500"  /* INCISION OF INTESTINE, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4501"  /* INCISION OF DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4502"  /* OTHER INCISION OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4503"  /* INCISION OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4511"  /* TRANSABDOMINAL ENDOSCOPY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4515"  /* OPEN BIOPSY OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4521"  /* TRANSABDOMINAL ENDOSCOPY OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4526"  /* OPEN BIOPSY OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4531"  /* OTHER LOCAL EXCISION OF LESION OF DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4532"  /* OTHER DESTRUCTION OF LESION OF DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4533"  /* LOCAL EXCISION OF LESION OR TISSUE OF SMALL INTESTINE, EXCEPT DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4534"  /* OTHER DESTRUCTION OF LESION OF SMALL INTESTINE, EXCEPT DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4541"  /* EXCISION OF LESION OR TISSUE OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4549"  /* OTHER DESTRUCTION OF LESION OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4550"  /* ISOLATION OF INTESTINAL SEGMENT, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4551"  /* ISOLATION OF SEGMENT OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4552"  /* ISOLATION OF SEGMENT OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4561"  /* MULTIPLE SEGMENTAL RESECTION OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4562"  /* OTHER PARTIAL RESECTION OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4563"  /* TOTAL REMOVAL OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="458"   /* TOTAL INTRA-ABDOMINAL COLECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4590"  /* INTESTINAL ANASTOMOSIS, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4591"  /* SMALL-TO-SMALL INTESTINAL ANASTOMOSIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4592"  /* ANASTOMOSIS OF SMALL INTESTINE TO RECTAL STUMP */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4593"  /* OTHER SMALL-TO-LARGE INTESTINAL ANASTOMOSIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4594"  /* LARGE-TO-LARGE INTESTINAL ANASTOMOSIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4595"  /* ANASTOMOSIS TO ANUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4601"  /* EXTERIORIZATION OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4603"  /* EXTERIORIZATION OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4610"  /* COLOSTOMY, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4611"  /* TEMPORARY COLOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4613"  /* PERMANENT COLOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4614"  /* DELAYED OPENING OF COLOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4620"  /* ILEOSTOMY, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4621"  /* TEMPORARY ILESOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4622"  /* CONTINENT ILEOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4623"  /* OTHER PERMANENT ILEOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4640"  /* REVISION OF INTESTINA STOMA, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4641"  /* REVISION OF STOMA OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4642"  /* REPAIR OF PERICOLOSTOMY HERNIA */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4643"  /* OTHER REVISION OF STOMA OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4650"  /* CLOSURE OF INTESTINAL STOMA, NOT OTHERWISE SPECIFIED */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4651"  /* CLOSURE OF STOMA OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4652"  /* CLOSURE OF STOMA OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4660"  /* FIXATION OF INTESTINE, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4661"  /* FIXATION OF SMALL INTESTINE TO ABDOMINAL WALL */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4662"  /* OTHER FIXATION OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4663"  /* FIXATION OF LARGE INTESTINE TO ABDOMINAL WALL */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4664"  /* OTHER FIXATION OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4672"  /* CLOSURE OF FISTULA OF DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4673"  /* SUTURE OF LACERATION OF SMALL INTESTINE, EXCEPT DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4674"  /* CLOSURE OF FISTULA OF SMALL INTESTINE, EXCEPT DUODENUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4675"  /* SUTURE OF LACERATION OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4676"  /* CLOSURE OF FISTULA OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4679"  /* OTHER REPAIR OF INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4680"  /* INTRA-ABDOMINAL MANIPULATION OF INTESTINE, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4681"  /* INTRA-ABDOMINAL MANIPULATION OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4682"  /* INTRA-ABDOMINAL MANIPULATION OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4691"  /* MYOTOMY OF SIGMOID COLON */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4692"  /* MYOTOMY OF OTHER PARTS OF COLON */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4693"  /* REVISION OF ANASTOMOSIS OF SMALL INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4694"  /* REVISION OF ANASTOMOSIS OF LARGE INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4697"  /* TRANSPLANT OF INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4699"  /* OTHER OPERATIONS ON INTESTINES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4821"  /* TRANSABDOMINAL PROCTOSIGMOIDOSCOPY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4825"  /* OPEN BIOPSY OF RECTUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4840"  /* PULL-THRU RES RECTUM NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4841"  /* SUBMUCOSAL RESECTION OF RECTUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4842"  /* LAP PULL-THRU RES RECTUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4843"  /* OPN PULL-THRU RES RECTUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4849"  /* OTHER PULL-THROUGH RESECTION OF RECTUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="485"   /* ABDOMINOPERINEAL RESECTION OF RECTUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4850"  /* ABDPERNEAL RES RECTM NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4851"  /* LAP ABDPERNEAL RESC REC */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4852"  /* OPN ABDPERNEAL RESC REC */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4859"  /* ABDPERNEAL RESC RECT NEC */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4871"  /* SUTURE OF LACERATION OF RECTUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4874"  /* RECTORECTOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="4875"  /* ABDOMINAL PROCTOPEXY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="500"   /* HEPATOTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5012"  /* OPEN BIOPSY OF LIVER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5014"  /* LAPAROPSCOPIC LIVER BIOPSY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5019"  /* OTHER DIAGNOSTIC PROCEDURES ON LIVER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5021"  /* MARSUPIALIZATION OF LESION OF LIVER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5022"  /* PARTIAL HEPATECTOMY HAS 3 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5023"  /* OPN ABLTN LIVER LES/TISS OCT06- */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5025"  /* LAPAROPSCOPIC ABLATION OF LIVER LESION OR TISSUE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5026"  /* ABLTN LIVER LES/TISS NEC OCT06- */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5029"  /* OTHER DESTRUCTION OF LESION OF LIVER HAS 2 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="503"   /* LOBECTOMY OF LIVER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="504"   /* TOTAL HEPATECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5051"  /* AUXILIARY LIVER TRANSPLANT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5059"  /* OTHER TRANSPLANT OF LIVER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5061"  /* CLOSURE OF LACERATION OF LIVER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5069"  /* OTHER REPAIR OF LIVER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5102"  /* TROCAR CHOLECYSTOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5103"  /* OTHER CHOLECYSTOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5104"  /* OTHER CHOLECYSTOTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5113"  /* OPEN BIOPSY OF GALLBLADDER OR BILE DUCTS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5119"  /* OTHER DIAGNOSTIC PROCEDURES ON BILIARY TRACT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5121"  /* OTHER PARTIAL CHOLECYSTECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5122"  /* CHOLECYSTECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5123"  /* LAPAROSCOPIC CHOLECYSTECTOMY SE 5122 WITH 116 CASES, THIS ONE HAS 7 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5124"  /* LAPAROSCOPIC PARTIAL CHOLECYSTECTOMY  */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5131"  /* ANASTOMOSIS OF GALLBLADDER TO HEPATIC DUCTS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5132"  /* ANASTOMOSIS OF GALLBLADDER TO INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5133"  /* ANASTOMOSIS OF GALLBLADDER TO PANCREAS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5134"  /* ANASTOMOSIS OF GALLBLADDER TO STOMACH */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5135"  /* OTHER GALLBLADDER ANASTOMOSIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5136"  /* CHOLEDOCHOENTEROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5137"  /* ANASTOMOSIS OF HEPATIC DUCT TO GASTROINTESTINAL TRACT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5139"  /* OTHER BILE DUCT ANASTOMOSIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5141"  /* COMMON DUCT EXPLORATION FOR REMOVAL OF CALCULUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5142"  /* COMMON DUCT EXPLORATION FOR RELIEF OF OTHER OBSTRUCTION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5143"  /* INSERTION OF CHOLEDOCHOHEPATIC TUBE FOR DECOMPRESSION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5149"  /* INCISION OF OTHER BILE DUCTS FOR RELIEF OF OBSTRUCTION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5151"  /* EXPLORATION OF COMMON DUCT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5159"  /* INCISION OF OTHER BILE DUCT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5161"  /* EXCISION OF CYSTIC DUCT REMNANT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5162"  /* EXCISION OF AMPULLA OF VATER (WITH REIMPLANTATION OF COMMON DUCT) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5163"  /* OTHER EXCISION OF COMMON DUCT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5169"  /* EXCISION OF OTHER BILE DUCT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5171"  /* SIMPLE SUTURE OF COMMON BILE DUCT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5172"  /* CHOLEDOCHOPLASTY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5179"  /* REPAIR OF OTHER BILE DUCTS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5181"  /* DILATION OF SPHINCTER OF ODDI */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5182"  /* PANCREATIC SPHINCTEROTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5183"  /* PANCREATIC SPHINCTEROPLASTY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5189"  /* OTHER OPERATIONS ON SPHINCTER OF ODDI */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5191"  /* REPAIR OF LACERATION OF GALLBLADDER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5192"  /* CLOSURE OF CHOLECYSTOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5193"  /* CLOSURE OF OTHER BILIARY FISTULA */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5194"  /* REVISION OF ANASTOMOSIS OF BILIARY TRACT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5195"  /* REMOVAL OF PROSTHETIC DEVICE FROM BILE DUCT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5199"  /* OTHER OPERATIONS ON BILIARY TRACT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5201"  /* DRAINAGE OF PANCREATIC CYST BY CATHETER */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5209"  /* OTHER PANCREATOTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5212"  /* OPEN BIOPSY OF PANCREAS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5219"  /* OTHER DIAGNOSTIC PROCEDURES ON PANCREAS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5222"  /* OTHER EXCISION OR DESTRUCT OF LESION OR TISSUE OF PANCREAS OR PANC DUCT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="523"   /* MARSUPIALIZATION OF PANCREATIC CYST */
	capture replace PRAPP2P_PR = 1 if PR`i' =="524"   /* INTERNAL DRAINAGE OF PANCREATIC CYST */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5251"  /* PROXIMAL PANCREATECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5252"  /* DISTAL PANCREATECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5253"  /* RADICAL SUBTOTAL PANCREATECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5259"  /* OTHER PARTIAL PANCREATECTOMY (HAS 1 CASE) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="526"   /* TOTAL PANCREATECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="527"   /* RADICAL PANCREATICODUODENECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5280"  /* PANCREATIC TRANSPLANT, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5281"  /* REIMPLANTATION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5282"  /* HOMOTRANSPLANT OF PANCREAS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5283"  /* HETEROTRANSPLANT OF PANCREAS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5292"  /* CANNULATION OF PANCREATIC DUCT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5295"  /* OTHER REPAIR OF PANCREAS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5296"  /* ANASTOMOSIS OF PANCREAS (HAS 1 CASE) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5299"  /* OTHER OPERATIONS ON PANCREAS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5300"  /* UNILATERAL REPAIR OF INGUINAL HERNIA, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5301"  /* REPAIR OF DIRECT INGUINAL HERNIA HAS 2 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5302"  /* REPAIR OF INDIRECT INGUINAL HERNIA HAS 2 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5303"  /* REPAIR OF DIRECT INGUINAL HERNIA W/ GRAFT OR PROSTHESIS HAS 1 CASE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5304"  /* REPAIR OF INDIRECT INGUINAL HERNIA W/ GRAFT OR PROSTHESIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5305"  /* REPAIR OF INGUINAL HERNIA W/ GRAFT OR PROSTHESIS, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5310"  /* BILATERAL REPAIR OF INGUINAL HERNIA, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5311"  /* BILATERAL REPAIR OF DIRECT INGUINAL HERNIA HAS 1 CASE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5312"  /* BILATERAL REPAIR OF INDIRECT INGUINAL HERNIA */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5313"  /* BILATERAL REPAIR OF INGUINAL HERNIA, ONE DIRECT AND ONE INDIRECT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5314"  /* BILATERAL REPAIR OF DIRECT INGUINAL HERNIA W/ GRAFT OR PROSTHESIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5315"  /* BILATERAL REPAIR OF INDIRECT INGUINAL HERNIA W/ GRAFT OR PROSTHESIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5316"  /* BILATERAL REPAIR OF INGUIN HERNIA, 1 DIRECT 1 INDIRECT, W/ GRAFT OR PROS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5317"  /* BILATERAL INGUINAL HERNIA REPAIR W/ GRAFT OR PROSTHESIS, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5321"  /* UNILATERAL REPAIR OF FEMORAL HERNIA */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5329"  /* OTHER UNILATERAL FEMORAL HERNIORRHAPHY HAS 1 CASE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5331"  /* BILATERAL REPAIR OF FEMORAL HERNIA W/ GRAFT OR PROSTHESIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5339"  /* OTHER BILATERAL FEMORAL HERNIORRHAPHY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5341"  /* REPAIR OF UMBILICAL HERNIA W/ PROSTHESIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5342"  /* LAP UMBIL HERNIA-GRAFT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5343"  /* LAP UMBILICAL HERNIA NEC */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5349"  /* OTHER UMBILICAL HERNIORRHAPHY HAS 2 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5351"  /* INCISIONAL HERNIA REPAIR HAS 2 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5359"  /* REPAIR OF OTHER HERNIA OF ANTERIOR ABDOMINAL WALL (HAS 5 CASES) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5361"  /* INCISIONAL HERNIA REPAIR W/ PROSTHESIS (HAS 6 CASES) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5362"  /* LAP INCIS HERN REPR-GRFT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5363"  /* LAP HERN ANT ABD-GFT NEC */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5369"  /* REPAIR OF OTHER HERNIA OF ANTERIOR ABDOMINAL WALL W/ PROSTHESIS HAS 1 CASE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="537"   /* REPAIR OF DIAPHRAGMATIC HERNIA, ABDOMINAL APPROACH */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5371"  /* LAP ABD REP-DIAPHR HERN */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5372"  /* OPN ABD DIAPHRM HERN NEC */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5375"  /* ABD REP-DIAPHR HERN NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="540"   /* INCISION OF ABDOMINAL WALL */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5411"  /* EXPLORATORY LAPAROTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5412"  /* REOPENING OF RECENT LAPAROTOMY SITE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5419"  /* OTHER LAPAROTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5421"  /* LAPAROSCOPY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5422"  /* BIOPSY OF ABDOMINAL WALL OR UMBILICUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5423"  /* BIOPSY OF ABDOMINAL WALL OR UMBILICUS (HAS 2 CASES) */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5429"  /* OTHER DIAGNOSTIC PROCEDURES ON ABDOMINAL REGION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="543"   /* EXCISION OR DESTRUCTION OF LESION OR TISSUE OF ABDOMINAL WALL OR UMBILICUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="544"   /* EXCISION OR DESTRUCTION OF PERITONEAL TISSUE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5451"  /* LAPAROSCOPIC LYSIS OF PERITONEAL ADHESIONS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5459"  /* OTHER LYSIS OF PERITONEAL ADHESIONS HAS 463 CASES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5461"  /* RECLOSURE OF POSTOPERATIVE DISRUPTION OF ABDOMINAL WALL */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5462"  /* DELAYED CLOSURE OF GRANULATING ABDOMINAL WOUND */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5463"  /* OTHER SUTURE OF ABDOMINAL WALL */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5464"  /* SUTURE OF PERITONEUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5471"  /* REPAIR OF GASTROSCHISIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5472"  /* OTHER REPAIR OF ABDOMINAL WALLS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5473"  /* OTHER REPAIR OF PERITONEUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5474"  /* OTHER REPAIR OF OMENTUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5475"  /* OTHER REPAIR OF MESENTERY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5492"  /* REMOVAL OF FOREIGN BODY FROM PERITONEAL CAVITY HAS 1 CASE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5493"  /* CREATION OF CUTANEOPERITONEAL FISTULA */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5494"  /* CREATION OF PERITONEOVASCULAR SHUNT */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5495"  /* INCISION OF PERITONEUM */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5651"  /* FORMATION OF CUTANEOUS URETERO-ILEOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5652"  /* REVISION OF CUTANEOUS URETERO-ILEOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5661"  /* FORMATION OF OTHER CUTANEOUS URETEROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5662"  /* REVISION OF OTHER CUTANEOUS URETEROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5671"  /* URINARY DIVERSION TO INTESTINE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5672"  /* REVISION OF URETEROINTESTINAL ANASTOMOSIS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="5900"  /* RETROPERITONEAL DISSECTION, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6501"  /* LAPAROSCOPIC OOPHOROTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6509"  /* OTHER OOPHORECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6512"  /* OTHER BIOPSY OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6521"  /* MARSUPIALIZATION OF OVARIAN CYST */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6522"  /* WEDGE RESECTION OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6523"  /* LAPAROSCOPIC MARSUPIALIZATION OF OVARIAN CYST */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6524"  /* LAPAROSCOPIC WEDGE RESECTION OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6525"  /* OTHER LAPAROSCOPIC LOCAL EXCISION OR DESTRUCTION OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6529"  /* OTHER LOCAL EXCISION OR DESTRUCTION OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6531"  /* LAPAROSCOPIC UNILATERAL OOPHORECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6539"  /* OTHER UNLILATERAL OOPHORECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6541"  /* LAPAROSCOPIC UNILATERAL SALPINGO-OOPHORECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6549"  /* OTHER UNILATERAL SALPINGOOPHORECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6551"  /* OTHER REMOVAL OF BOTH OVARIES AT SAME OPERATIVE EPISODE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6552"  /* OTHER REMOVAL OF REMAINING OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6553"  /* LAPAROSCOPIC REMOVAL OF BOTH OVARIES AT SAME OPERATIVE EPISODE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6554"  /* LAPAROSCOPIC REMOVAL OF REMAINING OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6561"  /* OTHER REMOVAL OF BOTH OVARIES AND TUBES AT SAME OPERATIVE EPISODE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6562"  /* OTHER REMOVAL OF REMAINING OVARY AND TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6563"  /* LAPAROSCOPIC REMOVAL OF BOTH OVARIES AND TUBES AT SAME OPERATIVE EPISODE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6564"  /* LAPAROSCOPIC REMOVAL OF REMAINING OVARY AND TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6571"  /* OTHER SIMPLE SUTURE OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6572"  /* OTHER REIMPLANTATION OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6573"  /* OTHER SALPINGO OOPHOROPLASTY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6574"  /* LAPAROSCOPIC SIMPLE SUTURE OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6575"  /* LAPAROSCOPIC REIMPLANTATION OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6576"  /* LAPAROSCOPIC SALPINGO-OOPHOROPLASTY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6579"  /* OTHER REPAIR OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6581"  /* LAPAROSCOPIC LYSIS OF ADHESIONS OF OVARY AND FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6589"  /* OTHER LYSIS OF ADHESIONS OF OVARY AND FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6592"  /* TRANSPLANTATION OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6593"  /* MANUAL RUPTURE OF OVARIAN CYST */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6594"  /* OVARIAN DENERVATION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6595"  /* RELEASE OF TORSION OF OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6599"  /* OTHER OPERATIONS ON OVARY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6601"  /* SALPINGOTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6602"  /* SALPINGOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6611"  /* BIOPSY OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6619"  /* OTHER DIAGNOSTIC PROCEDURES ON FALLOPIAN TUBES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6631"  /* OTHER BILATERAL LIGATION AND CRUSHING OF FALLOPIAN TUBES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6632"  /* OTHER BILATERAL LIGATION AND DIVISION OF FALLOPIAN TUBES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6639"  /* OTHER BILATERAL DESTRUCTION OR OCCLUSION OF FALLOPIAN TUBES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="664"   /* TOTAL UNILATERAL SALPINGECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6651"  /* REMOVAL OF BOTH FALLOPIAN TUBES AT SAME OPERATIVE EPISODE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6652"  /* REMOVAL OF REMAINING FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6661"  /* EXCISION OR DESTRUCTION OF LESION OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6662"  /* SALPINGECTOMY W/ REMOVAL OF TUBAL PREGNANCY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6663"  /* BILATERAL PARTIAL SALPINGECTOMY, NOS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6669"  /* OTHER PARTIAL SALPINGECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6671"  /* SIMPLE SUTURE OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6672"  /* SALPINGO-OOPHOROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6673"  /* SALPINGO-SALPINGOSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6674"  /* SALPINGO-UTEROSTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6679"  /* OTHER REPAIR OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6692"  /* UNILATERAL DESTRUCTION OR OCCLUSION OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6693"  /* IMPLANTATION OR capture replaceMENT OF PROSTHESIS OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6694"  /* REMOVAL OF PROSTHESIS OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6696"  /* DILATION OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6697"  /* BURYING OF FIMBRIAE IN UTERINE WALL */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6699"  /* OTHER OPERATION OF FALLOPIAN TUBE */
	capture replace PRAPP2P_PR = 1 if PR`i' =="680"   /* OTHER INCISION AND EXCISION OF UTERUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6813"  /* OPEN BIOPSY OF UTERUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6814"  /* OPEN BIOPSY OF UTERINE LIGAMENTS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6819"  /* OTHER DIAGNOSTIC PROCEDURES ON UTERUS AND SUPPORTING STRUCTURES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6823"  /* ENDOMETRIAL ABLATION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6829"  /* OTHER EXCISION OR DESTRUCTION OF LESION OF UTERUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="683"   /* SUBTOTAL ABDOMINAL HYSTERECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6831"  /* LAPAROSCOPIC SUPRACERVICAL HYSTERECTOMY [LSH] */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6839"  /* OTHER SUBTOTAL ABDOMINAL HYSTERECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="684"   /* TOTAL ABDOMINAL HYSTERECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6841"  /* LAP TOTAL ABDOMINAL HYST OCT06- */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6849"  /* TOTAL ABD HYST NEC/NOS OCT06- */
	capture replace PRAPP2P_PR = 1 if PR`i' =="686"   /* RADICAL ABDOMINAL HYSTERECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6861"  /* LAP RADICAL ABDOMNL HYST OCT06- */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6869"  /* RADICAL ABD HYST NEC/NOS OCT06- */
	capture replace PRAPP2P_PR = 1 if PR`i' =="688"   /* PELVIC EVISCERATION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="689"   /* OTHER AND UNSPECIFIED HYSTERECTOMY */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6919"  /* OTHER EXCISION OR DESTRUCTION OF UTERUS AND SUPPORTING STRUCTURES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6921"  /* INTERPOSITION OPERATION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6922"  /* OTHER UTERINE SUSPENSION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6923"  /* VAGINAL REPAIR OF CHRONIC INVERSION OF UTERUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6929"  /* OTHER REPAIR OF UTERUS AND SUPPORTING STRUCTURES */
	capture replace PRAPP2P_PR = 1 if PR`i' =="693"   /* PARACERVICAL UTERINE DENERVATION */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6941"  /* SUTURE OF LACERATION OF UTERUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6942"  /* CLOSURE OF FISTULA OF UTERUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6949"  /* OTHER REPAIR OF UTERUS */
	capture replace PRAPP2P_PR = 1 if PR`i' =="6998"  /* OTHER OPERATIONS ON SUPPORTING STRUCTURES OF UTERUS */
}
label var PRAPP2P_PR "Incidental Appendectomy (Population at Risk):"

/* Incidental Appendectomy (Outcome of Interest): */
gen PRAPPNP_PR = 0
forval i = 1/30 {
	capture replace PRAPPNP_PR = 1 if PR`i' == "471" /* INCIDENTAL APPENDECTOMY */
	capture replace PRAPPNP_PR = 1 if PR`i' == "4711" /* LAPAROSCOP INCID APPEND */
	capture replace PRAPPNP_PR = 1 if PR`i' == "4719" /* OTH INCID APPEND */
}
label var PRAPPNP_PR "Incidental Appendectomy (Outcome of Interest):"

/* Exclude: Colectomy or Pelvic Evisceration */
gen PRAPP3P_PR = 0 
forval i = 1/30 {
	capture replace PRAPP3P_PR = 1 if PR`i' == "1731" /* LAP MUL SEG RES LG INTES */
	capture replace PRAPP3P_PR = 1 if PR`i' == "1732" /* LAPAROSCOPIC CECECTOMY */
	capture replace PRAPP3P_PR = 1 if PR`i' == "1733" /* LAP RIGHT HEMICOLECTOMY */
	capture replace PRAPP3P_PR = 1 if PR`i' == "1734" /* LAP RES TRANSVERSE COLON */
	capture replace PRAPP3P_PR = 1 if PR`i' == "1735" /* LAP LEFT HEMICOLECTOMY */
	capture replace PRAPP3P_PR = 1 if PR`i' == "1736" /* LAP SIGMOIDECTOMY */
	capture replace PRAPP3P_PR = 1 if PR`i' == "1739" /* LAP PT EX LRG INTEST NEC */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4571" /* OPN MUL SEG LG INTES NEC */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4572" /* OPEN CECECTOMY NEC */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4573" /* OPN RT HEMICOLECTOMY NEC */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4574" /* OPN TRANSV COLON RES NEC */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4575" /* OPN LFT HEMICOLECTMY NEC */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4576" /* OPEN SIGMOIDECTOMY NEC */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4579" /* PRT LG INTES EXC NEC/NOS */
	capture replace PRAPP3P_PR = 1 if PR`i' == "458" /* TOT ABD COLECTMY */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4581" /* LAP TOT INTR-AB COLECTMY */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4582" /* OP TOT INTR-ABD COLECTMY */
	capture replace PRAPP3P_PR = 1 if PR`i' == "4583" /* TOT ABD COLECTMY NEC/NOS */
	capture replace PRAPP3P_PR = 1 if PR`i' == "688" /* PELVIC EVISCERATION */
}
label var PRAPP3P_PR "Exclude: Colectomy or Pelvic Evisceration"

/* Exclude: Cancer adj to appendix */
/* ICD-9-CM Diagnosis Codes: */
gen PRAPPND_DX = 0 
forval i = 1/35 {
	capture replace PRAPPND_DX = 1 if DX`i' == "1534" /*  MALIGNANT NEOPLASM CECUM */
	capture replace PRAPPND_DX = 1 if DX`i' == "1535" /*  MALIGNANT NEO APPENDIX */
	capture replace PRAPPND_DX = 1 if DX`i' == "1536" /*  MALIG NEO ASCEND COLON */
	capture replace PRAPPND_DX = 1 if DX`i' == "1538" /*  MALIGNANT NEO COLON NEC */
	capture replace PRAPPND_DX = 1 if DX`i' == "1539" /*  MALIGNANT NEO COLON NOS */
	capture replace PRAPPND_DX = 1 if DX`i' == "1588" /*  MAL NEO PERITONEUM NEC */
	capture replace PRAPPND_DX = 1 if DX`i' == "1589" /*  MAL NEO PERITONEUM NOS */
	capture replace PRAPPND_DX = 1 if DX`i' == "1590" /*  MALIG NEO INTESTINE NOS */
	capture replace PRAPPND_DX = 1 if DX`i' == "1598" /*  MAL NEO GI/INTRA-ABD NEC */
	capture replace PRAPPND_DX = 1 if DX`i' == "1599" /*  MAL NEO GI TRACT ILL-DEF */
	capture replace PRAPPND_DX = 1 if DX`i' == "1952" /*  MALIG NEO ABDOMEN */
	capture replace PRAPPND_DX = 1 if DX`i' == "1975" /*  SEC MALIG NEO LG BOWEL */
	capture replace PRAPPND_DX = 1 if DX`i' == "1976" /*  SEC MAL NEO PERITONEUM */
	capture replace PRAPPND_DX = 1 if DX`i' == "20974"  /*  SEC NEUROENDO TU-PERITON */
}

capture replace TPIQ24=0 if   MDC ! = 14   											///
					  & AGE >= 65   										///
					  & PRAPP2P_PR == 1  	
capture replace TPIQ24=1 if   MDC ! = 14   											///
					  & AGE >= 65   										///
					  & PRAPP2P_PR == 1 									///
					  & PRAPPNP_PR == 1
*** Exclude Colectomy or Pelvic Evisceration;

capture replace TPIQ24=. if   MDC ! = 14   											///
					  & AGE >= 65   										///
					  & PRAPP2P_PR == 1										///
					  & PRAPP3P_PR == 1

*** Exclude Cancer adj to Appendix;
capture replace TPIQ24=. if   MDC ! = 14   											///
					  & AGE >= 65   										///
					  & PRAPP2P_PR == 1										///
					  & PRAPPND_DX == 1

* -------------------------------------------------- ;
* --- IQI 25 : BI-LATERAL CATHETERIZATION        --- ;
* -------------------------------------------------- ;

/*  Catheterization (Population at Risk) */
/* ICD-9-CM Procedure Code: */
gen PRCAT2P_PR = 0
forval i = 1/30 {
	capture replace PRCAT2P_PR = 1 if PR`i' == "3722" /* LEFT HEART CARDIAC CATH */
	capture replace PRCAT2P_PR = 1 if PR`i' == "3723" /* RT/LEFT HEART CARD CATH */
}
label var PRCAT2P_PR " Catheterization (Population at Risk)"


/* Include only: Coronary artery disease */
/* ICD-9-CM Diagnosis Code: */
gen PRCATHD_DX = 0
forval i = 1/35 {
	capture replace PRCATHD_DX = 1 if DX`i'=="41000"  /* AMI ANTEROLATERAL,UNSPEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="41001"  /* AMI ANTEROLATERAL, INIT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41002"  /* AMI ANTEROLATERAL,SUBSEQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="41010"  /* AMI ANTERIOR WALL,UNSPEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="41011"  /* AMI ANTERIOR WALL, INIT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41012"  /* AMI ANTERIOR WALL,SUBSEQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="41020"  /* AMI INFEROLATERAL,UNSPEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="41021"  /* AMI INFEROLATERAL, INIT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41022"  /* AMI INFEROLATERAL,SUBSEQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="41030"  /* AMI INFEROPOST, UNSPEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="41031"  /* AMI INFEROPOST, INITIAL */
	capture replace PRCATHD_DX = 1 if DX`i'=="41032"  /* AMI INFEROPOST, SUBSEQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="41040"  /* AMI INFERIOR WALL,UNSPEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="41041"  /* AMI INFERIOR WALL, INIT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41042"  /* AMI INFERIOR WALL,SUBSEQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="41050"  /* AMI LATERAL NEC, UNSPEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="41051"  /* AMI LATERAL NEC, INITIAL */
	capture replace PRCATHD_DX = 1 if DX`i'=="41052"  /* AMI LATERAL NEC, SUBSEQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="41060"  /* TRUE POST INFARCT,UNSPEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="41061"  /* TRUE POST INFARCT, INIT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41062"  /* TRUE POST INFARCT,SUBSEQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="41070"  /* SUBENDO INFARCT, UNSPEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="41071"  /* SUBENDO INFARCT, INITIAL */
	capture replace PRCATHD_DX = 1 if DX`i'=="41072"  /* SUBENDO INFARCT, SUBSEQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="41080"  /* AMI NEC, UNSPECIFIED */
	capture replace PRCATHD_DX = 1 if DX`i'=="41081"  /* AMI NEC, INITIAL */
	capture replace PRCATHD_DX = 1 if DX`i'=="41082"  /* AMI NEC, SUBSEQUENT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41090"  /* AMI NOS, UNSPECIFIED */
	capture replace PRCATHD_DX = 1 if DX`i'=="41091"  /* AMI NOS, INITIAL */
	capture replace PRCATHD_DX = 1 if DX`i'=="41092"  /* AMI NOS, SUBSEQUENT */
	capture replace PRCATHD_DX = 1 if DX`i'=="4110"  /* POST MI SYNDROME */
	capture replace PRCATHD_DX = 1 if DX`i'=="4111"  /* INTERMED CORONARY SYND */
	capture replace PRCATHD_DX = 1 if DX`i'=="41181"  /* CORONARY OCCLSN W/O MI */
	capture replace PRCATHD_DX = 1 if DX`i'=="41189"  /* AC ISCHEMIC HRT DIS NEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="412"  /* OLD MYOCARDIAL INFARCT */
	capture replace PRCATHD_DX = 1 if DX`i'=="4130"  /* ANGINA DECUBITUS */
	capture replace PRCATHD_DX = 1 if DX`i'=="4131"  /* PRINZMETAL ANGINA */
	capture replace PRCATHD_DX = 1 if DX`i'=="4139"  /* ANGINA PECTORIS NEC/NOS */
	capture replace PRCATHD_DX = 1 if DX`i'=="4140"  /* CORONARY ATHEROSCLEROSIS */
	capture replace PRCATHD_DX = 1 if DX`i'=="41400"  /* COR ATH UNSP VSL NTV/GFT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41401"  /* CRNRY ATHRSCL NATVE VSSL */
	capture replace PRCATHD_DX = 1 if DX`i'=="41402"  /* CRN ATH ATLG VN BPS GRFT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41403"  /* CRN ATH NONATLG BLG GRFT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41404"  /* COR ATH ARTRY BYPAS GRFT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41405"  /* COR ATH BYPASS GRAFT NOS */
	capture replace PRCATHD_DX = 1 if DX`i'=="41406"  /* COR ATH NATV ART TP HRT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41407"  /* COR ATH BPS GRAFT TP HRT */
	capture replace PRCATHD_DX = 1 if DX`i'=="41410"  /* ANEURYSM, HEART (WALL) */
	capture replace PRCATHD_DX = 1 if DX`i'=="41411"  /* CORONARY VESSEL ANEURYSM */
	capture replace PRCATHD_DX = 1 if DX`i'=="41412"  /* DISSECTION COR ARTERY */
	capture replace PRCATHD_DX = 1 if DX`i'=="41419"  /* ANEURYSM OF HEART NEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="4143"  /* COR ATH D/T LPD RCH PLAQ */
	capture replace PRCATHD_DX = 1 if DX`i'=="4144"  /* CORONARY ATHEROSCLEROSIS DUE TO CALCIFID LESION */
	capture replace PRCATHD_DX = 1 if DX`i'=="4148"  /* CHR ISCHEMIC HRT DIS NEC */
	capture replace PRCATHD_DX = 1 if DX`i'=="4149"  /* CHR ISCHEMIC HRT DIS NOS */
}
label var PRCATHD_DX "Include only: Coronary artery disease"


/* Bi-lateral Catheterization (Outcome of Interest): */
/* ICD-9-CM Procedure Code: */
gen PRCATHP_PR = 0 
forval i = 1/30 {
	capture replace PRCATHP_PR = 1 if PR`i' == "3723" /* RT/LEFT HEART CARD CATH */
}
label var PRCATHP_PR  "Bi-lateral Catheterization (Outcome of Interest) "

/* Exclude: Indications for right-sided catherterization diagnosis */
/* ICD-9-CM Diagnosis Code: */
gen PRCAT2D_DX = 0
forval i = 1/35 {
	capture replace PRCAT2D_DX = 1 if DX`i'== "3910"  /* ACUTE RHEUMATIC PERICARD */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3911"  /* ACUTE RHEUMATIC ENDOCARD */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3912"  /* AC RHEUMATIC MYOCARDITIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3918"  /* AC RHEUMAT HRT DIS NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3919"  /* AC RHEUMAT HRT DIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3920"  /* RHEUM CHOREA W HRT INVOL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "393"  /* CHR RHEUMATIC PERICARD */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3940"  /* MITRAL STENOSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3941"  /* RHEUMATIC MITRAL INSUFF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3942"  /* MITRAL STENOSIS W INSUFF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3949"  /* MITRAL VALVE DIS NEC/NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3960"  /* MITRAL/AORTIC STENOSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3961"  /* MITRAL STENOS/AORT INSUF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3962"  /* MITRAL INSUF/AORT STENOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3963"  /* MITRAL/AORTIC VAL INSUFF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3968"  /* MITR/AORTIC MULT INVOLV */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3969"  /* MITRAL/AORTIC V DIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3970"  /* TRICUSPID VALVE DISEASE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3971"  /* RHEUM PULMON VALVE DIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3979"  /* RHEUM ENDOCARDITIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "3980"  /* RHEUMATIC MYOCARDITIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "39890"  /* RHEUMATIC HEART DIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "39891"  /* RHEUMATIC HEART FAILURE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "39899"  /* RHEUMATIC HEART DIS NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40200"  /* MAL HYPERTEN HRT DIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40201"  /* MAL HYPERT HRT DIS W CHF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40210"  /* BEN HYPERTEN HRT DIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40211"  /* BENIGN HYP HRT DIS W CHF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40290"  /* HYPERTENSIVE HRT DIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40291"  /* HYPERTEN HEART DIS W CHF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40400"  /* MAL HY HT/REN W/O HF/RF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40401"  /* MAL HYPER HRT/REN W HF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40402"  /* MAL HY HT/REN W REN FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40403"  /* MAL HYP HRT/REN W HF/RF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40410"  /* BEN HY HT/REN W/O HF/RF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40411"  /* BEN HYPER HRT/REN W HF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40412"  /* BEN HY HT/REN W REN FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40413"  /* BEN HYP HRT/REN W HF/RF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40490"  /* HY HT/REN NOS W/O HF/RF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40491"  /* HYPER HRT/REN NOS W HF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40492"  /* HY HT/REN NOS W REN FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "40493"  /* HYP HRT/REN NOS W HF/RF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4150"  /* ACUTE COR PULMONALE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4151"  /* PULMON EMBOLISM/INFARCT */
	capture replace PRCAT2D_DX = 1 if DX`i'== "41511"  /* IATROGEN PULM EMB/INFARC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "41512"  /* SEPTIC PULMONARY EMBOLSM */
	capture replace PRCAT2D_DX = 1 if DX`i'== "41513"  /* SADDLE EMBOLUS OF PULMONARY ARTERY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "41519"  /* PULM EMBOL/INFARCT NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4160"  /* PRIM PULM HYPERTENSION */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4161"  /* KYPHOSCOLIOTIC HEART DIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4168"  /* CHR PULMON HEART DIS NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4169"  /* CHR PULMON HEART DIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4170"  /* ARTERIOVEN FISTU PUL VES */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4171"  /* PULMON ARTERY ANEURYSM */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4178"  /* PULMON CIRCULAT DIS NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4179"  /* PULMON CIRCULAT DIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4200" /* AC PERICARDIT IN OTH DIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42090" /* ACUTE PERICARDITIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42091" /* AC IDIOPATH PERICARDITIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42099" /* ACUTE PERICARDITIS NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4210" /* AC/SUBAC BACT ENDOCARD */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4211" /* AC ENDOCARDIT IN OTH DIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4219" /* AC/SUBAC ENDOCARDIT NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4220" /* AC MYOCARDIT IN OTH DIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42290" /* ACUTE MYOCARDITIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42291" /* IDIOPATHIC MYOCARDITIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42292" /* SEPTIC MYOCARDITIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42293" /* TOXIC MYOCARDITIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42299" /* ACUTE MYOCARDITIS NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4230" /* HEMOPERICARDIUM */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4231" /* ADHESIVE PERICARDITIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4232" /* CONSTRICTIV PERICARDITIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4233" /* CARDIAC TAMPONADE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4238" /* PERICARDIAL DISEASE NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4239" /* PERICARDIAL DISEASE NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4240" /* MITRAL VALVE DISORDER */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4241" /* AORTIC VALVE DISORDER */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4242" /* NONRHEUM TRICUSP VAL DIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4243" /* PULMONARY VALVE DISORDER */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42490" /* ENDOCARDITIS NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42491" /* ENDOCARDITIS IN OTH DIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42499" /* ENDOCARDITIS NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4250" /* ENDOMYOCARDIAL FIBROSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4251" /* HYPERTR OBSTR CARDIOMYOP */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42511" /* HYPERTROPHIC OBSTRUCTUVE CARDIOMYOPATHY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42518" /* OTHER HYPERTROPHIC CARDIOMYOPATHY*/
	capture replace PRCAT2D_DX = 1 if DX`i'== "4252" /* OBSC AFRIC CARDIOMYOPATH */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4253" /* ENDOCARD FIBROELASTOSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4254" /* PRIM CARDIOMYOPATHY NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4255" /* ALCOHOLIC CARDIOMYOPATHY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4257" /* METABOLIC CARDIOMYOPATHY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4258" /* CARDIOMYOPATH IN OTH DIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4259" /* SECOND CARDIOMYOPATH NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4280" /* CHF NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4281" /* LEFT HEART FAILURE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42820" /* SYSTOLIC HRT FAILURE NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42821" /* AC SYSTOLIC HRT FAILURE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42822" /* CHR SYSTOLIC HRT FAILURE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42823" /* AC ON CHR SYST HRT FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42830" /* DIASTOLC HRT FAILURE NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42831" /* AC DIASTOLIC HRT FAILURE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42832" /* CHR DIASTOLIC HRT FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42833" /* AC ON CHR DIAST HRT FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42840" /* SYST/DIAST HRT FAIL NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42841" /* AC SYST/DIASTOL HRT FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42842" /* CHR SYST/DIASTL HRT FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "42843" /* AC/CHR SYST/DIA HRT FAIL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "4289" /* HEART FAILURE NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7450"  /* COMMON TRUNCUS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74510"  /* COMPL TRANSPOS GREAT VES */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74511"  /* DOUBLE OUTLET RT VENTRIC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74512"  /* CORRECT TRANSPOS GRT VES */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74519"  /* TRANSPOS GREAT VESS NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7452"  /* TETRALOGY OF FALLOT */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7453"  /* COMMON VENTRICLE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7454"  /* VENTRICULAR SEPT DEFECT */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7455"  /* SECUNDUM ATRIAL SEPT DEF */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74560"  /* ENDOCARD CUSHION DEF NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74561"  /* OSTIUM PRIMUM DEFECT */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74569"  /* ENDOCARD CUSHION DEF NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7457"  /* COR BILOCULARE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7458"  /* SEPTAL CLOSURE ANOM NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7459"  /* SEPTAL CLOSURE ANOM NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74600"  /* PULMONARY VALVE ANOM NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74601"  /* CONG PULMON VALV ATRESIA */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74602"  /* CONG PULMON VALVE STENOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74609"  /* PULMONARY VALVE ANOM NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7461"  /* CONG TRICUSP ATRES/STEN */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7462"  /* EBSTEIN'S ANOMALY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7463"  /* CONG AORTA VALV STENOSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7464"  /* CONG AORTA VALV INSUFFIC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7465"  /* CONGEN MITRAL STENOSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7466"  /* CONG MITRAL INSUFFICIENC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7467"  /* HYPOPLAS LEFT HEART SYND */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74681"  /* CONG SUBAORTIC STENOSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74682"  /* COR TRIATRIATUM */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74683"  /* INFUNDIB PULMON STENOSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74684"  /* OBSTRUCT HEART ANOM NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74685"  /* CORONARY ARTERY ANOMALY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74686"  /* CONGENITAL HEART BLOCK */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74687"  /* MALPOSITION OF HEART */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74689"  /* CONG HEART ANOMALY NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7469"  /* CONG HEART ANOMALY NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7470"  /* PATENT DUCTUS ARTERIOSUS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74710"  /* COARCTATION OF AORTA */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74711"  /* INTERRUPT OF AORTIC ARCH */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74720"  /* CONG ANOM OF AORTA NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74721"  /* ANOMALIES OF AORTIC ARCH */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74722"  /* AORTIC ATRESIA/STENOSIS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74729"  /* CONG ANOM OF AORTA NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7473"  /* PULMONARY ARTERY ANOM */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74731"  /* PULMONARY ARTERY COARCTATION AND ATRESIA */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74740"  /* GREAT VEIN ANOMALY NOS */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74741"  /* TOT ANOM PULM VEN CONNEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74742"  /* PART ANOM PULM VEN CONN */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74749"  /* GREAT VEIN ANOMALY NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7475"  /* UMBILICAL ARTERY ABSENCE */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74760"  /* UNSP PRPHERL VASC ANOMAL */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74761"  /* GSTRONTEST VESL ANOMALY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74762"  /* RENAL VESSEL ANOMALY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74763"  /* UPR LIMB VESSEL ANOMALY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74764"  /* LWR LIMB VESSEL ANOMALY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74769"  /* OTH SPCF PRPH VSCL ANOML */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74781"  /* CEREBROVASCULAR ANOMALY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74782"  /* SPINAL VESSEL ANOMALY */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74783"  /* PERSISTENT FETAL CIRC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "74789"  /* CIRCULATORY ANOMALY NEC */
	capture replace PRCAT2D_DX = 1 if DX`i'== "7479"  /* CIRCULATORY ANOMALY NOS */
}

capture replace TPIQ25 = 0  if   MDC ! = 14 & PRCAT2P_PR == 1 & PRCATHD_DX == 1 
capture replace TPIQ25 = 1  if   MDC ! = 14 & PRCAT2P_PR == 1 & PRCATHD_DX == 1  & ( PRCATHP_PR == 1 & PRCAT2D_DX != 1)
 
* -------------------------------------------------------------- ;
* --- EXCLUDE CASES WITH MISSING VALUES FOR DISP OR ASOURCE  --- ;
* -------------------------------------------------------------- ;

capture replace TPIQ08  = . if DISPUNIFORM < 0 
capture replace TPIQ09  = . if DISPUNIFORM < 0  
capture replace TPIQ09A = . if DISPUNIFORM < 0  
capture replace TPIQ09B = . if DISPUNIFORM < 0 
capture replace TPIQ11  = . if DISPUNIFORM < 0 
capture replace TPIQ11A = . if DISPUNIFORM < 0 
capture replace TPIQ11B = . if DISPUNIFORM < 0 
capture replace TPIQ11C = . if DISPUNIFORM < 0 
capture replace TPIQ11D = . if DISPUNIFORM < 0 
capture replace TPIQ12  = . if DISPUNIFORM < 0 
capture replace TPIQ13  = . if DISPUNIFORM < 0 
capture replace TPIQ14  = . if DISPUNIFORM < 0 
capture replace TPIQ15  = . if DISPUNIFORM < 0 
capture replace TPIQ16  = . if DISPUNIFORM < 0 
capture replace TPIQ17  = . if DISPUNIFORM < 0 
capture replace TPIQ17A = . if DISPUNIFORM < 0 
capture replace TPIQ17B = . if DISPUNIFORM < 0   
capture replace TPIQ17C = . if DISPUNIFORM < 0 
capture replace TPIQ18  = . if DISPUNIFORM < 0  
capture replace TPIQ19  = . if DISPUNIFORM < 0 
capture replace TPIQ20  = . if DISPUNIFORM < 0 
capture replace TPIQ30  = . if DISPUNIFORM < 0 
capture replace TPIQ31  = . if DISPUNIFORM < 0 
capture replace TPIQ32  = . if DISPUNIFORM < 0 

capture replace TPIQ32 = . if  missing(PointOfOriginUB04) 

* -------------------------------------------------------------- ;
* --- EXCLUDE TRANSFERS ---------------------------------------- ;
* -------------------------------------------------------------- ;
* --- TRANSFER FROM ANOTHER ACUTE CARE HOSPITAL ---------------- 
capture replace TPIQ32 = . if PointOfOriginUB04 == "4" 

capture replace TPIQ08   = . if DISPUNIFORM == 2
capture replace TPIQ09   = . if DISPUNIFORM == 2
capture replace TPIQ09A  = . if DISPUNIFORM == 2   
capture replace TPIQ09B  = . if DISPUNIFORM == 2 
capture replace TPIQ11   = . if DISPUNIFORM == 2
capture replace TPIQ11A  = . if DISPUNIFORM == 2  
capture replace TPIQ11B  = . if DISPUNIFORM == 2
capture replace TPIQ11C  = . if DISPUNIFORM == 2
capture replace TPIQ11D  = . if DISPUNIFORM == 2 
capture replace TPIQ12   = . if DISPUNIFORM == 2
capture replace TPIQ13   = . if DISPUNIFORM == 2
capture replace TPIQ14   = . if DISPUNIFORM == 2
capture replace TPIQ15   = . if DISPUNIFORM == 2
capture replace TPIQ16   = . if DISPUNIFORM == 2
capture replace TPIQ17   = . if DISPUNIFORM == 2 
capture replace TPIQ17A  = . if DISPUNIFORM == 2   
capture replace TPIQ17B  = . if DISPUNIFORM == 2
capture replace TPIQ17C  = . if DISPUNIFORM == 2
capture replace TPIQ18   = . if DISPUNIFORM == 2 
capture replace TPIQ19   = . if DISPUNIFORM == 2 
capture replace TPIQ20   = . if DISPUNIFORM == 2 
capture replace TPIQ30   = . if DISPUNIFORM == 2 
capture replace TPIQ31   = . if DISPUNIFORM == 2
capture replace TPIQ32   = . if DISPUNIFORM == 2 

* -------------------------------------------------------------- ;
* --- IDENTIFY TRANSFERS --------------------------------------- ;
* -------------------------------------------------------------- ;

gen TRNSFER = 0 
capture replace TRNSFER = 1 if PointOfOriginUB04 == "4" 
label var TRNSFER "Transfer from Another Acute Care Hospital"

gen NOPOUB04 = 0 
capture replace NOPOUB04 = 1 if missing(PointOfOriginUB04)
label var NOPOUB04 "No pint of origin"














































































