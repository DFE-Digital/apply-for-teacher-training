The scenarios on this page show example request URLs and payloads clients can
use to take actions via this API. The examples are only concerned with business
logic and are missing details necessary for real-world usage. For example,
authentication is completely left out.

At the beginning of each scenario, a candidate has completed an application for initial teacher training via the Apply service and that application is available via the API.

The provider has authenticated to your system and begins their work by retrieving all the applications since a given date. Your system issues the following request on their behalf:

```
GET /applications?since=2018-10-01T10:00:00Z&provider_code=2FR
```

This returns a list of
[Application](/api-docs/reference/#application-object)s.

The following examples all refer to a single application id, `11fc0d3b2f`, which
we assume belongs to one of the applications in that list.

## A successful application

### 1. Provider retrieves the application

Get the application data.

```
GET /applications/11fc0d3b2f
```

This returns an [application](/api-docs/reference/#application-object).

_See [retrieve an application](/api-docs/reference/#get-applications-application_id) endpoint._

### 2. The provider makes an offer

The provider would like to offer the candidate a conditional place.

```
POST /applications/11fc0d3b2f/offer
```

With a [request body containing conditions](/api-docs/reference/#post-applications-application_id-offer).

This returns an [application](/api-docs/reference/#application-object) with an updated `status`.

_See [make an offer](/api-docs/reference/#post-applications-application_id-offer) endpoint._

### 3. Confirm that the conditions are met

When the candidate has accepted this offer the application status changes to `meeting_conditions`.

Once you know the conditions are met, make the following request.

```
POST /applications/11fc0d3b2f/confirm-conditions-met
```

This returns an [application](/api-docs/reference/#application-object) with an updated `status`.

_See [confirm offer conditions are met](/api-docs/reference/#post-applications-application_id-confirm-conditions-met) endpoint._

### 4. Confirm candidate enrolment

Once the candidate has enrolled, make the following request.

```
POST /applications/11fc0d3b2f/confirm-enrolment
```

This returns an [application](/api-docs/reference/#application-object) with an updated `status`.

_See [confirm candidate enrolment](/api-docs/reference/#post-applications-application_id-confirm-enrolment) endpoint._

## Rejecting an application

### 1. The provider reviews the form and rejects the candidate without an interview

```
POST /applications/11fc0d3b2f/reject
```

With a [request body containing a reason](/api-docs/reference/#post-applications-application_id-reject).

This returns an [application](/api-docs/reference/#application-object) with an updated `status`.

_See [reject an application](/api-docs/reference/#post-applications-application_id-reject) endpoint._
