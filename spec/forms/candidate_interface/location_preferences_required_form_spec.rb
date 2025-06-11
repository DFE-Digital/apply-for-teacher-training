require 'rails_helper'

RSpec.describe CandidateInterface::LocationPreferencesRequiredForm, type: :model do
  subject(:form) do
    described_class.new({ preference: })
  end

  let(:preference) do
    create(:candidate_preference)
  end

  describe '#valid?' do
    it 'returns error if there are no location preferences' do
      expect(form.valid?).to be false
      expect(form.errors[:base].first).to eq 'Add an area you can train in'
    end
  end
end
