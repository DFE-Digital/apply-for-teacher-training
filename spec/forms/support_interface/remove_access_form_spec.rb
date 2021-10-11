require 'rails_helper'

RSpec.describe SupportInterface::RemoveAccessForm, type: :model do
  let(:fraud_match) { create(:fraud_match) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }
  end

  describe '#save' do
    it 'updates the candidates email address to the desired format' do
      form = described_class.new({ accept_guidance: true })
      email_address = fraud_match.candidates.first.email_address

      form.save(fraud_match.candidates.first)

      expect(fraud_match.candidates.first.email_address).to eq(
        "fraud-match-id-#{fraud_match.id}-candidate-id-#{fraud_match.candidates.first.id}-#{email_address}",
      )
    end
  end
end
