module ProviderInterface
  class ChangeCourseDetailsComponent < ViewComponent::Base
    include ViewHelper
    include QualificationValueHelper

    FUNDING_TYPES = { apprenticeship: :apprenticeship, salary: :salaried, fee: :fee_paying }.freeze

    attr_reader :application_choice, :provider_name, :course_name_and_code,
                :cycle, :preferred_location, :study_mode, :qualification, :available_providers,
                :available_courses, :course, :available_course_options, :course_option

    def initialize(application_choice:, course_option:, available_providers: [], available_courses: [], available_course_options: [])
      @application_choice = application_choice
      @course_option = course_option
      @available_providers = available_providers
      @available_courses = available_courses
      @available_course_options = available_course_options

      @course = course_option.course

      @provider_name = course.provider.name
      @course_name_and_code = course.name_and_code
      @cycle = course.recruitment_cycle_year
      @preferred_location = preferred_location_text
      @study_mode = course_option.study_mode.humanize
      @qualification = qualification_text(course_option)
    end

    def rows
      [
        {
          key: 'Training provider',
          value: provider_name,
          action: {
            href: change_provider_path,
            visually_hidden_text: change_provider_path.present? ? 'training provider' : nil,
          },
        },
        {
          key: 'Course',
          value: course_name_and_code,
          action: {
            href: change_course_path,
            visually_hidden_text: change_course_path.present? ? 'course' : nil,
          },
        },
        {
          key: 'Full time or part time',
          value: study_mode,
          action: {
            href: change_study_mode_path,
            visually_hidden_text: change_study_mode_path.present? ? 'full time or part time' : nil,
          },
        },
        location_row,
        { key: 'Accredited body', value: accredited_body },
        { key: 'Qualification', value: qualification },
        { key: 'Funding type', value: funding_type },
      ].compact_blank
    end

    def preferred_location_text
      "#{course_option.site.name_and_code}\n" \
        "#{formatted_address}"
    end

    def accredited_body
      accredited_body = course.accredited_provider
      accredited_body.present? ? accredited_body.name : provider_name
    end

    def funding_type
      key = course.funding_type.to_sym
      FUNDING_TYPES[key].to_s.humanize
    end

  private

    def formatted_address
      site = course_option.site
      "#{site.address_line1}\n" \
        "#{site.address_line2}\n" \
        "#{site.address_line3}\n" \
        "#{site.postcode}"
    end

    def change_provider_path
      available_providers.length > 1 ? edit_provider_interface_application_choice_course_providers_path(application_choice) : nil
    end

    def change_course_path
      available_courses.length > 1 ? edit_provider_interface_application_choice_course_courses_path(application_choice) : nil
    end

    def change_study_mode_path
      course.full_time_or_part_time? ? edit_provider_interface_application_choice_course_study_modes_path(application_choice) : nil
    end

    def change_location_path
      available_course_options.length > 1 ? edit_provider_interface_application_choice_course_locations_path(application_choice) : nil
    end

    def location_row
      return {} if @application_choice.school_placement_auto_selected?

      {
        key: t('school_placements.location'),
        value: preferred_location,
        action: {
          href: change_location_path,
          visually_hidden_text: change_location_path.present? ? t('school_placements.visually_hidden_text') : nil,
        },
      }
    end
  end
end
