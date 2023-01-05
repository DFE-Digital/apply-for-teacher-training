module SupportInterface
  module ApplicationForms
    class EditGcseGradeForm
      include ActiveModel::Model

      attr_reader :gcse
      attr_accessor :grade, :audit_comment

      validates :grade, presence: true
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator

      delegate :application_form, :subject, to: :gcse

      def initialize(gcse)
        @gcse = gcse

        super(
          grade: @gcse.grade,
        )
      end

      def save!
        @gcse.update!(
          grade:,
          audit_comment:,
        )
      end
    end
  end
end
