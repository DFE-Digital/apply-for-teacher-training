module ProviderInterface
  module StatusBoxComponents
    class ConditionsNotMetComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def candidate_name
        application_choice.application_form.full_name
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
