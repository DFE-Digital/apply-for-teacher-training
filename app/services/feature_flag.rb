class FeatureFlag
  FEATURES = %w[
    choose_study_mode
    confirm_conditions
    dfe_sign_in_incident
    edit_application
    equality_and_diversity
    force_ok_computer_to_fail
    improved_expired_token_flow
    pilot_open
    provider_application_filters
    provider_change_response
    show_new_referee_needed
    suitability_to_work_with_children
    training_with_a_disability
    work_breaks
    you_selected_a_course_page
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
