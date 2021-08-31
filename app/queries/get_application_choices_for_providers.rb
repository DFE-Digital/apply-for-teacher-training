class GetApplicationChoicesForProviders
  DEFAULT_INCLUDES = [
    :accredited_provider,
    :current_course_option,
    :provider,
    :site,
    {
      application_form: %i[candidate application_references application_work_experiences application_volunteering_experiences application_qualifications application_work_history_breaks],
      course: %i[provider accredited_provider],
      course_option: [{ course: %i[provider] }, :site],
    },
  ].freeze

  def self.call(providers:, vendor_api: false, includes: DEFAULT_INCLUDES, recruitment_cycle_year: RecruitmentCycle.years_visible_to_providers)
    raise MissingProvider if providers.blank? # super important!

    provider_ids = providers.map(&:id)
    statuses = vendor_api ? ApplicationStateChange.states_visible_to_provider_without_deferred : ApplicationStateChange.states_visible_to_provider

    ApplicationChoice
      .where(provider_ids_check(provider_ids))
      .where(current_recruitment_cycle_year: recruitment_cycle_year)
      .where(status: statuses)
      .includes(*includes)
  end

  def self.provider_ids_check(provider_ids)
    combine_with_or(
      provider_ids.map { |id| id_in_provider_ids(id) },
    )
  end

  def self.id_in_provider_ids(provider_id)
    Arel::Nodes::Contains.new(
      ApplicationChoice.arel_table[:provider_ids],
      Arel::Nodes.build_quoted("{#{provider_id}}"),
    )
  end

  def self.combine_with_or(conditions)
    conditions.drop(1).inject(conditions[0]) { |a, b| a.or(b) }
  end
end
