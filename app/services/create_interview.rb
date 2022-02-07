class CreateInterview
  include ImpersonationAuditHelper

  attr_reader :auth, :application_choice, :interview

  def initialize(
    actor:,
    application_choice:,
    provider:,
    date_and_time:,
    location:,
    additional_details:
  )
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @interview = Interview.new(application_choice: application_choice,
                               provider: provider,
                               date_and_time: date_and_time,
                               location: location,
                               additional_details: additional_details)
  end

  def save!
    auth.assert_can_set_up_interviews!(application_choice: application_choice,
                                       course_option: application_choice.current_course_option)

    if interview_validations.valid?
      audit(auth.actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).interview!

          interview.save!
        end

        CandidateMailer.new_interview(application_choice, @interview).deliver_later
      end
    else
      raise ValidationException, interview_validations.errors.map(&:message)
    end
  end

private

  def interview_validations
    @interview_validations ||= InterviewValidations.new(interview: interview)
  end
end
