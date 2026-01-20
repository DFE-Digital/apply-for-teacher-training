module CandidateInterface
  class PreviousApplicationReviewComponent < ViewComponent::Base
    include CourseFeeRowHelper

    attr_reader :application_choice
    delegate :unsubmitted?,
             :current_course,
             :current_course_option,
             to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def rows
      [
        status_row,
        course_info_row,
        course_fee_row(application_choice, current_course),
        qualifications_row,
        course_length_row,
        study_mode_row,
        personal_statement_row,
      ].compact
    end

    def status_row
      {
        key: 'Status',
        value: render(
          ApplicationStatusTagComponent.new(application_choice:, display_info_text: false),
        ),
      }
    end

    def course_info_row
      {
        key: 'Course',
        value: govuk_link_to(current_course.name_and_code, current_course.find_url, new_tab: true),
      }.tap do |row|
        if unsubmitted?
          row[:action] = {
            href: candidate_interface_edit_course_choices_which_course_are_you_applying_to_path(application_choice.id),
            visually_hidden_text: "course for #{current_course.name_and_code}",
          }
        end
      end
    end

    def qualifications_row
      {
        key: 'Qualifications',
        value: current_course.qualifications_to_s,
      }
    end

    def course_length_row
      {
        key: 'Course length',
        value: DisplayCourseLength.call(course_length: current_course.course_length),
      }
    end

    def study_mode_row
      {
        key: 'Full time or part time',
        value: current_course_option.study_mode.humanize.to_s,
      }.tap do |row|
        if unsubmitted? && current_course.currently_has_both_study_modes_available?
          row[:action] = {
            href: candidate_interface_edit_course_choices_course_study_mode_path(application_choice.id, current_course.id),
            visually_hidden_text: "full time or part time for #{current_course.name_and_code}",
          }
        end
      end
    end

    def location_row
      return if application_choice.school_placement_auto_selected?

      {
        key: 'Location',
        value: current_course_option.site_name,
      }.tap do |row|
        if unsubmitted? && current_course.multiple_sites?
          row[:action] = {
            href: candidate_interface_edit_course_choices_course_site_path(application_choice.id, current_course.id, current_course_option.study_mode),
            visually_hidden_text: "location for #{current_course.name_and_code}",
          }
        end
      end
    end

    def personal_statement_row
      {
        key: 'Personal statement',
        value: render(PersonalStatementSummaryComponent.new(application_choice:)),
      }
    end

    def provider
      application_choice.current_provider
    end
  end
end
