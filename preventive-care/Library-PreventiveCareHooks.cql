// # Introduction

// CDS Hooks logic for use with CQF Ruler

library PreventiveCareHooks version '1.0.0'

// # Data model #

using FHIR version '4.0.1'

// # Referenced libraries #

include ProstateCancerScreening version '1.0.0' called Screening
include ProstateCancerSummary version '1.0.0' called Summary

// # CDS logic #

context Patient

/*
 * Expressions for CDS Hook cards.
 */

// Used to trigger presentation of recommendations
define "Age Between 40 and 70":
  AgeInYears() between 40 and 70

define "Needs Prostate Cancer Screening":
  "Age Between 40 and 70" and
  (Screening."No PSA test results"
    or (Screening."Last PSA value is high" and not Screening."Has PSA within one year")
    or not Screening."Has PSA within two years"
  )

define "Needs Prostate Cancer Screening Summary":
  'Prostate Cancer Screening'

define "Needs Prostate Cancer Screening Detail":
  Summary."MI PSA Date 1" + ' ' + Summary."PSA value 1"

define "Needs Prostate Cancer Screening Indicator":
  if Screening."Last PSA value is high" then 'critical'
  else 'warning'
