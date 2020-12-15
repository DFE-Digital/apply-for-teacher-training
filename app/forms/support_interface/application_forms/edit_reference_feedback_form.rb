module SupportInterface
  module ApplicationForms
    class EditReferenceFeedbackForm
      include ActiveModel::Model

      attr_accessor :feedback, :audit_comment, :send_emails

      validates :feedback, presence: true, word_count: { maximum: 500 }
      validates :audit_comment, presence: true

      def self.build_from_reference(reference)
        new(feedback: reference.feedback)
      end

      def save(reference)
        return false unless valid?

        reference.update!(
          feedback: feedback,
          audit_comment: audit_comment,
        )
      end
    end
  end
end
