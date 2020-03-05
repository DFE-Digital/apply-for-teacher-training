class FeatureFlag
  FEATURES = %w[
    application_withrawn_provider_email
    automated_decline_by_default_candidate_chaser
    automated_provider_chaser
    automated_referee_chaser
    automated_referee_replacement
    candidate_rejected_by_provider_email
    choose_study_mode
    confirm_conditions
    decline_by_default_notification_to_candidate
    decline_by_default_notification_to_provider
    dfe_sign_in_incident
    edit_application
    equality_and_diversity
    experimental_api_features
    force_ok_computer_to_fail
    improved_expired_token_flow
    notify_candidate_of_new_reference
    offer_accepted_provider_emails
    offer_declined_provider_emails
    pilot_open
    provider_application_filters
    provider_change_response
    send_dfe_sign_in_invitations
    send_reference_confirmation_email
    show_new_referee_needed
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
