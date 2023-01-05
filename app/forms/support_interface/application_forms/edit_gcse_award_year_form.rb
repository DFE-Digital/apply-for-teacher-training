module SupportInterface
  module ApplicationForms
    class EditGcseAwardYearForm
      include ActiveModel::Model

      attr_reader :gcse
      attr_accessor :award_year, :audit_comment

      validates :award_year, presence: true, length: { is: 4 }
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator

      delegate :application_form, :subject, to: :gcse

      def initialize(gcse)
        @gcse = gcse

        super(
          award_year: @gcse.award_year,
        )
      end

      def save!
        @gcse.update!(
          award_year:,
          audit_comment:,
        )
      end
    end
  end
end
