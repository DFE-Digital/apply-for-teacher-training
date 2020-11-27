class GetApplicationChoicesForProviders
  DEFAULT_INCLUDES = [
    :accredited_provider,
    :offered_course_option,
    :provider,
    :site,
    application_form: %i[candidate application_references application_work_experiences application_volunteering_experiences application_qualifications],
    course: %i[provider],
    course_option: [{ course: %i[provider] }, :site],
  ].freeze

  def self.call(providers:, vendor_api: false, includes: DEFAULT_INCLUDES)
    providers = Array.wrap(providers).select(&:present?)

    raise MissingProvider if providers.none?

    statuses = vendor_api ? ApplicationStateChange.states_visible_to_provider_without_deferred : ApplicationStateChange.states_visible_to_provider

    provider_ids_string = providers.map(&:id).join(', ')

    ApplicationChoice.includes(*includes).from <<~GET_APPLICATION_CHOICES_FOR_PROVIDERS.squish
      (
        SELECT ac.*
          FROM application_choices ac
          INNER JOIN course_options co
                  ON co.id = COALESCE(ac.offered_course_option_id, ac.course_option_id)
          INNER JOIN courses c
                  ON co.course_id = c.id
          LEFT OUTER JOIN course_options original_co
                  ON original_co.id = ac.course_option_id
          LEFT OUTER JOIN courses original_c
                  ON original_co.course_id = original_c.id
          WHERE c.recruitment_cycle_year IN (#{RecruitmentCycle.years_visible_to_providers.join(', ')})
            AND ac.status IN (#{statuses.map { |s| "'#{s}'" }.join(', ')})
            AND (
              c.provider_id IN (#{provider_ids_string})
              OR c.accredited_provider_id IN (#{provider_ids_string})
              OR original_c.provider_id IN (#{provider_ids_string})
              OR original_c.accredited_provider_id IN (#{provider_ids_string})
            )
      ) AS application_choices
    GET_APPLICATION_CHOICES_FOR_PROVIDERS
  end
end
