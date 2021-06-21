module ProviderInterface
  module StatusBoxComponents
    class PendingConditionsComponent < ViewComponent::Base
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice, :provider_can_respond

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @provider_can_respond = options[:provider_can_respond]
        @options = options
      end

      def render?
        application_choice.pending_conditions? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        course_rows(course_option: application_choice.current_course_option)
      end

      def update_conditions_path
        if FeatureFlag.active?(:individual_offer_conditions)
          edit_provider_interface_condition_statuses_path(application_choice)
        else
          provider_interface_application_choice_edit_conditions_path(application_choice)
        end
      end
    end
  end
end
