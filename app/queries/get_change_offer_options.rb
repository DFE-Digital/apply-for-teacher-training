class GetChangeOfferOptions
  attr_accessor :user, :accredited_provider, :recruitment_cycle_year

  def initialize(user:, current_course:)
    @user = user
    @accredited_provider = current_course.accredited_provider || current_course.provider
    @recruitment_cycle_year = current_course.recruitment_cycle_year
  end

  def make_decisions_courses
    Course
      .joins(training_provider_make_decisions)
      .joins(ratifying_provider_make_decisions)
      .where(combine_user_and_provider_permissions)
  end

  def offerable_courses
    make_decisions_courses
      .where(
        open_on_apply: true,
        recruitment_cycle_year: recruitment_cycle_year,
      )
      .where(ratifying_provider_is_preserved)
  end

  def available_providers
    Provider
      .with(offerable_courses: offerable_courses)
      .joins('INNER JOIN offerable_courses ON providers.id = offerable_courses.provider_id')
      .group('providers.id')
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
    return '1 != 1' if permitted_provider_ids.blank? # valid SQL which returns no results

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

  def ratifying_provider_is_preserved
    # accredited_provider_id is nil for self-ratified courses
    <<~RATIFYING_PROVIDER_IS_PRESERVED
      (provider_id = #{accredited_provider.id} AND accredited_provider_id IS NULL)
      OR accredited_provider_id = #{accredited_provider.id}
    RATIFYING_PROVIDER_IS_PRESERVED
  end
end
