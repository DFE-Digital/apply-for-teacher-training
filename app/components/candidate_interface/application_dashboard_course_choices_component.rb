module CandidateInterface
  class ApplicationDashboardCourseChoicesComponent < ApplicationComponent
    include ViewHelper
    include CourseChoicesRowHelper

    def initialize(
      application_form:,
      editable: true,
      heading_level: 2,
      show_status: false,
      show_incomplete: false,
      missing_error: false,
      application_choice_error: false,
      render_link_to_find_when_rejected_on_qualifications: false,
      display_accepted_application_choices: false
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
    end

    def course_choice_rows(application_choice)
      [
        status_row(application_choice),
        rejection_reasons_row(application_choice),
        offer_withdrawal_reason_row(application_choice),
        interview_row(application_choice),
        ske_conditions_row(application_choice),
        reference_conditions_row(application_choice),
        conditions_row(application_choice),
        withdraw_row(application_choice),
        respond_to_offer_row(application_choice),
      ].compact
    end

    def any_withdrawable?
      @application_form.application_choices.any? do |application_choice|
        withdrawable?(application_choice)
      end
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.course_choices_completed && @editable
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

    def title_for(application_choice)
      "<span class=\"app-course-choice__provider-name\">#{application_choice.current_course.provider.name}</span>
      <span class=\"app-course-choice__course-name\">#{application_choice.current_course.name_and_code}</span>".html_safe
    end

  private

    attr_reader :application_form

    def successful_application?(application_choice)
      application_choice.pending_conditions? || application_choice.offer? || application_choice.offer_deferred?
    end

    def status_row(application_choice)
      if @show_status
        {
          key: 'Status',
          value: render(ApplicationStatusTagComponent.new(application_choice:)),
        }
      end
    end

    def multiple_courses?(application_choice)
      Course.current_cycle.where(provider: application_choice.provider).many?
    end

    def application_choices_with_accepted_states
      @application_form
        .application_choices
        .includes(:course, :site, :provider, :current_course, :current_course_option, :interviews)
        .includes(offer: :conditions)
        .order(id: :asc)
        .select { |ac| ac.status.to_sym.in?(ApplicationStateChange::ACCEPTED_STATES) }
    end

    def all_application_choices
      @application_form
        .application_choices
        .includes(:course, :site, :provider, :current_course, :current_course_option, :interviews)
        .includes(offer: :conditions)
        .order(id: :asc)
    end

    def application_choice_with_accepted_state_present?
      @application_form.application_choices.any? { |ac| ApplicationStateChange::ACCEPTED_STATES.include?(ac.status.to_sym) }
    end

    def withdraw_row(application_choice)
      return nil unless withdrawable?(application_choice)

      {
        key: ' ',
        value: render(
          CandidateInterface::CourseChoicesSummaryCardActionComponent.new(
            action: :withdraw,
            application_choice:,
          ),
        ),
      }
    end
  end
end
