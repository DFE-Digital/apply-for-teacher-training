class FeatureFlag
  attr_accessor :name, :description, :owner

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
  end

  def feature
    Feature.find_or_initialize_by(name: name)
  end

  PERMANENT_SETTINGS = [
    [:banner_for_ucas_downtime, 'Displays a banner to notify users that UCAS is having problems', 'Apply team'],
    [:dfe_sign_in_fallback, 'Use this when DfE Sign-in is down', 'Apply team'],
    [:force_ok_computer_to_fail, 'OK Computer implements a health check endpoint, this flag forces it to fail for testing purposes', 'Apply team'],
    [:pilot_open, 'Enables the Apply for Teacher Training service', 'Apply team'],
    [:service_information_banner, 'Displays an information banner for both providers and candidates. Text configured in service_information_banner.yml', 'Apply team'],
    [:deadline_notices, 'Show candidates copy related to end of cycle deadlines', 'Apply team'],
    [:export_hesa_data, 'Providers can export applications including HESA data.', 'Apply team'],
    [:service_unavailable_page, 'Displays a maintenance page on the whole application', 'Apply team'],
    [:send_request_data_to_bigquery, 'Send request data to Google Bigquery via background worker', 'Apply team'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:provider_activity_log, 'Show provider users a log of all application activity', 'Michael Nacos'],
    [:export_application_data, 'Providers can export a customised selection of application data', 'Ben Swannack'],
    [:restructured_work_history, 'Candidates use the new design for the Work History section', 'David Gisbey'],
    [:unconditional_offers_via_api, 'Activates the ability to accept unconditional offers via the API', 'Steve Laing'],
    [:content_security_policy, 'Enables the content security policy declared in `config/initializers/content_security_policy.rb`', 'Steve Hook'],
    [:support_user_reinstate_offer, 'Allows a support users to reinstate a declined course choice offer', 'James Glenn'],
    [:expanded_quals_export, 'Rework the Qualifications export to contain all candidate qualifications', 'Malcolm Baig'],
    [:support_user_change_offered_course, 'Allows support users to offer a different course option for an application choice', 'David Gisbey'],
    [:reference_selection, 'Allow candidates to receive multiple references and then select which two are added to their application', 'Malcolm Baig'],
    [:new_provider_user_flow, 'New flow for creating or updating a single ProviderUser and adding Provider users in bulk', 'Toby Retallick'],
    [:individual_offer_conditions, 'Enables individual offer condition management', 'Despo Pentara'],
    [:withdraw_at_candidates_request, "Allows providers to withdraw an application at the candidate's request", 'Steve Laing'],
    [:summer_recruitment_banner, 'Show a banner to indicate a shorter recruitment timeframe during summer', 'Richard Pattinson'],
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).map { |name, description, owner|
    [name, FeatureFlag.new(name: name, description: description, owner: owner)]
  }.to_h.with_indifferent_access.freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, true)
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, false)
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    FEATURES[feature_name].feature.active?
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active
    feature.save!
  end
end
