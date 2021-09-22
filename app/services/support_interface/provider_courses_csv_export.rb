module SupportInterface
  class ProviderCoursesCSVExport
    def initialize(provider:)
      @provider = provider
    end

    def rows
      course_options.map do |co|
        {
          recruitment_cycle_year: co.course.recruitment_cycle_year,
          name: co.course.name,
          code: co.course.code,
          study_mode: co.study_mode,
          site_name: co.site.name,
          site_code: co.site.code,
          provider_code: co.course.provider.code,
          provider_name: co.course.provider.name,
          accredited_provider_name: co.course.accredited_provider&.name,
          accredited_provider_code: co.course.accredited_provider&.code,
        }
      end
    end

  private

    def course_options
      @provider.courses.current_cycle.or(
        @provider.accredited_courses.current_cycle,
      ).includes(:provider, :accredited_provider, course_options: [:site]).flat_map(&:course_options)
    end
  end
end
