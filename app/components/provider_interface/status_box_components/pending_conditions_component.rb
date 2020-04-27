module ProviderInterface
  module StatusBoxComponents
    class PendingConditionsComponent < ViewComponent::Base
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @options = options
      end

      def render?
        application_choice.pending_conditions? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Offer accepted',
            value: application_choice.accepted_at.to_s(:govuk_date),
          },
        ] + course_rows(course_option: application_choice.offered_option)
      end
    end
  end
end
