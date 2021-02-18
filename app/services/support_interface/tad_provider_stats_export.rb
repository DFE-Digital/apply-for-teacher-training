module SupportInterface
  class TADProviderStatsExport
    def data_for_export(run_once_flag = false)
      Course
        .includes(:provider)
        .map { |c| course_to_row(c) break if run_once_flag }
        .sort_by { |r| r[:provider_code] }
    end

    # alias_method :data_for_export, :call

  private

    def course_to_row(course)
      statuses = ApplicationChoice
                   .joins(:course)
                   .where(courses: { id: course.id })
                   .where('status IN (?)', ApplicationStateChange.states_visible_to_provider_without_deferred)
                   .pluck(:status)

      row_template = {
        provider_id: nil,
        provider_code: course.provider.code,
        provider: course.provider.name,
        provider_type: nil,
        urn: nil,
        lead_school: nil,
        course_code: course.code,
        subject: course.name,
        applications: statuses.count,
        offers: 0,
        acceptances: 0,
      }

      statuses.reduce(row_template) do |row, status|
        row[:offers] += 1 if ApplicationStateChange::OFFERED_STATES.include?(status.to_sym)
        row[:acceptances] += 1 if ApplicationStateChange::ACCEPTED_STATES.include?(status.to_sym)
        row
      end
    end
  end
end
