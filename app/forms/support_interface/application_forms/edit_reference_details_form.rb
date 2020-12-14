module SupportInterface
  module ApplicationForms
    class EditReferenceDetailsForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :name
      attr_accessor :email_address
      attr_accessor :relationship
      attr_accessor :audit_comment

      attr_reader :reference
      attr_reader :application_form

      validates :name, presence: true, length: { minimum: 2, maximum: 200 }
      validates :email_address, presence: true, email_address: true, length: { maximum: 100 }
      validates :relationship, presence: true, word_count: { maximum: 50 }
      validates :audit_comment, presence: true

      def initialize(application_form, reference)
        @application_form = application_form
        @reference = reference

        super(
            name: @reference.name,
            email_address: @reference.email_address,
            relationship: @reference.relationship,
        )
      end

      def save!
        @reference.update!(
          name: name,
          email_address: email_address,
          relationship: relationship,
          audit_comment: audit_comment,
        )
      end
    end
  end
end
