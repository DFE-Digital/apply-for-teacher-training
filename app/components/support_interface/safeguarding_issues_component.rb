module SupportInterface
  class SafeguardingIssuesComponent < ApplicationComponent
    attr_reader :message

    def initialize(application_form:)
      @message = SafeguardingStatus.new(
        status: application_form.safeguarding_issues_status,
        i18n_key: 'support_interface.safeguarding_issues_component',
      ).message
    end
  end
end
