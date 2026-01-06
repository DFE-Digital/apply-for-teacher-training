module ProviderInterface
  class MakeOfferComponent < ViewComponent::Base
    include ViewHelper
    include QualificationValueHelper

    attr_accessor :application_choice, :course, :course_option, :conditions, :reference_condition, :available_providers, :available_courses, :available_course_options, :ske_conditions

    def initialize(application_choice:, course:, course_option:, conditions:, reference_condition: nil, available_providers: [], available_courses: [], available_course_options: [], ske_conditions: [])
      @application_choice = application_choice
      @school_placement_auto_selected = application_choice.school_placement_auto_selected
      @course_option = course_option
      @conditions = conditions
      @reference_condition = reference_condition
      @available_providers = available_providers
      @available_courses = available_courses
      @available_course_options = available_course_options
      @course = course
      @ske_conditions = ske_conditions
    end

    def rows
      rows = [
        {
          key: 'Candidate',
          value: application_choice.application_form.full_name,
        },
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
        {
          key: 'Additional conditions',
          value: text_conditions,
          action: {
            href: [:new, :provider_interface, @application_choice, :offer, :conditions],
          },
        },
        {
          key: 'Specific references',
          value: text_reference_condition,
          action: {
            href: [:new, :provider_interface, @application_choice, :offer, :conditions],
          },
        },
      ]

      return rows if course_option.course.accredited_provider.blank?

      rows.insert(4, accredited_body_details(course_option))
    end

    def text_conditions
      conditions.present? ? conditions.map(&:text).join("\n\n") : 'None'
    end

    def text_reference_condition
      reference_condition&.description.present? ? reference_condition.description : 'None'
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

    def accredited_body_details(course_option)
      {
        key: 'Accredited body',
        value: course_option.course.accredited_provider.name_and_code,
      }
    end

    def change_length_path
      new_provider_interface_application_choice_offer_ske_length_path(
        application_choice,
      )
    end

    def change_reason_path
      new_provider_interface_application_choice_offer_ske_reason_path(
        application_choice,
      )
    end

    def remove_condition_path
      new_provider_interface_application_choice_offer_ske_requirements_path(
        application_choice,
      )
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
