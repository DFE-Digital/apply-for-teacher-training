class CreateInterview
  attr_reader :auth, :application_choice, :provider, :date_and_time, :location, :additional_details

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
    @provider = provider
    @date_and_time = date_and_time
    @location = location
    @additional_details = additional_details
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

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(application_choice).interview!

      @interview = Interview.new(application_choice: application_choice,
                                 provider: provider,
                                 date_and_time: date_and_time,
                                 location: location,
                                 additional_details: additional_details)
      @interview.save!
    end

    CandidateMailer.new_interview(application_choice, @interview).deliver_later
  end
end
