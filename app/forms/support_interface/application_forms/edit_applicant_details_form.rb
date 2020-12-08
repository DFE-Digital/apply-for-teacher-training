module SupportInterface
  module ApplicationForms
    class EditApplicantDetailsForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :day, :month, :year
      attr_accessor :phone_number
      attr_accessor :audit_comment
      attr_reader :application_form

      validates :first_name, :last_name, presence: true
      validates :first_name, :last_name,
                length: { maximum: 60 }

      validates :date_of_birth, presence: true
      validate :date_of_birth_valid
      validate :date_of_birth_not_in_future
      validate :date_of_birth_is_within_lower_age_limit

      validates :phone_number, presence: true, phone_number: true
      validates :audit_comment, presence: true

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

        if valid_year?(year) && Date.valid_date?(*date_args)
          Date.new(*date_args)
        else
          Struct.new(:day, :month, :year).new(day, month, year)
        end
      end

      def date_of_birth_valid
        errors.add(:date_of_birth, :invalid) unless date_of_birth.is_a?(Date)
      end

      def date_of_birth_not_in_future
        errors.add(:date_of_birth, :future) if date_of_birth.is_a?(Date) && date_of_birth > Time.zone.today
      end

      def date_of_birth_is_within_lower_age_limit
        return unless date_of_birth.is_a?(Date) && date_of_birth < Time.zone.today

        age_limit = Time.zone.today - 16.years
        errors.add(:date_of_birth, :below_lower_age_limit, date: age_limit.to_s(:govuk_date)) if date_of_birth > age_limit
      end
    end
  end
end
