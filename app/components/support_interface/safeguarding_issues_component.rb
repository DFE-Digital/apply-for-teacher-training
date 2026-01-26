module SupportInterface
  class SafeguardingIssuesComponent < ViewComponent::Base
    attr_reader :message

    def initialize(application_form:)
      @application_form = application_form
      @message = SafeguardingStatus.new(
        status: application_form.safeguarding_issues_status,
        i18n_key: 'support_interface.safeguarding_issues_component',
      ).message
    end

    def previous_training_record
      @previous_training_record ||= @application_form.published_previous_teacher_trainings.sample
    end
  end
end
