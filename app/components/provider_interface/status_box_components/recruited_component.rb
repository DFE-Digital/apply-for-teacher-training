module ProviderInterface
  module StatusBoxComponents
    class RecruitedComponent < ApplicationComponent
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice, :provider_can_respond

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @provider_can_respond = options[:provider_can_respond]
        @options = options
      end

      def render?
        application_choice.recruited? ||
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Recruited',
            value: application_choice.recruited_at.to_fs(:govuk_date),
          },
        ] + course_rows(application_choice:)
      end
    end
  end
end
