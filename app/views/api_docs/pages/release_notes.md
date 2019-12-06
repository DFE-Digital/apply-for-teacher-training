### Unreleased Changes
- Add Development, Test and Vendor Sandbox enviroment details to [api info](/reference/#api-info) page.
- Add [/test-data/regenerate](/reference/#post-test-data-regenerate) endpoint.
- Add [single application](/reference/#singleapplicationresponse) and [multiple applications](/reference/#multipleapplicationsresponse) response schemas.
- Add `422` error response to `POST` endpoints including:
    - [offer](/reference/#post-applications-application-id-offer)
    - [confirm enrolment](/reference/#post-applications-application-id-confirm-enrolment)
    - [confirm conditions met](/reference/#post-applications-application-id-confirm-conditions-met)
    - [reject](/reference/#post-applications-application-id-reject)

### Release 0.4.0 - 26 September 2019

Changes to the data:

- Change the structure of an [application](/reference#get-applications):
  - add `type` field
  - add `attributes` field and move `status`, `submitted_at`, `updated_at`, `personal_statement`
    `candidate`, `contact_details`, `course`, `qualifications`, `work_experiences`
    `references`, `offer`, `withdrawal` and `rejection` fields into it
- Remove date from [reject](/reference/#post-applications-application-id-reject) endpoint
- Limit [candidates](/reference/#candidate) to only 2 nationalities
- Rename the `org` field on [work experience](/reference/#workexperience) to `organisation_name`
- Rename the `type` field on [qualification](/reference/#qualification) to `qualification_type`
- Rename the `type` field on [reference](/reference/#reference) to `reference_type`
- Add HESA ITT data to the [application](/reference#get-applications). Available only once a student is enrolled

Changes to functionality:

- Change the successful response for all endpoints to be within a `data` object
- Change the successful response for making an offer, confirming candidate
  enrolment, confirming offer conditions are met and rejecting an application
  endpoints to be the application
- Change the HTTP response code for making an offer, confirming candidate enrolment,
  confirming offer conditions are met and rejecting an application endpoints to `200`
- Support a `provider_ucas_code` parameter when [retrieving many applications](/retrieve-many-applications)
- Require a `meta` key in POST request bodies, holding `attribution` and `timestamp` metadata

Additional changes:

- Clarify the endpoint for rejecting an application in [usage scenarios](/usage-scenarios)
- Clarify the timestamp format for retrieving applications in [usage scenarios](/usage-scenarios)
- Clarify maximum length of strings in Schemas
- Add description of the [API versioning](/#versioning)
- Add error responses to OpenAPI spec for all endpoints
- Add [instructions](/reference/#use-the-swagger-editor) for importing our OpenAPI specification in the Swagger Editor
- Add `provider_code` param to retrieving many applications in [usage scenarios](/usage-scenarios)
- Update responses for [making an offer](/reference/#post-applications-application-id-offer),
  [confirming candidate enrolment](/reference/#post-applications-application-id-confirm-enrolment),
  [confirming offer conditions are met](/reference/#post-applications-application-id-confirm-conditions-met)
  and [rejecting an application](/reference/#post-applications-application-id-reject) endpoints in [usage scenarios](/usage-scenarios)
- Clarify the steps between making an offer and confirming that offer conditions are met in [usage scenarios](/usage-scenarios)

### Release 0.3 - 16 September 2019

Changes to the data:

- Remove first and last name from Candidate in favour of full name
- Remove id from Candidate
- Remove disability information from Candidate, as this is not collected via the application form
- Remove functionality to amend an offer
- Rename the rejection endpoint
- Update Contact Details resource to split address into separate fields
- Remove description from course resource
- Add first name, last name and date of birth for Candidate

### Release 0.2 - 11 September 2019

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

### Release 0.1 - 4 July 2019

Initial release of the API documentation.
