module ProviderInterface
  module StatusBoxComponents
    class EnrolledComponent < ViewComponent::Base
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @options = options
      end

      def render?
        application_choice.enrolled? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Enrolled',
            value: application_choice.enrolled_at.to_s(:govuk_date),
          },
        ] + course_rows(course_option: application_choice.offered_option)
      end
    end
  end
end
