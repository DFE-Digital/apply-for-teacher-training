module ProviderInterface
  class ActiveApplicationStatusesByProvider
    attr_reader :provider

    def initialize(provider)
      @provider = provider
    end

    def call
      grouped_course_data.map do |course_data|
        courses = course_data.last
        {
          header: courses.first.name_and_code,
          subheader: provider_name(courses.first),
          values: [status_count(courses, :awaiting_provider_decision),
                   status_count(courses, :interviewing),
                   status_count(courses, :offer),
                   status_count(courses, :pending_conditions),
                   status_count(courses, :recruited)],
        }
      end
    end

  private

    def grouped_course_data
      @course_data ||= GetApplicationProgressDataByCourse.new(provider: provider).call.group_by(&:id)
    end

    def status_count(courses, status)
      courses.find { |course| course.status == status.to_s }&.count || 0
    end

    def provider_name(course)
      accredited_by_different_provider?(course) ? course.accredited_provider_name : course.provider_name
    end

    def accredited_by_different_provider?(course)
      course.accredited_provider_id && provider.id == course.provider_id && course.provider_id != course.accredited_provider_id
    end
  end
end
