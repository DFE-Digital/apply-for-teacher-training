require 'rails_helper'

RSpec.describe Publications::WithdrawalReasonsReportGenerator do
  include DfE::Bigquery::TestHelper

  subject(:generator) { described_class.new(provider_id:, recruitment_cycle_year:) }

  before do
    stub_bigquery_withdrawal_reasons_request(
      rows: [[
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: provider_id.to_s },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_2' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore.another-career-path-or-accepted-a-job-offer' },
        { name: 'before_accepting', type: 'STRING', value: '28' },
        { name: 'after_accepting', type: 'STRING', value: '7' },
      ]],
    )
  end

  let(:provider_id) { create(:provider).id }
  let(:recruitment_cycle_year) { 2026 }
  let(:attributes) do
    [
      {
        'provider_code' => 'code',
        'provider_id' => provider_id.to_s,
        'provider_name' => 'provider name',
        'recruitment_cycle_year' => '2026',
        'withdrawal_tier' => 'tier_2',
        'tier_withdrawal_reason' => 'do-not-want-to-train-anymore.another-career-path-or-accepted-a-job-offer',
        'before_accepting' => '28',
        'after_accepting' => '7',
      },
    ]
  end

  it 'returns data' do
    expect(generator.data).to eq(attributes)
  end

  describe '#call' do
    it 'creates a new report' do
      expect { generator.call }.to change(Publications::WithdrawalReasonsReport, :count).by(1)
    end

    it 'stores the correct data in the model' do
      generator.call

      model = Publications::WithdrawalReasonsReport.last

      expect(model).to have_attributes({
        provider_id: provider_id,
        recruitment_cycle_year:,
        statistics: attributes,
      })
    end

    context 'when data is blank' do
      before do
        stub_bigquery_withdrawal_reasons_request(result: false)
      end

      it 'does not store data in the model' do
        generator.call

        expect { generator.call }.to not_change(Publications::WithdrawalReasonsReport, :count)
      end
    end
  end
end
