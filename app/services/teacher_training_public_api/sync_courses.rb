module TeacherTrainingPublicAPI
  class SyncCourses
    attr_reader :provider

    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_id, recruitment_cycle_year)
      @provider = ::Provider.find(provider_id)

      TeacherTrainingPublicAPI::Course.where(
        year: recruitment_cycle_year,
        provider_code: @provider.code,
      ).paginate(per_page: 500).each do |course_from_api|
        update_course(course_from_api, recruitment_cycle_year)
      end
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

  private

    # As we’re augmenting existing data, don’t create fresh incomplete courses,
    # only update those that already exist
    def update_course(course_from_api, recruitment_cycle_year)
      course = provider.courses.find_by(
        code: course_from_api.code,
        recruitment_cycle_year: recruitment_cycle_year,
      )

      if course
        course.update!(
          program_type: course_from_api.program_type,
          qualifications: course_from_api.qualifications,
        )
      end
    end
  end
end
