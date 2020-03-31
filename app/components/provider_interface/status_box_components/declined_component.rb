module ProviderInterface
  module StatusBoxComponents
    class DeclinedComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(args)
        @application_choice = args[:application_choice]
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
    end
  end
end
