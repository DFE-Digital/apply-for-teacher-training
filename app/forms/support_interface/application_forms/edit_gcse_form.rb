module SupportInterface
  module ApplicationForms
    class EditGcseForm
      include ActiveModel::Model

      attr_reader :gcse
      attr_accessor :award_year, :audit_comment

      validates :award_year, presence: true
      validates :audit_comment, presence: true

      delegate :application_form, :subject, to: :gcse

      def initialize(gcse)
        @gcse = gcse

        super(
          award_year: @gcse.award_year,
        )
      end

      def save!
        @gcse.update!(
          award_year: award_year,
          audit_comment: audit_comment,
        )
      end
    end
  end
end
