module SupportInterface
  class TADProviderStatsExport
    def call
      data_for_export = courses.map do |course|
        choice_statuses = choice_statuses(course)

        {
          provider_id: nil,
          provider_code: course.provider.code,
          provider_name: course.provider.name,
          provider_type: nil,
          urn: nil,
          lead_school: nil,
          course_code: course.code,
          subject: course.name,
          applications: choice_statuses.count,
          offers: count_offers(choice_statuses),
          acceptances: count_acceptances(choice_statuses),
        }
      end

      data_for_export.sort_by { |row| row[:provider_code] }
    end

    alias_method :data_for_export, :call

  private

    def courses
      Course.includes(:provider)
    end

    def choice_statuses(course)
      ApplicationChoice
          .joins(:course)
          .where(courses: { id: course.id })
          .where('status IN (?)', ApplicationStateChange.states_visible_to_provider_without_deferred)
          .pluck(:status)
    end

    def count_offers(choice_statuses)
      choice_statuses.count { |status| ApplicationStateChange::OFFERED_STATES.include?(status.to_sym) }
    end

    def count_acceptances(choice_statuses)
      choice_statuses.count { |status| ApplicationStateChange::ACCEPTED_STATES.include?(status.to_sym) }
    end
  end
end
