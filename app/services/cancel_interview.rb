class CancelInterview
  include ImpersonationAuditHelper

  attr_reader :auth, :application_choice, :interview, :cancellation_reason

  def initialize(
    actor:,
    application_choice:,
    interview:,
    cancellation_reason:
  )
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @interview = interview
    @cancellation_reason = cancellation_reason
  end

  def save!
    auth.assert_can_set_up_interviews!(application_choice: application_choice,
                                       course_option: application_choice.current_course_option)

    raise_error_if_state_transition_not_allowed!

    interview.cancellation_reason = cancellation_reason
    interview.cancelled_at = Time.zone.now

    if interview_validations.valid?
      audit(auth.actor) do
        ActiveRecord::Base.transaction do
          interview.save!

          ApplicationStateChange.new(application_choice).cancel_interview! if @application_choice.interviews.kept.none?
        end

        CandidateMailer.interview_cancelled(application_choice, interview, cancellation_reason).deliver_later
      end
    else
      raise ValidationException, interview_validations.errors.map(&:message)
    end
  end

  def raise_error_if_state_transition_not_allowed!
    unless ApplicationStateChange.new(application_choice).can_cancel_interview?
      raise "Interview cannot be cancelled when the application_choice is in #{application_choice.status} state"
    end
  end

private

  def interview_validations
    @interview_validations ||= InterviewValidations.new(interview: interview)
  end
end
