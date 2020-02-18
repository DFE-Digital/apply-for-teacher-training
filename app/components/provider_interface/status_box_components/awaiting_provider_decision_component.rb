module ProviderInterface
  module StatusBoxComponents
    class AwaitingProviderDecisionComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def rows
        [
          {
            key: 'Status',
            value: render(ProviderInterface::ApplicationStatusTagComponent.new(application_choice: application_choice)),
          },
          {
            key: 'Application submitted',
            value: application_choice.application_form.submitted_at&.to_s(:govuk_date),
          },
          {
            key: 'Respond to applicant by',
            value: application_choice.reject_by_default_at&.to_s(:govuk_date),
          },
        ]
      end
    end
  end
end
