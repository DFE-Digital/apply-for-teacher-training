module ProviderInterface
  module StatusBoxComponents
    class RejectedComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def offer_withdrawn_at
        application_choice.offer_withdrawn_at&.to_s(:govuk_date)
      end

      def offer_withdrawn_rows
        [
          {
            key: 'Status',
            value: render(
              ProviderInterface::ApplicationStatusTagComponent,
              application_choice: application_choice,
            ),
          },
          {
            key: 'Offer withdrawn',
            value: offer_withdrawn_at,
          },
          {
            key: 'Course',
            value: render(
              ProviderInterface::CoursePresentationComponent,
              application_choice: application_choice,
            ),
          },
          {
            key: 'Location',
            value: render(
              ProviderInterface::LocationPresentationComponent,
              application_choice: application_choice,
            ),
          },
        ]
      end

      def rejected_rows
        [
          {
            key: 'Status',
            value: render(
              ProviderInterface::ApplicationStatusTagComponent,
              application_choice: application_choice,
            ),
          },
          {
            key: 'Application rejected',
            value: application_choice.rejected_at&.to_s(:govuk_date),
          },
        ]
      end
    end
  end
end
