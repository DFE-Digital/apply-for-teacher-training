module SupportInterface
  class SafeguardingIssuesComponent < ActionView::Component::Base
    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    HAS_DISCLOSED_MESSAGE = 'The candidate has shared information related to safeguarding.'.freeze
    NO_ANSWER_MESSAGE = 'Not answered.'.freeze
    NO_INFO_MESSAGE = 'No information shared.'.freeze

    def message
      if has_no_answer?
        NO_ANSWER_MESSAGE
      elsif has_disclosed_safeguarding_issues?
        HAS_DISCLOSED_MESSAGE
      else
        NO_INFO_MESSAGE
      end
    end

  private

    def has_disclosed_safeguarding_issues?
      @application_form.safeguarding_issues != 'No'
    end

    def has_no_answer?
      @application_form.safeguarding_issues.blank?
    end
  end
end
