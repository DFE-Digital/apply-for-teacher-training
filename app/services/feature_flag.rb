class FeatureFlag
  attr_accessor :name, :description, :owner, :type

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
    self.type =  VARIANT_FEATURES.include?(name.to_sym) ? 'variant' : 'invariant'
  end

  def feature
    Feature.find_or_initialize_by(name:)
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
    [:unlock_application_for_editing, 'Allow the candidate to make edits to their application form post submission', 'Find and Apply team'],
    [:monthly_statistics_preview, 'Preview unpublished monthly statistics reports', 'Tomas'],
    [:draft_vendor_api_specification, 'The specification for upcoming vendor API releases', 'Abeer Salameh'],
    [:adviser_sign_up, 'Allow candidates to sign up for a teacher training adviser', 'Ross Oliver'],
    [:monthly_statistics_redirected, 'Redirect requests for Publications Monthly Statistics to temporarily unavailable', 'Iain McNulty'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:reference_nudges, 'Nudge emails for candidates that have incomplete references', 'Steve Hook'],
    [:sample_applications_factory, 'An alternate generator for test/sample applications, uses `SampleApplicationsFactory` in place of `TestApplications.new`', 'Elliot Crosby-McCullough + Tomas Destefi'],
    [:structured_reference_condition, 'Structured reference condition that can be added as a condition to an offer', 'Tomas Destefi'],
    [:continuous_applications, 'The new continuous applications flow', 'James Glenn'],
    [:teacher_degree_apprenticeship, 'The degree apprenticeship program', 'Tomas Destefi'],
    [:recruitment_performance_report, 'The new and improved mid-cycle report', 'Lori Bailey'],
    [:recruitment_performance_report_generator, 'Toggle the Recruitment Performance Report generation', 'Iain McNulty'],
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
    [name, FeatureFlag.new(name:, description:, owner:)]
  end.with_indifferent_access.freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, true)

    yield if block_given?
  ensure
    deactivate(feature_name) if block_given?
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, false)

    yield if block_given?
  ensure
    activate(feature_name) if block_given?
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
