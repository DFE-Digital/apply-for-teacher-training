module ProviderInterface
  module StatusBoxComponents
    class OfferDeferredComponent < ViewComponent::Base
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice, :provider_can_respond
      attr_reader :available_providers, :available_courses, :available_study_modes, :available_course_options

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @provider_can_respond = options[:provider_can_respond]
        @available_providers = options[:available_providers]
        @available_courses = options[:available_courses]
        @available_study_modes = options[:available_study_modes]
        @available_course_options = options[:available_course_options]
      end

      def render?
        application_choice.offer_deferred? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Offer deferred',
            value: application_choice.offer_deferred_at.to_s(:govuk_date),
          },
        ] + add_change_links_to(course_rows(course_option: application_choice.current_course_option))
      end

      def add_change_links_to(rows)
        rows.map do |row|
          case row[:key]
          when 'Provider'
            row.merge(change_path: change_path(:provider), action: 'training provider')
          when 'Course'
            row.merge(change_path: change_path(:course), action: 'course')
          when 'Full time or part time'
            row.merge(change_path: change_path(:study_mode), action: 'to full time or part time')
          when 'Location'
            row.merge(change_path: change_path(:course_option), action: 'location')
          else
            row
          end
        end
      end

    private

      def change_path(target)
        if show_link?(target)
          provider_interface_application_choice_edit_offer_path(
            application_choice.id,
            step: target.to_s,
          )
        end
      end

      def show_link?(target)
        collection = case target
                     when :provider then available_providers
                     when :course then available_courses
                     when :study_mode then available_study_modes
                     when :course_option then available_course_options
                     end
        collection.count > 1 if collection
      end
    end
  end
end
