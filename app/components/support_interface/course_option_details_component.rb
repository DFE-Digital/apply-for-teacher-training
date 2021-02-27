module SupportInterface
  class CourseOptionDetailsComponent < SummaryListComponent
    include ViewHelper

    attr_reader :course_option

    def initialize(course_option:)
      @course_option = course_option
    end

    def rows
      [
        { key: 'Recruitment cycle', value: course_option.course.recruitment_cycle_year },
        { key: 'Provider', value: govuk_link_to(course_option.course.provider.name_and_code, support_interface_provider_path(course_option.course.provider)) },
        { key: 'Accredited body', value: accredited_body.present? ? govuk_link_to(accredited_body.name_and_code, support_interface_provider_path(accredited_body)) : nil },
        { key: 'Course', value: render(SupportInterface::CourseNameAndStatusComponent.new(course_option: course_option)) },
        { key: 'Location', value: course_option.site.name_and_code },
        { key: 'Chosen study mode', value: course_option.study_mode.humanize },
      ]
    end

  private

    def accredited_body
      course_option.course.accredited_provider
    end
  end
end
