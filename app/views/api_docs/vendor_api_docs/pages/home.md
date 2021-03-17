This is API documentation for the Department for Education (DfE)’s new Apply for teacher training service.

Apply is replacing the online UCAS application form for postgraduate teacher training. All vendors of student record systems (SRS) and some training providers will need to make changes to integrate with Apply.

## What this API is for

Once a candidate has submitted their application via the Apply service, the application will become available over the API.

Providers can then use the API for:

- [Retrieving applications](/api-docs/reference/#get-applications)
- [Making an offer to a candidate](/api-docs/reference/#post-applications-application_id-offer)
- Confirming a candidate [has met conditions](/api-docs/reference/#post-applications-application_id-confirm-conditions-met)
- [Rejecting unsuccessful applications](/api-docs/reference/#post-applications-application_id-reject)

To get an idea of how the API works, we recommend you [review the example usage scenarios](/api-docs/usage-scenarios).

## Codes and reference data

### Course data

The source of course data such as provider codes, course codes, training locations, vacancy status and study modes for both Apply and UCAS Teacher Training is the DfE [Teacher Training Courses API](https://api.publish-teacher-training-courses.service.gov.uk/api-reference.html#teacher-training-courses-api). This data is managed via [Publish teacher training courses](https://www.publish-teacher-training-courses.service.gov.uk/sign-in).

### Application data

Before each application cycle, UCAS provides vendors with reference data defining how certain values appear in API responses.

DfE Apply will avoid prioprietary codes wherever possible, preferring existing data formats such as ISO-certified standards or HESA codes.

Codes appear in three contexts:

- All dates in the API specification are intended to be [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) compliant
- Nationality is expressed as an [ISO 3166-2](https://www.iso.org/iso-3166-country-codes.html) country code
- Demographic data required for HESA reporting uses [HESA codes for the 2020/21 Initial Teacher Training return](https://www.hesa.ac.uk/collection/c20053). When the HESA codes for the next cycle are released, we will update the documentation to reflect these.

Where it is not possible to structure data strictly — for example, in the case of GCSE subjects, where candidates need to be able to enter subjects our sources might not include — we encourage candidates to enter values from an [autocomplete field](https://designnotes.blog.gov.uk/2017/04/20/were-building-an-autocomplete/).

To enable API clients to benefit from this consistency, we expose the following lists of possible autocomplete values:

- `/reference-data/gcse-subjects`: a list of GCSE subjects based on [Ofqual’s list](https://register.ofqual.gov.uk/Download)
- `/reference-data/a-and-as-level-subjects`: a list of A and AS level subjects based on [Ofqual’s list](https://register.ofqual.gov.uk/Download)

Grades for GCSEs and A/AS levels are strictly validated since the ITT 2021 recruitment cycle. The following lists contain all possible grades for these qualifications:

- `/reference-data/gcse-grades`
- `/reference-data/a-and-as-level-grades`

## How do I connect to this API?

### Authentication and authorisation

Requests to the API must be accompanied by an authentication token.

Each token is associated with a single provider. It will grant access to applications for courses offered by or accredited by that provider. You can get a token by writing to [becomingateacher@digital.education.gov.uk](mailto:becomingateacher@digital.education.gov.uk).

For instructions on how to authenticate see the [API reference](/api-docs/reference#authentication).

### Versioning

The version of the API is specified in the URL `/api/v{n}/`. For example: `/api/v1/`, `/api/v2/`, `/api/v3/`, ...

When the API changes in a way that is backwards-incompatible, a new version number of the API will be published.

When a new version, for example `/api/v2`, is published, both the previous **v1** and the current **v2** versions will be supported.

We, however, only support one version back, so if the **v3** is published, the **v1** will be discontinued.

When non-breaking changes are made to the API, this will not result in a version bump. An example of a non-breaking change could be the introduction of a new field without removing an existing field.

Information about deprecations (for instance attributes/endpoints that will be modified/removed) will be included in the API response through a ‘Warning’ header.

We will update our [release notes](/api-docs/release-notes) with all breaking and non-breaking changes.

## Testing

To get familiar with our system and perform testing, you can use [our sandbox environment](https://sandbox.apply-for-teacher-training.service.gov.uk).
