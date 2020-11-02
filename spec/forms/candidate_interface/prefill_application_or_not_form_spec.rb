require 'rails_helper'

RSpec.describe CandidateInterface::PrefillApplicationOrNotForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:prefill) }
  end

  describe '#prefill?' do
    it "returns false if prefill is 'false'" do
      form = described_class.new(prefill: 'false')
      expect(form.prefill?).to be false
    end

    it "returns true if prefill is 'true'" do
      form = described_class.new(prefill: 'true')
      expect(form.prefill?).to be true
    end
  end
end
