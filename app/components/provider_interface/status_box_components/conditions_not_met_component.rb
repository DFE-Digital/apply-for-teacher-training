module ProviderInterface
  module StatusBoxComponents
    class ConditionsNotMetComponent < ApplicationComponent
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @options = options
      end

      def render?
        application_choice.conditions_not_met? ||
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        course_rows(application_choice:)
      end
    end
  end
end
