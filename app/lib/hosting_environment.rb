module HostingEnvironment
  def self.application_url
    if Rails.env.production?
      "https://#{hostname}"
    else
      'http://localhost:3000'
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
      'beta'
    else
      environment_name
    end
  end

  def self.phase_banner_text
    if sandbox?
      return 'This is a <a href="/">test version of Apply</a> for providers and software vendors'.html_safe
    end

    case environment_name
    when 'production'
      'This is a new service - <a href="mailto:becomingateacher@digital.education.gov.uk?subject=Apply+feedback" class="govuk-link">give feedback or report a problem</a>'.html_safe
    when 'qa'
      'This is the QA version of the Apply service'
    when 'staging'
      'This is a internal environment used by DfE to test deploys'
    when 'development'
      'This is a development version of the Apply service'
    when 'review'
      'This is a review environment used to test a pull request'
    when 'unknown-environment'
      'This is a unknown version of the Apply service'
    end
  end

  def self.environment_name
    ENV.fetch('HOSTING_ENVIRONMENT_NAME', 'unknown-environment')
  end

  def self.review?
    environment_name == 'review'
  end

  def self.qa?
    environment_name == 'qa'
  end

  def self.production?
    environment_name == 'production'
  end

  def self.sandbox?
    ENV.fetch('SANDBOX', 'false') == 'true'
  end
end
