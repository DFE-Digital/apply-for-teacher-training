module SupportInterface
  class SafeguardingIssuesComponent < ApplicationComponent
    attr_reader :message, :current_user

    def initialize(application_form:, current_user:)
      @application_form = application_form
      @current_user = current_user
      @message = SafeguardingStatus.new(
        status: application_form.safeguarding_issues_status,
        i18n_key: 'support_interface.safeguarding_issues_component',
      ).message
    end

    def previous_training_record
      @previous_training_record ||= @application_form.published_previous_teacher_trainings.sample
    end

    def yes_started_previous_teacher_trainings
      @yes_started_previous_training_record ||= @application_form.published_previous_teacher_trainings.started_yes
    end
  end
end
