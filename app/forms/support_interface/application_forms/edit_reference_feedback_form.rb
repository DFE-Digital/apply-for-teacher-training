module SupportInterface
  module ApplicationForms
    class EditReferenceFeedbackForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :feedback
      attr_accessor :audit_comment

      attr_reader :reference
      attr_reader :application_form

      validates :feedback, presence: true, word_count: { maximum: 500 }
      validates :audit_comment, presence: true

      def initialize(application_form, reference)
        @application_form = application_form
        @reference = reference

        super(feedback: @reference.feedback)
      end

      def save!
        @reference.update!(
          feedback: feedback,
          audit_comment: audit_comment,
        )
        SubmitReference.new(reference: @reference).save!
      end
    end
  end
end
