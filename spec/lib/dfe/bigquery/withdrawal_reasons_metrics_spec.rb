require 'rails_helper'

RSpec.describe DfE::Bigquery::WithdrawalReasonsMetrics do
  include DfE::Bigquery::TestHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle(2026))
  end

  describe '.data' do
    let(:provider) { create(:provider) }
    let(:rows) do
      [[
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: '1' },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_2' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore.another-career-path-or-accepted-a-job-offer' },
        { name: 'before_accepting', type: 'STRING', value: '28' },
        { name: 'after_accepting', type: 'STRING', value: '7' },
      ], [
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: '1' },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_2' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore.other' },
        { name: 'before_accepting', type: 'STRING', value: '4' },
        { name: 'after_accepting', type: 'STRING', value: '0' },
      ], [
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: '1' },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_2' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore.personal-circumstances-have-changed' },
        { name: 'before_accepting', type: 'STRING', value: '13' },
        { name: 'after_accepting', type: 'STRING', value: '4' },
      ], [
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: '1' },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_3' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore.personal-circumstances-have-changed.other' },
        { name: 'before_accepting', type: 'STRING', value: '0' },
        { name: 'after_accepting', type: 'STRING', value: '2' },
      ], [
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: '1' },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_3' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore.personal-circumstances-have-changed.concerns-about-having-enough-time-to-train' },
        { name: 'before_accepting', type: 'STRING', value: '5' },
        { name: 'after_accepting', type: 'STRING', value: '1' },
      ], [
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: '1' },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_3' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore.personal-circumstances-have-changed.concerns-about-cost-of-doing-course' },
        { name: 'before_accepting', type: 'STRING', value: '9' },
        { name: 'after_accepting', type: 'STRING', value: '2' },
      ], [
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: '1' },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_3' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore.personal-circumstances-have-changed.concerns-about-training-with-a-disability-or-health-condition' },
        { name: 'before_accepting', type: 'STRING', value: '1' },
        { name: 'after_accepting', type: 'STRING', value: '0' },
      ], [
        { name: 'provider_code', type: 'STRING', value: 'code' },
        { name: 'provider_id', type: 'STRING', value: '1' },
        { name: 'provider_name', type: 'STRING', value: 'provider name' },
        { name: 'recruitment_cycle_year', type: 'STRING', value: '2026' },
        { name: 'withdrawal_tier', type: 'STRING', value: 'tier_1' },
        { name: 'tier_withdrawal_reason', type: 'STRING', value: 'do-not-want-to-train-anymore' },
        { name: 'before_accepting', type: 'STRING', value: '41' },
        { name: 'after_accepting', type: 'STRING', value: '11' },
      ]]
    end

    let(:results) do
      [{
        provider_code: 'code',
        provider_id: '1',
        provider_name: 'provider name',
        recruitment_cycle_year: '2026',
        withdrawal_tier: 'tier_2',
        tier_withdrawal_reason: 'do-not-want-to-train-anymore.another-career-path-or-accepted-a-job-offer',
        before_accepting: '28',
        after_accepting: '7',
      }, {
        provider_code: 'code',
        provider_id: '1',
        provider_name: 'provider name',
        recruitment_cycle_year: '2026',
        withdrawal_tier: 'tier_2',
        tier_withdrawal_reason: 'do-not-want-to-train-anymore.other',
        before_accepting: '4',
        after_accepting: '0',
      }, {
        provider_code: 'code',
        provider_id: '1',
        provider_name: 'provider name',
        recruitment_cycle_year: '2026',
        withdrawal_tier: 'tier_2',
        tier_withdrawal_reason: 'do-not-want-to-train-anymore.personal-circumstances-have-changed',
        before_accepting: '13',
        after_accepting: '4',
      }, {
        provider_code: 'code',
        provider_id: '1',
        provider_name: 'provider name',
        recruitment_cycle_year: '2026',
        withdrawal_tier: 'tier_3',
        tier_withdrawal_reason: 'do-not-want-to-train-anymore.personal-circumstances-have-changed.other',
        before_accepting: '0',
        after_accepting: '2',
      }, {
        provider_code: 'code',
        provider_id: '1',
        provider_name: 'provider name',
        recruitment_cycle_year: '2026',
        withdrawal_tier: 'tier_3',
        tier_withdrawal_reason: 'do-not-want-to-train-anymore.personal-circumstances-have-changed.concerns-about-having-enough-time-to-train',
        before_accepting: '5',
        after_accepting: '1',
      }, {
        provider_code: 'code',
        provider_id: '1',
        provider_name: 'provider name',
        recruitment_cycle_year: '2026',
        withdrawal_tier: 'tier_3',
        tier_withdrawal_reason: 'do-not-want-to-train-anymore.personal-circumstances-have-changed.concerns-about-cost-of-doing-course',
        before_accepting: '9',
        after_accepting: '2',
      }, {
        provider_code: 'code',
        provider_id: '1',
        provider_name: 'provider name',
        recruitment_cycle_year: '2026',
        withdrawal_tier: 'tier_3',
        tier_withdrawal_reason: 'do-not-want-to-train-anymore.personal-circumstances-have-changed.concerns-about-training-with-a-disability-or-health-condition',
        before_accepting: '1',
        after_accepting: '0',
      }, {
        provider_code: 'code',
        provider_id: '1',
        provider_name: 'provider name',
        recruitment_cycle_year: '2026',
        withdrawal_tier: 'tier_1',
        tier_withdrawal_reason: 'do-not-want-to-train-anymore',
        before_accepting: '41',
        after_accepting: '11',
      }]
    end

    subject(:data) do
      described_class.new(provider_id: provider.id, recruitment_cycle_year: 2026).data
    end

    before do
      stub_bigquery_withdrawal_reasons_request(rows:)
    end

    it 'returns the first result' do
      expect(data.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      data

      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT provider_code, provider_id, provider_name, recruitment_cycle_year, withdrawal_tier, tier_withdrawal_reason, before_accepting, after_accepting
<<<<<<< HEAD
        FROM `dataform.provider_withdrawal_reasons`
=======
        FROM `1_key_tables.provider_withdrawal_reasons`
>>>>>>> c93079005e (view)
        WHERE provider_id = "#{provider.id}"
        AND recruitment_cycle_year = 2026
      SQL
    end

    context 'when the api returns no data' do
      before do
        stub_bigquery_withdrawal_reasons_request(rows: [])
      end

      it 'returns an empty array' do
        expect(data).to be_empty
      end
    end
  end

  describe described_class::Result do
    let(:result) { described_class.new({ provider_code: 'code' }) }

    before do
      stub_bigquery_withdrawal_reasons_request
    end

    describe '#attributes' do
      it 'returns the correct #attributes' do
        expect(result.attributes).to include({
          'provider_code' => 'code',
        })
      end
    end
  end

  describe 'when the query returns nil for rows' do
    let(:provider) { create(:provider) }

    subject(:data) do
      described_class.new(provider_id: provider.id, recruitment_cycle_year: 2027).data
    end

    before do
      stub_bigquery_withdrawal_reasons_request(rows: nil)
    end

    it 'fails silently' do
      data
    end
  end

  describe 'when there is an error' do
    let(:provider) { create(:provider) }

    subject(:data) do
      described_class.new(provider_id: provider.id, recruitment_cycle_year: 2027).data
    end

    context 'when the query job does not complete in time' do
      before do
        stub_bigquery_withdrawal_reasons_request(job_complete: false)
      end

      it 'raises an error' do
        expect { data }.to raise_error(DfE::Bigquery::Relation::JobIncompleteError)
      end
    end

    context 'when there is more than one page' do
      before do
        stub_bigquery_withdrawal_reasons_request(page_token: true)
      end

      it 'raises an error' do
        expect { data }.to raise_error(DfE::Bigquery::Relation::MorePagesError)
      end
    end

    context 'when an unhandled type is returned' do
      before do
        stub_bigquery_withdrawal_reasons_request(rows: [[
          { name: 'some_value', type: 'COFFEE', value: '☕' },
        ]])
      end

      it 'raises an error' do
        expect { data }.to raise_error(DfE::Bigquery::Relation::UnknownTypeError).with_message("cannot parse this type of value: 'COFFEE'")
      end
    end
  end
end
