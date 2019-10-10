class MakeAnOffer
  include ActiveModel::Validations

  def initialize(application_choice:, offer_conditions:)
    @application_choice = application_choice
    @offer_conditions = offer_conditions
  end

  def save
    if @offer_conditions.present?
      ApplicationStateChange.new(@application_choice).make_conditional_offer!
      @application_choice.offer = { 'conditions' => @offer_conditions }
    else
      ApplicationStateChange.new(@application_choice).make_unconditional_offer!
      @application_choice.offer = { 'conditions' => [] }
    end

    @application_choice.save
  rescue Workflow::NoTransitionAllowed => e
    errors.add(:state, e.message)
    false
  end
end
