module ProviderInterface
  class OfferSummaryListComponent < ActionView::Component::Base
    include ViewHelper
    attr_reader :application_choice, :header

    def initialize(application_choice:, header: 'Your offer', extra_arguments: {})
      @application_choice = application_choice
      @header = header
      @course_option_id = extra_arguments[:course_option_id]
      @entry = extra_arguments[:entry]
    end

    def rows
      [
        {
          key: 'Candidate name',
          value: application_choice.application_form.full_name,
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
      case target
      when :provider
        paths.provider_interface_application_choice_change_offer_edit_provider_path(application_choice.id) if show_provider_link?
      when :course
        paths.provider_interface_application_choice_change_offer_edit_course_path(application_choice.id) if show_course_link?
      when :course_option
        paths.provider_interface_application_choice_change_offer_edit_course_option_path(application_choice.id) if show_course_option_link?
      end
    end

    def show_provider_link?
      @entry == 'provider'
    end

    def show_course_link?
      @entry != 'course_option'
    end

    def show_course_option_link?
      true
    end

    def new_course_option
      @course_option ||= CourseOption.find(@course_option_id) if @course_option_id
      @course_option unless @course_option && @course_option.id != application_choice.offered_option.id
    end
  end
end
