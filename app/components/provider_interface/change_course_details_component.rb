module ProviderInterface
  class ChangeCourseDetailsComponent < ViewComponent::Base
    include ViewHelper
    include QualificationValueHelper

    FUNDING_TYPES = { apprenticeship: :apprenticeship, salary: :salaried, fee: :fee_paying }.freeze

    attr_reader :application_choice, :provider_name_and_code, :course_name_and_code,
                :cycle, :preferred_location, :study_mode, :qualification, :available_providers,
                :available_courses, :course, :available_course_options

    def initialize(application_choice:, course: nil, available_providers: [], available_courses: [], available_course_options: [])
      @application_choice = application_choice
      @provider_name_and_code = application_choice.provider.name_and_code
      @course_name_and_code = application_choice.course.name_and_code
      @cycle = application_choice.course.recruitment_cycle_year
      @preferred_location = preferred_location_text
      @study_mode = application_choice.course_option.study_mode.humanize
      @qualification = qualification_text(application_choice.course_option)
      @available_providers = available_providers
      @available_courses = available_courses
      @course = course
      @available_course_options = available_course_options
    end

    def rows
      [
        { key: 'Training provider', value: provider_name_and_code, action: { href: change_provider_path } },
        { key: 'Course', value: course_name_and_code, action: { href: change_course_path } },
        { key: 'Cycle', value: cycle },
        { key: 'Full or part time', value: study_mode, action: { href: change_study_mode_path } },
        { key: 'Location', value: preferred_location, action: { href: change_location_path } },
        { key: 'Accredited body', value: accredited_body },
        { key: 'Qualification', value: qualification },
        { key: 'Funding type', value: funding_type },
      ]
    end

    def preferred_location_text
      "#{application_choice.site.name_and_code}\n" \
        "#{formatted_address}"
    end

    def accredited_body
      accredited_body = @application_choice.course.accredited_provider
      accredited_body.present? ? accredited_body.name_and_code : provider_name_and_code
    end

    def funding_type
      key = @application_choice.course.funding_type.to_sym
      FUNDING_TYPES[key].to_s.humanize
    end

  private

    def formatted_address
      site = application_choice.site
      "#{site.address_line1}, " \
        "#{site.address_line2}, " \
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
  end
end
