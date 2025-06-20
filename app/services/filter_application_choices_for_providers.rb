class FilterApplicationChoicesForProviders
  CANDIDATE_APPLICATION_NUMBER_REGEX = /^\d+$/

  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    combined_query = ApplicationChoice.includes(
      :candidate,
      current_course_option: [
        :site,
        course: %i[provider accredited_provider course_subjects],
      ],
    )
    .with(supplied_choices: application_choices)
    .joins('INNER JOIN supplied_choices ON supplied_choices.id = application_choices.id')

    create_filter_query(combined_query, filters)
  end

  class << self
  private

    def search(application_choices, candidates_name_or_number)
      return application_choices if candidates_name_or_number.blank?

      candidate_application_number_match = candidates_name_or_number.strip.match(CANDIDATE_APPLICATION_NUMBER_REGEX)

      if candidate_application_number_match
        application_choices.where(id: candidate_application_number_match[0])
      else
        application_choices.joins(:application_form).where("CONCAT(application_forms.first_name, ' ', application_forms.last_name) ILIKE ?", "%#{candidates_name_or_number.squish}%")
      end
    end

    def invited_candidates(application_choices, invited_only, years)
      return application_choices if invited_only.blank?

      invites = Pool::Invite.published.where(
        provider_id: application_choices.pluck(:provider_ids).flatten.uniq,
        recruitment_cycle_year: years.presence || RecruitmentCycleTimetable.years_visible_to_providers,
      )

      application_choices.where('candidate.id': invites.pluck(:candidate_id))
    end

    def recruitment_cycle_year(application_choices, years)
      return application_choices if years.blank?

      application_choices.where(course: { recruitment_cycle_year: years })
    end

    def status(application_choices, statuses)
      return application_choices if statuses.blank?

      statuses.push('inactive') if statuses.include?('awaiting_provider_decision')

      application_choices.where(status: statuses)
    end

    def provider(application_choices, providers)
      return application_choices if providers.blank?

      application_choices
        .where(provider: { id: providers })
    end

    def accredited_provider(application_choices, accredited_providers)
      return application_choices if accredited_providers.blank?

      application_choices
        .where(accredited_provider: { id: accredited_providers })
    end

    def provider_location(application_choices, provider_locations)
      return application_choices if provider_locations.blank?

      query_string = provider_locations.map do |provider|
        provider_id, name, code = provider.split('_')
        "(#{ActiveRecord::Base.connection.quote(provider_id)},#{ActiveRecord::Base.connection.quote(name)},#{ActiveRecord::Base.connection.quote(code)})"
      end.join(',')

      application_choices.joins(:current_site).where(
        "(sites.provider_id, sites.name, sites.code) IN (#{ActiveRecord::Base.sanitize_sql(query_string)})",
      )
    end

    def course_subject(application_choices, subject_ids)
      return application_choices unless subject_ids&.any?

      application_choices
        .where(course_subjects: { subject_id: subject_ids })
    end

    def study_mode(application_choices, study_mode)
      return application_choices if study_mode.blank?

      application_choices.where(current_course_option: { study_mode: })
    end

    def hide_in_reporting(application_choices, hide_in_reporting)
      return application_choices if hide_in_reporting.nil?

      application_choices.where(candidate: { hide_in_reporting: })
    end

    def course_type(application_choices, course_type_filter)
      return application_choices if course_type_filter.blank? || all_course_types?(course_type_filter)

      if course_type_filter.include?(ProviderInterface::ProviderApplicationsFilter::TEACHER_DEGREE_APPRENTICESHIP_PARAM_NAME)
        application_choices.joins(:current_course).where(current_course: { program_type: 'TDA' })
      else
        application_choices.joins(:current_course).where.not(current_course: { program_type: 'TDA' })
      end
    end

    def all_course_types?(course_type_filter)
      course_type_filter.compact_blank.sort == [ProviderInterface::ProviderApplicationsFilter::POSTGRADUATE_PARAM_NAME, ProviderInterface::ProviderApplicationsFilter::TEACHER_DEGREE_APPRENTICESHIP_PARAM_NAME]
    end

    def create_filter_query(application_choices, filters)
      filtered_application_choices = search(application_choices, filters[:candidate_name])
      filtered_application_choices = invited_candidates(filtered_application_choices, filters[:invited_only], filters[:recruitment_cycle_year])
      filtered_application_choices = recruitment_cycle_year(filtered_application_choices, filters[:recruitment_cycle_year])
      filtered_application_choices = provider(filtered_application_choices, filters[:provider])
      filtered_application_choices = accredited_provider(filtered_application_choices, filters[:accredited_provider])
      filtered_application_choices = status(filtered_application_choices, filters[:status])
      filtered_application_choices = course_subject(filtered_application_choices, filters[:subject])
      filtered_application_choices = study_mode(filtered_application_choices, filters[:study_mode])
      filtered_application_choices = hide_in_reporting(filtered_application_choices, filters[:hide_in_reporting])
      filtered_application_choices = course_type(filtered_application_choices, filters[:course_type])
      provider_location(filtered_application_choices, filters[:provider_location])
    end
  end
end
