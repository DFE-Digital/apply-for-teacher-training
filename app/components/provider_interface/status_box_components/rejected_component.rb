module ProviderInterface
  module StatusBoxComponents
    class RejectedComponent < ViewComponent::Base
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @options = options
      end

      def render?
        application_choice.rejected? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def offer_withdrawn_at
        application_choice.offer_withdrawn_at&.to_s(:govuk_date) # nil is legit here
      end

      def offer_withdrawn_rows
        [
          {
            key: 'Offer withdrawn',
            value: offer_withdrawn_at,
          },
        ] + course_rows(course_option: application_choice.offered_option)
      end

      def rejected_rows
        [
          {
            key: 'Status',
            value: render(ProviderInterface::ApplicationStatusTagComponent.new(application_choice: application_choice)),
          },
          {
            key: 'Application rejected',
            value: application_choice.rejected_at.to_s(:govuk_date),
          },
        ]
      end
    end
  end
end
