# Reasons for rejection

**Updated: January 2024**

Apply allows provider users and vendor API users to reject applications.
It is necessary to give reasons for rejecting the application.

### History

#### First iteration

_Text Column_

First there was one column on the `ApplicationChoice` model called `rejection_reason`. It was a singular varchar, meaning one reason. It was soon realised that more detail was required.


#### Second iteration

_Flat JSON_

A new column `structured_reasons_for_rejection` of type `jsonb` was introduced to store detailed rejection reasons.

This brought with it the `rejection_reasons_type`. This allowed us to know what column / format of rejection reason the application used.

**V1 `rejection_reasons_type`**
 - `rejection_reason` - singular
 - `reasons_for_rejection` - new Flat JSON format

[Flat JSON Example](#flat-json)

#### Third iteration

_Nested JSON_

Then the Flat format was redesigned. The new format of JSON would be stored in the same column `structured_reasons_for_rejection`.

A new type was added:

**V2 `rejection_reasons_type`**
 - `rejection_reason` - singular
 - `reasons_for_rejection` - Flat JSON format
 - `rejection_reasons` - new nested JSON format

Then we stopped using `reasons_for_rejection` (last record in production: 2022-04-26 14:25:40).

[Nested JSON Example](#nested-json)

#### Fourth iteration

_Vendor API Codes_

A new system of providing an API endpoint to vendors which allows them to reject applications based on arbitrary codes we provide to them.

**V3 `rejection_reasons_type`**
 - `rejection_reason` - singular.
 - `vendor_api_rejection_reasons` - new nested JSON format assigned by code.
 - `rejection_reasons` - new nested JSON format.

`vendor_api_rejection_reasons` was introduced recently (first record in production: 2023-06-01 16:32:09).

The codes are stored in a YAML file here [config/rejection_reason_codes.yml](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/config/rejection_reason_codes.yml).

Some of the changes:

 - https://github.com/DFE-Digital/apply-for-teacher-training/pull/7256
 - https://github.com/DFE-Digital/apply-for-teacher-training/pull/7257
 - https://github.com/DFE-Digital/apply-for-teacher-training/pull/7260


## Latest

We've iterated the way we capture reasons for rejections several times and this has led to a variety of ways we store the rejection reasons data.

- As a single text field value in `ApplicationChoice#rejection_reason`
- As a complex set of flat attributes as JSON in `ApplicationChoice#structured_rejection_reasons`
- As a complex set of nested attributes as JSON in `ApplicationChoice#structured_rejection_reasons`

We use the field and corresponding enum [`ApplicationChoice#rejection_reasons_type`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/application_choice.rb#L52-L56) to determine the reasons data format.

|rejection_reasons_type|Column name|data type|Source|Info|
|---|---|---|---|---|
|`rejection_reason`|`rejection_reason`|String|Vendor API, ProviderInterface||
|`reasons_for_rejection`|`structured_rejection_reasons`|flat JSON|ProviderInterface|DEPRECATED 2022|
|`rejection_reasons`|`structured_rejection_reasons`|nested JSON |ProviderInterface||
|`vendor_api_rejection_reasons`|`structured_rejection_reasons`|nested JSON|Vendor API|Introduced 2023|

### Why are the old versions still used

The Vendor API is being supported for the lifetime of v1. It is costly for Providers to upgrade if they use an SRS (Student Record System) provided by a 3rd party.


### Models and Components

#### Models
Models are ruby classes we use to make objects from the data stored in the `structured_rejection_reasons`. We have two models for each of the types stored in `structured_rejection_reasons`.

|type|model|
|---|---|
|`rejection_reason`|none|
|`reasons_for_rejection`|`ReasonsForRejection`|
|`rejection_reasons`|`RejectionReasons`|


- `rejection_reason` - Single text field value predating structured reasons, still writeable via the Vendor API.
- `reasons_for_rejection` - Initial iteration of structured reasons, which can be inflated into the [`ReasonsForRejection`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/reasons_for_rejection.rb) model.
- `rejection_reasons` - Current iteration of structured reasons, which can be inflated into the [`RejectionReasons`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/rejection_reasons.rb) model.

We still read and render all three types of reasons in various components and presenters and via the Vendor API.

Some Providers are still writing all three formats in the production database as of now in 2024.


#### Components

|Component|type|purpose
|---|---|---|
|[RejectionsComponent](,,.app/components/shared/rejections_component.rb) | |Delegator|
|[RejectionReasons::ReasonsForRejectionComponent](../app/components/shared/rejection_reasons/reasons_for_rejection_component.rb)|`reasons_for_rejection`|Render|
|[RejectionReasons::RejectionReasonComponent](../app/components/shared/rejection_reasons/rejection_reason_component.rb)|`rejection_reason`|Render|
|[RejectionReasons::RejectionReasonsComponent](../app/components/shared/rejection_reasons/rejection_reasons_component.rb)|`rejection_reasons`|Render|

`RejectionsComponent` is a kind of Factory pattern. It delegates to sub types depending on the type of the `rejection_reasons_type`. It's used in `CandidateInterface` and `SupportInterface`.


## Rejections wizard form configuration

The current iteration of structured rejection reasons uses a YAML configuration file [config/rejection_reasons.yml](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/config/rejection_reasons.yml) to describe the form structure used to capture reasons for an application being rejected.

This configuration file is used throughout the latest iteration to define the available reasons for rejection.

Attributes are dymanically defined on the [`RejectionsWizard`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/forms/provider_interface/rejections_wizard.rb) and attribute data is inflated into the [`RejectionReasons`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/rejection_reasons.rb) model in the described nested structure, reducing the need for repeating the same definitions in presenters and components.

## Vendor API

Currently providers can write rejections to the `rejection_reason` field via a string parameter and `structured_rejection_reasons` via codes.

[Reject V1](https://www.apply-for-teacher-training.service.gov.uk/api-docs/v1.4/reference#post-applications-application_id-reject)

[Reject by code](https://www.apply-for-teacher-training.service.gov.uk/api-docs/v1.4/reference#post-applications-application_id-reject-by-codes)

## Structured rejection reasons JSON formats

The initial iteration of structured rejection reasons stores data in the following _flat_ JSON format:

#### Flat JSON<a name="flat-json"></a>

<details><summary>Flat JSON example</summary>
<p>


```json
{
  "course_full_y_n": "No",
  "candidate_behaviour_y_n": "Yes",
  "candidate_behaviour_other": "Persistent scratching",
  "candidate_behaviour_what_to_improve": "Not scratch so much",
  "candidate_behaviour_what_did_the_candidate_do": [
    "didnt_reply_to_interview_offer",
    "didnt_attend_interview",
    "other"
  ],
  "honesty_and_professionalism_y_n": "Yes",
  "honesty_and_professionalism_concerns_other_details": null,
  "honesty_and_professionalism_concerns": [
    "information_false_or_inaccurate",
    "references"
  ],
  "honesty_and_professionalism_concerns_plagiarism_details": null,
  "honesty_and_professionalism_concerns_references_details": "Clearly not a popular student",
  "honesty_and_professionalism_concerns_information_false_or_inaccurate_details": "Fake news",
  "offered_on_another_course_y_n": "No",
  "offered_on_another_course_details": null,
  "performance_at_interview_y_n": "Yes",
  "performance_at_interview_what_to_improve": "Be fully dressed",
  "qualifications_y_n": "Yes",
  "qualifications_other_details": "All the other stuff",
  "qualifications_which_qualifications": [
    "no_english_gcse",
    "other"
  ],
  "quality_of_application_y_n": "Yes",
  "quality_of_application_other_details": "Lights on but nobody home",
  "quality_of_application_other_what_to_improve": "Study harder",
  "quality_of_application_which_parts_needed_improvement": [
    "personal_statement",
    "subject_knowledge",
    "other"
  ],
  "quality_of_application_subject_knowledge_what_to_improve": "Claiming to be the 'world's leading expert' seemed a bit strong",
  "quality_of_application_personal_statement_what_to_improve": "Use a spellchecker",
  "safeguarding_y_n": "Yes",
  "safeguarding_concerns": [
    "other"
  ],
  "safeguarding_concerns_other_details": "We need to run further checks",
  "safeguarding_concerns_vetting_disclosed_information_details": null,
  "safeguarding_concerns_candidate_disclosed_information_details": null,
  "cannot_sponsor_visa_y_n": "No",
  "cannot_sponsor_visa_details": null,
  "interested_in_future_applications_y_n": null,
  "why_are_you_rejecting_this_application": null,
  "other_advice_or_feedback_y_n": null,
  "other_advice_or_feedback_details": null
}
```
</p>
</details>

#### Nested JSON<a name="nested-json"></a>

<details><summary>Nested JSON example</summary>
<p>

The current iteration of structured rejection reasons stores data in the following _nested_ JSON format:

```json
{
  "selected_reasons": [
    {
      "id": "qualifications",
      "label": "Qualifications",
      "selected_reasons": [
        {
          "id": "no_maths_gcse",
          "label": "No maths GCSE at minimum grade 4 or C, or equivalent"
        },
        {
          "id": "no_english_gcse",
          "label": "No English GCSE at minimum grade 4 or C, or equivalent"
        },
        {
          "id": "no_science_gcse",
          "label": "No science GCSE at minimum grade 4 or C, or equivalent"
        },
        {
          "id": "no_degree",
          "label": "No bachelor’s degree or equivalent"
        },
        {
          "id": "unverified_qualifications",
          "label": "Could not verify qualifications",
          "details": {
            "id": "unverified_qualifications_details",
            "text": "We could find no record of your GCSEs."
          }
        }
      ]
    },
    {
      "id": "personal_statement",
      "label": "Personal statement",
      "selected_reasons": [
        {
          "id": "quality_of_writing",
          "label": "Quality of writing",
          "details": {
            "id": "quality_of_writing_details",
            "text": "We do not accept applications written in Old Norse."
          }
        }
      ]
    },
    {
      "id": "references",
      "label": "References",
      "details": {
        "id": "references_details",
        "text": "We do not accept references from close family members, such as your mum."
      }
    },
    {
      "id": "course_full",
      "label": "Course full"
    },
    {
      "id": "other",
      "label": "Other",
      "details": {
        "id": "other_details",
        "text": "So many other things were wrong..."
      }
    }
  ]
}
```
</p>
</details>
