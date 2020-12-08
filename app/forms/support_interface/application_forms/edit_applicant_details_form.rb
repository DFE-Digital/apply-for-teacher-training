module SupportInterface
  module ApplicationForms
    class EditApplicantDetailsForm
      include ActiveModel::Model

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :day, :month, :year
      attr_accessor :phone_number
      attr_accessor :audit_comment
      attr_reader :application_form

      validates :first_name, presence: true
      validates :last_name, presence: true
      validates :date_of_birth, presence: true
      validates :phone_number, presence: true, phone_number: true

      def initialize(application_form)
        @application_form = application_form

        super(
          first_name: @application_form.first_name,
          last_name: @application_form.last_name,
          day: @application_form.date_of_birth&.day,
          month: @application_form.date_of_birth&.month,
          year: @application_form.date_of_birth&.year,
          phone_number: @application_form.phone_number
        )
      end

      def save!
        @application_form.first_name = first_name
        @application_form.last_name = last_name
        @application_form.date_of_birth = date_of_birth
        @application_form.phone_number = phone_number
        @application_form.audit_comment = audit_comment
        @application_form.save!
      end

      def date_of_birth
        date_args = [year, month, day].map(&:to_i)
        Date.new(*date_args)
      end
    end
  end
end
