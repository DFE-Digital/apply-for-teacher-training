require 'rails_helper'

RSpec.describe RejectionReasons::Reason do
  describe 'validations' do
    it 'validates that a reason has been selected' do
      reason = described_class.new(
        id: 'aaa',
        reasons_id: 'aaa_reasons',
        reasons: [{ id: 'bbb' }],
        selected_reasons: [],
      )
      expect(reason.valid?).to be false
      expect(reason.errors.attribute_names).to eq([:aaa_reasons])

      reason.selected_reasons << described_class.new(id: 'ccc')

      expect(reason.valid?).to be true
    end

    it 'validates details' do
      reason = described_class.new(
        id: 'aaa',
        details: { id: 'bbb', text: nil },
      )
      expect(reason.valid?).to be false
      expect(reason.errors.attribute_names).to eq([:bbb])

      reason.details = RejectionReasons::Details.new(id: 'ccc', text: 'yeh')

      expect(reason.valid?).to be true
    end
  end
end
