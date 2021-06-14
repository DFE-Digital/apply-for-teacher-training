module CheckboxOptionsHelper
  def disabilities_checkboxes
    DisabilityHelper::STANDARD_DISABILITIES.map do |id, disability|
      OpenStruct.new(
        id: id,
        name: disability,
        hint_text: I18n.t("equality_and_diversity.disabilities.#{id}.hint_text"),
      )
    end
  end

  def standard_conditions_checkboxes
    OfferCondition::STANDARD_CONDITIONS.map do |condition|
      OpenStruct.new(
        id: condition,
        name: condition,
      )
    end
  end
end
