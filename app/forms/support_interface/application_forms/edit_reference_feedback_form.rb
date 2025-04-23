module SupportInterface
  module ApplicationForms
    class EditReferenceFeedbackForm
      include ActiveModel::Model

      attr_accessor :feedback, :audit_comment, :send_emails, :confidential

      validates :confidential, presence: true
      validates :feedback, presence: true, word_count: { maximum: 500 }
      validates :audit_comment, presence: true
      validates :send_emails, presence: true

      def self.build_from_reference(reference)
        new(feedback: reference.feedback, confidential: reference.confidential)
      end

      def save(reference)
        return false unless valid?

        ApplicationForm.with_unsafe_application_choice_touches do
          reference.update!(
            feedback:,
            audit_comment:,
            confidential:,
          )
        end
      end
    end
  end
end
