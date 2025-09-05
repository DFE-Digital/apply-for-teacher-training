module ProviderInterface
  class OfferSummaryComponent < ApplicationComponent
    include ViewHelper
    include QualificationValueHelper

    attr_accessor :application_choice, :course, :course_option, :conditions, :available_providers, :available_courses, :available_course_options, :border, :editable, :show_conditions_link, :ske_conditions, :show_recruit_pending_button

    def initialize(application_choice:, course:, course_option:, conditions:, available_providers: [], available_courses: [], available_course_options: [], border: true, editable: true, show_conditions_link: false, ske_conditions: [], show_recruit_pending_button: false)
      @application_choice = application_choice
      @school_placement_auto_selected = application_choice.school_placement_auto_selected
      @course_option = course_option
      @conditions = conditions
      @available_providers = available_providers
      @available_courses = available_courses
      @available_course_options = available_course_options
      @course = course
      @border = border
      @editable = editable
      @show_conditions_link = show_conditions_link
      @ske_conditions = ske_conditions
      @show_recruit_pending_button = show_recruit_pending_button
    end

    def rows
      rows = [
        {
          key: 'Training provider',
          value: course_option.provider.name_and_code,
          action: {
            href: change_provider_path,
          },
        },
        {
          key: 'Course',
          value: course_option.course.name_and_code,
          action: {
            href: change_course_path,
          },
        },
        {
          key: 'Full time or part time',
          value: course_option.study_mode.humanize,
          action: {
            href: change_study_mode_path,
            visually_hidden_text: 'if full time or part time',
          },
        },
        {
          key: location_key,
          value: course_option.site.name_and_address("\n"),
          action: {
            href: change_location_path,
          },
        },
        {
          key: 'Qualification',
          value: qualification_text(course_option),
        },
        {
          key: 'Funding type',
          value: course.funding_type.humanize,
        },
      ]
      return rows if course_option.course.accredited_provider.blank?

      rows.insert(4, accredited_body_details(course_option))
    end

    def change_provider_path
      available_providers.length > 1 ? new_provider_interface_application_choice_offer_providers_path(application_choice) : nil
    end

    def change_course_path
      available_courses.length > 1 ? new_provider_interface_application_choice_offer_courses_path(application_choice) : nil
    end

    def change_location_path
      available_course_options.length > 1 ? new_provider_interface_application_choice_offer_locations_path(application_choice) : nil
    end

    def change_study_mode_path
      course.full_time_or_part_time? ? new_provider_interface_application_choice_offer_study_modes_path(application_choice) : nil
    end

    def update_conditions_path
      edit_provider_interface_condition_statuses_path(application_choice)
    end

    def show_recruit_with_pending_conditions?
      CanRecruitWithPendingConditions.new(application_choice:).call
    end

    def conditions_to_update?
      @application_choice.pending_conditions? || RecruitedWithPendingConditions.new(application_choice:).call
    end

  private

    def accredited_body_details(course_option)
      {
        key: 'Accredited body',
        value: course_option.course.accredited_provider.name_and_code,
      }
    end

    def border_class
      'app-offer-panel--no-border' unless border
    end

    def mode
      :new
    end

    def location_key
      if @application_choice.different_offer?
        t('school_placements.changed')
      elsif @school_placement_auto_selected
        t('school_placements.auto_selected')
      else
        t('school_placements.selected_by_candidate')
      end
    end
  end
end
