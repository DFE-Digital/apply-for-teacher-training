module ProviderInterface
  module StatusBoxComponents
    class RecruitedComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(args)
        @application_choice = args[:application_choice]
      end

      def render?
        application_choice.recruited? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Conditions met',
            value: application_choice.recruited_at.to_s(:govuk_date),
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
