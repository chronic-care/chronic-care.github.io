// # Introduction

// The Preventive Care logic library supports decision-making on preventive care screening for Prostate Cancer.

library ProstateCancerScreening version '1.0.0'

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

// # CDS logic #

context Patient

/* Prostate cancer screening logic */

define "Needs Prostate Cancer Screening":
  Data."Patient is male"
  and AgeInYears() between 40 and 70
  and ("No PSA test results"
    or not "Has PSA within two years"
  )

define "Has prostate cancer Hx":
  exists( "Prostate cancer conditions" )

define "Prostate cancer conditions":
  Data."All active conditions" C
    where C.code ~ PCC."Prostate cancer"

define "Has family history of prostate cancer":
  /* exists([FamilyMemberHistory.condition.code: PCC."Prostate cancer"]) */
  exists([Condition: PCC."Family history of prostate cancer"])

define "PSA Observations":
  C3F.Verified([Observation: PCC."Prostate Specific Antigen Test"])

define "Last PSA":
  C3F.MostRecent("PSA Observations")

define "Last PSA value":
  C3F.QuantityValue("Last PSA").value

define "Last PSA date":
  C3F.FindDate("Last PSA")

define "Has PSA test":
  exists("PSA Observations")

define "No PSA test results":
  not exists("PSA Observations")

define "Has PSA within one year":
  exists(C3F.ObservationLookBack("PSA Observations", 1 year))

define "Has PSA within two years":
  exists(C3F.ObservationLookBack("PSA Observations", 2 year))

define "Has high PSA value":
  exists("PSA Observations" C
    where C3F.QuantityValue(C).value > 4.0)

define "Last PSA value is high":
  "Last PSA value" > 4.0
