class AcceptUnconditionalOffer < AcceptOffer
  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).accept_unconditional_offer!
      @application_choice.update!(accepted_at: Time.zone.now, recruited_at: Time.zone.now)

      withdraw_and_decline_associated_application_choices!
    end

    NotificationsList.for(@application_choice, event: :unconditional_offer_accepted, include_ratifying_provider: true).each do |provider_user|
      ProviderMailer.unconditional_offer_accepted(provider_user, @application_choice).deliver_later
    end

    application_choice.application_form.application_references.creation_order.includes([:application_form]).not_requested_yet.each do |reference|
      RequestReference.new.call(reference)
    end

    CandidateMailer.unconditional_offer_accepted(@application_choice).deliver_later
  rescue Workflow::NoTransitionAllowed
    false
  end
end
