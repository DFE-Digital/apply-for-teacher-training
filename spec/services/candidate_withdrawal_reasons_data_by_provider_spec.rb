require 'rails_helper'

RSpec.describe CandidateWithdrawalReasonsDataByProvider do
  let(:provider) { create(:provider) }
  let!(:report) { create(:withdrawal_reasons_report, provider:) }

  describe '#all_rows' do
    context 'when report is present' do
      it 'returns data for the report' do
        rows = described_class.new(provider).all_rows

        expect(rows.present?).to be(true)
      end
    end

    context 'when report is not present' do
      let!(:report) { nil }

      it 'returns an empty array' do
        expect(described_class.new(provider).all_rows).to eq []
      end
    end
  end
end
