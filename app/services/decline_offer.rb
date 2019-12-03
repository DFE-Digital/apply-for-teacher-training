class DeclineOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ApplicationStateChange.new(@application_choice).decline!
    StateChangeNotifier.call(:offer_declined, application_choice: @application_choice)
  end
end
