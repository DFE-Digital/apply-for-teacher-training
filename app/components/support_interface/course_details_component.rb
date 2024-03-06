module SupportInterface
  class CourseDetailsComponent < SummaryListComponent
    include ViewHelper

    attr_reader :course

    def initialize(course:)
      @course = course
    end

    def rows
      rows = [
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
          value: course.start_date.to_fs(:month_and_year),
        },
        {
          key: 'Last updated',
          value: course.updated_at.to_fs(:govuk_date_and_time),
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
          key: 'Can sponsor student visas?',
          value: course.can_sponsor_student_visa? ? 'Yes' : 'No',
        },
        {
          key: 'Can sponsor skilled worker visas?',
          value: course.can_sponsor_skilled_worker_visa? ? 'Yes' : 'No',
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
          key: 'Provider manually closed',
          value: course.application_status_open? ? govuk_tag(text: 'Not closed', colour: 'green') : govuk_tag(text: 'Closed', colour: 'red'),
        },
        {
          key: 'Find status',
          value: course.exposed_in_find? ? govuk_tag(text: 'Shown on Find', colour: 'green') : govuk_tag(text: 'Hidden on Find', colour: 'grey'),
          action: {
            href: course.find_url,
            text: 'Course page on Find',
          },
        },
        {
          key: 'Apply status',
          value: course.open_on_apply? ? govuk_tag(text: open_on_apply_message(course), colour: 'green') : govuk_tag(text: 'Not open on Apply', colour: 'blue'),
          action: {
            href: candidate_interface_apply_from_find_path(providerCode: course.provider.code, courseCode: course.code),
            text: 'Start page on Apply',
          },
        },
      ]

      if course.open_on_apply?
        rows.push({
          key: 'Opened on Apply at',
          value: course.opened_on_apply_at.to_fs(:govuk_date_and_time),
        })
      end

      rows
    end

    def open_on_apply_message(course)
      course.recruitment_cycle_year > 2021 ? 'Open on Apply' : 'Open on Apply & UCAS'
    end
  end
end
