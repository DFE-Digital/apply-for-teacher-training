class FeatureFlag
  FEATURES = %w[
    add_additional_courses_page
    banner_about_problems_with_dfe_sign_in
    banner_for_ucas_downtime
    create_account_or_sign_in_page
    covid_19
    display_additional_course_details
    check_full_courses
    confirm_conditions
    edit_application
    equality_and_diversity
    force_ok_computer_to_fail
    improved_expired_token_flow
    pilot_open
    provider_application_filters
    provider_change_response
    provider_view_safeguarding
    show_new_referee_needed
    suitability_to_work_with_children
    training_with_a_disability
    work_breaks
    you_selected_a_course_page
    before_you_start
    provider_interface_work_breaks
    referee_confirm_relationship_and_safeguarding
    referee_type
    replacement_referee_with_referee_type
    timeline
    edit_course_choices
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
