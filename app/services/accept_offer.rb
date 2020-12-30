class AcceptOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    declined = []
    withdrawn = []

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).accept!
      @application_choice.update!(accepted_at: Time.zone.now)

      StateChangeNotifier.disable_notifications do
        other_application_choices_with_offers.each do |application_choice|
          DeclineOffer.new(application_choice: application_choice).save!
          declined << application_choice
        end

        application_choices_awaiting_provider_decision.each do |application_choice|
          WithdrawApplication.new(application_choice: application_choice).save!
          withdrawn << application_choice
        end
      end
    end

    NotificationsList.for(@application_choice).each do |provider_user|
      ProviderMailer.offer_accepted(provider_user, @application_choice).deliver_later
      Metrics::Tracker.new(@application_choice, 'notifications.on', provider_user).track(:offer_accepted)
    end

    NotificationsList.off_for(@application_choice).each do |provider_user|
      Metrics::Tracker.new(@application_choice, 'notifications.off', provider_user).track(:offer_accepted)
    end

    CandidateMailer.offer_accepted(@application_choice).deliver_later

    StateChangeNotifier.accept_offer(accepted: @application_choice, declined: declined, withdrawn: withdrawn)
  end

private

  def other_application_choices_with_offers
    @application_choice
      .self_and_siblings
      .offer
      .where.not(id: @application_choice.id)
  end

  def application_choices_awaiting_provider_decision
    @application_choice
      .self_and_siblings
      .awaiting_provider_decision
  end
end
