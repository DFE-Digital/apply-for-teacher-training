class FilterApplicationChoicesForProviders
  CANDIDATE_APPLICATION_NUMBER_REGEX = /^\d+$/.freeze

  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    combined_query = ApplicationChoice.includes(
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
        application_choices.joins(:application_form).where("CONCAT(first_name, ' ', last_name) ILIKE ?", "%#{candidates_name_or_number.squish}%")
      end
    end

    def recruitment_cycle_year(application_choices, years)
      return application_choices if years.blank?

      application_choices.where(course: { recruitment_cycle_year: years })
    end

    def status(application_choices, statuses)
      return application_choices if statuses.blank?

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

    def provider_location(application_choices, provider_location)
      return application_choices if provider_location.blank?

      name, code = provider_location[0].split('|')

      application_choices.where(site: { name: name, code: code })
    end

    def course_subject(application_choices, subject_ids)
      return application_choices unless subject_ids&.any?

      application_choices
        .where(course_subjects: { subject_id: subject_ids })
    end

    def study_mode(application_choices, study_mode)
      return application_choices if study_mode.blank?

      application_choices.where(current_course_option: { study_mode: study_mode })
    end

    def create_filter_query(application_choices, filters)
      filtered_application_choices = search(application_choices, filters[:candidate_name])
      filtered_application_choices = recruitment_cycle_year(filtered_application_choices, filters[:recruitment_cycle_year])
      filtered_application_choices = provider(filtered_application_choices, filters[:provider])
      filtered_application_choices = accredited_provider(filtered_application_choices, filters[:accredited_provider])
      filtered_application_choices = status(filtered_application_choices, filters[:status])
      filtered_application_choices = course_subject(filtered_application_choices, filters[:subject])
      filtered_application_choices = study_mode(filtered_application_choices, filters[:study_mode])
      provider_location(filtered_application_choices, filters[:provider_location])
    end
  end
end
