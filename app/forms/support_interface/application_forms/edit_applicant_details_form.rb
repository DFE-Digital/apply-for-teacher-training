module SupportInterface
  module ApplicationForms
    class EditApplicantDetailsForm
      include ActiveModel::Model

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :phone_number
      attr_accessor :audit_comment
      attr_reader :application_form

      validates :phone_number, presence: true, phone_number: true
      validates :first_name, presence: true
      validates :last_name, presence: true

      def initialize(application_form)
        @application_form = application_form

        super(
          first_name: @application_form.first_name,
          last_name: @application_form.last_name,
          phone_number: @application_form.phone_number
        )
      end

      def save!
        @application_form.first_name = first_name
        @application_form.last_name = last_name
        @application_form.phone_number = phone_number
        @application_form.audit_comment = audit_comment
        @application_form.save!
      end
    end
  end
end
