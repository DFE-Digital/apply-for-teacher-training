module SupportInterface
  module ApplicationForms
    class EditReferenceForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :name
      attr_accessor :email_address
      attr_accessor :relationship
      attr_accessor :feedback
      attr_accessor :audit_comment

      attr_reader :reference
      attr_reader :application_form

      validates :name, presence: true, length: { minimum: 2, maximum: 200 }
      validates :email_address, presence: true, email_address: true, length: { maximum: 100 }
      validates :relationship, presence: true, word_count: { maximum: 50 }
      validates :feedback, presence: true, word_count: { maximum: 500 }
      validates :audit_comment, presence: true

      def initialize(application_form, reference)
        @application_form = application_form
        @reference = reference

        super(
          name: @reference.name,
          email_address: @reference.email_address,
          relationship: @reference.relationship,
          feedback: @reference.feedback,
        )
      end

      def save!
        @reference.update!(
          name: name,
          email_address: email_address,
          relationship: relationship,
          feedback: feedback,
          audit_comment: audit_comment,
          feedback_status: 'feedback_provided',
        )
      end
    end
  end
end
