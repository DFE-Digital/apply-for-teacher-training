module ProviderInterface
  module StatusBoxComponents
    class OfferComponent < ViewComponent::Base
      include ViewHelper
      attr_reader :application_choice
      attr_reader :available_providers, :available_courses, :available_course_options

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @available_providers = options[:available_providers]
        @available_courses = options[:available_courses]
        @available_course_options = options[:available_course_options]
      end

      def render?
        application_choice.offer? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Offer made',
            value: application_choice.offered_at.to_s(:govuk_date),
          },
          {
            key: 'Provider',
            value: application_choice.offered_course.provider.name,
            change_path: change_path(:provider), action: 'training provider'
          },
          {
            key: 'Course',
            value: application_choice.offered_course.name_and_code,
            change_path: change_path(:course), action: 'course'
          },
          {
            key: 'Location',
            value: application_choice.offered_site.name_and_address,
            change_path: change_path(:course_option), action: 'location'
          },
        ]
      end

      def paths
        Rails.application.routes.url_helpers
      end

      def change_path(target)
        return nil unless FeatureFlag.active?('provider_change_response')

        case target
        when :provider
          paths.provider_interface_application_choice_change_offer_edit_provider_path(application_choice.id, entry: 'provider') if show_provider_link?
        when :course
          paths.provider_interface_application_choice_change_offer_edit_course_path(application_choice.id, entry: 'course') if show_course_link?
        when :course_option
          paths.provider_interface_application_choice_change_offer_edit_course_option_path(application_choice.id, entry: 'course_option') if show_course_option_link?
        end
      end

      def show_provider_link?
        available_providers.count > 1 if available_providers
      end

      def show_course_link?
        available_courses.count > 1 if available_courses
      end

      def show_course_option_link?
        available_course_options.count > 1 if available_course_options
      end
    end
  end
end
