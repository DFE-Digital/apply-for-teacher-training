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
      CandidateMailers::SendDeclinedLastApplicationChoiceEmailWorker.perform_async(@application_choice.id)
    end

    NotificationsList.for(@application_choice, event: :declined, include_ratifying_provider: true).each do |provider_user|
      ProviderMailer.declined(provider_user, @application_choice).deliver_later
    end
  end
end
