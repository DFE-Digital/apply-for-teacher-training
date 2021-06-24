class SaveOfferConditionsFromText
  attr_reader :offer, :conditions

  def initialize(application_choice:, conditions:)
    @offer = application_choice.offer || application_choice.build_offer
    @conditions = conditions.reject(&:blank?)
  end

  def save
    offer_conditions = conditions.map do |condition_text|
      offer.conditions.find_or_initialize_by(text: condition_text)
    end

    offer.conditions = offer_conditions
    offer.save!
  end
end
