require 'rails_helper'

RSpec.describe CheckboxOptionsHelper, type: :helper do
  describe '#disabilities_checkboxes' do
    it 'return a stuctured list of all listed disabilities' do
      id, name = DisabilityHelper::STANDARD_DISABILITIES.sample

      expect(disabilities_checkboxes).to include(
        CheckboxOptionsHelper::Checkbox.new(id, name, I18n.t("equality_and_diversity.disabilities.#{id}.hint_text")),
      )
    end
  end

  describe '#standard_conditions_checkboxes' do
    it 'returns structured data for standard offer conditions' do
      expected = OfferCondition::STANDARD_CONDITIONS.map do |condition|
        CheckboxOptionsHelper::Checkbox.new(condition, condition, nil)
      end

      expect(standard_conditions_checkboxes).to eq(expected)
    end
  end
end
