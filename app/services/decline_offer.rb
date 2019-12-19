class DeclineOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ApplicationStateChange.new(@application_choice).decline!
    @application_choice.update!(declined_at: Time.zone.now)
    StateChangeNotifier.call(:offer_declined, application_choice: @application_choice)
  end
end
