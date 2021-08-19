module ProviderInterface
  class ActiveApplicationStatusesByProvider
    include DataForActiveApplicationsStatuses

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
  end
end
