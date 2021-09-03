library ColonCancerScreening version '1.0.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1' called FC

valueset "Colonoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "CT Colonography": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1038'
valueset "Fecal Occult Blood Test (FOBT)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1011'
valueset "FIT DNA": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1039'
valueset "Flexible Sigmoidoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1010'
valueset "Malignant Neoplasm of Colon": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "Total Colectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1019'
valueset "Condition Clinical Status": 'http://fhir.org/guides/utah-edu/lcs-cds/ValueSet/conditionclinical'

context Patient

/* Data Elements */
define "Flexible Sigmoidoscopy Performed":
  [Procedure: "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.status = 'completed'
			and FC.ToInterval(FlexibleSigmoidoscopy.performed) ends 5 years or less on or before Today()

define "CT Colonography Performed":
  [Procedure: "CT Colonography"] Colonography
		where Colonography.status = 'completed'
			and FC.ToInterval(Colonography.performed) ends 5 years or less on or before Today()

define "Fecal Occult Blood Test Performed":
  [Observation: "Fecal Occult Blood Test (FOBT)"] FecalOccultResult
		where FecalOccultResult.status in {'final', 'amended', 'corrected', 'preliminary'}
			and FecalOccultResult.value is not null
			and FC.ToInterval(FecalOccultResult.effective) occurs 1 years or less on or before Today()

define "Fecal Immunochemical Test DNA":
  [Observation: "FIT DNA"] FitDNA
		where FitDNA.status in {'final', 'amended', 'corrected', 'preliminary'}
			and FitDNA.value is not null
			and FC.ToInterval(FitDNA.effective) occurs 3 years or less on or before Today()

define "Colonoscopy Performed":
  [Procedure: "Colonoscopy"] Colonoscopy
		where Colonoscopy.status = 'completed'
		  and FC.ToInterval(Colonoscopy.performed) ends 10 years or less on or before Today()

define "Malignant Neoplasm":
  [Condition: "Malignant Neoplasm of Colon"] C
    where C.clinicalStatus in "Condition Clinical Status"

define "Total Colectomy Performed":
  [Procedure: "Total Colectomy"] Colectomy
		where Colectomy.status = 'completed'
//			and FC.ToInterval(Colectomy.performed) starts on or before Today()

/* Intermediate Data Elements */
define "Age 45 through 75":
  AgeInYears() in Interval[45, 75]

/* Recommendations */
define "Recommend Screening":
  "Inclusion Criteria" and not "Exclusion Criteria"

/* Inclusion Criteria */
define "Inclusion Criteria":
  "Age 45 through 75"
  and not (exists "Colonoscopy Performed"
		or exists "Fecal Occult Blood Test Performed"
		or exists "Flexible Sigmoidoscopy Performed"
		or exists "Fecal Immunochemical Test DNA"
    )

/* Exclusion Criteria */
define "Exclusion Criteria":
  exists "Malignant Neoplasm"
    or exists "Total Colectomy Performed"
