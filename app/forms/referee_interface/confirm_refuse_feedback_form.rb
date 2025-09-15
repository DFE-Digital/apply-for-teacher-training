module RefereeInterface
  class ConfirmRefuseFeedbackForm
    include ActiveModel::Model

    def save(reference)
      ApplicationForm.with_unsafe_application_choice_touches do
        reference.update!(feedback_status: :feedback_refused, feedback_refused_at: Time.zone.now)
      end
      SendNewRefereeRequestEmail.call(reference:, reason: :refused)
    end
  end
end
