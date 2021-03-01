class GetChangeOfferOptions
  attr_accessor :user, :ratifying_provider, :recruitment_cycle_year

  def initialize(user:, ratifying_provider:, recruitment_cycle_year:)
    @user = user
    @ratifying_provider = ratifying_provider
    @recruitment_cycle_year = recruitment_cycle_year
  end

  def actionable_courses
    courses_with_org_permission_joins = Course
      .joins(training_provider_make_decisions)
      .joins(ratifying_provider_make_decisions)

    same_year_open_courses_with_make_decisions = courses_with_org_permission_joins
      .where(combine_user_and_provider_permissions)
      .where(
        open_on_apply: true,
        recruitment_cycle_year: recruitment_cycle_year,
      )

    same_year_open_courses_with_make_decisions.where(accredited_provider: ratifying_provider)
  end

  def available_providers
    Provider
      .with(actionable_courses: actionable_courses)
      .joins('INNER JOIN actionable_courses ON providers.id = actionable_courses.provider_id')
      .distinct
  end

private

  def permitted_provider_ids
    user.provider_permissions.where(make_decisions: true).pluck(:provider_id)
  end

  def provider_relationship_permissions_sql(join_name, additional_checks)
    <<~PROVIDER_RELATIONSHIP_PERMISSIONS.squish
      LEFT OUTER JOIN provider_relationship_permissions AS #{join_name}
        ON provider_id = #{join_name}.training_provider_id
        AND accredited_provider_id = #{join_name}.ratifying_provider_id
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
        provider_id IN (#{permitted_provider_ids.join(',')}) AND
        (
          accredited_provider_id IS NULL
          OR training_provider_make_decisions.id IS NOT NULL
        )
      ) OR
      (
        accredited_provider_id IN (#{permitted_provider_ids.join(',')}) AND
        ratifying_provider_make_decisions.id IS NOT NULL
      )
    COMBINE_USER_AND_PROVIDER_PERMISSIONS
  end
end
