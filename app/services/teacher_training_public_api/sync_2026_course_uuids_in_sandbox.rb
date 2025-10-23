module TeacherTrainingPublicAPI
  class Sync2026CourseUuidsInSandbox
    # This is a temporary job to fix a specific problem in sandbox. We can delete it after it is run.
    # It will enable the normal syncs to run again, so only updates the UUID, no other course data.

    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :low_priority

    def perform
      return unless HostingEnvironment.sandbox_mode?

      # In sandbox there are 420 providers with 2026 courses
      provider_codes = ::Provider
                         .joins(:courses)
                         .where('courses.recruitment_cycle_year': 2026)
                         .pluck(:code)

      provider_codes.each do |provider_code|
        Sync2026CourseUuidsInSandboxSecondaryWorker.perform_async(provider_code)
      end
    end
  end

  class Sync2026CourseUuidsInSandboxSecondaryWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_code)
      return unless HostingEnvironment.sandbox_mode?

      provider = ::Provider.find_by(code: provider_code)

      provider_courses_from_api = TeacherTrainingPublicAPI::Course.where(
        year: 2026,
        provider_code: provider_code,
      ).paginate(per_page: 500)

      provider_courses_from_api.each do |course_from_api|
        course = provider.courses.find_by(code: course_from_api.code, recruitment_cycle_year: 2026)
        return if course.blank?

        return if course.uuid == course_from_api.uuid

        course.update!(uuid: course_from_api.uuid)
      end
    end
  end
end
