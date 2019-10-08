class ConfirmOfferConditions
  Response = Struct.new(:successful?, :application_choice)

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    ApplicationStateChange.new(@application_choice).confirm_conditions_met!
    Response.new(true, @application_choice)
  end
end
