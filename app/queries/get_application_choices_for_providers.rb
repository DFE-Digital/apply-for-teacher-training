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

  def self.call(
    providers:,
    exclude_deferrals: false,
    includes: DEFAULT_INCLUDES,
    recruitment_cycle_year: RecruitmentCycleTimetable.years_visible_to_providers
  )
    # It is very important to raise an error if no providers have been supplied
    # because otherwise Rails omits the provider_ids where clause
    # and all applications are returned
    raise MissingProviderError if providers.blank? || providers.any?(&:blank?)

    provider_ids = providers.map(&:id)
    statuses = exclude_deferrals ? ApplicationStateChange.states_visible_to_provider_without_deferred : ApplicationStateChange.states_visible_to_provider

    ApplicationChoice
      .where(provider_ids_check(provider_ids))
      .where(current_recruitment_cycle_year: recruitment_cycle_year)
      .where(status: statuses)
      .includes(*includes)
  end

  # The reason we use separate where clauses for each provider id and
  # combine them with ORs is that postgres doesn't support an ANY type
  # lookup for multiple inputs e.g. '{26, 9}' = ANY(provider_ids)
  # It allows checking that both '{26, 9}' exist in the provider_ids
  # of an application choice, but this is not what we want.
  def self.provider_ids_check(provider_ids)
    combine_with_or(
      provider_ids.map { |id| id_in_provider_ids(id) },
    )
  end

  # This is an Arel way of generating 'contains' where clauses
  # e.g. provider_ids @> '{26}'
  #
  # The alternative syntax 26 = ANY(provider_ids) is not supported by Arel
  # and couldn't use the GIN database index anyway
  #
  # Joining Arel constraints with .or is better than using ActiveRecord .or
  # clauses, which results in separate queries combined together. The result
  # of combining Arel constraints with .or can be fed to a single AR where
  # clause.
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
