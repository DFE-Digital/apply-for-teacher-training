module ProviderInterface
  class OfferSummaryComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :application_choice, :course, :course_option, :conditions, :available_providers, :available_courses, :available_course_options, :border, :editable, :show_conditions_link

    def initialize(application_choice:, course:, course_option:, conditions:, available_providers: [], available_courses: [], available_course_options: [], border: true, editable: true, show_conditions_link: false)
      @application_choice = application_choice
      @course_option = course_option
      @conditions = conditions
      @available_providers = available_providers
      @available_courses = available_courses
      @available_course_options = available_course_options
      @course = course
      @border = border
      @editable = editable
      @show_conditions_link = show_conditions_link
    end

    def rows
      [
        { key: 'Provider',
          value: course_option.provider.name_and_code,
          action: 'Change',
          change_path: change_provider_path },
        { key: 'Course',
          value: course_option.course.name_and_code,
          action: 'Change',
          change_path: change_course_path },
        { key: 'Location',
          value: course_option.site.name_and_address,
          action: 'Change',
          change_path: change_location_path },
        { key: 'Full time or part time',
          value: course_option.study_mode.humanize,
          action: 'Change',
          change_path: change_study_mode_path },
      ]
    end

    def change_provider_path
      available_providers.many? ? new_provider_interface_application_choice_offer_providers_path(application_choice) : nil
    end

    def change_course_path
      available_courses.many? ? new_provider_interface_application_choice_offer_courses_path(application_choice) : nil
    end

    def change_location_path
      available_course_options.many? ? new_provider_interface_application_choice_offer_locations_path(application_choice) : nil
    end

    def change_study_mode_path
      course.full_time_or_part_time? ? new_provider_interface_application_choice_offer_study_modes_path(application_choice) : nil
    end

    def conditions_met?
      return application_choice.status_before_deferral == 'recruited' if application_choice.status == 'offer_deferred'

      application_state.current_state == :recruited
    end

    delegate :conditions_not_met?, to: :application_state

  private

    def application_state
      @application_state ||= ApplicationStateChange.new(application_choice)
    end

    def border_class
      'no-border' unless border
    end

    def mode
      :new
    end
  end
end
