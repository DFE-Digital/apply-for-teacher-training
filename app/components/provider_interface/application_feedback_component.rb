module ProviderInterface
  class ApplicationFeedbackComponent < ViewComponent::Base
    include ViewHelper
    include StatusBoxComponents::CourseRows

    attr_reader :application_choice

    def initialize(application_choice:, options: {})
      @application_choice = application_choice
      @options = options
    end

    def render?
      application_choice.rejected?
    end

    def rejected_rows
      if application_choice.rejected_by_default
        rows = [
          {
            key: 'Automatically rejected',
            value: application_choice.rejected_at.to_s(:govuk_date),
          },
        ]
        if application_choice.reject_by_default_feedback_sent_at.present?
          rows + [
            {
              key: 'Feedback sent',
              value: application_choice.reject_by_default_feedback_sent_at.to_s(:govuk_date),
            },
            {
              key: 'Feedback for candidate',
              value: application_choice.rejection_reason,
            },
          ]
        else
          rows
        end
      else
        [
          {
            key: 'Rejected',
            value: application_choice.rejected_at.to_s(:govuk_date),
          },
          {
            key: 'Feedback for candidate',
            value: application_choice.rejection_reason,
          },
        ]
      end
    end
  end
end
