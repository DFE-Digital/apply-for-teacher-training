module ProviderInterface
  module StatusBoxComponents
    class OfferDeferredComponent < ViewComponent::Base
      include ViewHelper
      include StatusBoxComponents::CourseRows

      attr_reader :application_choice, :provider_can_respond, :available_providers,
                  :available_courses, :available_study_modes, :available_course_options

      def initialize(application_choice:, options: {})
        @application_choice = application_choice
        @provider_can_respond = options[:provider_can_respond]
        @available_providers = options[:available_providers]
        @available_courses = options[:available_courses]
        @available_study_modes = options[:available_study_modes]
        @available_course_options = options[:available_course_options]
      end

      def render?
        application_choice.offer_deferred? ||
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Offer deferred',
            value: application_choice.offer_deferred_at.to_fs(:govuk_date),
          },
        ] + add_change_links_to(course_rows(application_choice:))
      end

      def add_change_links_to(rows)
        rows.map do |row|
          case row[:key]
          when 'Training provider'
            row.merge(action: { href: change_path(:provider) })
          when 'Course'
            row.merge(action: { href: change_path(:course) })
          when 'Full time or part time'
            row.merge(action: { href: change_path(:study_mode), visually_hidden_text: 'if full time or part time' })
          when 'Location'
            row.merge(action: { href: change_path(:course_option) })
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
                     else CourseOption.none
                     end
        collection.many?
      end
    end
  end
end
