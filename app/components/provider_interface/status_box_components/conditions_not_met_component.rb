module ProviderInterface
  module StatusBoxComponents
    class ConditionsNotMetComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def render?
        application_choice.conditions_not_met? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Provider',
            value: application_choice.offered_course.provider.name,
          },
          {
            key: 'Course',
            value: application_choice.offered_course.name_and_code,
          },
          {
            key: 'Location',
            value: application_choice.offered_site.name_and_address,
          },
        ]
      end
    end
  end
end
