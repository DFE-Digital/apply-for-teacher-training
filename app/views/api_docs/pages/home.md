This is API documentation for the Department for Education (DfE)’s new Apply for teacher training service.

Apply will replace the online UCAS application form for postgraduate teacher training. All vendors of student record systems (SRS) and some training providers will need to make changes to integrate with Apply.

The API is a work in progress. We are publishing draft documentation so that:

- providers and vendors have all the information they need to plan a transition to the new service - the Apply team can better understand providers’ and vendors’ needs for the API

## What this API is for

Once a candidate has submitted their application via the Apply service, the application will become available over the API.

Providers can then use the API for:

- [Retrieving applications](/api-docs/reference/#get-applications)
- [Making an offer to a candidate](/api-docs/reference/#post-applications-application_id-offer)
- Confirming a candidate [has met conditions](/api-docs/reference/#post-applications-application_id-confirm-conditions-met), or [has been enrolled](/api-docs/reference/#post-applications-application_id-confirm-enrolment)
- [Rejecting unsuccessful applications](/api-docs/reference/#post-applications-application_id-reject)

To get an idea of how the API works, we recommend you [review the example usage scenarios](/api-docs/usage-scenarios).

## Codes and reference data

Before each application cycle, UCAS provides vendors with reference data defining how certain values appear in API responses.

DfE Apply will avoid prioprietary codes wherever possible, preferring existing data formats such as ISO-certified standards or HESA codes.

Codes appear in three contexts:

- All dates in the API specification are intended to be [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) compliant
- Nationality is expressed as an [ISO 3166](https://www.iso.org/iso-3166-country-codes.html) country code
- Demographic data required for HESA reporting uses [HESA codes for the 2019/20 Initial Teacher Training return](https://www.hesa.ac.uk/collection/c19053/e/ittschms). When the HESA codes for the next cycle are released, we will update the documentation to reflect these.

## How do I connect to this API?

### Authentication and authorisation

The data held by the Apply service is confidential and only available to candidates themselves and staff from the training provider to which applications are made. Therefore authentication will be required for all API interactions.

To set up an authenticated connection between the student record system and DfE Apply, users will need to provide an API key to the SRS. To get an API key, the user will need to sign in to the DfE Apply web interface using DfE Sign-in, the Single Sign-on provider used on the existing _Publish teacher training courses_ service, part of [Find postgraduate teacher training](https://find-postgraduate-teacher-training.education.gov.uk). For each provider supported by your SRS, one user needs to generate this key. It is up to SRS vendors to provide a way for users to add the API key to their SRS system.

The API key will expire after 6 months. One month in advance of expiry, DfE Apply will email the user who generated the key so that they know to come back and generate a new one. To prevent a hard cut-over between keys, once a new key is created the old key will continue to work until it expires.

### Versioning

The version of the API is specified in the URL `/api/v{n}/`. For example: `/api/v1/`, `/api/v2/`, `/api/v3/`, ...

When the API changes in a way that is backwards-incompatible, a new version number of the API will be published.

When a new version, for example `/api/v2`, is published, both the previous **v1** and the current **v2** versions will be supported.

We, however, only support one version back, so if the **v3** is published, the **v1** will be discontinued.

When non-breaking changes are made to the API, this will not result in a version bump. An example of a non-breaking change could be the introduction of a new field without removing an existing field.

Information about deprecations (for instance attributes/endpoints that will be modified/removed) will be included in the API response through a ‘Warning’ header.

We will update our [release notes](/api-docs/release-notes) with all breaking and non-breaking changes.

## Application Lifecycle

The following diagram gives an overview of the states in the application lifecycle:

![Application lifecycle](/api_docs/states.png)

Note that applications are visible to providers only after they reach the `awaiting_provider_decision` state.
