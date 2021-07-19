class PhaseBannerComponent < ViewComponent::Base
  DEFAULT_FEEDBACK_LINK = 'mailto:becomingateacher@digital.education.gov.uk?subject=Feedback%20about%20Apply%20for%20teacher%20training'.freeze

  def initialize(no_border: false, feedback_link: DEFAULT_FEEDBACK_LINK)
    @no_border = no_border
    @feedback_link = feedback_link
  end

  def text
    if HostingEnvironment.sandbox_mode?
      return "This is a #{govuk_link_to('test version of Apply', '/', class: 'govuk-link--no-visited-state')} for providers and software vendors".html_safe
    end

    case HostingEnvironment.environment_name
    when 'production'
      "This is a new service – #{govuk_link_to('give feedback or report a problem', @feedback_link, class: 'govuk-link--no-visited-state')}".html_safe
    when 'qa'
      'This is the QA version of the Apply service'
    when 'staging'
      'This is an internal environment used by DfE to test deploys'
    when 'development'
      'This is a development version of the Apply service'
    when 'review'
      'This is a review environment used to test a pull request'
    when 'research'
      'This is the user research environment for the Apply service'
    when 'load-test'
      'This is the user load-test environment for the Apply service'
    when 'unknown-environment'
      'This is a unknown version of the Apply service'
    end
  end
end
