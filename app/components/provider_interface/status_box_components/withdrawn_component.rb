module ProviderInterface
  module StatusBoxComponents
    class WithdrawnComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def rows
        [
          {
            key: 'Status',
            value: render(
              ProviderInterface::ApplicationStatusTagComponent,
              application_choice: application_choice,
            ),
          },
          {
            key: 'Application withdrawn',
            value: application_choice.withdrawn_at&.to_s(:govuk_date),
          },
        ]
      end
    end
  end
end
