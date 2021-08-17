class GetApplicationProgressDataByCourse
  attr_reader :provider

  def initialize(provider:)
    @provider = provider
  end

  def call
    Course.left_outer_joins(:application_choices)
      .joins(:provider)
      .left_joins(:accredited_provider)
      .where(recruitment_cycle_year: RecruitmentCycle.current_year, provider_id: provider.id)
      .or(Course.where(accredited_provider_id: provider.id))
      .group('courses.id', 'courses.name', 'courses.code', 'application_choices.status', 'providers.name', 'accredited_providers_courses.name')
      .select('courses.provider_id', 'courses.accredited_provider_id', 'providers.name as provider_name',
              'accredited_providers_courses.name as accredited_provider_name', 'courses.name', 'courses.code',
              "count('application_choices.status') as count", 'application_choices.status as status', 'courses.id').order(name: :asc, code: :asc)
  end

  def provider_application_choices
    ApplicationChoice.joins(:course)
      .where(status: %i[awaiting_provider_decision interviewing offer pending_conditions recruited])
  end
end
