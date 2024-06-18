This is API documentation for the Department for Education (DfE)’s new Apply for teacher training service.

Apply has replaced the online UCAS teacher training service for postgraduate initial teacher training in England. All vendors of student record systems (SRS) and some training providers will need to make changes to integrate with Apply.

## What this API is for

Once a candidate has submitted their application via the Apply service, the application will become available over the API.

Providers can then use the API for:

- [Retrieving applications](/api-docs/reference/#get-applications)
- [Making an offer to a candidate](/api-docs/reference/#post-applications-application_id-offer)
- Confirming a candidate [has met conditions](/api-docs/reference/#post-applications-application_id-confirm-conditions-met)
- [Rejecting unsuccessful applications](/api-docs/reference/#post-applications-application_id-reject)

To get an idea of how the API works, we recommend you [review the example usage scenarios](/api-docs/usage-scenarios).

## What the API doesn't support

The API currently doesn’t support the following features:

- Decision codes (e.g. to provide structured reasons for rejection, or conditions)
- Tracking and confirming individual conditions

We are exploring the addition of those features, and may support them in later API versions.

## Codes and reference data

### Course data

The source of course data such as provider codes, course codes, training locations, vacancy status and study modes for both Apply and UCAS Teacher Training is the DfE [Teacher Training Courses API](https://api.publish-teacher-training-courses.service.gov.uk/). This data is managed via [Publish teacher training courses](https://www.publish-teacher-training-courses.service.gov.uk/sign-in).

### Application data

Before each application cycle, UCAS provides vendors with reference data defining how certain values appear in API responses.

DfE Apply will avoid prioprietary codes wherever possible, preferring existing data formats such as ISO-certified standards or HESA codes.

Codes appear in three contexts:

- All dates in the API specification are intended to be [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) compliant
- Nationality is expressed as an [ISO 3166-2](https://www.iso.org/iso-3166-country-codes.html) country code
- Demographic data required for HESA reporting uses [HESA codes for the 2021/22 Initial Teacher Training return](https://www.hesa.ac.uk/collection/c21053). When the HESA codes for the next cycle are released, we will update the documentation to reflect these

Where it is not possible to structure data strictly — for example, in the case of GCSE subjects, where candidates need to be able to enter subjects our sources might not include — we encourage candidates to enter values from an [autocomplete field](https://designnotes.blog.gov.uk/2017/04/20/were-building-an-autocomplete/).

To enable API clients to benefit from this consistency, we expose the following lists of possible autocomplete values:

- `/reference-data/gcse-subjects`: a list of GCSE subjects based on [Ofqual’s list](https://register.ofqual.gov.uk/Download)
- `/reference-data/a-and-as-level-subjects`: a list of A and AS level subjects based on [Ofqual’s list](https://register.ofqual.gov.uk/Download)

Grades for GCSEs and A/AS levels are strictly validated since the ITT 2021 recruitment cycle. The following lists contain all possible grades for these qualifications:

- `/reference-data/gcse-grades`
- `/reference-data/a-and-as-level-grades`

### How candidates and applications are identified

Applications on the API have three identifiers associated with them:

- `Application.id`, eg `1234`. This identifies an application to a single course, also known as an application choice. We show it to candidates as the "application number". Candidates can have up to three application choices for one application form.
- `Candidate.id`, eg `C7890`. This identifies a candidate.
- `ApplicationAttributes.support_reference`, eg `AB1234`. This identifies the application form carrying this application choice. Candidates can have multiple application forms. For instance, when a candidate moves from Apply 1 to Apply again their candidate ID will stay the same, but that’s a new application form so the `support_reference` will be different.

## How do I connect to this API?

### Authentication and authorisation

Requests to the API must be accompanied by an authentication token.

Each token is associated with a single provider. It will grant access to applications for courses offered by or accredited by that provider. You can get a token by writing to [becomingateacher@digital.education.gov.uk](mailto:becomingateacher@digital.education.gov.uk).

For instructions on how to authenticate see the [API reference](/api-docs/reference#authentication).

## API versioning strategy

When we provide new features through the API, we sometimes make changes that require you to update student record systems.

We give a new number to the new version of the API. The change of version number shows whether we’ve made breaking or non-breaking changes to the API.

### Breaking changes

Breaking changes usually involve modifying or deleting parts of the API, such as:

- removing features
- removing fields
- changing the behaviour of endpoints, for example requiring a new parameter in order for applications to be synced

You must update student record systems before you move to a new version with breaking changes.

### Non-breaking changes

When we make non-breaking changes the API remains ‘backward compatible’. This means that the changes do not affect the existing functionality of the API.

Non-breaking changes include adding new:

- endpoints, for example to allow individual conditions to be marked as met or not met
- nested resources and objects, for example details of interviews
- fields, for example when candidates are asked a new question
- optional query parameters, for example to allow optional pagination when applications are synced

You do not need to update student record systems before moving to a new version with non-breaking changes. You only need to make updates if you want to use the version’s new features.

### How the API version number reflects the changes we’ve made

We use the format major.minor (for example, `1.2`) to indicate the API version.

The first number indicates a major version. This is incremented each time breaking changes are made, for example `1.2` changes to `2.0`.

The number after the decimal point indicates a minor version. This is incremented each time non-breaking changes are made, for example `1.2` changes to `1.3`.

The current version of this API is `<%= current_api_version %>`. The next minor version will be `<%= next_api_version %>`.

Changes are documented in our [release notes](/api-docs/release-notes).

### Using the correct version of the API

When an API version is officially released, minor version updates will be made available:

- on their own minor version URL, for example `v1.1`
- on a major version URL which does not indicate a minor version, for example `v1`

This means that if you use the major version URL, you do not need to update student record systems every time we make a minor update.

For example, after version `1.1` is released you can use:

- <https://www.apply-for-teacher-training.service.gov.uk/api/v1.0> for version `1.0`
- <https://www.apply-for-teacher-training.service.gov.uk/api/v1.1> for version `1.1`
- <https://www.apply-for-teacher-training.service.gov.uk/api/v1> for version `1.1` - but if version `1.2` is released then this URL will give you version `1.2` instead

## How applications are updated

Most changes through the API happen when a user does something. For example when a provider makes an offer, information is passed over the API to change the application status from ‘awaiting provider decision’ to ‘offered’.

Changes can also be made to data without a user doing anything. For example:

- applications are automatically rejected if a decision has not been made after a certain amount of time
- developers at the Department for Education (DfE) may make changes when they migrate data from one system to another
- the support team at the DfE may make changes which cannot be made using the API, such as reverting an offer to ‘awaiting provider decision’ after a provider accidentally withdraws it

Any changes made to an application are time stamped to identify when they occured.

## Testing

To get familiar with our system and perform testing, you can use [our sandbox environment](https://sandbox.apply-for-teacher-training.service.gov.uk).
