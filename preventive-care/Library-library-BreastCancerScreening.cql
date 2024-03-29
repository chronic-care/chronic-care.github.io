library BreastCancerScreening version '1.0.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1' called FC
include PreventiveCareData version '1.0.0' called Data

// Breast Cancer Screening
valueset "Bilateral Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005'
valueset "History of bilateral mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1068'
valueset "Mammography": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018'
valueset "Status Post Left Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1069'
valueset "Status Post Right Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1070'
valueset "Unilateral Mastectomy Left": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1133'
valueset "Unilateral Mastectomy Right": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1134'
valueset "Unilateral Mastectomy, Unspecified Laterality": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1071'
valueset "Left": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.122.12.1036'
valueset "Right": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.122.12.1035'

context Patient

/* Data Elements */
define "Mammography diagnostic report":
  [DiagnosticReport: "Mammography"] Mammogram
    where Mammogram.status in { 'final', 'amended', 'corrected', 'appended' }

define "Right Mastectomy Diagnosis":
	[Condition: "Status Post Right Mastectomy"]
	union
	[Condition: "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
			where UnilateralMastectomyDiagnosis.bodySite in "Right"

define "Right Mastectomy Procedure":
  [Procedure: "Unilateral Mastectomy Right"] UnilateralMastectomyRightPerformed
    where UnilateralMastectomyRightPerformed.status = 'completed'

define "Left Mastectomy Procedure":
  [Procedure: "Unilateral Mastectomy Left"] UnilateralMastectomyLeftPerformed
    where UnilateralMastectomyLeftPerformed.status = 'completed'

define "Left Mastectomy":
  [Condition: "Status Post Left Mastectomy"]
  union
	[Condition: "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
			where UnilateralMastectomyDiagnosis.bodySite in "Left"

define "Bilateral Mastectomy Diagnosis":
  [Condition: "History of bilateral mastectomy"]

define "Bilateral Mastectomy Procedure":
  [Procedure: "Bilateral Mastectomy"] BilateralMastectomyPerformed
  	where BilateralMastectomyPerformed.status = 'completed'

/* Intermediate Data Elements */
define "Age 40 through 49":
   AgeInYears() in Interval[40, 49]

define "Age 50 through 74":
   AgeInYears() in Interval[50, 74]

define "Most recent mammogram":
  Last("Mammography diagnostic report" R
    sort by (FHIRHelpers.ToDateTime(issued))
  )

define "Never had a mammogram":
  not exists "Mammography diagnostic report"

define "Had mammogram in past two years":
  exists ("Mammography diagnostic report" M
    where FC.ToInterval(M.effective) ends 2 year or less before Today()
  )

/* Recommendations */
define "Recommend Screening":
  "Inclusion Criteria" and not "Exclusion Criteria"

/* Inclusion Criteria */
define "Inclusion Criteria":
  Data."Patient is female"
  	and ("Age 40 through 49" or "Age 50 through 74")
    and not "Had mammogram in past two years"

/* Exclusion Criteria */
define "Exclusion Criteria":
  ((exists "Right Mastectomy Diagnosis" or exists "Right Mastectomy Procedure")
      and (exists "Left Mastectomy" or exists "Left Mastectomy Procedure"))
	or exists "Bilateral Mastectomy Diagnosis"
	or exists "Bilateral Mastectomy Procedure"
