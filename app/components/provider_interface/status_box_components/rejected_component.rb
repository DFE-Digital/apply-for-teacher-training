module ProviderInterface
  module StatusBoxComponents
    class RejectedComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
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
            key: 'Status',
            value: render(ProviderInterface::ApplicationStatusTagComponent.new(application_choice: application_choice)),
          },
          {
            key: 'Offer withdrawn',
            value: offer_withdrawn_at,
          },
          {
            key: 'Course',
            value: render(ProviderInterface::OfferedCourseComponent.new(application_choice: application_choice)),
          },
          {
            key: 'Location',
            value: render(ProviderInterface::OfferedCourseComponent.new(application_choice: application_choice, display: :site)),
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
