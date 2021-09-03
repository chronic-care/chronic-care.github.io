// # Introduction

// The Preventive Care logic library supports decision-making on preventive care screening for Prostate Cancer.

library ProstateCancerSummary version '1.0.0'

// # Data model #

using FHIR version '4.0.1'

// # Referenced libraries #

// The FHIRHelpers library provides common functions for simplifying interaction w/ the FHIR R4 data model.
include FHIRHelpers version '4.0.1' called FHIRHelpers
// The CDS Connect Commons library provides functions representing commonly used CDS logic and patterns.
include CDSConnectCommons version '1.0.0' called C3F
// The PreventiveCareConcepts library provides terminology concepts used to identify data elements throughout the artifact.
include PreventiveCareConcepts version '1.0.0' called PCC
// The PreventiveCareData library provides common data retrieval logic for preventive care guidelines.
include PreventiveCareData version '1.0.0' called Data
// Common expressions and functions for summaries.
include PreventiveCareSummary version '1.0.0' called Summary
// Prostate cancer screening logic from USPSTF
include ProstateCancerScreening version '1.0.0' called PCS

// # CDS logic #

context Patient

/*
 *  Summary Tuples are the primary interface for returning results to applications.
 */
/* define PatientSummary: {
  givenName: Data."Patient Given Name",
  fullName: Data."Patient Full Name",
  gender: Patient.gender.value,
  birthSex: Data."Patient Birth Sex",
  age: AgeInYears(),
  race: Data."Patient Race Text",
  pcpName: Data."Patient PCP name"
} */

define ScreeningSummary: {
  alertPatient: PCS."Needs Prostate Cancer Screening",
  information: "Screening Information Statement",
  riskStatement: "PSA risk statement",
  riskPhrase: "PSA risk phrase"
}

// TODO: nextSteps is a list that should be customized for each patient.
define NextStepsSummary: {
  nextSteps: {
    "Next Step 3",
    "Next Step 4"
  }
}

/*
 * Patient messages personalized with content from patient's clinical data.
 */

define "Screening Information Statement":
  if PCS."No PSA test results"
    then 'You have never had a PSA test'
  else
    'Your PSA value was ' + ToString(PCS."Last PSA value") + ' on ' + ToString(PCS."Last PSA date")

// # Next Steps #

define "Next Step 1":
  'Talk with ' + Data."Patient PCP name" + ' about whether you need another PSA test now.'

define "Next Step 2":
  'When you turn 55, learn about prostate cancer screening and think about whether you want to be tested.'

define "Next Step 3":
  'Decide with ' + Data."Patient PCP name" + ' whether a PSA test is right for you.'

define "Next Step 4":
  'Learn about PSA testing and think about whether you want another test after ' + ToString(PCS."Last PSA date" + 2 years)

// # Text Variables #

define "PC Status":
  if PCS."Has prostate cancer Hx"
    then Data."Patient PCP name" + ' says that you have a history of prostate cancer'
  else if PCS."Has high PSA value"
    then 'you said that you have a history of high PSA value (PSA value higher than 4.0)'
  else
    null

define "MI PSA Date 1":
  if PCS."Has PSA within one year"
    then Data."Patient PCP name" + '\'s record states that you last had a PSA test on ' + ToString(PCS."Last PSA date") + '.  You may be up-to-date with your PSA test.'
  else if PCS."Has PSA test"
    then Data."Patient PCP name" + '\'s record states that you last had a PSA test on ' + ToString(PCS."Last PSA date") + '.  You may be due for another PSA test.'
  else Data."Patient PCP name" + ' does not have a record of when your last PSA was.'

define "PSA value 1":
  'Your last PSA value was ' + ToString(PCS."Last PSA value") + '. Generally, a PSA below 4 is considered good. Higher values may be, OK if they are not increasing over time.'

// # PSA risk statements #

// TODO handle unknown FH. Research negation of conditions and unknown.
define "PSA risk statement":
  if Data."Race is African American" and PCS."Has family history of prostate cancer"
    then 'You are African American and have a family history of prostate cancer.  This places you at higher risk for prostate cancer.'
  else if not Data."Race is African American" and PCS."Has family history of prostate cancer"
    then 'You have a family history of prostate cancer.  This places you at higher risk for prostate cancer.'
  else if Data."Race is African American" and not PCS."Has family history of prostate cancer"
    then 'You are African American.  This places you at higher risk for prostate cancer.'
  else if Data."Race is African American"
    then 'You are African American.  This places you at higher risk for prostate cancer.  You said you are unsure if you have a family history of prostate cancer.  If you do, this also places you at higher risk for prostate cancer.'
  else
    'You said you are unsure if you have a family history of prostate cancer.  If you do, this places you at higher risk for prostate cancer.'

// TODO handle unknown FH. Research negation of conditions and unknown.
define "PSA risk phrase":
  if Data."Race is African American" and PCS."Has family history of prostate cancer"
    then 'are African American and have a family history of prostate cancer'
  else if not Data."Race is African American" and PCS."Has family history of prostate cancer"
    then 'have a family history of prostate cancer'
  else if Data."Race is African American" and not PCS."Has family history of prostate cancer"
    then 'are African American'
  else if Data."Race is African American"
    then 'are African American and may have a family history of prostate cancer'
  else
    'may have a family history of prostate cancer'

// # Patient text blocks #

define "Need PSA statement":
  Data."Patient PCP name" + '\'s record says you last had a PSA test on ' + ToString(PCS."Last PSA date")
