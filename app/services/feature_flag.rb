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
    [:banner_about_problems_with_dfe_sign_in, 'Displays a banner to notify users that DfE-Sign is having problems', 'Jake Benilov'],
    [:banner_for_ucas_downtime, 'Displays a banner to notify users that UCAS is having problems', 'Theodor Vararu'],
    [:covid_19, 'Alters deadlines and displays an information banner related to our response to Covid-19', 'Theodor Vararu'],
    [:dfe_sign_in_fallback, 'Use this when DfE Sign-in is down', 'Tijmen Brommet'],
    [:force_ok_computer_to_fail, 'OK Computer implements a health check endpoint, this flag forces it to fail for testing purposes', 'Michael Nacos'],
    [:pilot_open, 'Enables the Apply for Teacher Training service', 'Tijmen Brommet'],
    [:summer_recruitment_banner, 'Displays an information banner related to RBD during the summer months', 'Michael Nacos'],
    [:getting_ready_for_next_cycle_banner, 'Displays an information banner related to 2020 end-of-cycle with link to static page', 'Steve Hook'],
    [:switch_to_2021_recruitment_cycle, 'Sync and serve courses for the 2021 recruitment cycle. DO NOT ENABLE IN PRODUCTION.', 'Duncan Brown'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:providers_can_manage_users_and_permissions, 'Allows provider users to invite other provider users, and allows providers to manage other users permissions to do make decisions, view safeguarding, and add other users', 'Tijmen Brommet'],
    [:provider_change_response, 'Allows providers to change the course that they are offering to a candidate', 'Michael Nacos'],
    [:provider_view_safeguarding, 'Allows providers to see whether a candidate has declared safeguarding issues', 'Will McBrien'],
    [:enforce_provider_to_provider_permissions, 'Provider-to-provider permissions affect what provider users can see and do', 'Duncan Brown'],
    [:unavailable_course_option_warnings, 'Warns candidates at submission time if a course has become unavailable since they originally chose it', 'Malcolm Baig'],
    [:track_validation_errors, 'Captures validation errors triggered by candidates so that they can be reviewed by support staff', 'Steve Hook'],
    [:apply_again, 'Enables unsuccessful candidates to reapply, AKA Apply 2', 'Steve Hook'],
    [:replace_full_or_withdrawn_application_choices, 'Allows candidates to replace full or withdrawn application choices post-submission', 'David Gisbey'],
    [:unavailable_course_notifications, 'Candidates with applications waiting for references receive an email notification if their course choice is withdrawn has no vacancies', 'Steve Hook'],
    [:hesa_degree_data, 'Use structured HESA data to autocomplete certain parts of the add degree flow', 'Malcolm Baig'],
    [:international_addresses, 'Candidates who live outside the UK can enter their local address in free-text format', 'Steve Hook'],
    [:international_personal_details, 'Changes to the candidate personal details section to account for international applicants.', 'David Gisbey'],
    [:efl_section, 'Allow candidates with nationalities other then British or Irish to specify their English as a Foreign Language experience', 'Malcolm Baig'],
    [:international_degrees, 'Changes to the model and forms for degree qualifications to cater for non-UK degrees.', 'Steve Hook'],
    [:international_gcses, 'Candidates can provide details of international GCSE equivalents.', 'George Holborn'],
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

  def self.reset!
    return if Rails.env.production?

    Feature.update_all(active: false)
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active
    feature.save!
  end
end
