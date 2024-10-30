require 'rails_helper'

RSpec.describe ProviderInterface::CandidateWithdrawalDataByProvider do
  let(:provider) { create(:provider) }

  describe '#submitted_withdrawal_reason_count' do
    context 'when there are no withdrawals submitted for the provider' do
      it 'returns zero' do
        expect(described_class.new(provider: provider).submitted_withdrawal_reason_count).to eq(0)
      end
    end

    context 'when there are withdrawals submitted for the provider' do
      let!(:application_choice) { create(:application_choice, :with_structured_withdrawal_reasons, provider_ids: [provider.id]) }

      it 'returns the count of submitted withdrawals' do
        expect(described_class.new(provider: provider).submitted_withdrawal_reason_count).to eq(1)
      end
    end
  end

  describe '#withdrawal_data' do
    let(:config_path) { Rails.root.join('config/withdrawal_reasons.yml') }
    let(:selectable_reasons) { YAML.load_file(config_path) }
    let!(:application_choice_with_accepted_offer) { create(:application_choice, :withdrawn, accepted_at: 3.days.ago, structured_withdrawal_reasons: ['provider_behaviour'], provider_ids: [provider.id]) }

    before do
      create_list(:application_choice, 2, :with_structured_withdrawal_reasons, provider_ids: [provider.id])
    end

    it 'returns withdrawal data grouped by reason' do
      withdrawal_data = described_class.new(provider: provider).withdrawal_data

      expect(withdrawal_data.size).to eq(selectable_reasons.size)

      expect(withdrawal_data.find { |data| data[:header] == 'I have concerns about the cost of doing the course' }[:values]).to eq([2, 0, 2])
      expect(withdrawal_data.find { |data| data[:header] == 'The training provider has not responded to me' }[:values]).to eq([0, 1, 1])
    end

    context 'when the candidate is not associated with the provider' do
      let(:other_provider) { create(:provider) }

      it 'does not return the candidates withdrawal data' do
        withdrawal_data = described_class.new(provider: other_provider).withdrawal_data

        expect(withdrawal_data.all? { |data| data[:values].all?(&:zero?) }).to be_truthy
      end
    end
  end
end
