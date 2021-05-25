class UpdateOfferConditions
  def initialize(application_choice:)
    @application_choice = application_choice
    @conditions = application_choice.offer&.[]('conditions')
  end

  def call
    offer = Offer.find_or_create_by(application_choice: @application_choice)
    offer.conditions.destroy_all
    conditions_attrs = @conditions.map do |condition|
      {
        text: condition,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      }
    end
    offer.conditions.insert_all!(conditions_attrs)
  end
end
