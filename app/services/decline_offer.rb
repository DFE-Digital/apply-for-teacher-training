class DeclineOffer
  def initialize(application_choice:, accepted_offer: false)
    @application_choice = application_choice
    @accepted_offer = accepted_offer
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
      if @accepted_offer
        ProviderMailer.declined_automatically_on_accept_offer(provider_user, @application_choice).deliver_later
      else
        ProviderMailer.declined(provider_user, @application_choice).deliver_later
      end
    end
  end
end
