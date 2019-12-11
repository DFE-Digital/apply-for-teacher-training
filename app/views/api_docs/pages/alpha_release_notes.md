These are the release notes for the API while still in alpha.

See the [current release notes](/api-docs/release-notes) for the release notes
once v1 is live.

### Alpha release - 11 December 2019

Changes to the docs:

- We've added more examples and descriptions to the attributes
- The OpenAPI spec is now accessible via the API itself
- Move the documentation to https://www.apply-for-teacher-training.education.gov.uk/api-docs

New attributes:

- `Candidate` now has an `id`. This is a version of our internal identifier, and could be used to match previous candidate records.
- `Course` now has a `study_mode` attribute that shows whether the candidate wants to study full time or part time. 

Removed attributes:

- Referee `phone_number` and `confirms_safe_to_work_with_children` have been removed
- We've removed the `date` from `Rejection` object

Updated attributes:

- Updated the application `status` enum to contain all statuses that could appear
- We've renamed `provider_ucas_code` to `provider_code`, `course_ucas_code` to `course_code` and `site_ucas_code` to `site_code`. The `site_code` will also be able to have more characters.

### Alpha release - 29 October 2019

Changes to the data:

- Application statuses: remove `declined` and add `unsubmitted`
- Remove `provider_ucas_code` URL param on GET requests (only applications for
  the currently authenticated provider will be returned)
- Add `futher_information` key to `ApplicationAttributes`
- Rename `work_experiences` array to `work_experience` object in
  `ApplicationAttributes` and add properties `jobs` and `volunteering`
- Change `qualifications` key to an object with with properties `gcses`,
  `degrees` and `other`
- Change `Qualification` schema, grouping `place_of_study`,
  `awarding_body_country` and `awarding_body_name` in a single string
  `institution_details`.
- Add `english_main_language`, `english_language_qualifications`,
  `other_languages` and `disability_disclosure` to `Candidate` schema
- Rename `location_ucas_code` to `site_ucas_code`
- Change `WorkExperience` schema, adding `working_with_children` boolean and
  `commitment` (part/full time) and increasing the length of the `description`
  field
- Change `Reference` schema, adding `confirms_safe_to_work_with_children` and
  `phone_number`, renaming `content` to `reference` and removing
  `reference_type` and `reason_for_character_reference`

Changes to functionality:

- Add [/test-data/regenerate](/api-docs/reference/#post-test-data-regenerate) endpoint.
- Add [single application](/api-docs/reference/#singleapplicationresponse-object) and [multiple
  applications](/api-docs/reference/#multipleapplicationsresponse-object) response schemas.
- Add `422` error response to `POST` endpoints including:
    - [offer](/api-docs/reference/#post-applications-application_id-offer)
    - [confirm enrolment](/api-docs/reference/#post-applications-application_id-confirm-enrolment)
    - [confirm conditions met](/api-docs/reference/#post-applications-application_id-confirm-conditions-met)
    - [reject](/api-docs/reference/#post-applications-application_id-reject)

Additional changes:

- Add [limits](/api-docs/reference/#rate-limits) section to give details around api rate limiting.
- Add Development and Vendor Sandbox enviroment details to [api info](/api-docs/reference/#api-info) page.
- Add Authentication and Metadata sections to the API Reference

### Alpha release - 26 September 2019

Changes to the data:

- Change the structure of an [application](/api-docs/reference#get-applications):
  - add `type` field
  - add `attributes` field and move `status`, `submitted_at`, `updated_at`, `personal_statement`
    `candidate`, `contact_details`, `course`, `qualifications`, `work_experiences`
    `references`, `offer`, `withdrawal` and `rejection` fields into it
- Remove date from [reject](/api-docs/reference/#post-applications-application_id-reject) endpoint
- Limit [candidates](/api-docs/reference/#candidate-object) to only 2 nationalities
- Rename the `org` field on [work experience](/api-docs/reference/#workexperience-object) to `organisation_name`
- Rename the `type` field on [qualification](/api-docs/reference/#qualification-object) to `qualification_type`
- Rename the `type` field on [reference](/api-docs/reference/#reference-object) to `reference_type`
- Add HESA ITT data to the [application](/api-docs/reference#get-applications). Available only once a student is enrolled

Changes to functionality:

- Change the successful response for all endpoints to be within a `data` object
- Change the successful response for making an offer, confirming candidate
  enrolment, confirming offer conditions are met and rejecting an application
  endpoints to be the application
- Change the HTTP response code for making an offer, confirming candidate enrolment,
  confirming offer conditions are met and rejecting an application endpoints to `200`
- Support a `provider_ucas_code` parameter when [retrieving many applications](/api-docs/reference#retrieve-many-applications)
- Require a `meta` key in POST request bodies, holding `attribution` and `timestamp` metadata

Additional changes:

- Clarify the endpoint for rejecting an application in [usage scenarios](/api-docs/usage-scenarios)
- Clarify the timestamp format for retrieving applications in [usage scenarios](/api-docs/usage-scenarios)
- Clarify maximum length of strings in Schemas
- Add description of the [API versioning](/#versioning)
- Add error responses to OpenAPI spec for all endpoints
- Add [instructions](/api-docs/reference/#use-the-swagger-editor) for importing our OpenAPI specification in the Swagger Editor
- Add `provider_code` param to retrieving many applications in [usage scenarios](/api-docs/usage-scenarios)
- Update responses for [making an offer](/api-docs/reference/#post-applications-application_id-offer),
  [confirming candidate enrolment](/api-docs/reference/#post-applications-application_id-confirm-enrolment),
  [confirming offer conditions are met](/api-docs/reference/#post-applications-application_id-confirm-conditions-met)
  and [rejecting an application](/api-docs/reference/#post-applications-application_id-reject) endpoints in [usage scenarios](/api-docs/usage-scenarios)
- Clarify the steps between making an offer and confirming that offer conditions are met in [usage scenarios](/api-docs/usage-scenarios)

### Alpha release - 16 September 2019

Changes to the data:

- Remove first and last name from Candidate in favour of full name
- Remove id from Candidate
- Remove disability information from Candidate, as this is not collected via the application form
- Remove functionality to amend an offer
- Rename the rejection endpoint
- Update Contact Details resource to split address into separate fields
- Remove description from course resource
- Add first name, last name and date of birth for Candidate

### Alpha release - 11 September 2019

Changes to functionality:

- Add documentation on the proposed way of authenticating users
- Limit the number of offer conditions to 20
- Remove functionality to amend an offer (you can reuse the make an offer endpoint)
- Remove functionality to confirm a placement for a candidate
- Remove functionality to schedule interviews for a candidate

Changes to the data:

- Remove first and last name from Candidate in favour of full name
- Remove id from Candidate
- Remove disability information from Candidate, as this is not collected via the application form
- Rename the rejection endpoint
- Update Contact Details resource to split address into separate fields
- Applications now have a 10 character identifier
- The `course` attribute of an application now refers to a single course instead of multiple
- References have a "content" attribute containing the referee's contribution
- Qualifications have an "equivalency_details" attribute for overseas awards
- Withdrawals and Rejections now have timestamps instead of dates
- Withdrawal reason has become optional

Additional changes:

- Clarify that strings have a 255 character limit, unless otherwise specified
- Clarify that only candidates can withdraw an application
- Clarify that we're using [ISO 3166 for country codes](/#codes-and-reference-data), not ISO 3611
- Clarify how to make an unconditional and conditional offer
- Clarify that offer conditions are optional

### Alpha release - 4 July 2019

Initial release of the API documentation.
