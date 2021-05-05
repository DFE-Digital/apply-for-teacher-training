## 5th May

The following experimental/sandbox endpoint has been updated:

`/test-data/generate` now accepts optional `for_training_courses` and `for_test_provider_courses` query params.

Supplying `for_training_courses=true` will ensure that applications are generated for courses run by the organisation.
Supplying `for_test_provider_courses=true` will ensure that applications are generated for courses run by a separate, sandbox only, test provider.
Supplying none of `for_ratified_courses`, `for_training_courses` or `for_test_provider_courses` as `true`, will result in applications being generated to courses run by the organisation (the same effect as just `for_training_courses=true`)


## 26th April

Add [documentation](/api-docs#how-candidates-and-applications-are-identified) about application and candidate IDs

## 16th April

`Qualification` now includes an optional `subject_code` field. This contains the HECoS code for the subject if it is available

## 15th April

Changes to existing attributes:

- Update the return values of the `rejection` object `reason` field to return `Not entered` if there is no rejection reason yet provided on an application rejected by default.

## 31st March

`Qualification.grade` now has a value of `Not entered` when the candidate did not provide a value. This used to be `null`, though we promised a string.

## 22nd March

The following experimental/sandbox endpoint has been updated:

`/test-data/generate` is now asynchronous:

- A POST request to this endpoint will queue a job to generate the specified test applications.
- The list of created application IDs will no longer be returned.
- The new applications will become available as soon as they have been generated.
- Applications generated in this way will now have their `updated_at` set to the current time, so they can be retrieved using the `GET /applications` endpoint with the `since` parameter.

## 19th March

Fix a bug where HESA ITT data was not being returned for applications with accepted offers.

## 9th March

Changes to existing attributes:

- Update return values of `uk_residency_status` to correspond with candidate application options. Removes 'Candidate does not know' and the value 'Candidate needs to apply for permission to work and study in the UK' is returned where the candidate has answered `no` or `decide_later`.

New attributes:

- Adds `uk_residency_status_code` field. Single alphabetical character code for the candidate’s UK residency status indicating their right to work and study in the UK.

## 29th February

- deprecate `Qualification.awarding_body` as this field has always been null.

## 26th February

New attributes:

- `Candidate` now has a `fee_payer` attribute of type string, returning a two-digit string corresponding to UCAS Fee Payer codes. It indicates a provisional fee payer status. Its value is derived from the candidate's nationality, residency status and domicile.

Documentation:

- Clarify the description of `Candidate.uk_residency_status` field in the documentation.

## 25th February

- Documentation updated to indicate that the `Candidate.domicile` field is encoded as a HESA DOMICILE code.

## 5th February

The following experimental/sandbox endpoint has been updated:

- `/test-data/generate` now accepts an optional `for_ratified_courses` query param. If this parameter is supplied and set to a non-empty string, applications will be generated for courses the organisation awards, not runs. This means subsequent calls to `/test-data/clear` will NOT delete these applications.

## 29th January

- The documented enum values for `Reference.referee_type` have been corrected to remove commas and replace `school-based` with `school_based`.

## 17th December

- The `Rejection` `reason` field may now return more complex 'structured' reasons for rejection. The field type remains `string`. The field contains details and advice about the rejected application as seen by the candidate, grouped under relevant headings.

## 16th December 2020

Changes to existing attributes:

- The `domicile` attribute of `Candidate` has been updated to return two-letter HESA codes instead of ISO 3166-2 country codes. For most international addresses the two types of code are identical, but HESA domicile codes do not include a `GB` value, specifying the country instead (e.g. `XF` for England, `XI` for Wales etc.)

## 15th December 2020

New feature: reference data. See the [Codes and reference data section](https://www.apply-for-teacher-training.service.gov.uk/api-docs#codes-and-reference-data) of the documentation.

- `reference-data/gcse-subjects` returns a list of GCSE subjects
- `reference-data/gcse-grades` returns a list of GCSE grades
- `reference-data/a-and-as-level-subjects` returns a list of A and AS Level subjects
- `reference-data/a-and-as-level-grades` returns a list of A and AS Level grades

## 11th December 2020

Change to international addresses:

- Previously, international addresses were not structured and only the address_line1 field was populated. From now on, international addresses will be structured and will populate address lines 1-4.
- `address_line1` character count is reduced from 200 to 50 in line with other address lines.

## 7th December 2020

Documentation:

- Clarify the format of the `grade` field in the spec and documentation

## 19th November 2020

- The `Qualification` object now supports multiple types of English GCSEs (eg. English Language, English Studies Double Award). Candidates may have multiple English GCSEs. Each GCSE is provided as a separate `Qualification`. The title of the GCSE is given in the `subject` field.

## 16th November 2020

- The `Qualification` `grade` field will now be populated with GCSE Science triple award information in the following format, where present: `[biology_grade][chemistry_grade][physics_grade]` e.g 'ABC'

## 13th November 2020

Documentation has been amended to indicate that `disability` is an array and not a string

## 9th November 2020

New attributes:

- `Course` now has a `start_date` attribute giving the month and year the course begins

## 23rd October 2020

New attributes:

- `ApplicationAttributes` now has a `recruited_at` attribute which will contain an ISO8601 date for candidates in the `recruited` state.
- `Offer` now has three new date fields: `offer_made_at`, `offer_accepted_at` and `offer_declined_at`.
- `Reference` now has two new fields: an enum `referee_type` and a boolean `safeguarding_concerns`
- `Qualification` now has a free text field `non_uk_qualification_type` which is populated in the event the qualification type is `non_uk`

## 8th October 2020

New attributes:

- `Candidate` now has a `domicile` attribute of type string, returning a two-letter country code (ISO 3166-2). Its value is derived from the candidate's address.
- `Qualification` now includes attributes for HESA qualification codes, if the qualification is degree-level. The attributes are: `hesa_degtype`, `hesa_degsbj`, `hesa_degclss`, `hesa_degest`, `hesa_degctry`, `hesa_degstdt`, `hesa_degenddt`.

Changes to existing attributes:

- The `equivalency_details` attribute of `Qualification` will now contain a NARIC code and its description, if these are avalailable. Example: 'Naric: 4000123456 - Between GCSE and GCSE AS Level - Equivalent to GCSE C'

## 5th October 2020

Changes to existing attributes:

- clarify that `hesa_itt_data` will be populated once an offer has been accepted. (Previously it was following enrolment, but enrolment has been removed).

## 29th September 2020

New attributes:

- `Reference` now has a unique `id` attribute of type integer to assist with tracking of reference changes.

## 16th September 2020

Changes to existing attributes:

- Increase the limit of elements in the `nationality` array to 5. Nationalities are sorted so British or Irish are first.
- `uk_residency_status` now returns strings indicating candidate's right to work and study in the UK

## 15th September 2020

Changes to existing attributes:

- Maximum length of `address_line1` increased to 200 characters to account for international addresses.

## 9th September 2020

- fix a bug with test data generation where provider names in qualifications were strings like `#<struct HESA::Institution::InstitutionStruct...>`

## 1st September 2020

- Deprecate the `enrolled` state which will not be part of the Apply service
- Deprecate the `enrol` endpoint which will now simply return the application unchanged
- Remove mentions of enrolment from the API documentation

## 28th August 2020

New attributes:

- `Application` now has a `safeguarding_issues_status` attribute of type string and an optional `safeguarding_issues_details_url` attribute of type string.

## 24th August 2020

- Fix a bug where the study mode of a chosen or offered course appeared as "full_or_part_time" instead of "full_time" or "part_time" as appropriate.

## 10th August 2020

- `POST /application/:id/offer` is now idempotent and will continue to return 200 if the same offer details are POSTed repeatedly
- `POST /application/:id/offer` now supports changing the conditions on an offer while retaining the original offered course. Previously this returned a 422 error saying it was necessary to offer a different course.
- Deprecate `Withdrawal.reason`, which was supposed to hold a candidate’s reason for withdrawing their application. The Apply service will not collect this information

## 7th July 2020

Documentation has been amended to emphasise the stability of `/applications` endpoints in contrast to the `/test-data` endpoints.

Experimental endpoints have also been updated:

- `/test-data/regenerate` endpoint has been deactivated. The response contains an explanatory error message.
- `/experimental/test-data/*` endpoints moved to `/test-data/*` and POST requests to the old paths return 410 status with a message detailing the new location.

## 2nd July 2020

The documentation around the `/offer` endpoint has been clarified to show that:

- it is possible to change the offer by POSTing to that endpoint again
- for the time being, a changed offer must have a changed course, not just changed conditions

## 30th June 2020

New attributes:

- `Rejection` now has a `date` attribute of type string.

## 24th June 2020

Changes to existing attributes:

- `ContactDetails` attributes `address_line1`, `address_line2`, `address_line3` and `postcode` are no longer required attributes.

## 16th June 2020

Sandbox changes:

- Sandbox no longer sends emails to providers about application state changes

## 15th June 2020

New attributes:

- `Qualification` now has a `start_year` attribute of type string.

## 9th June 2020

New attributes:

- `ApplicationAttributes` now has a `support_reference` attribute of type string.

## 20th May 2020

Corrections to documentation

- The Application lifecycle incorrectly stated that candidates have 5 days to respond to offers. This has been amended to 10 days.
- Clarify that we use the two-letter version of ISO 3166, ISO 3166-2, for country codes.

## 11th February 2020

New attributes:

- `Rejection` now includes offer withdrawal reasons

## 10 February 2020

- Add minimum of 1 to `courses_per_application` field for [`test-data/generate`](/experimental/test-data/generate). Stops test application data being generated that have zero courses per application.

## 5th February 2020

Field lengths updated:

- free text coming from inline inputs is standardised to 256 chars
- free text coming from textareas is standardised to 10240 chars (allowing room for over 1000 words)

## 28th January 2020

New attributes:

- `WorkExperience` now has a unique `id` attribute of type integer.
- `Qualification` now has a unique `id` attribute of type integer.

## 14th January 2020

- Introduce `missing_gcses_explanation` field to [`qualifications`](/api-docs/reference#qualifications-object). This contains the candidate’s explanation for any missing GCSE (or equivalent) qualifications.

## 7th January 2020

- Correct size of [`personal_statement`](/api-docs/reference#applicationattributes-object) field to 11624 chars
- Introduce `work_history_break_explanation` field to [`work_experience`](/api-docs/reference#workexperiences-object). This contains the candidate’s explanation for any breaks in work history.

## v1.0 — 18th December 2019

Initial release of the API.

For a log of pre-release changes, [see the alpha release notes](/api-docs/alpha-release-notes).
