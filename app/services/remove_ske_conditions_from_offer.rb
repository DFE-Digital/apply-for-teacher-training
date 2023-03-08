class RemoveSkeConditionsFromOffer
  attr_reader :offer

  def initialize(offer:)
    @offer = offer
  end

  def call
    offer.ske_conditions.destroy_all
  end
end
