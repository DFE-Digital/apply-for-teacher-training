require 'rails_helper'

RSpec.describe ReferenceCondition do
  let(:reference_condition) { build(:reference_condition) }

  describe '#status' do
    it 'defaults to pending' do
      expect(reference_condition).to be_pending
    end
  end

  describe '#text' do
    it 'returns humanised text' do
      expect(reference_condition.text).to eq('Specific references')
    end
  end
end
