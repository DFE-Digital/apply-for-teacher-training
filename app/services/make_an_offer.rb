class MakeAnOffer
  Response = Struct.new(:successful?, :application_choice)

  def initialize(application_choice:, offer_conditions:)
    @application_choice = application_choice
    @offer_conditions = offer_conditions
  end

  def call
    @application_choice.status = @offer_conditions.present? ? :conditional_offer : :unconditional_offer
    @application_choice.offer = @offer_conditions.present? ? @offer_conditions : { 'conditions' => [] }
    @application_choice.save
    Response.new(true, @application_choice)
  end
end
