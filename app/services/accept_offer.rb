class AcceptOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).accept!

      other_application_choices_with_offers.each do |other_application_choice|
        ApplicationStateChange.new(other_application_choice).decline!
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
end
