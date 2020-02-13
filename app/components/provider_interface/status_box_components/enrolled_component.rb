module ProviderInterface
  module StatusBoxComponents
    class EnrolledComponent < ActionView::Component::Base
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
            key: 'Enrolled',
            value: application_choice.enrolled_at&.to_s(:govuk_date),
          },
          {
            key: 'Course',
            value: render(
              ProviderInterface::CoursePresentationComponent,
              application_choice: application_choice,
            ),
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
