class AcceptUnconditionalOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).accept_unconditional_offer!
      @application_choice.update!(accepted_at: Time.zone.now, recruited_at: Time.zone.now)
    end

    NotificationsList.for(@application_choice, include_ratifying_provider: true).each do |provider_user|
      ProviderMailer.offer_accepted(provider_user, @application_choice).deliver_later
    end

    CandidateMailer.offer_accepted(@application_choice).deliver_later

    StateChangeNotifier.new(:recruited, @application_choice).application_outcome_notification
  end
end
