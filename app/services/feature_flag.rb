class FeatureFlag
  FEATURES = %w[
    add_additional_courses_page
    banner_about_problems_with_dfe_sign_in
    banner_for_ucas_downtime
    candidate_can_cancel_reference
    create_account_or_sign_in_page
    covid_19
    check_full_courses
    confirm_conditions
    edit_application
    equality_and_diversity
    force_ok_computer_to_fail
    improved_expired_token_flow
    pilot_open
    prompt_for_additional_qualifications
    provider_application_filters
    provider_change_response
    provider_view_safeguarding
    suitability_to_work_with_children
    work_breaks
    before_you_start
    provider_interface_work_breaks
    referee_type
    replacement_referee_with_referee_type
    notes
    timeline
    edit_course_choices
    satisfaction_survey
    group_providers_by_region
    provider_add_provider_users
    unavailable_course_option_warnings
  ].freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    rollout.activate(feature_name)
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    rollout.deactivate(feature_name)
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    rollout.active?(feature_name)
  end

  def self.rollout
    @rollout ||= Rollout.new(Redis.current)
  end
end
