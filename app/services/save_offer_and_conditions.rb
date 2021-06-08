class SaveOfferAndConditions
  attr_reader :application_choice, :conditions

  def initialize(application_choice:, conditions:)
    @application_choice = application_choice
    @conditions = conditions
  end

  def save
    application_choice.offer = { 'conditions' => conditions }
    UpdateOfferConditions.new(application_choice: application_choice).call
  end
end
