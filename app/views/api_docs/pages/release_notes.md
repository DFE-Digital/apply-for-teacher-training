### 24th June 2020

Changes to existing attributes:

- `ApplicationForm` attributes `address_line1`, `address_line2`, `address_line3` and `postcode` are no longer required attributes.

### 16th June 2020

Sandbox changes:

- Sandbox no longer sends emails to providers about application state changes

### 15th June 2020

New attributes:

- `Qualification` now has a `start_year` attribute of type string.

### 9th June 2020

New attributes:

- `ApplicationAttributes` now has an `support_reference` attribute of type string.

### 20th May 2020

Corrections to documentation

- The Application lifecycle incorrectly stated that candidates have 5 days to respond to offers. This has been amended to 10 days.
- Clarify that we use the two-letter version of ISO 3166, ISO 3166-2, for country codes.

### 11th February 2020

New attributes:

- `Rejection` now includes offer withdrawal reasons

### 10 February 2020

- Add minimum of 1 to `courses_per_application` field for [`test-data/generate`](/experimental/test-data/generate). Stops test application data being generated that have zero courses per application.

### 5th February 2020

Field lengths updated:

- free text coming from inline inputs is standardised to 256 chars
- free text coming from textareas is standardised to 10240 chars (allowing room for over 1000 words)

### 28th January 2020

New attributes:

- `WorkExperience` now has a unique `id` attribute of type integer.
- `Qualification` now has a unique `id` attribute of type integer.

### 14th January 2020

- Introduce `missing_gcses_explanation` field to [`qualifications`](/api-docs/reference#qualifications-object). This contains the candidate’s explanation for any missing GCSE (or equivalent) qualifications.

### 7th January 2020

- Correct size of [`personal_statement`](/api-docs/reference#applicationattributes-object) field to 11624 chars
- Introduce `work_history_break_explanation` field to [`work_experience`](/api-docs/reference#workexperiences-object). This contains the candidate’s explanation for any breaks in work history.

### v1.0 — 18th December 2019

Initial release of the API.

For a log of pre-release changes, [see the alpha release notes](/api-docs/alpha-release-notes).
