module ProviderInterface
  module StatusBoxComponents
    class PendingConditionsComponent < ApplicationComponent
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice, :provider_can_respond

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @provider_can_respond = options[:provider_can_respond]
        @options = options
      end

      def render?
        application_choice.pending_conditions? ||
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        course_rows(application_choice:)
      end

      def update_conditions_path
        edit_provider_interface_condition_statuses_path(application_choice)
      end
    end
  end
end
