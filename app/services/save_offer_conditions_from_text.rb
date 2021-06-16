class SaveOfferConditionsFromText
  attr_reader :application_choice, :conditions

  def initialize(application_choice:, conditions:)
    @application_choice = application_choice
    @conditions = conditions
  end

  def save
    offer = Offer.find_or_create_by(application_choice: application_choice)

    offer_conditions = conditions.map do |condition_text|
      offer.conditions.find_or_initialize_by(text: condition_text)
    end

    offer.conditions = offer_conditions
    offer.save!
  end
end
