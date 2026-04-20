module SupportInterface
  module ApplicationChoices
    class VisaExplanationForm
      include ActiveModel::Model

      attr_accessor :application_choice, :visa_explanation, :visa_explanation_details,
                    :audit_comment

      validates :visa_explanation, presence: true
      validates :visa_explanation_details, presence: true, if: -> { visa_explanation == 'other' }
      validates :audit_comment, presence: true

      def initialize(application_choice)
        @application_choice = application_choice
        @visa_explanation = application_choice&.visa_explanation
        @visa_explanation_details = application_choice&.visa_explanation_details
      end

      def save
        return if invalid?

        application_choice.update(
          visa_explanation:,
          visa_explanation_details:,
          audit_comment:,
        )
      end
    end
  end
end
