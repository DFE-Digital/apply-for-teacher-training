# Reasons for rejection

Apply allows provider users and vendor API users to reject applications.
It is necessary to give reasons for rejecting the application.

We've iterated the way we capture reasons for rejections several times and this has led to a variety of ways we store the rejection reasons data.

- As a single text field value in `ApplicationChoice#rejection_reason`
- As a complex set of flat attributes as JSON in `ApplicationChoice#structured_rejection_reasons`
- As a complex set of nested attributes as JSON in `ApplicationChoice#structured_rejection_reasons`

We use the field and corresponding enum [`ApplicationChoice#rejection_reasons_type`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/application_choice.rb#L52-L56) to denote the reasons data format.

- `rejection_reason` - Single text field value predating structured reasons, still writeable via the Vendor API.
- `reasons_for_rejection` - Initial iteration of structured reasons, which can be inflated into the [`ReasonsForRejection`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/reasons_for_rejection.rb) model.
- `rejection_reasons` - Current iteration of structured reasons, which can be inflated into the [`RejectionReasons`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/rejection_reasons.rb) model.

We still read and render all three types of reasons in various components and presenters and via the Vendor API.

We currently only write `rejection_reasons` type data to the db as JSON.

We currently stil support writing rejection reason text as a single field in `ApplicationChoice#rejection_reason` via the Vendor API.


## Structured rejection reasons JSON formats

The initial iteration of structured rejection reasons stores data in the following _flat_ JSON format:

```
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
    "other"
  ],
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


The current iteration of structured rejection reasons stores data in the following _nested_ JSON format:

```
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

## Rejections wizard form configuration

The current iteration of structured rejection reasons uses a [YAML configuration file](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/config/rejection_reasons.yml) to describe the form structure used to capture reasons for an application being rejected.

This configuration file is used throughout the latest iteration to define the available reasons for rejection.

Attributes are dymanically defined on the [`RejectionsWizard`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/forms/provider_interface/rejections_wizard.rb) and attribute data is inflated into the [`RejectionReasons`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/rejection_reasons.rb) model in the described nested structure, reducing the need for repeating the same definitions in presenters and components.

