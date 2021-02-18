class AcceptUnconditionalOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).accept_unconditional_offer!
      @application_choice.update!(accepted_at: Time.zone.now, recruited_at: Time.zone.now)
    end

    # TODO: Mailer methods for unconditional offers (needs provider & candidate notifications).
    CandidateMailer.offer_accepted(@application_choice).deliver_later

    StateChangeNotifier.new(:recruited, @application_choice).application_outcome_notification
  end
end
