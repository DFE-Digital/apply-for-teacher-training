module ProviderInterface
  module StatusBoxComponents
    class OfferComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def candidate_name
        application_choice.application_form.full_name
      end

      def rows
        [
          {
            key: 'Status',
            value: render(ProviderInterface::ApplicationStatusTagComponent.new(application_choice: application_choice)),
          },
          {
            key: 'Offer made',
            value: application_choice.offered_at&.to_s(:govuk_date),
          },
          {
            key: 'Course',
            value: render(ProviderInterface::CoursePresentationComponent.new(application_choice: application_choice)),
          },
          {
            key: 'Location',
            value: render(ProviderInterface::LocationPresentationComponent.new(application_choice: application_choice)),
          },
        ]
      end
    end
  end
end
