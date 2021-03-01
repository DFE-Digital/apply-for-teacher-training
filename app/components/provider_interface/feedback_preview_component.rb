module ProviderInterface
  class FeedbackPreviewComponent < SummaryListComponent
    include ViewHelper

    attr_reader :rejection_reason

    def initialize(application_choice:, rejection_reason: nil)
      @application_choice = application_choice
      @rejection_reason = rejection_reason
      @rejection_reason ||= application_choice.rejection_reason
    end

    def rows
      feedback_row = {
        key: 'Feedback for candidate',
        value: rejection_reason,
      }

      if @application_choice.rejected_by_default
        feedback_row[:change_path] = change_feedback_path
        feedback_row[:action] = 'feedback for candidate'
      end

      [feedback_row]
    end

    def change_feedback_path
      Rails.application.routes.url_helpers.provider_interface_application_choice_new_rbd_feedback_path(
        @application_choice.id,
        provider_interface_rejected_by_default_feedback_form: { rejection_reason: rejection_reason },
      )
    end
  end
end
