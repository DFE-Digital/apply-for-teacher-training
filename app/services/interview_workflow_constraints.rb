class InterviewWorkflowConstraints
  STATES_ALLOWING_INTERVIEW_CHANGES = ApplicationStateChange.interviewable.map(&:to_s).freeze

  attr_reader :interview, :today
  delegate :application_choice, to: :interview

  def initialize(interview:)
    @interview = interview
    @today = Time.zone.now.beginning_of_day
  end

  def create!
    application_not_in_interviewing_states?
  end

  def update!
    interview_in_the_past?
    interview_already_cancelled?
    application_not_in_interviewing_states?
  end

  def cancel!
    interview_in_the_past?
    interview_already_cancelled?
    application_not_in_interviewing_states?
  end

  def interview_in_the_past?
    old_date = interview.date_and_time_was

    if old_date.present? && old_date < today
      raise WorkflowError, error_message(:changing_a_past_interview)
    end
  end

  def interview_already_cancelled?
    if interview.cancelled_at_was
      raise WorkflowError, error_message(:changing_a_cancelled_interview)
    end
  end

  def application_not_in_interviewing_states?
    unless STATES_ALLOWING_INTERVIEW_CHANGES.include?(application_choice.status)
      raise WorkflowError, error_message(:changing_interviews_for_application_not_in_interviewing_states)
    end
  end

  def error_message(error)
    I18n.t("activemodel.errors.models.interview_workflow_constraints.attributes.#{error}")
  end

  class WorkflowError < StandardError; end
end
