module HostingEnvironment
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
    case environment_name
    when 'www'
      'This is a new service - <a href="mailto:becomingateacher@digital.education.gov.uk?subject=Apply+feedback" class="govuk-link">give feedback or report a problem</a>'.html_safe
    when 'qa'
      'This the QA version of the Apply service'
    when 'sandbox'
      'This is a demo environment for software vendors who integrate with our API'
    when 'staging'
      'This is a internal environment used by DfE to test deploys'
    when 'development'
      'This is a development version of the Apply service'
    end
  end

  def self.environment_name
    hostname = ENV['CUSTOM_HOSTNAME']
    if hostname
      hostname.split('.').first
    else
      'development'
    end
  end

  def self.production?
    environment_name == 'www'
  end
end
