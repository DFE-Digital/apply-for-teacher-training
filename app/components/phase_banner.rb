class PhaseBanner < ViewComponent::Base
  DEFAULT_FEEDBACK_LINK = 'mailto:becomingateacher@digital.education.gov.uk?subject=Apply+feedback'.freeze

  def initialize(no_border: false, feedback_link: nil)
    @no_border = no_border
    @feedback_link = feedback_link
  end

  def text
    if HostingEnvironment.sandbox_mode?
      return 'This is a <a href="/" class="govuk-link">test version of Apply</a> for providers and software vendors'.html_safe
    end

    case HostingEnvironment.environment_name
    when 'production'
      "This is a new service - <a href='#{@feedback_link || DEFAULT_FEEDBACK_LINK}' class='govuk-link govuk-link--no-visited-state'>give feedback or report a problem</a>".html_safe
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

  def phase_tag_class
    return '' if HostingEnvironment.production?

    "govuk-tag--#{HostingEnvironment.phase_colour}"
  end
end
