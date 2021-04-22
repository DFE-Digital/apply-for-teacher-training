module ProviderInterface
  module StatusBoxComponents
    class OfferWithdrawnComponent < ViewComponent::Base
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @options = options
      end

      def render?
        application_choice.offer_withdrawn? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def offer_withdrawn_at
        application_choice.offer_withdrawn_at.to_s(:govuk_date)
      end

      def offer_withdrawn_rows
        [
          {
            key: 'Offer withdrawn',
            value: offer_withdrawn_at,
          },
        ] + course_rows(course_option: application_choice.current_course_option)
      end
    end
  end
end
