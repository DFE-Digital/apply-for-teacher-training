class UpdateInterviewsProvider
  include ImpersonationAuditHelper

  attr_reader :auth, :interviews, :provider, :application_choice

  def initialize(
    actor:,
    application_choice:,
    provider:
  )
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @provider = provider
    @interviews = application_choice.interviews
  end

  def save!
    auth.assert_can_set_up_interviews!(application_choice: application_choice,
                                       course_option: application_choice.current_course_option)

    return if interview_list.empty?

    interview_list.each { |interview| update_provider!(interview) }
  end

  def notify
    return if interview_list.empty?

    interview_list.map do |interview|
      CandidateMailer.interview_updated(interview.application_choice, interview).deliver_later
    end
  end

private

  def interview_list
    @interview_list ||= interviews.upcoming.reject do |interview|
      interview.cancelled? || provider_already_associated_with_interview?(interview)
    end
  end

  def provider_already_associated_with_interview?(interview)
    interview.provider == provider || interview.provider == application_choice.current_accredited_provider
  end

  def update_provider!(interview)
    interview.provider = provider

    InterviewWorkflowConstraints.new(interview: interview).update!

    interview_validations = InterviewValidations.new(interview: interview)

    if interview_validations.valid?(:update)
      audit(auth.actor) do
        interview.save!
      end
    else
      raise ValidationException, interview_validations.errors.map(&:message)
    end
  end
end
