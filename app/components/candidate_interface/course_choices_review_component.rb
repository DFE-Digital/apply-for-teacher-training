module CandidateInterface
  class CourseChoicesReviewComponent < ViewComponent::Base
    include ViewHelper

    def initialize(
      application_form:,
      editable: true,
      heading_level: 2,
      show_status: false,
      show_incomplete: false,
      missing_error: false,
      application_choice_error: false,
      render_link_to_find_when_rejected_on_qualifications: false,
      display_accepted_application_choices: false,
      return_to_application_review: false
    )

      @application_form = application_form
      @editable = editable
      @heading_level = heading_level
      @show_status = show_status
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @application_choice_error = application_choice_error
      @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
      @display_accepted_application_choices = display_accepted_application_choices
      @return_to_application_review = return_to_application_review
    end

    def course_choice_rows(application_choice)
      [
        course_row(application_choice),
        study_mode_row(application_choice),
        location_row(application_choice),
        type_row(application_choice),
        course_length_row(application_choice),
        start_date_row(application_choice),
        degree_required_row(application_choice),
        gcse_required_row(application_choice),
        status_row(application_choice),
        rejection_reasons_row(application_choice),
        offer_withdrawal_reason_row(application_choice),
        interview_row(application_choice),
        visa_details_row(application_choice),
      ].compact
    end

    def withdrawable?(application_choice)
      ApplicationStateChange.new(application_choice).can_withdraw?
    end

    def any_withdrawable?
      application_choices.any? do |application_choice|
        withdrawable?(application_choice)
      end
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.course_choices_completed && @editable
    end

    def course_change_path(application_choice)
      if multiple_courses?(application_choice)
        candidate_interface_edit_course_choices_course_path(
          application_choice.provider.id,
          change_path_params(application_choice),
        )
      end
    end

    def site_change_path(application_choice)
      if multiple_sites?(application_choice)
        candidate_interface_edit_course_choices_site_path(
          application_choice.provider.id,
          application_choice.current_course.id,
          application_choice.current_course_option.study_mode,
          change_path_params(application_choice),
        )
      end
    end

    def container_class(application_choice)
      return unless @editable

      if application_choice.course_option_availability_error?
        "govuk-inset-text app-inset-text--narrow-border app-inset-text--#{@application_choice_error ? 'error' : 'important'}"
      end
    end

    def application_choices
      @application_choices ||= if @display_accepted_application_choices && application_choice_with_accepted_state_present?
                                 # Reject all applications that do not have an ACCEPTED_STATE
                                 # These will appear in the CandidateInterface::PreviousApplications component
                                 application_choices_with_accepted_states
                               else
                                 all_application_choices
                               end
    end

  private

    attr_reader :application_form

    def application_choices_with_includes
      @application_form.application_choices.includes(
        %i[course site provider current_course current_course_option current_site interviews],
      )
    end

    def course_row(application_choice)
      {
        key: 'Course',
        value: course_row_value(application_choice),
        action: {
          href: course_change_path(application_choice),
          visually_hidden_text: "course choice for #{application_choice.current_course.name_and_code}",
        },
        html_attributes: {
          data: {
            qa: 'course-choice',
          },
        },
      }
    end

    def course_row_value(application_choice)
      if CycleTimetable.find_down?
        "#{application_choice.current_course.name} (#{application_choice.current_course.code})"
      else
        govuk_link_to("#{application_choice.current_course.name} (#{application_choice.current_course.code})", application_choice.current_course.find_url, target: '_blank', rel: 'noopener')
      end
    end

    def location_row(application_choice)
      {
        key: 'Location',
        value: "#{application_choice.current_site.name}\n#{application_choice.current_site.full_address}",
        action: {
          href: site_change_path(application_choice),
          visually_hidden_text: "location for #{application_choice.current_course.name_and_code}",
        },
        html_attributes: {
          data: {
            qa: 'course-choice-location',
          },
        },
      }
    end

    def study_mode_row(application_choice)
      return unless application_choice.current_course.full_time_or_part_time?

      change_path = candidate_interface_edit_course_choices_study_mode_path(
        application_choice.provider.id,
        application_choice.current_course.id,
        change_path_params(application_choice),
      )

      {
        key: 'Full time or part time',
        value: application_choice.current_course_option.study_mode.humanize,
        action: {
          href: change_path,
          visually_hidden_text: "study mode for #{application_choice.current_course.name_and_code}",
        },
        html_attributes: {
          data: {
            qa: 'course-choice-study-mode',
          },
        },
      }
    end

    def type_row(application_choice)
      {
        key: 'Type',
        value: application_choice.current_course.description,
      }
    end

    def course_length_row(application_choice)
      {
        key: 'Course length',
        value: DisplayCourseLength.call(course_length: application_choice.current_course.course_length),
      }
    end

    def start_date_row(application_choice)
      unless application_choice.offer_deferred?
        {
          key: 'Date course starts',
          value: application_choice.current_course.start_date.to_s(:month_and_year),
        }
      end
    end

    def degree_required_row(application_choice)
      return nil unless application_choice.current_course.degree_grade?

      {
        key: 'Degree requirements',
        value: render(DegreeRequiredComponent.new(application_choice)),
      }
    end

    def gcse_required_row(application_choice)
      {
        key: 'GCSE requirements',
        value: render(PendingGcseRequiredComponent.new(application_choice)),
      }
    end

    def interview_row(application_choice)
      if application_choice.interviews.kept.any?
        {
          key: 'Interview'.pluralize(application_choice.interviews.size),
          value: render(InterviewBookingsComponent.new(application_choice)),
        }
      end
    end

    def visa_details_row(application_choice)
      return nil if right_to_work_or_study?(application_choice) ||
                    application_predates_visa_sponsorship_information?(application_choice)

      {
        key: 'Visa sponsorship',
        value: render(CourseChoicesReviewVisaStatusComponent.new(application_choice: application_choice)),
      }
    end

    def right_to_work_or_study?(application_choice)
      application_choice.application_form.british_or_irish? ||
        application_choice.application_form.right_to_work_or_study_yes?
    end

    def application_predates_visa_sponsorship_information?(application_choice)
      application_choice.application_form.recruitment_cycle_year < 2022
    end

    def status_row(application_choice)
      if @show_status
        {
          key: 'Status',
          value: render(ApplicationStatusTagComponent.new(application_choice: application_choice)),
        }
      end
    end

    def offer_withdrawal_reason_row(application_choice)
      return nil unless application_choice.offer_withdrawn?

      if application_choice.offer_withdrawal_reason.present?
        {
          key: 'Reason for offer withdrawal',
          value: application_choice.offer_withdrawal_reason,
        }
      end
    end

    def rejection_reasons_row(application_choice)
      return nil unless application_choice.rejected?

      if application_choice.structured_rejection_reasons.present?
        {
          key: 'Feedback',
          value: render(
            ReasonsForRejectionComponent.new(
              application_choice: application_choice,
              reasons_for_rejection: ReasonsForRejection.new(application_choice.structured_rejection_reasons),
              editable: false,
              render_link_to_find_when_rejected_on_qualifications: @render_link_to_find_when_rejected_on_qualifications,
            ),
          ),
        }
      elsif application_choice.rejection_reason.present?
        {
          key: 'Feedback',
          value: application_choice.rejection_reason,
        }
      end
    end

    def multiple_sites?(application_choice)
      CourseOption.available.where(course_id: application_choice.current_course.id, study_mode: application_choice.current_course_option.study_mode).many?
    end

    def multiple_courses?(application_choice)
      Course.current_cycle.where(provider: application_choice.provider).many?
    end

    def application_choices_with_accepted_states
      application_choices_with_includes.order(id: :asc)
        .order(id: :asc)
        .select { |ac| ac.status.to_sym.in?(ApplicationStateChange::ACCEPTED_STATES) }
    end

    def all_application_choices
      application_choices_with_includes.order(id: :asc)
    end

    def application_choice_with_accepted_state_present?
      @application_form.application_choices.any? { |ac| ApplicationStateChange::ACCEPTED_STATES.include?(ac.status.to_sym) }
    end

    def change_path_params(application_choice)
      params = { course_choice_id: application_choice.id }
      if @return_to_application_review
        params.merge(return_to_application_review_params)
      else
        params.merge(return_to_section_review_params)
      end
    end

    def return_to_application_review_params
      { 'return-to' => 'application-review' }
    end

    def return_to_section_review_params
      { 'return-to' => 'section-review' }
    end
  end
end
