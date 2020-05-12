class FeatureFlag
  attr_accessor :name, :description, :owner

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
  end

  PERMANENT_SETTINGS = [
    [:banner_about_problems_with_dfe_sign_in, '', ''],
    [:banner_for_ucas_downtime, '', ''],
    [:covid_19, '', ''],
    [:dfe_sign_in_fallback, '', ''],
    [:force_ok_computer_to_fail, '', ''],
    [:pilot_open, 'Enables the Apply for Teacher Training service', 'Theo'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:confirm_conditions, '', ''],
    [:download_dataset1_from_support_page, '', ''],
    [:notes, '', ''],
    [:provider_add_provider_users, '', ''],
    [:provider_application_filters, '', ''],
    [:provider_change_response, '', ''],
    [:provider_interface_work_breaks, '', ''],
    [:provider_view_safeguarding, '', ''],
    [:support_sign_in_confirmation_email, '', ''],
    [:timeline, '', ''],
    [:unavailable_course_option_warnings, '', ''],
    [:track_validation_errors, '', ''],
    [:apply_again, 'Enables unsuccessful candidates to reapply, AKA Apply 2', 'Steve Hook'],
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).map { |name, description, owner|
    [name, FeatureFlag.new(name: name, description: description, owner: owner)]
  }.to_h.with_indifferent_access.freeze

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
