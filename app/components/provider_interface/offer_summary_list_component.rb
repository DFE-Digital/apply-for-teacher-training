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
          value: course_option.course.provider.name,
          change_path: change_path(:provider), action: 'training provider'
        },
        {
          key: 'Course',
          value: course_option.course.name_and_code,
          change_path: change_path(:course), action: 'course'
        },
        {
          key: 'Location',
          value: course_option.site.name_and_address,
          change_path: change_path(:course_option), action: 'location'
        },
      ]
    end

    def paths
      Rails.application.routes.url_helpers
    end

    # TODO: paths produced preserve the current (unsaved) provider/course/option selection
    def change_path(target)
      if new_course_option
        case target
        when :provider
          paths.provider_interface_application_choice_change_offer_edit_provider_path(application_choice.id) if show_provider_link?
        when :course
          paths.provider_interface_application_choice_change_offer_edit_course_path(application_choice.id) if show_course_link?
        when :course_option
          paths.provider_interface_application_choice_change_offer_edit_course_option_path(application_choice.id) if show_course_option_link?
        end
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
      if @course_option_id
        @new_course_option ||= CourseOption.find(@course_option_id)
        @new_course_option if @course_option_id != application_choice.offered_option.id
      end
    end

    def course_option
      new_course_option || application_choice.offered_option
    end
  end
end
