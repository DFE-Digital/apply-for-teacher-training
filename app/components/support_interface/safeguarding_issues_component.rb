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
      @previous_training_record ||= @application_form.published_previous_teacher_training
    end

    def training_rows
      return [] if previous_training_record.blank?

      [
        {
          key: t('support_interface.safeguarding_issues_component.have_you_started'),
          value: previous_training_record.started.capitalize,
        },
        {
          key: t('support_interface.safeguarding_issues_component.name_of_training_provider'),
          value: previous_training_record.provider_name,
        },
        {
          key: t('support_interface.safeguarding_issues_component.training_dates'),
          value: previous_training_record.formatted_dates,
        },
        {
          key: t('support_interface.safeguarding_issues_component.details'),
          value: previous_training_record.details,
        },
      ].filter { |row| row[:value].present? }
    end
  end
end
