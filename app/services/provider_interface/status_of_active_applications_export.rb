module ProviderInterface
  class StatusOfActiveApplicationsExport
    include DataForActiveApplicationsStatuses

    attr_reader :provider

    def initialize(provider:)
      @provider = provider
    end

    def call
      data = grouped_course_data.inject([]) do |rows, course_data|
        courses = course_data.last
        rows << {
          name: courses.first.name,
          code: courses.first.code,
          partner_organisation: provider_name(courses.first),
          received: status_count(courses, :awaiting_provider_decision),
          interviewing: status_count(courses, :interviewing),
          offered: status_count(courses, :offer),
          awaiting_conditions: status_count(courses, :pending_conditions),
          pending_conditions: status_count(courses, :recruited),
        }
      end
      SafeCSV.generate(data.map(&:values), data.first.keys)
    end
  end
end
