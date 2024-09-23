module SupportInterface
  class CourseOptionDetailsComponent < SummaryListComponent
    include ViewHelper

    attr_reader :course_option

    def initialize(course_option:, application_choice:)
      @course_option = course_option
      @school_placement_auto_selected = application_choice.school_placement_auto_selected?
      @course_option_is_original = application_choice.original_course_option == course_option
    end

    def rows
      rows = [
        { key: 'Training provider', value: govuk_link_to(course_option.course.provider.name_and_code, support_interface_provider_path(course_option.course.provider)) },
        { key: 'Course', value: render(SupportInterface::CourseNameAndStatusComponent.new(course_option:)) },
        { key: 'Course type', value: course_option.course.course_type.capitalize },
        { key: 'Cycle', value: course_option.course.recruitment_cycle_year },
        { key: 'Full time or part time', value: course_option.study_mode.humanize },
        { key: location_key, value: course_option.site.name_and_code },
      ]

      if accredited_body.present?
        rows += [{ key: 'Accredited body', value: govuk_link_to(accredited_body.name_and_code, support_interface_provider_path(accredited_body)) }]
      end

      rows
    end

  private

    def accredited_body
      course_option.course.accredited_provider
    end

    def location_key
      if @course_option_is_original
        if @school_placement_auto_selected

          t('school_placements.auto_selected')
        else
          t('school_placements.selected_by_candidate')
        end
      else
        t('school_placements.changed')
      end
    end
  end
end
