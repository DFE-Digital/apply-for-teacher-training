# Teacher Training API (TTAPI)


TTAPI is the public API on the Find and Publish repo. In this repo we populate the courses and providers within this application by fetching them from the find and publish repo.


### JsonApiClient

The TTAPI is modeled using the [JsonApiClient](https://github.com/JsonApiClient/json_api_client) gem. Each resource inherits from this and behaves very like ActiveRecord, allowing us to declare associations.

The API Client defines models each of which inherit from `JsonApiClient::Resource`. The API Client is encapsulated within the resources just like the database is encapsulated in `ActiveRecord`.

    module TeacherTrainingPublicAPI
      class Resource < JsonApiClient::Resource
        self.site = ENV.fetch('TEACHER_TRAINING_API_BASE_URL')


    module TeacherTrainingPublicAPI
      class RecruitmentCycle < TeacherTrainingPublicAPI::Resource


### Models

Below is a list of classes we use to model the API:

    ▼ 📂 models
        ▼ 📂 teacher_training_public_api
            💎 course.rb
            💎 location.rb
            💎 location_status.rb
            💎 provider.rb
            💎 recruitment_cycle.rb
            💎 resource.rb
            💎 subject.rb

### Schedule

The data is fetched from the TTAPI on a schedule using the `clock` gem. `clock` basically implements cron in ruby.

    # config/clock.rb

    # Every 10 minutes
    IncrementalSyncAllFromTeacherTrainingPublicAPI


    # Every 7 days
    FullSyncAllFromTeacherTrainingPublicAPI


### The Sync classes

These classes are responsible for using the JsonApi classes to make the request to the api. Currently, they also transform the api data into application data within the jobs.


    ▼ 📂 services
        ▼ 📂 teacher_training_public_api
            💎 assign_site_attributes.rb            # SiteMapper
            💎 full_sync_update_error.rb            # ErrorClass
            💎 sync_all_providers_and_courses.rb    # Sync Entry
            💎 sync_courses.rb                      # SidekiqWorker
            💎 sync_error.rb                        # ErrorClass
            💎 sync_provider.rb                     # Sync Entry
            💎 sync_sites.rb                        # SidekiqWorker
            💎 sync_subjects.rb                     # SidekiqWorker
            💎 trigger_full_sync_if_find_closed.rb  # Sync Entry

    ▼ 📂 workers
        ▼ 📂 teacher_training_public_api
            💎 sync_all_providers_and_courses_worker.rb


`SyncAllProvidersAndCourses`

There are a models backed by `ActiveRecord` tables in the application. When data is imported from the TTAPI we need to transform the data so it can be saved as the `ActiveRecord` classes in the application.
