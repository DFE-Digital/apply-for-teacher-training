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
      provider_name = course.provider_name || provider.name
      provider_name = Provider.find(course.accredited_provider_id).name if course.provider_id != course.accredited_provider_id
      provider_name
    end
  end
end
