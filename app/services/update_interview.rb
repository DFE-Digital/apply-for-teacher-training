class UpdateInterview
  attr_reader :auth, :interview, :provider, :date_and_time, :location, :additional_details

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
  end

  def save!
    auth.assert_can_set_up_interviews!(
      application_choice: interview.application_choice,
      course_option: interview.application_choice.current_course_option,
    )

    interview.provider = provider
    interview.date_and_time = date_and_time
    interview.location = location
    interview.additional_details = additional_details

    return unless interview.changed?

    interview.save!

    CandidateMailer.interview_updated(interview.application_choice, interview).deliver_later
  end
end
