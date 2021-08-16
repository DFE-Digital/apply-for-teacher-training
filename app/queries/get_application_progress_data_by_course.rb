class GetApplicationProgressDataByCourse
  attr_reader :provider

  def initialize(provider:)
    @provider = provider
  end

  def call
    Course.joins(:application_choices).merge(provider_application_choices).left_joins(:accredited_provider)
      .group('courses.id', 'courses.name', 'courses.code', 'application_choices.status', 'providers.name')
      .select('courses.provider_id', 'courses.accredited_provider_id', 'providers.name as provider_name', 'courses.name', 'courses.code', "count('application_choices.status') as count", 'application_choices.status as status', 'courses.id')
  end

  def provider_application_choices
    ApplicationChoice.joins(:course)
      .where(status: %i[awaiting_provider_decision interviewing offer pending_conditions recruited])
      .where(course: { provider_id: provider.id })
      .or(ApplicationChoice.joins(:course).where(course: { accredited_provider_id: provider.id }))
      .where(course: { recruitment_cycle_year: RecruitmentCycle.current_year })
  end
end
