class UpdateInterview
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
    if FeatureFlag.active?(:interview_permissions)
      auth.assert_can_set_up_interviews!(
        application_choice: application_choice,
        course_option: application_choice.current_course_option,
      )
    else
      auth.assert_can_make_decisions!(
        application_choice: application_choice,
        course_option: application_choice.current_course_option,
      )
    end

    interview.provider = provider
    interview.date_and_time = date_and_time
    interview.location = location
    interview.additional_details = additional_details

    return unless interview.changed?

    interview.save!

    CandidateMailer.interview_updated(interview.application_choice, interview).deliver_later
  end
end
