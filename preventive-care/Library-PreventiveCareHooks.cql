// # Introduction

// CDS Hooks logic for use with CQF Ruler

library PreventiveCareHooks version '1.0.0'

// # Data model #

using FHIR version '4.0.1'

// # Referenced libraries #

include ProstateCancerScreening version '1.0.0' called Prostate

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
  (Prostate."No PSA test results"
    or (Prostate."Last PSA value is high" and not Prostate."Has PSA within one year")
    or not Prostate."Has PSA within two years"
  )

define "Needs Prostate Cancer Screening Summary":
  'Prostate Cancer Screening'

define "Needs Prostate Cancer Screening Detail":
  Prostate."MI PSA Date 1" + ' ' + Prostate."PSA value 1"

define "Needs Prostate Cancer Screening Indicator":
  if Prostate."Last PSA value is high" then 'critical'
  else 'warning'
