require 'rails_helper'

RSpec.describe SupportInterface::RemoveAccessForm, type: :model do
  let(:duplicate_match) { create(:duplicate_match) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }
  end

  describe '#save' do
    it 'updates the candidates email address to the desired format' do
      form = described_class.new({ accept_guidance: true })
      email_address = duplicate_match.candidates.first.email_address

      form.save(duplicate_match.candidates.first)

      expect(duplicate_match.candidates.first.email_address).to eq(
        "fraud-match-id-#{duplicate_match.id}-candidate-id-#{duplicate_match.candidates.first.id}-#{email_address}",
      )
    end
  end
end
