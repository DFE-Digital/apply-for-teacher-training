# 17. Application Choice Updated At

Date: 2021-01-14

## Status

Accepted

## Context

Consumers of the Vendor API can filter applications by updated_at value, to get a list of applications that have changed since a certain time.
They typically use this to avoid processing applications that have already been ingested into their services.
If the updated_at values are inaccurate, there is a potential for vendors to process applications twice or miss application changes entirely.
For that reason, we set up touch relationships from the application form to the application choice to ensure that changes to the application form touch the application choices.

This approach resulted in false positives (where the updated_at value had changed but the data in the application API response had not). This is because there are fields on the application form which do not appear in the application API response.

For example, when geocoding data was added to applications. Every application was touched, but the data was not included in the response so API consumers could not see any changes.

## First approach

The first idea we had to address this issue was to render the API response for an application whenever we were changing a model related to it and see if the change had affected the response.
If a change was detected, we would change the update_at on the application choice.
This intended to only change the updated_at value when the response changed.

However, this approach is sensitive to changes to the shape of the API response, as well as changes to the data. For example, adding a new field to the response would indicate an update where there had not been one.

To fix this drawback, we would have to add logic to ignore certain changes to API responses, at which point this simple idea becomes complex.

## Decision

For changes to the application form we will specify a whitelist of attributes that, when changed, affect the application API response. There are pros and cons to this method:

Pros:
 - We keep an explicit list of significant attributes
 - This is a simple approach using standard Rails techniques, so is easy to follow

Cons:
 - Forgetting to mark a field as significant will result in the application updated_at not being changed (false negative)
 - Forgetting to remove a field from the list of significant ones when it no longer affects an application response will result in the application updated_at being changed (false positive)

In order to mitigate the cons, we have added specs to check that the list of significant attributes contains all attributes which affect an API response, and that there are no extra attributes included.
See [single_application_presenter_spec.rb](../spec/presenters/vendor_api/single_application_presenter_spec.rb)

This solution will require that spec to be kept up to date with a variety of applications in different states so as to cover all the code paths the application presenter has.

As described so far, this solution only addresses changes from the ApplicationForm model that affect API responses for ApplicationChoices.
There are other models (e.g. ApplicationQualification or ApplicationWorkExperience) for which changes to their attributes affect their associated applications.
For these smaller models, we have added a concern TouchApplicationChoices which touches the application_choices whenever the model is created, updated or deleted.

## Consequences

- The updated_at attribute for ApplicationChoices will now accurately reflect when the last update that affected it occurred
- There are new specs that need to be maintained when the single application presenter is changed
