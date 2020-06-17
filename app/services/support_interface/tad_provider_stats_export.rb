module SupportInterface
  class TADProviderStatsExport
    OFFERED_STATES = %w[offer enrolled recruited declined].freeze
    ACCEPTED_STATES = %w[recruited enrolled].freeze

    def call
      Course.all
        .map { |c| course_to_row(c) }
        .sort_by { |r| r[:provider_code] }
    end

  private

    def course_to_row(course)
      statuses = ApplicationChoice
                   .joins(:course)
                   .where(courses: { id: course.id })
                   .where('status IN (?)', ApplicationStateChange.states_visible_to_provider)
                   .pluck(:status)

      row_template = {
        provider_id: nil,
        provider_code: course.provider.code,
        provider: course.provider.name,
        provider_type: nil,
        urn: nil,
        lead_school: nil,
        subject: course.name,
        applications: statuses.count,
        offers: 0,
        acceptances: 0,
      }

      statuses.reduce(row_template) do |row, status|
        row[:offers] += 1 if OFFERED_STATES.include?(status)
        row[:acceptances] += 1 if ACCEPTED_STATES.include?(status)
        row
      end
    end
  end
end
