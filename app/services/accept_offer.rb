class AcceptOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).accept!
      @application_choice.update!(accepted_at: Time.zone.now)

      other_application_choices_with_offers.each do |other_application_choice|
        DeclineOffer.new(application_choice: other_application_choice).save!
      end

      application_choices_awaiting_provider_decision.each do |application_choices|
        WithdrawApplication.new(application_choice: application_choices).save!
      end
    end

    StateChangeNotifier.call(:offer_accepted, application_choice: @application_choice)
  end

private

  def other_application_choices_with_offers
    @application_choice
      .application_form
      .application_choices
      .offer
      .where.not(id: @application_choice.id)
  end

  def application_choices_awaiting_provider_decision
    @application_choice
      .application_form
      .application_choices
      .awaiting_provider_decision
  end
end
