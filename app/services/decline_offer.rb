class DeclineOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ApplicationStateChange.new(@application_choice).decline!
    @application_choice.update!(
      declined_at: Time.zone.now,
      withdrawn_or_declined_for_candidate_by_provider: false,
    )

    if @application_choice.application_form.ended_without_success?
      recommended_courses_url = CandidateCoursesRecommender.recommended_courses_url(
        candidate: @application_choice.candidate,
        locatable: @application_choice.course.provider,
      )
      CandidateMailer.decline_last_application_choice(@application_choice, recommended_courses_url).deliver_later
    end

    NotificationsList.for(@application_choice, event: :declined, include_ratifying_provider: true).each do |provider_user|
      ProviderMailer.declined(provider_user, @application_choice).deliver_later
    end
  end
end
