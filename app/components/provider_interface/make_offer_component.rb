module ProviderInterface
  class MakeOfferComponent < ViewComponent::Base
    include ViewHelper
    include QualificationValueHelper

    attr_accessor :application_choice, :course, :course_option, :conditions, :available_providers, :available_courses, :available_course_options, :ske_conditions

    def initialize(application_choice:, course:, course_option:, conditions:, available_providers: [], available_courses: [], available_course_options: [], ske_conditions: [])
      @application_choice = application_choice
      @school_placement_auto_selected = application_choice.school_placement_auto_selected
      @course_option = course_option
      @conditions = conditions
      @available_providers = available_providers
      @available_courses = available_courses
      @available_course_options = available_course_options
      @course = course
      @ske_conditions = ske_conditions
    end

    def rows
      [
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
            visually_hidden_text: 'course',
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
        accredited_body_details,
        location_row,
        {
          key: 'Qualification',
          value: qualification_text(course_option),
        },
        {
          key: 'Funding type',
          value: course.funding_type.humanize,
        },
        {
          key: 'Conditions of offer',
          value: text_conditions.join("\n\n"),
          action: {
            href: [:new, :provider_interface, @application_choice, :offer, :conditions],
            visually_hidden_text: 'conditions of offer',
          },
        },
      ].compact_blank
    end

    def text_conditions
      sorted_conditions = conditions.sort_by do |condition|
        [OfferCondition::STANDARD_CONDITIONS.index(condition.text) || Float::INFINITY, condition.created_at]
      end

      sorted_conditions.map do |condition|
        text = condition.text
        if condition.is_a?(ReferenceCondition) && condition.description.present?
          text += " #{condition.description}"
        end

        text
      end
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

    def accredited_body_details
      return {} if course_option.accredited_provider.blank?

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

    def location_row
      return {} unless application_choice.different_offer? || !@school_placement_auto_selected

      {
        key: t('school_placements.changed'),
        value: course_option.site.name_and_address("\n"),
        action: {
          href: change_location_path,
          visually_hidden_text: t('school_placements.visually_hidden_text'),
        },
      }
    end
  end
end
