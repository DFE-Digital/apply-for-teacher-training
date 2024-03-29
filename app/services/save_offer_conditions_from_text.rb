class SaveOfferConditionsFromText
  attr_reader :offer, :conditions

  def initialize(application_choice:, conditions:)
    @offer = application_choice.offer || application_choice.build_offer
    @conditions = conditions.compact_blank
  end

  def save
    offer_conditions = conditions.map do |condition_text|
      offer.conditions.find_by("details->>'description' = ?", condition_text) ||
        offer.conditions.build(type: 'TextCondition', details: { description: condition_text })
    end

    offer.conditions = offer_conditions
    offer.save!
  end
end
