module CheckboxOptionsHelper
  Checkbox = Struct.new(:id, :name, :hint_text)

  def disabilities_checkboxes
    DisabilityHelper::STANDARD_DISABILITIES.map do |id, disability|
      Checkbox.new(id, disability, I18n.t("equality_and_diversity.disabilities.#{id}.hint_text"))
    end
  end

  def standard_conditions_checkboxes
    OfferCondition::STANDARD_CONDITIONS.map do |condition|
      Checkbox.new(condition, condition, nil)
    end
  end
end
