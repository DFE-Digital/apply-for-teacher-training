module SupportInterface
  module ApplicationForms
    class EditApplicantDetailsForm
      include ActiveModel::Model

      attr_accessor :first_name, :last_name, :email_address, :phone_number, :audit_comment,
                    :day, :month, :year
      attr_reader :application_form

      validates :first_name, :last_name, presence: true, length: { maximum: 60 }
      validates :email_address, presence: true, valid_for_notify: true, length: { maximum: 100 }
      validate :email_address_unique

      validates :date_of_birth, date: { presence: true, date_of_birth: true }
      validates :phone_number, presence: true, phone_number: true
      validates :audit_comment, presence: true

      def initialize(application_form)
        @application_form = application_form

        super(
          first_name: @application_form.first_name,
          last_name: @application_form.last_name,
          email_address: @application_form.candidate.email_address,
          day: @application_form.date_of_birth&.day,
          month: @application_form.date_of_birth&.month,
          year: @application_form.date_of_birth&.year,
          phone_number: @application_form.phone_number
        )
      end

      def save!
        @application_form.update!(
          first_name: first_name,
          last_name: last_name,
          date_of_birth: date_of_birth,
          phone_number: phone_number,
          audit_comment: audit_comment,
        )

        candidate.email_address = email_address
        candidate.save!
      end

      def date_of_birth
        date_args = [year, month, day].map(&:to_i)

        begin
          Date.new(*date_args)
        rescue ArgumentError
          Struct.new(:day, :month, :year).new(day, month, year)
        end
      end

      def email_address_unique
        return if @application_form.persisted? &&
          @application_form.candidate.email_address == email_address

        return unless Candidate.exists?(email_address: email_address)

        errors.add(
          :email_address,
          I18n.t('activemodel.errors.models.support_interface/application_forms/edit_applicant_details_form.attributes.email_address.taken'),
        )
      end

    private

      def candidate
        @application_form.candidate
      end
    end
  end
end
