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
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:download_dataset1_from_support_page, 'Enables the application CSV download from the support interface', 'Al Davidson'],
    [:provider_add_provider_users, 'Allows provider users to invite other provider users', 'Steve Laing'],
    [:provider_change_response, 'Allows providers to change the course that they are offering to a candidate', 'Michael Nacos'],
    [:provider_interface_work_breaks, 'Adds work break information to the provider interface', 'Steve Hook'],
    [:provider_view_safeguarding, 'Allows providers to see whether a candidate has declared safeguarding issues', 'Will McBrien'],
    [:enforce_provider_to_provider_permissions, 'Provider-to-provider permissions affect what provider users can see and do', 'Duncan Brown'],
    [:unavailable_course_option_warnings, 'Warns candidates at submission time if a course has become unavailable since they originally chose it', 'Malcolm Baig'],
    [:track_validation_errors, 'Captures validation errors triggered by candidates so that they can be reviewed by support staff', 'Steve Hook'],
    [:apply_again, 'Enables unsuccessful candidates to reapply, AKA Apply 2', 'Steve Hook'],
    [:mark_every_section_complete, 'Each section of the application form should have to be explicitly completed', 'David Gisbey'],
    [:move_edit_by_to_application_form, 'Migrate edit_by from application_choices to application_form', 'David Gisbey'],
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
