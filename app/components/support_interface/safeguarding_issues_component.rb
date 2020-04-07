module SupportInterface
  class SafeguardingIssuesComponent < ActionView::Component::Base
    attr_reader :safeguarding_status

    def initialize(application_form:)
      @safeguarding_status = SafeguardingStatus.new(
        application_form: application_form,
        i18n_key: 'support_interface.safeguarding_issues_component',
      )
    end

    def message
      safeguarding_status.message
    end
  end
end
