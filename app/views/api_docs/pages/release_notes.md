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
