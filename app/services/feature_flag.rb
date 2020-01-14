class FeatureFlag
  FEATURES = %w[
    pilot_open
    accept_and_decline_via_ui
    conditional_science_gcse
    candidate_withdrawals
    training_with_a_disability
    edit_application
    send_reference_email_via_support
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
