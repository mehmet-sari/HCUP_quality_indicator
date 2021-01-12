### HCUP Inpatient Quality Indicators
AHRQ provides free software for assigning quality indicators to inpatient records.
Unfortunately, AHRQ provides only two softwares; 

1. SAS QI
2. WinQI

SAS QI is SAS program which requires SAS software to run while WinQI requires a windows operating system to run. For researchers who store the HCUP data in their servers or don't have access to SAS and Windows, there is a need for third option. 
This program is written in stata. I converted SAS program to Stata do file. SAS program can be found in the HCUP website.

#### The structure of the Do files
#### 1. Hcup_quality_indicator_ICD10.do
It includes both ICD-10 format and hospital measure. For now it works for inpatient data as of 4. quarter of 2015 (ICD-9 will be added soon to cover before that time.For now there are two seperate do files.) 
It is written as program so it needs to be called by another do file which shows which datafile will be used as an input.
#### 2. Hcup_quality_indicator_ICD9.do
It creates IQI indicators for ICD-9. It works for any HCUP SID until 2015q1q3 (including the 3. quarter). 
#### 2. IQI_quality_final.do
This do file, as an example, shows which states and years would be used as an input for Hcup_quality_indicator_ICD10.do and Hcup_quality_indicator_ICD9.do file. The user need to list states and years in the first two lines or can customize it. 
