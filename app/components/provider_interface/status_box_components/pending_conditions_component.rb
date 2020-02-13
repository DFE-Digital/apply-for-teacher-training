module ProviderInterface
  module StatusBoxComponents
    class PendingConditionsComponent < ActionView::Component::Base
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
            key: 'Offer accepted',
            value: application_choice.accepted_at&.to_s(:govuk_date),
          },
          {
            key: 'Course',
            value: render(
              ProviderInterface::CoursePresentationComponent,
              application_choice: application_choice,
            ),
            # change_path: '/change-me',
          },
          {
            key: 'Location',
            value: render(
              ProviderInterface::LocationPresentationComponent,
              application_choice: application_choice,
            ),
          },
        ]
      end
    end
  end
end
