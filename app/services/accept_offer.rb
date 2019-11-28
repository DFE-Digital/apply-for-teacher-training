class AcceptOffer
  include ActiveModel::Validations

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save
    ApplicationStateChange.new(@application_choice).accept!

    other_application_choices = @application_choice
      .application_form
      .application_choices
      .offer
      .where.not(id: @application_choice.id)

    other_application_choices.each do |other_application_choice|
      ApplicationStateChange.new(other_application_choice).decline!
    end

    StateChangeNotifier.call(:offer_accepted, application_choice: @application_choice)
    # FUTURE: This is where we send an email to the candidate

    true
  rescue Workflow::NoTransitionAllowed => e
    errors.add(:state, e.message)
    false
  end
end
