module SupportInterface
  class CourseDetailsComponent < SummaryListComponent
    include ViewHelper

    attr_reader :course

    def initialize(course:)
      @course = course
    end

    def rows
      [
        {
          key: 'Recruitment cycle year',
          value: course.recruitment_cycle_year,
        },
        {
          key: 'Name',
          value: course.name_and_code,
        },
        {
          key: 'Provider',
          value: govuk_link_to(course.provider.name_and_code, support_interface_provider_path(course.provider)),
        },
        {
          key: 'Accredited body',
          value: course.accredited_provider&.name_and_code || 'None',
        },
        {
          key: 'Level',
          value: course.level.humanize,
        },
        {
          key: 'Program type',
          value: Course.human_attribute_name("program_type.#{course.program_type}", default: 'Unknown'),
        },
        {
          key: 'Qualifications',
          value: (course.qualifications || []).map(&:upcase).to_sentence,
        },
        {
          key: 'Description',
          value: course.description,
        },
        {
          key: 'Start date',
          value: course.start_date.to_s(:month_and_year),
        },
        {
          key: 'Last updated',
          value: course.updated_at.to_s(:govuk_date_and_time),
        },
        {
          key: 'Study modes',
          value: course.study_mode.humanize,
        },
        {
          key: 'Funding type',
          value: Course.human_attribute_name("funding_type.#{course.funding_type}"),
        },
        {
          key: 'Financial support',
          value: course.financial_support || 'None',
        },
        {
          key: 'Course in previous cycle',
          value: course.in_previous_cycle ? govuk_link_to(course.in_previous_cycle.year_name_and_code, support_interface_course_path(course.in_previous_cycle)) : 'None',
        },
        {
          key: 'Course in next cycle',
          value: course.in_next_cycle ? govuk_link_to(course.in_next_cycle.year_name_and_code, support_interface_course_path(course.in_next_cycle)) : 'None',
        },
        {
          key: 'Find status',
          value: render(course.exposed_in_find? ? TagComponent.new(text: 'Shown on Find', type: 'green') : TagComponent.new(text: 'Hidden on Find', type: 'grey')),
          action: 'Course page on Find',
          action_path: course.find_url,
        },
        {
          key: 'Apply status',
          value: render(course.open_on_apply? ? TagComponent.new(text: 'Open on Apply & UCAS', type: 'green') : TagComponent.new(text: 'Open on UCAS only', type: 'blue')),
          action: 'Start page on Apply',
          action_path: candidate_interface_apply_from_find_path(providerCode: course.provider.code, courseCode: course.code),
        },
      ]
    end
  end
end
