require 'rails_helper'

RSpec.describe CheckboxOptionsHelper, type: :helper do
  describe '#disabilities_checkboxes' do
    it 'return a stuctured list of all listed disabilities' do
      id, name = DisabilityHelper::STANDARD_DISABILITIES.sample

      expect(disabilities_checkboxes).to include(
        OpenStruct.new(
          id: id,
          name: name,
          hint_text: I18n.t("equality_and_diversity.disabilities.#{id}.hint_text"),
        ),
      )
    end
  end

  describe '#standard_conditions_checkboxes' do
    it 'returns structured data for standard offer conditions' do
      expected = OfferCondition::STANDARD_CONDITIONS.map do |condition|
        OpenStruct.new(id: condition, name: condition)
      end

      expect(standard_conditions_checkboxes).to eq(expected)
    end
  end
end
