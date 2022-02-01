# Versioning Vendor API

## Summary

This document describes the steps required in order to increment the minor version of the Vendor API. Incrementing the API to major versions is currently not supported.


## Introducing new changes

Changes in the API are specified in `VersionChange` classes and each version can be made up of one or more classes. Every change class must be configured in `app/lib/vendor_api.rb`

A `VersionChange` class has a `description`, an `action` and/or one or multiple resources set using the `resource` identifier.


e.g. to make retrieving a single applications available in version 1.1

_Configure the route in routes.rb_

```
namespace :vendor_api ... do
    get '/applications/:application_id' => 'applications#show'
    ...
end
```

_Add the Presenter in app/presenters/vendor_api/application_choice_presenter.rb_

```ruby
class VendorAPI::ApplicationChoicePresenter < Base
   def initialize(version, application_choice)
      super(version)
      @applicattion_choice = application_choice
   end

   def as_json
      schema.to_json
   end

private

   def schema
   {
     id: application_choice.id.to_s,
     type: 'application',
     attributes: {
       application_url: provider_interface_application_choice_url(application_choice),
       support_reference: application_form.support_reference,
       status: status,
       phase: application_form.phase,
       updated_at: application_choice.updated_at.iso8601,
       submitted_at: application_form.submitted_at.iso8601,
       ...
   }
   end

   def application_form
     @application_form ||= application_choice.application_form
   end

  ...
end
```

_Implement the new action in the VendorAPI::ApplicationChoice controller_
Note that **version** is available to all controllers that extend the  `VendorAPIController`

```ruby
 class VendorAPI::ApplicationChoice < VendorAPIController
    ...
    def show
       application_choice = application_choices_visible_to_provider.find(params[:application_id])

       render json: %({"data":#{ApplicationPresenter.new(version_number, application_choice).serialized_json}})
    end
 end
```

in `/app/lib/vendor_api/changes/retrieve_single_applications.rb` configure both the controller and presenter, as alternatively neither will be available to the API, and add a meaninful description indicating what this specific class introduces (or changes) in the API.

```ruby
class RetrieveApplications < VersionChange
   description 'Implements functionality and exposes endpoint for retrieving a single application choice'

   action ApplicationsController, :show

   resource ApplicationPresenter
end
```

When everything else is in place, map the version change to the version that you want to introduce it in via `/app/lib/vendor_api.rb`

```ruby
module VendorAPI
  ...
  VERSIONS = {
   '1.0' => [ ... ],
   '1.1' => [ Changes::RetrieveSingleApplication ]
  }
end
```

### Pre-release versions

To introduce a new version to the test and deelopment environments without releasing it to production or sandbox, all you have to do is suffix it with `pre` in the `VendorAPI::VERSIONS` constant.


```ruby
module VendorAPI
  ...
  VERSIONS = {
   '1.0' => [ ... ],
   '1.1pre' => [ Changes::RetrieveSingleApplication ] # the Application retrieval endpoint is now
                                                      # available in all environments besides sandbox and  production
  }
end
```

To allow access to that version to the sandbox environment, you need to update the `VendorAPI::VERSION` constant to reflect the highest available version you want to make available.

```ruby
module VendorAPI
  VERSION = '1.1'.freeze
  ...
  VERSIONS = {
   '1.0' => [ ... ],
   '1.1pre' => [ Changes::RetrieveSingleApplication ] # the Application retrieval endpoint is now
                                                      # available in all environments besides production
  }
end
```

To release to production, you need to ensure that **BOTH** the `VendorAPI::VERSION` and `VendorAPI::VERSIONS` are updated to point to the latest version and not include the prerelease suffix.

```ruby
module VendorAPI
  VERSION = '1.1'.freeze
  ...
  VERSIONS = {
   '1.0' => [ ... ],
   '1.1' => [ Changes::RetrieveSingleApplication ]
  }
end
```

### Adding a new endpoint

New endpoints are not by default made available via the API. In order to make them available from a specific version onwards, the endpoint's action must be configured in the version class and the version class must be mapped on a version. The VersionChange class supports configuring a single action.

e.g. to make retrieving all applications available in version 1.1


_in `/app/lib/vendor_api/changes/retrieve_applications.rb`_

```ruby
class RetrieveApplications < VersionChange
   action ApplicationsController, :index
end
```

_in `/app/lib/vendor_api.rb`_

```ruby
module VendorAPI
  ...
  VERSIONS = {
   '1.0' => [ ... ],
   '1.1' => [ Changes::RetrieveApplications ]
  }
end
```

### Adding a new resource

To ensure that the API supports all existing minor versions, any changes must be introduced through presenter modules. This enables serving older versions without including changes introduced at later points.

#### Adding a new presenter

Presenters must extend the `VendorAPI::Base` and return the object Hash through a private `schema` method. The hash can then be converted to JSON through public methods that utilise the application cache (look at `ApplicationPresenter`).

Below, you can see an example of configuring a new `InterviewPresenter`. If required you can configure multiple than one resources per version change.


_Add the presenter in app/presenters/vendor_api/interview_presenter.rb_

```ruby
class VendorAPI::InterviewPresenter < Base
   attr_reader :interview

   def initialize(version, interview)
      super(version)
      @interview = interview
   end

   def as_json
      schema.to_json
   end

private

   def schema
   {
     id: interview.id.to_s,
     type: 'interview',
     attributes: {
       date: interview.date.iso8601,
       location: interview.location,
       additional_details: interview.additional_details,
       updated_at: interview.updated_at.iso8601,
   }
   end
```

_configure the new presenter in the VersionChange class_

```ruby
class AddInterviews < VersionChange
   resource InterviewPresenter
end
```

```ruby
module VendorAPI
  ...
  VERSION = {
   '1.0' => [...],
   '1.1' => [AddInterviews],
  }
end
```

#### Updating an existing presenter

When introducing new functionality or changing the behavior of existing fields, create a new module that implements the `schema` method, and deep merge into the returned value. Changing the values directly in the existing presenter is not recommended as that will have an impact on previous versions of the API.

For example, to add a new `date` field to the `InterviewPresenter` implemented above


_introduce a new presenter module..._

```ruby
module AddInterviewDate
  def schema
    super.deep_merge!({
      date_and_time: interview.date_and_time.iso8601,
    })
  end
end
```

_configure this in a version change class_

```ruby
class AddDateToInterview < VersionChange
   resource InterviewPresenter, [AddInterviewDate]
end
```

_include the change in the vendor API_

```ruby
module VendorAPI
  ...
  VERSIONS = {
   '1.0' => [...],
   '1.1' => [...],
   '1.2' => [AddDateToInterview]
  }
end
```

## Version unlocking

In order to change the latest available API version, the `VERSION` constant specified in `app/lib/vendor_api.rb` must be updated to reflect it. This enables new versions to be introduced and tested throught the specs (by stubbing the constant) before they are made available in any environment.

## Documenting changes

Changes to the API are documented in the release_notes file, after specifying the version and date that the version was released.

For a minor version release

```markdown
## v1.1 - 19th January 2022

- Introduce new `notes` endpoint
- Update application choice object to include nested notes
- Add pagination
```

For a patch version release

```markdown
## v1.1.1 - 22nd January 2022

- Fix a bug with Application choice HESA ITT data not returning the correct value

```

### Resources

- [Vendor API version information](../app/lib/vendor_api.rb)
- [Vendor API version change classses](../app/lib/vendor_api/changes)
- [API Presenter base class](../app/presenters/vendor_api/base.rb)
