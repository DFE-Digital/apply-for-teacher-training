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
    [:provider_information_banner, 'Displays an information banner for providers on the start page and applications page', 'Apply team'],
    [:deadline_notices, 'Show candidates copy related to end of cycle deadlines', 'Apply team'],
    [:export_hesa_data, 'Providers can export applications including HESA data.', 'Apply team'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:provider_activity_log, 'Show provider users a log of all application activity', 'Michael Nacos'],
    [:export_application_data, 'Providers can export a customised selection of application data', 'Ben Swannack'],
    [:interviews, 'Providers can filter applications by interviewing state', 'Despo Pentara'],
    [:restructured_work_history, 'Candidates use the new design for the Work History section', 'David Gisbey'],
    [:structured_reasons_for_rejection_on_rbd, 'Allows providers to give specific feedback for applications rejected by default', 'Aga Dufrat'],
    [:updated_offer_flow, 'Activates the new make offer flow for providers', 'Despo Pentara'],
    [:unconditional_offers_via_api, 'Activates the ability to accept unconditional offers via the API', 'Steve Laing'],
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
