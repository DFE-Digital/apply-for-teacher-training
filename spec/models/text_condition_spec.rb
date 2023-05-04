require 'rails_helper'

RSpec.describe TextCondition do
  let(:text_condition) { build(:text_condition, description: 'Grow a beard') }

  describe '#status' do
    it 'defaults to pending' do
      expect(text_condition).to be_pending
    end
  end

  describe '#text' do
    it 'returns text detail attribute' do
      expect(text_condition.text).to eq('Grow a beard')
    end
  end
end
