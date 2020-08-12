# 8. API extensions mechanism

Date: 2019-11-06

## Status

Accepted

## Context

With the first alpha version of our API released and the first vendor integrations on the the horizon, we need a plan around minor and major revisions to our API. Our API baseurl is already versioned ('/api/v1') but it was suggested we should explore 'extension' mechanisms to the API so that we are able to release previews of API changes to vendors or supply custom fields to specific vendors, if needed, without creating problems for everyone else. There is some concern that the tools or libraries vendors may use to integrate with our API break when they encounter a new/unknown attribute, instead of just ignoring it.

The main idea explored was giving vendors the ability to request optional fields as URL query parameters (e.g. ```/?extensions=key1,key2```), which would ensure:

- only vendors who explicitly requested optional fields would receive them, and
- the set of optional fields requested would always stay the same, unless vendors update the URL they use for their API requests

Therefore, we tried to come up with a plan which would provide such functionality while consistent with the API choices made so far.

An ideal 'extensions' mechanism would provide:

- an update path for API changes,
- which does not obstruct API use for vendors who expect payloads never to change,
- while allows enough customisation for vendors with more agile teams

### Findings

Although our API is not advertised as a [JSON:API](https://jsonapi.org/), it follows many conventions of the spec, so we tried to plan an 'extensions' mechanism consistent with JSON:API guidelines. JSON:API allows the use of ```/?fields=``` and ```/?include=```.

However, the JSON:API spec contains:

> If a client requests a restricted set of fields for a given resource type, an endpoint MUST NOT include additional fields in resource objects of that type in its response.

and

> A resource object’s attributes and its relationships are collectively called its “fields”.

This would work fine for vendors not specifying ```/?fields=``` but would result in very long URLs for vendors requesting optional fields, as they would need to specify all fields they need (unless we use something like a non-standard ```/?fieldset=``` grouping).

We could, in theory, use ```/?include=``` to specify groups of attributes to be included in a separate part of the response (JSON:API provides an ```included:``` section), but strictly speaking these extra fields are not really additional resources. There would also be some complexity around mapping data between the main attributes block and the ```included:``` section, even more for one-to-many associations/lists, especially in the absence of ids.

If we wanted to proceed with either ```/?fields```= or ```/?include=```, we would probably need to consider changing the presentation of resources to make use of the ```relationships:``` and ```included:``` blocks, as is good JSON:API practice. This, in effect, would mean we start advertising our API as a JSON:API one, as parsing relationships and associations properly would then require the use of JSON:API consumer library, for practical purposes. JSON:API libraries exist in many languages and ecosystems, but their level of maturity varies.

#### Pros

- implementing an extensions API would allow us to pre-release features to specific vendors
- agile vendors could optimise their requests, by requesting exactly the fields that they need
- we would not need to increment our API version with every minor field addition

#### Cons

- it is unclear what the best approach for adding this extensions mechanism is (```/?fields=``` vs ```/?include=``` vs ```/?fieldset=```, plus do we merge fields in main attributes block or do we add to the ```included:``` section)
- if we were to follow JSON:API recommendations and put associations in ```relationships:``` and ```included:``` blocks, it would be easier to add ```/?fields=``` and ```/?included=``` support, but this would make our responses hard to parse by vendors that do not have JSON:API libraries.
- implementing such an 'extensions' mechanism may be overkill for a small number of vendors and minor API revisions a year
- an 'extensions' mechanism could, actually, be introduced as part of a minor release at any point, does not need to be implemented now

## Decision

We have decided to not to implement an 'extensions' mechanism at this point because there is no immediate need and we are likely to make a better choice of implementation when and if such a need does arise. If additional fields need to be released, we shall take the traditional route of a minor version release, ensuring no breaking changes are included in the release. The current advertised API versioning strategy can be found here: [https://apply-for-postgraduate-teacher-training-tech-docs.cloudapps.digital/#versioning](https://apply-for-postgraduate-teacher-training-tech-docs.cloudapps.digital/#versioning)

## Consequences

None, unless the rate of minor releases becomes too frequent, at which time we will be in a better position to decide on how to implement that extension mechanism - fields, include or something else.

