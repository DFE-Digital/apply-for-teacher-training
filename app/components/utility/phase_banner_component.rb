class PhaseBannerComponent < ApplicationComponent
  include ApplicationHelper

  DEFAULT_FEEDBACK_LINK = 'mailto:becomingateacher@digital.education.gov.uk?subject=Feedback%20about%20Apply%20for%20teacher%20training'.freeze

  def initialize(no_border: false, feedback_link: DEFAULT_FEEDBACK_LINK)
    @no_border = no_border
    @feedback_link = feedback_link
  end

  def text
    if HostingEnvironment.sandbox_mode?
      return "This is a #{govuk_link_to('test version of Apply', '/', no_visited_state: true)} for providers and software vendors".html_safe
    end

    case HostingEnvironment.environment_name
    when 'production', 'qa'
      if current_namespace == 'candidate_interface'
        govuk_link_to(t('layout.support_links.candidate_complaints'), candidate_interface_complaints_path, class: 'govuk-link--no-visited-state')
      else
        "This is a new service – your #{govuk_link_to('feedback', @feedback_link, class: 'govuk-link--no-visited-state')} will help us improve it".html_safe
      end
    when 'staging'
      'This is an internal environment used by DfE to test deploys'
    when 'development'
      'This is a development version of the Apply service'
    when 'review'
      'This is a review environment used to test a pull request'
    when 'unknown-environment'
      'This is a unknown version of the Apply service'
    end
  end
end
