class UpdateInterview
  include ImpersonationAuditHelper

  attr_reader :auth, :interview, :provider, :date_and_time, :location, :additional_details, :application_choice

  def initialize(
    actor:,
    interview:,
    provider:,
    date_and_time:,
    location:,
    additional_details:
  )
    @auth = ProviderAuthorisation.new(actor: actor)
    @interview = interview
    @provider = provider
    @date_and_time = date_and_time
    @location = location
    @additional_details = additional_details
    @application_choice = interview.application_choice
  end

  def save!
    auth.assert_can_set_up_interviews!(application_choice: application_choice,
                                       course_option: application_choice.current_course_option)

    interview.provider = provider || interview.provider
    interview.date_and_time = date_and_time || interview.date_and_time
    interview.location = location || interview.location
    interview.additional_details = additional_details || interview.additional_details

    return unless interview.changed?

    if interview_validations.valid?
      audit(auth.actor) do
        interview.save!

        CandidateMailer.interview_updated(interview.application_choice, interview).deliver_later
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
