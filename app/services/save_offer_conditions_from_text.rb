class SaveOfferConditionsFromText
  attr_reader :application_choice, :conditions

  def initialize(application_choice:, conditions: nil)
    @application_choice = application_choice
    @conditions = conditions || application_choice&.offer&.conditions&.map(&:text) || []
  end

  def save
    offer = Offer.find_or_create_by(application_choice: application_choice)
    offer.conditions.delete_all
    conditions_attrs = conditions.map do |condition|
      {
        text: condition,
        status: condition_status,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      }
    end
    offer.conditions.insert_all!(conditions_attrs) if conditions_attrs.any?
  end

private

  def condition_status
    @condition_status ||= if application_choice.recruited?
                            :met
                          elsif application_choice.conditions_not_met?
                            :unmet
                          else
                            :pending
                          end
  end
end
