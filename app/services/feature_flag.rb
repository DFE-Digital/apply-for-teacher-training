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
    [:service_information_banner, 'Displays an information banner for both providers and candidates. Text configured in service_information_banner.yml', 'Apply team'],
    [:deadline_notices, 'Show candidates copy related to end of cycle deadlines', 'Apply team'],
    [:service_unavailable_page, 'Displays a maintenance page on the whole application', 'Apply team'],
    [:send_request_data_to_bigquery, 'Send request data to Google Bigquery via background worker', 'Apply team'],
    [:enable_chat_support, 'Enable Zendesk chat support', 'Apply team'],
    [:lock_external_report_to_january_2022, 'Lock the current external report to January 2022', 'Apply team'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:provider_activity_log, 'Show provider users a log of all application activity', 'Michael Nacos'],
    [:export_application_data, 'Providers can export a customised selection of application data', 'Ben Swannack'],
    [:unconditional_offers_via_api, 'Activates the ability to accept unconditional offers via the API', 'Steve Laing'],
    [:support_user_reinstate_offer, 'Allows a support users to reinstate a declined course choice offer', 'James Glenn'],
    [:withdraw_at_candidates_request, "Allows providers to withdraw an application at the candidate's request", 'Steve Laing'],
    [:summer_recruitment_banner, 'Show a banner to indicate a shorter recruitment timeframe during summer', 'Richard Pattinson'],
    [:support_user_revert_withdrawn_offer, 'Allows a support user to revert an application withdrawn by the candidate', 'James Glenn'],
    [:draft_vendor_api_specification, 'The specification for Draft Vendor API v1.1', 'Abeer Salameh'],
    [:change_course_details_before_offer, 'Allows providers to change course choice details before the point of offer', 'James Glenn'],
    [:structured_reasons_for_rejection_redesign, 'Latest iteration of structured reasons for rejection', 'Steve Laing'],
    [:candidate_nudge_emails, 'Sends nudge emails to candidates that have unsubmitted but completed applications', 'Steve Hook'],
    [:new_degree_flow, 'Allows us to use the new degree flow', 'Jon Filar'],
    [:application_number_replacement, 'Replaces reference number and candidate ID with application choice ID', 'Carlos Martinez'],
    [:candidate_nudge_course_choice_and_personal_statement, 'Sends nudge emails to candidates that have zero course choices or did not marked the personal statement as complete', 'Tomas Destefi & Steve Hook'],
  ].freeze

  CACHE_EXPIRES_IN = 1.day
  FEATURE_FLAG_STATUSES_CACHE_KEY = 'feature-flag-statuses'.freeze

  # Mark features as `variant` i.e. can be inconsistently marked as active/inactive
  # across environments and we won't be notified if inconsistent. All other features
  # will default to `invariant` which means they will need to be consistently marked
  # as active/inactive across all our environments, and we will be notified about otherwise.
  VARIANT_FEATURES = %i[
    send_request_data_to_bigquery
    enable_chat_support
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).to_h do |name, description, owner|
    [name, FeatureFlag.new(name: name, description: description, owner: owner)]
  end.with_indifferent_access.freeze

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

  def self.inactive?(feature_name)
    !active?(feature_name)
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
