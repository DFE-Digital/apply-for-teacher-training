module SupportInterface
  module ApplicationForms
    class VisaExpiryForm
      include ActiveModel::Model
      include DateValidationHelper

      attr_accessor :application_form, :visa_expired_day, :visa_expired_month,
                    :visa_expired_year, :audit_comment
      validates :visa_expired_at, date: { presence: true }
      validates :audit_comment, presence: true

      def initialize(application_form)
        @application_form = application_form
        @visa_expired_day = application_form.visa_expired_at&.day
        @visa_expired_month = application_form.visa_expired_at&.month
        @visa_expired_year = application_form.visa_expired_at&.year
      end

      def save
        return if invalid?

        application_form.update(
          visa_expired_at:,
          audit_comment:,
        )
      end

      def visa_expired_at
        valid_or_invalid_date(visa_expired_year, visa_expired_month, visa_expired_day)
      end
    end
  end
end
