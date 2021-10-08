class FeatureFlag
  attr_accessor :name, :description, :owner, :type

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
    self.type =  VARIANT_FEATURES.include?(name.to_sym) ? 'variant' : 'invariant'
  end

  def feature
    Feature.find_or_initialize_by(name: name)
  end

  PERMANENT_SETTINGS = [
    [:dfe_sign_in_fallback, 'Use this when DfE Sign-in is down', 'Apply team'],
    [:force_ok_computer_to_fail, 'OK Computer implements a health check endpoint, this flag forces it to fail for testing purposes', 'Apply team'],
    [:pilot_open, 'Enables the Apply for Teacher Training service', 'Apply team'],
    [:service_information_banner, 'Displays an information banner for both providers and candidates. Text configured in service_information_banner.yml', 'Apply team'],
    [:deadline_notices, 'Show candidates copy related to end of cycle deadlines', 'Apply team'],
    [:service_unavailable_page, 'Displays a maintenance page on the whole application', 'Apply team'],
    [:send_request_data_to_bigquery, 'Send request data to Google Bigquery via background worker', 'Apply team'],
    [:enable_chat_support, 'Enable Zendesk chat support', 'Apply team'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:provider_activity_log, 'Show provider users a log of all application activity', 'Michael Nacos'],
    [:export_application_data, 'Providers can export a customised selection of application data', 'Ben Swannack'],
    [:unconditional_offers_via_api, 'Activates the ability to accept unconditional offers via the API', 'Steve Laing'],
    [:content_security_policy, 'Enables the content security policy declared in `config/initializers/content_security_policy.rb`', 'Steve Hook'],
    [:support_user_reinstate_offer, 'Allows a support users to reinstate a declined course choice offer', 'James Glenn'],
    [:expanded_quals_export, 'Rework the Qualifications export to contain all candidate qualifications', 'Malcolm Baig'],
    [:support_user_change_offered_course, 'Allows support users to offer a different course option for an application choice', 'David Gisbey'],
    [:withdraw_at_candidates_request, "Allows providers to withdraw an application at the candidate's request", 'Steve Laing'],
    [:summer_recruitment_banner, 'Show a banner to indicate a shorter recruitment timeframe during summer', 'Richard Pattinson'],
    [:restructured_immigration_status, 'New model for right to work and study in the UK to be released from 2022 cycle', 'Steve Hook'],
    [:block_fraudulent_submission, 'A button used on the fraud audit page to block submissions', 'James Glenn'],
  ].freeze

  CACHE_EXPIRES_IN = 1.day
  FEATURE_FLAG_STATUSES_CACHE_KEY = 'feature-flag-statuses'.freeze

  # Mark features as `variant` i.e. can be inconsistently marked as active/inactive
  # across environments and we won't be notified if inconsistent. All other features
  # will default to `invariant` which means they will need to be consistently marked
  # as active/inactive across all our environments, and we will be notified about otherwise.
  VARIANT_FEATURES = [
    :send_request_data_to_bigquery,
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).map do |name, description, owner|
    [name, FeatureFlag.new(name: name, description: description, owner: owner)]
  end.to_h.with_indifferent_access.freeze

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

    feature_statuses[feature_name].presence || false
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active

    clear_cache!
    feature.save!
  end

  def self.feature_statuses
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRES_IN) do
      Feature.where(name: FEATURES.keys).pluck(:name, :active).to_h.with_indifferent_access
    end
  end

  def self.cache_key
    CacheKey.generate(FEATURE_FLAG_STATUSES_CACHE_KEY)
  end

  def self.clear_cache!
    Rails.cache.delete(cache_key)
  end
end
