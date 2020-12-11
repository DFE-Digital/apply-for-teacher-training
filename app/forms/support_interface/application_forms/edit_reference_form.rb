module SupportInterface
  module ApplicationForms
    class EditReferenceForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :name
      attr_accessor :email_address
      attr_accessor :feedback
      attr_accessor :relationship
      attr_accessor :audit_comment

      attr_reader :reference
      attr_reader :application_form

      validates :name, presence: true
      validates :email_address, presence: true
      validates :feedback, presence: true
      validates :relationship, presence: true
      validates :audit_comment, presence: true

      def initialize(application_form, reference)
        @application_form = application_form
        @reference = reference

        super(
          name: @reference.name,
          email_address: @reference.email_address,
          feedback: @reference.feedback,
          relationship: @reference.relationship,
        )
      end

      def save!
        @reference.update!(
          name: name,
          email_address: email_address,
          feedback: feedback,
          relationship: relationship,
          audit_comment: audit_comment,
        )
      end
    end
  end
end
