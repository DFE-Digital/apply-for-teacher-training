module ProviderInterface
  module StatusBoxComponents
    class RejectedComponent < ActionView::Component::Base
      include ViewHelper
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
