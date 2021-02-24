class GetChangeOfferOptions
  attr_accessor :application_choice, :user

  def initialize(application_choice:, user:)
    @application_choice = application_choice
    @user = user
  end

  def actionable_courses
    courses_with_org_permission_joins = Course
      .joins('INNER JOIN providers AS training_provider ON provider_id = training_provider.id')
      .joins('LEFT OUTER JOIN providers AS ratifying_provider ON accredited_provider_id = ratifying_provider.id')
      .joins(training_provider_make_decisions)
      .joins(ratifying_provider_make_decisions)

    courses_with_org_permission_joins
      .where(combine_user_and_provider_permissions)
      .where(
        open_on_apply: true,
        recruitment_cycle_year: application_choice.offered_course.recruitment_cycle_year,
      )
  end

  def available_providers
    Provider
      .with(actionable_courses: actionable_courses)
      .joins('INNER JOIN actionable_courses ON providers.id = actionable_courses.provider_id')
      .distinct
  end

  # GetChangeOfferOptions.new(application_choice: ..., user: ...).available_courses(provider: ...)
  def available_courses(provider:); end

  # GetChangeOfferOptions.new(application_choice: ..., user: ...).available_study_modes(course: ...)
  def available_study_modes(course:); end

  # GetChangeOfferOptions.new(application_choice: ..., user: ...).available_sites(course: ..., study_mode: ...)
  def available_sites(course:, study_mode:); end

private

  def permitted_provider_ids
    user.provider_permissions.where(make_decisions: true).pluck(:provider_id)
  end

  def provider_relationship_permissions_sql(join_name, additional_checks)
    <<~PROVIDER_RELATIONSHIP_PERMISSIONS.squish
      LEFT OUTER JOIN provider_relationship_permissions AS #{join_name}
        ON training_provider.id = #{join_name}.training_provider_id
        AND ratifying_provider.id = #{join_name}.ratifying_provider_id
        AND #{additional_checks}
    PROVIDER_RELATIONSHIP_PERMISSIONS
  end

  def training_provider_make_decisions
    check = 'training_provider_make_decisions.training_provider_can_make_decisions IS TRUE'
    provider_relationship_permissions_sql('training_provider_make_decisions', check)
  end

  def ratifying_provider_make_decisions
    check = 'ratifying_provider_make_decisions.ratifying_provider_can_make_decisions IS TRUE'
    provider_relationship_permissions_sql('ratifying_provider_make_decisions', check)
  end

  def combine_user_and_provider_permissions
    <<~COMBINE_USER_AND_PROVIDER_PERMISSIONS
      (
        training_provider.id IN (#{permitted_provider_ids.join(',')}) AND
        (
          ratifying_provider.id IS NULL
          OR training_provider_make_decisions.id IS NOT NULL
        )
      ) OR
      (
        ratifying_provider.id IN (#{permitted_provider_ids.join(',')}) AND
        ratifying_provider_make_decisions.id IS NOT NULL
      )
    COMBINE_USER_AND_PROVIDER_PERMISSIONS
  end
end
