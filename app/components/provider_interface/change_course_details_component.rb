module ProviderInterface
  class ChangeCourseDetailsComponent < ApplicationComponent
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
        { key: 'Training provider', value: provider_name, action: { href: change_provider_path } },
        { key: 'Course', value: course_name_and_code, action: { href: change_course_path } },
        { key: 'Full time or part time', value: study_mode, action: { href: change_study_mode_path } },
        { key: location_key, value: preferred_location, action: { href: change_location_path } },
        { key: 'Accredited body', value: accredited_body },
        { key: 'Qualification', value: qualification },
        { key: 'Funding type', value: funding_type },
      ]
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

    # If the course option being displayed is the original course option chosen
    # by the candidate we show the context. Otherwise we just show the
    # simplified key.
    def location_key
      if application_choice.different_offer?
        t('school_placements.changed')
      elsif @application_choice.school_placement_auto_selected?
        t('school_placements.auto_selected')

      else
        t('school_placements.selected_by_candidate')
      end
    end
  end
end
