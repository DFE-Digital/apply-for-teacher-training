module SupportInterface
  module ApplicationForms
    class EditOtherQualificationAwardYearForm
      include ActiveModel::Model
      include DateValidationHelper

      attr_reader :qualification
      attr_accessor :award_year, :audit_comment

      validates :award_year, presence: true, year: { future: true }
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator

      delegate :application_form, :subject, to: :qualification

      def initialize(qualification)
        @qualification = qualification

        super(
          award_year: @qualification.award_year,
        )
      end

      def save!
        @qualification.update!(
          award_year:,
          audit_comment:,
        )
        qualification
      end
    end
  end
end
