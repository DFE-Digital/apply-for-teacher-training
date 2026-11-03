
This is the API documentation for the Department for Education (DfE)’s Apply for teacher training service.

<div class="app-contents-list--font-size-19 govuk-!-margin-bottom-6">
  <p class="govuk-body govuk-!-margin-bottom-0">Contents</p>
  <ol class="app-contents-list__list">
    <li class="app-contents-list__list-item app-contents-list__list-item--dashed">
      <%= govuk_link_to 'What this API is for', '#what-this-api-is-for' %>
    </li>
    <li class="app-contents-list__list-item app-contents-list__list-item--dashed">
      <%= govuk_link_to 'What the API does not support', '#what-the-api-does-not-support' %>
    </li>
    <li class="app-contents-list__list-item app-contents-list__list-item--dashed">
      <%= govuk_link_to 'Codes and reference data', '#codes-and-reference-data' %>
    </li>
    <li class="app-contents-list__list-item app-contents-list__list-item--dashed">
      <%= govuk_link_to 'How to connect to the API', '#how-to-connect-to-the-api' %>
    </li>
    <li class="app-contents-list__list-item app-contents-list__list-item--dashed">
      <%= govuk_link_to 'API versioning strategy', '#api-versioning-strategy' %>
    </li>
    <li class="app-contents-list__list-item app-contents-list__list-item--dashed">
      <%= govuk_link_to 'How applications are updated', '#how-applications-are-updated' %>
    </li>
    <li class="app-contents-list__list-item app-contents-list__list-item--dashed">
      <%= govuk_link_to 'Testing', '#testing' %>
    </li>
  </ol>
</div>

## What this API is for

Once a candidate submits an application through Apply, the application becomes available through the API.

Providers can use the API to:

- [retrieve applications](/api-docs/reference/#get-applications)
- [make an offer to a candidate](/api-docs/reference/#post-applications-application_id-offer)
- confirm a candidate [has met conditions](/api-docs/reference/#post-applications-application_id-confirm-conditions-met)
- [reject unsuccessful applications](/api-docs/reference/#post-applications-application_id-reject)

[Review the example usage scenarios](/api-docs/usage-scenarios) to see how the API works.

## What the API does not support

The API does not currently support tracking and confirming individual conditions. We’re exploring this and may support it in later versions.

## Codes and reference data

### Course data

The DfE [Teacher Training Courses API](https://api.publish-teacher-training-courses.service.gov.uk/) is the source of course data for Apply, including provider codes, course codes, training locations, vacancy status and study modes. This data is managed through [Publish teacher training courses](https://www.publish-teacher-training-courses.service.gov.uk/sign-in).

### Application data

DfE Apply avoids proprietary codes wherever possible and uses existing data formats instead, such as ISO-certified standards or HESA codes.

The API uses codes to express:

- dates, in formats intended to be [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) compliant
- nationality, as an [ISO 3166-2](https://www.iso.org/iso-3166-country-codes.html) country code
- demographic data for HESA reporting, using [HESA codes for the most recent Initial Teacher Training return](https://www.hesa.ac.uk/collection/c24053/)

This documentation will be updated when the codes for the next cycle are released.

Some data cannot be structured strictly. For example, candidates sometimes need to enter GCSE subjects that our sources might not include. In these cases, we ask candidates to choose from an [autocomplete field](https://designnotes.blog.gov.uk/2017/04/20/were-building-an-autocomplete/).

To keep these values consistent, the API exposes:

- a list of GCSE subjects based on [Ofqual’s list](https://register.ofqual.gov.uk/Download), at `/reference-data/gcse-subjects`
- a list of A and AS level subjects based on [Ofqual’s list](https://register.ofqual.gov.uk/Download), at `/reference-data/a-and-as-level-subjects`

Grades for GCSEs, and A and AS levels have been strictly validated since the ITT 2021 recruitment cycle. The following lists contain:

- all possible GCSE grades, at `/reference-data/gcse-grades`
- all possible A and AS level grades, at `/reference-data/a-and-as-level-grades`

### How candidates and applications are identified

There are 3 identifiers used for applications on the API.

#### Application ID

`Application.id`, for example `1234`, identifies an application to a single course, also known as an application choice. We show this to candidates as the ‘application number’. Candidates can have up to <%= ChoiceLimitsCalculator::IN_PROGRESS_LIMIT %> in progress application choices on one application form.

#### Candidate ID

`Candidate.id`, for example `C7890`, identifies a candidate.

#### Support reference

`ApplicationAttributes.support_reference`, for example `AB1234`, identifies the application form carrying this application choice.

Candidates can have multiple application forms. Their candidate ID will stay the same, but the support reference will change because it’s a new application form.

## How to connect to the API

### Authentication and authorisation

Requests to the API must be accompanied by an authentication token. Each token is associated with a single provider and grants access to applications for courses that provider offers or accredits.

You can only generate a token if you have permission to. You should request this from the person at your organisation who manages permissions. Tokens that are not used will be revoked.

For instructions on how to authenticate, see the [API reference](/api-docs/reference#authentication).

## API versioning strategy

When we add new features to the API, we sometimes make changes that require you to update student record systems.

We give each new version of the API a new number. The version number shows whether we’ve made breaking or non-breaking changes.

### Breaking changes

Breaking changes usually involve modifying or deleting parts of the API, such as:

- removing features
- removing fields
- changing the behaviour of endpoints, for example requiring a new parameter before applications can sync

You must update student record systems before you move to a new version with breaking changes.

### Non-breaking changes

Non-breaking changes keep the API backward compatible, so they do not affect existing functionality.

Non-breaking changes include adding new:

- endpoints, for example to allow individual conditions to be marked as met or not met
- nested resources and objects, for example interview details
- fields, for example when candidates are asked a new question
- optional query parameters

### How the API version number reflects the changes we’ve made

We use the format major.minor (for example, `2.1`) to indicate API versions.

The first number indicates a major version. This is incremented each time breaking changes are made, for example `2.1` changes to `3.0`.

The number after the decimal point indicates a minor version. This is incremented each time non-breaking changes are made, for example `2.1` changes to `2.2`.

We document changes in our [release notes](/api-docs/release-notes).

### Using the correct version of the API

When we officially release an API version, we make minor version updates available on:

- their own minor version URL, for example `v2.1`
- a major version URL which does not indicate a minor version, for example `v2`

This means you do not need to update student record systems every time we make a minor update.

For example, after version `2.1` is released you can use:

- <https://www.apply-for-teacher-training.service.gov.uk/api/v2.0> for version `2.0`
- <https://www.apply-for-teacher-training.service.gov.uk/api/v2.1> for version `2.1`
- <https://www.apply-for-teacher-training.service.gov.uk/api/v2> for version `2.1`, but if version `2.2` is released this URL will give you version `2.2` instead

## How applications are updated

Most changes through the API happen when a user does something. For example, when a provider makes an offer, information is passed over the API to change the application status from ‘awaiting provider decision’ to ‘offered’.

Changes can also happen without a user doing anything, including when:

- applications are automatically made inactive after a certain amount of time
- developers at DfE make changes when they migrate data from one system to another
- the DfE support team make changes which cannot be made using the API, such as reverting an offer to ‘awaiting provider decision’ after a provider accidentally withdraws it

Every change made to an application is timestamped to show when it occurred.

## Testing

Use our [sandbox environment](https://sandbox.apply-for-teacher-training.service.gov.uk) to get familiar with the system and run tests.

