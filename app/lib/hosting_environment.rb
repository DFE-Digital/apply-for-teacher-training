module HostingEnvironment
  TEST_ENVIRONMENTS = %w[development test qa review].freeze
  PRODUCTION_URL = 'https://apply-for-teacher-training.service.gov.uk'.freeze
  ENVIRONMENT_COLOR = {
    development: 'grey',
    review: 'purple',
    qa: 'orange',
    staging: 'red',
    'unknown-environment': 'yellow',
  }.stringify_keys.freeze

  def self.application_url
    if Rails.env.production?
      "https://#{hostname}"
    else
      "http://localhost:#{ENV.fetch('PORT', 3000)}"
    end
  end

  def self.authorised_hosts
    ENV.fetch('AUTHORISED_HOSTS').split(',').map(&:strip)
  end

  def self.hostname
    ENV.fetch('CUSTOM_HOSTNAME', authorised_hosts.first)
  end

  def self.phase
    if production?
      'Beta'
    else
      environment_name.capitalize
    end
  end

  def self.phase_colour
    return 'purple' if HostingEnvironment.sandbox_mode?

    ENVIRONMENT_COLOR[HostingEnvironment.environment_name]
  end

  def self.environment_name
    ENV.fetch('HOSTING_ENVIRONMENT_NAME', 'unknown-environment')
  end

  def self.development?
    environment_name == 'development'
  end

  def self.qa?
    environment_name == 'qa'
  end

  def self.review?
    environment_name == 'review'
  end

  def self.staging?
    environment_name == 'staging'
  end

  def self.production?
    environment_name == 'production'
  end

  def self.loadtest?
    environment_name == 'loadtest'
  end

  def self.sandbox_mode?
    ENV.fetch('SANDBOX', 'false') == 'true'
  end

  def self.test_environment?
    TEST_ENVIRONMENTS.include?(HostingEnvironment.environment_name)
  end

  def self.workflow_testing?
    test_environment? || sandbox_mode?
  end

  def self.generate_test_data?
    qa? || development?
  end

  def self.dfe_signup_only?
    review? || qa? || staging?
  end
end
