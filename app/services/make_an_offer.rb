class MakeAnOffer
  Response = Struct.new(:successful?, :application_choice)

  def initialize(application_choice:, offer_conditions:)
    @application_choice = application_choice
    @offer_conditions = offer_conditions
  end

  def call
    if @offer_conditions.present?
      ApplicationStateChange.new(@application_choice).make_conditional_offer!
      @application_choice.offer = @offer_conditions
    else
      ApplicationStateChange.new(@application_choice).make_unconditional_offer!
      @application_choice.offer = { 'conditions' => [] }
    end

    @application_choice.save
    Response.new(true, @application_choice)
  end
end
