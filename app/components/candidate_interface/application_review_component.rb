module CandidateInterface
  class ApplicationReviewComponent < ApplicationComponent
    include CourseFeeRowHelper

    attr_reader :application_choice
    delegate :interviewing?,
             :unsubmitted?,
             :current_course,
             :current_course_option,
             to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def rows
      [
        status_row,
        application_number_row,
        submitted_at_row,
        course_info_row,
        course_fee_row(current_course),
        qualifications_row,
        course_length_row,
        study_mode_row,
        location_row,
        personal_statement_row,
        interview_row,
        rejection_reasons_row,
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

    def application_number_row
      return unless application_choice.sent_to_provider_at

      { key: 'Application number', value: application_choice.id }
    end

    def submitted_at_row
      return unless application_choice.sent_to_provider_at

      value = "#{application_choice.sent_to_provider_at.to_fs(:govuk_date_and_time)} (#{time_ago_in_words(application_choice.sent_to_provider_at)} ago)"

      { key: 'Application submitted', value: }
    end

    def course_info_row
      {
        key: 'Course',
        value: govuk_link_to(current_course.name_and_code, current_course.find_url, target: '_blank', rel: 'noopener'),
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

    def interview_row
      return unless interviewing?

      {
        key: 'Interview',
        value: @application_choice.interviews.kept.map { |interview| render(InterviewSummaryComponent.new(interview:)) },
      }
    end

    def rejection_reasons_row
      return unless application_choice.rejected?
      return unless application_choice.rejection_reason.present? || application_choice.structured_rejection_reasons.present?

      {
        key: 'Reasons for rejection',
        value: render(
          CandidateInterface::RejectionsComponent.new(
            application_choice:,
            render_link_to_find_when_rejected_on_qualifications: true,
            feedback_button: true,
          ),
        ),
      }
    end

    def show_what_happens_next?
      ApplicationStateChange::DECISION_PENDING_AND_INACTIVE_STATUSES.include?(@application_choice.status.to_sym)
    end

    def holiday_response_time_warning_text
      return unless application_choice.unsubmitted?

      if holiday_response_time_indicator.christmas_response_time_delay_possible?
        govuk_warning_text(text: t('.christmas_warning'))
      elsif holiday_response_time_indicator.easter_response_time_delay_possible?
        govuk_warning_text(text: t('.easter_warning'))
      end
    end

    def show_easter_or_christmas_delay_text?
      holiday_response_time_indicator.holiday_response_time_delay_possible?
    end

    def show_withdraw?
      ApplicationStateChange.new(@application_choice).can_withdraw?
    end

    def show_provider_contact_component?
      application_states = %w[
        awaiting_provider_decision
        inactive
        interviewing
        offer
      ]

      application_choice.status.in?(application_states)
    end

    def can_add_more_choices?
      application_choice.application_form.can_add_more_choices?
    end

    def provider
      application_choice.current_provider
    end

    def holiday_response_time_indicator
      @holiday_response_time_indicator ||= CandidateInterface::HolidayResponseTimeIndicator.new(application_choice:)
    end
  end
end
