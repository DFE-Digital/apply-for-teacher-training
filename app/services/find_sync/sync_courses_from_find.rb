module FindSync
  class SyncCoursesFromFind
    attr_reader :provider

    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_id, provider_recruitment_cycle_year)
      @provider = Provider.find(provider_id)
      @provider_recruitment_cycle_year = provider_recruitment_cycle_year

      find_provider.courses.each do |find_course|
        update_course(find_course)
      end
    rescue JsonApiClient::Errors::ApiError
      raise FindSync::SyncError
    end

  private

    def find_provider
      # https://api.publish-teacher-training-courses.service.gov.uk/api/v3/recruitment_cycles/2021/providers/1N1/?include=courses.subjects
      @find_provider ||= begin
        FindAPI::Provider
          .recruitment_cycle(@provider_recruitment_cycle_year)
          .includes(courses: [:subjects])
          .find(provider.code)
          .first
      end
    end

    # As we’re augmenting existing data, don’t create fresh incomplete courses,
    # only update those that already exist
    def update_course(find_course)
      course = provider.courses.find_by(
        code: find_course.code,
        recruitment_cycle_year: @provider_recruitment_cycle_year,
      )
      course.update!(subject_codes: find_course.subject_codes) if course
    end
  end
end
