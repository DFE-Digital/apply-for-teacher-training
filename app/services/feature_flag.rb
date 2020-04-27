class FeatureFlag
  PERMANENT_SETTINGS = %w[
    banner_about_problems_with_dfe_sign_in
    banner_for_ucas_downtime
    covid_19
    force_ok_computer_to_fail
    pilot_open
  ].freeze

  TEMPORARY_FEATURE_FLAGS = %w[
    candidate_can_cancel_reference
    confirm_conditions
    download_dataset1_from_support_page
    edit_course_choices
    equality_and_diversity
    notes
    provider_add_provider_users
    provider_application_filters
    provider_change_response
    provider_interface_work_breaks
    provider_view_safeguarding
    suitability_to_work_with_children
    support_sign_in_confirmation_email
    timeline
    unavailable_course_option_warnings
    work_breaks
    track_validation_errors
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).freeze

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
