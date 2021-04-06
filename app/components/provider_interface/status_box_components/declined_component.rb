module ProviderInterface
  module StatusBoxComponents
    class DeclinedComponent < ViewComponent::Base
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @options = options
      end

      def render?
        application_choice.declined? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Offer declined',
            value: application_choice.declined_at.to_s(:govuk_date),
          },
        ] + course_rows(course_option: application_choice.current_course_option)
      end
    end
  end
end
