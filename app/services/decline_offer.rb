class DeclineOffer
  include ActiveModel::Validations

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save
    ApplicationStateChange.new(@application_choice).decline!
    StateChangeNotifier.call(:offer_declined, application_choice: @application_choice)
    # FUTURE: send an email to the candidate
    true
  rescue Workflow::NoTransitionAllowed => e
    errors.add(:state, e.message)
    false
  end
end
