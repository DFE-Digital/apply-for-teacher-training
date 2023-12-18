# Vendor API Minor Versions

## Summary

This document describes the steps required in order to increment the minor version of the Vendor API.

Incrementing the API to major versions is currently not supported.

Minor version updates are only for non-breaking changes. A key design principle is maintaining backwards compatibility with all prior minor versions.

When incrementing a minor version, the following changes can be introduced:

- Adding fields to an existing schema
- Adding a new action to an existing controller
- Adding a new nested resource
- Adding metadata fields

Fields, routes and endpoints cannot be removed once they have been introduced.

## Starting a new minor version

To start introducing a new minor version, add the version number to the `app/lib/vendor_api.rb` `VERSIONS` constant as a key. In order to mark this as a preliminary version, `pre` is suffixed to the version number. This is recommended, as it will prevent the new version from being surfaced in production under all circumstances.

Adding a new version to `VERSIONS` makes it immediately available in development environments.

```ruby
module VendorAPI
  VERSION = '1.1'.freeze

  VERSIONS = {
   '1.0' => [ ... ],
   '1.1' => [ ... ],
   '1.2pre' => [], # The newly added minor version, only accessible in dev environments.
  }
end
```

## Adding fields to an existing schema

When introducing a new field or changing the behavior of existing fields, create a new presenter module in a corresponding `app/presenters/vendor_api/<presenter_name>/` folder.

The presenter module needs to implement the `schema` method, and deep merge into the returned value.

For example, to add a new `date_and_time` field to an existing `InterviewPresenter` schema, there are three key steps:

1. Introduce a new presenter module
2. Create a change class
3. Include the change class in the Vendor API
4. Add tests for the presenter changes
5. Update the Vendor API documentation

### Introduce a new presenter module

Create a new presenter module in the directory that corresponds to the presenter module e.g. `app/presenters/vendor_api/interview_presenter/add_interview_date.rb`. This should implement a schema method, which uses `deep_merge!` to add the new field to the presenter's schema.

```ruby
module VendorAPI::InterviewPresenter::AddInterviewDate
  def schema
    super.deep_merge!({
      date_and_time: interview.date_and_time.iso8601,
    })
  end
end
```

### Create a version change class

Create a new change class in `app/lib/vendor_api/changes/`

```ruby
module VendorAPI
  module Changes
    class AddDateToInterview < VersionChange
       description 'Add a date and time to interviews.'

       resource InterviewPresenter, [AddInterviewDate]
    end
  end
end
```

### Include the change in the Vendor API

In `app/lib/vendor_api.rb` add the name of the change class to the version you want it to be introduced in.

```ruby
module VendorAPI
  VERSION = '1.1'.freeze

  VERSIONS = {
   '1.0' => [...],
   '1.1' => [...],
   '1.2pre' => [Changes::AddDateToInterview]
  }
end
```

### Add tests for the presenter changes

We do not test presenter modules at the module level. Instead we test for the expected changes at the presenter level for the version of the API that introduces these changes. This verifies the module is mixed into the presenter at the right API version, as well as verifying the presence of any new fields.

In `spec/presenters/vendor_api/v1.2/` find or create the `interview_presenter_spec.rb`. This is meant to test only the changes introduced to the presenter in this version.

```ruby
require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  subject(:interview_schema) { described_class.new(version, interview).schema }

  let(:version) { '1.2' }

  describe 'interview date_and_time' do
    let(:interview) { create(:interview, :future_date_and_time) }

    it 'includes date_and_time' do
      expect(interview_schema[:date_and_time]).to be_present
    end
  end
end
```

### Update the Vendor API documentation

The `config/vendor_api/draft.yml` should contain an accurate spec for the proposed changes for this version, as this will be used as a demonstration of the changes.

The `config/vendor_api/v1.X.yml` file should be updated incrementally with the changes that you've made.

## Adding a new action to an existing controller

Adding a new action to an existing controller is similar to adding a new action in Rails, except that it needs to also be included in the Vendor API version.

1. Add the new action to the routes
2. Add the new action to the controller
3. Create a change class
4. Include the change class in the Vendor API
5. Add tests for the controller changes
6. Update the Vendor API documentation

### Add the new action to the routes

The example shows a new route being added to `config/routes.rb` for deleting a note on an application.

```ruby
namespace :vendor_api, path: 'api/:api_version', api_version: /v[.0-9]+/, constraints: ValidVendorApiRoute do
  ...
  scope path: '/applications/:application_id' do
    post '/notes/create' => 'notes#create'
    post '/notes/:note_id/delete' => 'notes#destroy' # The new action being added
```

### Add the new action to the controller

The new action is added to the existing controller. In the example this would be `app/controllers/vendor_api/notes_controller.rb`

```ruby
module VendorAPI
  class NotesController < VendorAPIController
    include ApplicationDataConcerns
    include APIValidationsAndErrorHandling
    ...
    def destroy # The new controller action
      ...
      render_application
    end

  private
    ...
  end
end
```

### Create a change class

A change class will need to specify the controller and the new action that has been added. Create a change class e.g. `app/lib/vendor_api/changes/delete_note.rb`

```ruby
module VendorAPI
  module Changes
    class DeleteNote < VersionChange
      description 'Deletes a note.'

      action NotesController, :destroy
    end
  end
end
```

### Include the change class in the Vendor API

Add the change class to the version you want to introduce it in for `app/lib/vendor_api.rb`

```ruby
module VendorAPI
  VERSION = '1.1'.freeze

  VERSIONS = {
   '1.0' => [...],
   '1.1' => [...],
   '1.2pre' => [
     Changes::AddDateToInterview,
     Changes::DeleteNote,
   ]
  }
end
```

Requests that are sent to the current pre-release version do not need to include `pre` in their version number e.g. `http://localhost:3000/api/v1.2/applications?since=2021-10-01`

### Add tests for the controller changes

Add a request spec that covers the new controller method and action e.g. `spec/requests/vendor_api/v1.2/post_destroy_note_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/notes/:note_id/delete', type: :request do
  include VendorAPISpecHelpers
  ...
  describe 'deleting a note' do
    it 'Succeeds and renders a SingleApplicationResponse' do
      post_api_request "/api/v1.2/applications/#{application_choice.id}/notes/#{note.id}/delete"
      ...
      expect(response).to have_http_status(:ok)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.2')
    end
  end
end
```

### Update the Vendor API documentation

The `config/vendor_api/draft.yml` should contain an accurate spec for the proposed changes for this version, as this will be used as a demonstration of the changes.

The `config/vendor_api/v1.X.yml` file should be updated incrementally with the changes that you've made.

## Adding a new nested resource

Adding a new nested resource requires a new controller and presenter. It is then passed into a change class, which is included in the new version.

When adding multiple actions for a new controller, separate them out into change classes for each action.

1. Add all the new actions for the new resource to the routes
2. Create the new controller
3. Create the appropriate change classes
4. (Optional) Add the new resource to the ApplicationPresenter
5. Include the change classes in the Vendor API
6. Add tests for the controller changes
7. Update the Vendor API documentation

### Add all the new actions for the new resource to the routes

Add the routes for the new resource in `config/routes.rb`

```ruby
namespace :vendor_api, path: 'api/:api_version', api_version: /v[.0-9]+/, constraints: ValidVendorApiRoute do
  ...
    scope path: '/applications/:application_id' do
      post '/feedback' => 'feedback#create'
      post '/feedback/:feedback_id' => 'feedback#update'
```

### Create the new controller

Create the controller with the new actions defined e.g. `app/controllers/vendor_api/feedback_controller.rb`

```ruby
module VendorAPI
  class FeedbackController < VendorAPIController
    include ApplicationDataConcerns
    include APIValidationsAndErrorHandling

    def create
      ...
      render_application
    end

    def update
      ...
      render_application
    end
  end
end
```

### Create the appropriate change classes for the controller actions

For each new action, a separate change class will need to be created in `app/lib/vendor_api/changes/`

```ruby
module VendorAPI
  module Changes
    class CreateFeedback < VersionChange
      description 'Create feedback for an application.'

      action FeedbackController, :create
    end
  end
end
```

```ruby
module VendorAPI
  module Changes
    class UpdateFeedback < VersionChange
      description 'Update feedback for an application.'

      action FeedbackController, :update
    end
  end
end
```

### (Optional) Add the new resource to the ApplicationPresenter

If the new resource is nested under the application, then a new presenter for the resource will need to be created.

The example below shows a new FeedbackPresenter being created in `app/presenters/vendor_api/feedback_presenter.rb`

```ruby
class VendorAPI::FeedbackPresenter < VendorAPI::Base
  attr_reader :feedback

  def initialize(version, feedback)
    super(version)
    @feedback = feedback
  end

  def as_json
    schema.to_json
  end

  def schema
    {
      id: feedback.id.to_s,
      text: feedback.text,
    }
  end
end
```

Create a presenter module that merges in the new resource in the ApplicationPresenter e.g. `app/presenters/vendor_api/application_presenter/feedback.rb`

```ruby
module VendorAPI::ApplicationPresenter::Feedback
  def schema
    super.deep_merge!({
      attributes: {
        feedback: VendorAPI::FeedbackPresenter.new(active_version, application_choice.feedback).schema },
      },
    })
  end
end
```

Create a change class that incorporates the new presenter and the presenter module e.g. `app/lib/vendor_api/changes/add_feedback_to_application.rb`

```ruby
module VendorAPI
  module Changes
    class AddFeedbackToApplication < VersionChange
      description 'Add the feedback resource to the ApplicationPresenter.'

      resource FeedbackPresenter
      resource ApplicationPresenter, [ApplicationPresenter::Feedback]
    end
  end
end
```

### Include the change classes in the Vendor API

Add the change classes to the new version in `app/lib/vendor_api.rb`

```ruby
module VendorAPI
  VERSION = '1.1'.freeze

  VERSIONS = {
   '1.0' => [...],
   '1.1' => [...],
   '1.2pre' => [
     Changes::AddDateToInterview,
     Changes::DeleteNote,
     Changes::CreateFeedback,
     Changes::UpdateFeedback,
     Changes::AddFeedbackToApplication,
   ]
  }
end
```

### Add tests for the controller changes

For each new controller action, add a request spec:

- `spec/requests/vendor_api/v1.2/post_create_feedback_spec.rb`
- `spec/requests/vendor_api/v1.2/post_update_feedback_spec.rb`

For the optional new presenter, create a new presenter spec e.g. `spec/presenters/vendor_api/v1.2/feedback_presenter_spec.rb`

An ApplicationPresenter spec will also need to be created or updated for the new version, covering the new included resource e.g. `spec/presenters/vendor_api/v1.2/application_presenter_spec.rb`

### Update the Vendor API documentation

The `config/vendor_api/draft.yml` should contain an accurate spec for the proposed changes for this version, as this will be used as a demonstration of the changes.

The `config/vendor_api/v1.X.yml` file should be updated incrementally with the changes that you've made.

Update the `config/vendor_api/v1.2.yml` and the `config/vendor_api/draft.yml`

### Adding metadata fields

Additional content for a presenter can be added as a separate component to the `data` content. A presenter that defines the content for the metadata will need to be created, and then a change module which merges the content into an existing presenter's `serialized_json` response is required.

1. Create a metadata presenter
2. Create a presenter module
3. Create a change class
4. Include the change classes in the Vendor API

### Create a metadata presenter

A presenter which contains the 'as_json' content will need to be created e.g. `app/presenters/vendor_api/meta_presenter.rb`

```ruby
module VendorAPI
  class MetaPresenter < Base

    def initialize
      ...
    end

    def as_json
      meta_hash = { ... }
      meta_hash.to_json
    end
  end
end
```

### Create a presenter module

A presenter module will need to be created to incorporate the metadata into an existing presenter. In this example, we are including the meta presenter's content in the SingleApplicationPresenter, by creating `app/presenters/vendor_api/single_application_presenter/meta.rb`

We define the `serialized_json` method to return the existing `data` content, as well as our new `meta` content using the MetaPresenter we have created.

```ruby
module VendorAPI::SingleApplicationPresenter::Meta
  def serialized_json
    %({"data":#{VendorAPI::ApplicationPresenter.new(active_version, application).serialized_json}, "meta": #{VendorAPI::MetaPresenter.new(active_version).as_json}})
  end
end
```

### Create a change class

Create a change class e.g. `app/lib/vendor_api/changes/add_meta_to_application.rb`

This will specify the MetaPresenter as a new presenter, as well as introducing the Meta presenter module to the SingleApplicationPresenter

```ruby
module VendorAPI
  module Changes
    class AddMetaToApplication < VersionChange
      description 'Adds top level meta object to single application response'

      resource MetaPresenter
      resource SingleApplicationPresenter, [SingleApplicationPresenter::Meta]
    end
  end
end
```

### Include the change class in the Vendor API

Add the change class to the new version in `app/lib/vendor_api.rb`

```ruby
module VendorAPI
  VERSION = '1.1'.freeze

  VERSIONS = {
   '1.0' => [...],
   '1.1' => [...],
   '1.2pre' => [
     Changes::AddDateToInterview,
     Changes::DeleteNote,
     Changes::CreateFeedback,
     Changes::UpdateFeedback,
     Changes::AddFeedbackToApplication,
     Changes::AddMetaToApplication,
   ]
  }
end
```

## Releasing a new version to Sandbox

In `app/lib/vendor_api.rb` update the `VERSION` so that it is greater than or equal to the version that you want to expose in the sandbox environment.

```ruby
module VendorAPI
  VERSION = '1.2'.freeze # This is the highest version accessible in Sandbox

  VERSIONS = {
   '1.0' => [...], # Versions equal to or below the current version, without the 'pre', will be accessible in all environments
   '1.1' => [...],
   '1.2pre' => [ # The 'pre' here is necessary to prevent this version from being exposed in production
     Changes::AddDateToInterview,
     Changes::DeleteNote,
     Changes::CreateFeedback,
     Changes::UpdateFeedback,
     Changes::AddFeedbackToApplication,
     Changes::AddMetaToApplication,
   ],
   '1.3' => [] # This version will only be accessible in development environments
  }
end
```

Requests that are sent to the current pre-release version do not need to include `pre` in their version number e.g. `http://localhost:3000/api/v1.2/applications?since=2021-10-01`

## Releasing a new version to Production

To expose a version in Production (and all other environments as well), in `app/lib/vendor_api.rb` the `pre` needs to be removed from the required version, and the `VERSION` needs to be greater than or equal to the required version.

```ruby
module VendorAPI
  VERSION = '1.2'.freeze # This is the highest version accessible in Production

  VERSIONS = {
   '1.0' => [...],
   '1.1' => [...],
   '1.2' => [ # This and all prior versions without a 'pre' tag will be exposed in Production
     Changes::AddDateToInterview,
     Changes::DeleteNote,
     Changes::CreateFeedback,
     Changes::UpdateFeedback,
     Changes::AddFeedbackToApplication,
   ],
   '1.3' => [], # This version will only be accessible in development environments
  }
end
```

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

## Resources

- [Vendor API version information](../app/lib/vendor_api.rb)
- [Vendor API version change classes](../app/lib/vendor_api/changes)
- [API Presenter base class](../app/presenters/vendor_api/base.rb)
