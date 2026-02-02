require 'rails_helper'

RSpec.describe DfE::Bigquery::RegionalProviderMetrics do
  include DfE::Bigquery::TestHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle(2024))
  end

  describe '.regional_data' do
    subject(:region_statistics) do
      described_class.new(cycle_week: 18, region: 'London').regional_data
    end

    let(:rows) do
      [[
        { name: 'nonregion_filter', type: 'STRING', value: 'Level' },
        { name: 'nonregion_filter_category', type: 'STRING', value: 'Primary' },
        { name: 'cycle_week', type: 'INTEGER', value: '18' },
        { name: 'recruitment_cycle_year', type: 'INTEGER', value: '2024' },
        { name: 'region_filter', type: 'STRING', value: 'London' },
        { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '100' },
        { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: '200' },
        { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: '0.5' },
        { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: '10' },
        { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: '5' },
        { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: '2.0' },
        { name: 'offer_rate_to_date', type: 'FLOAT', value: '1.2' },
        { name: 'offer_rate_to_same_date_previous_cycle', type: 'FLOAT', value: '1.5' },
        { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: '1' },
        { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: '10' },
        { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: '0.1' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
        { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'FLOAT', value: '0.12' },
        { name: 'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle', type: 'FLOAT', value: '0.12' },
      ]]
    end

    let(:results) do
      [
        {
          nonregion_filter: 'Level',
          nonregion_filter_category: 'Primary',
          cycle_week: 18,
          recruitment_cycle_year: 2024,
          region_filter: 'London',
          number_of_candidates_submitted_to_date: 100,
          number_of_candidates_submitted_to_same_date_previous_cycle: 200,
          number_of_candidates_submitted_to_date_as_proportion_of_last_cycle: 0.5,
          number_of_candidates_with_offers_to_date: 10,
          number_of_candidates_with_offers_to_same_date_previous_cycle: 5,
          number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle: 2.0,
          offer_rate_to_date: 1.2,
          offer_rate_to_same_date_previous_cycle: 1.5,
          number_of_candidates_accepted_to_date: 1,
          number_of_candidates_accepted_to_same_date_previous_cycle: 10,
          number_of_candidates_accepted_to_date_as_proportion_of_last_cycle: 0.1,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: 12,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: 12,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle: 0,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: 12,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: 12,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle: 0,
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date: 12,
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates: 0.12,
          number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle: 0.12,
        },
      ]
    end

    before do
      stub_bigquery_regional_provider_metrics_request(rows:)
    end

    it 'returns the first result' do
      expect(region_statistics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      region_statistics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT nonregion_filter, nonregion_filter_category, cycle_week, recruitment_cycle_year, region_filter, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_offers_to_date, number_of_candidates_with_offers_to_same_date_previous_cycle, number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle, offer_rate_to_date, offer_rate_to_same_date_previous_cycle, number_of_candidates_accepted_to_date, number_of_candidates_accepted_to_same_date_previous_cycle, number_of_candidates_accepted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates, number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle
        FROM `1_key_tables.application_metrics_by_region`
        WHERE region_filter = "London"
        AND region_filter_category = "ITL1"
        AND cycle_week = 18
        AND recruitment_cycle_year = 2024
        AND (
          nonregion_filter_category = "Secondary subject"
          OR (nonregion_filter_category = "Level" AND nonregion_filter IN ("Primary", "Secondary"))
          OR (nonregion_filter = "All")
        )
      SQL
    end

    it 'assigns the attributes for the application metrics', :aggregate_failures do
      expect(region_statistics.first.nonregion_filter).to eq 'Level'
      expect(region_statistics.first.nonregion_filter_category).to eq 'Primary'
      expect(region_statistics.first.cycle_week).to eq 18
      expect(region_statistics.first.recruitment_cycle_year).to eq 2024
      expect(region_statistics.first.region_filter).to eq 'London'
      expect(region_statistics.first.number_of_candidates_submitted_to_date).to eq 100
      expect(region_statistics.first.number_of_candidates_submitted_to_same_date_previous_cycle).to eq 200
      expect(region_statistics.first.number_of_candidates_submitted_to_date_as_proportion_of_last_cycle).to eq 0.5
      expect(region_statistics.first.number_of_candidates_with_offers_to_date).to eq 10
      expect(region_statistics.first.number_of_candidates_with_offers_to_same_date_previous_cycle).to eq 5
      expect(region_statistics.first.number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle).to eq 2.0
      expect(region_statistics.first.number_of_candidates_accepted_to_date).to eq 1
      expect(region_statistics.first.number_of_candidates_accepted_to_same_date_previous_cycle).to eq 10
      expect(region_statistics.first.number_of_candidates_accepted_to_date_as_proportion_of_last_cycle).to eq 0.1
      expect(region_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date).to eq 12
      expect(region_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle).to eq 12
      expect(region_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle).to eq 0
      expect(region_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date).to eq 12
      expect(region_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle).to eq 12
      expect(region_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle).to eq 0
      expect(region_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date).to eq 12
      expect(region_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates).to eq 0.12
      expect(region_statistics.first.number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle).to eq 0.12
      expect(region_statistics.first.number_of_candidates_submitted_to_date).to eq 100
    end

    context 'when the api returns no data for the provider id' do
      before do
        stub_bigquery_regional_provider_metrics_request(rows: [])
      end

      it 'returns an empty array' do
        expect(region_statistics).to be_empty
      end
    end
  end

  describe described_class::Result do
    let(:result) { described_class.new({ region_filter: 'London', nonregion_filter: 'Primary' }) }

    before do
      stub_bigquery_regional_provider_metrics_request
    end

    describe '#attributes' do
      it 'returns the correct #attributes' do
        expect(result.attributes).to include({
          'region_filter' => 'London',
          'nonregion_filter' => 'Primary',
          'number_of_candidates_submitted_to_same_date_previous_cycle' => nil,
        })
      end
    end
  end

  describe 'when the query returns nil for rows' do
    subject(:region_statistics) do
      described_class.new(cycle_week: 18, region: 'London').regional_data
    end

    let(:stub_bigquery_response) do
      stub_bigquery_regional_provider_metrics_request(result: false)
    end

    before do
      stub_bigquery_response
    end

    it 'fails silently' do
      region_statistics
    end
  end

  describe 'when there is an error' do
    subject(:region_statistics) do
      described_class.new(cycle_week: 7, region: 'London').regional_data
    end

    context 'when there is more than one page' do
      before do
        stub_bigquery_regional_provider_metrics_request(page_token: true)
      end

      it 'raises an error' do
        expect { region_statistics }.to raise_error(DfE::Bigquery::Relation::MorePagesError)
      end
    end

    context 'when the query job does not complete in time' do
      before do
        stub_bigquery_regional_provider_metrics_request(job_complete: false)
      end

      it 'raises an error' do
        expect { region_statistics }.to raise_error(DfE::Bigquery::Relation::JobIncompleteError)
      end
    end

    context 'when an unhandled type is returned' do
      before do
        stub_bigquery_regional_provider_metrics_request(rows: [[
          { name: 'some_value', type: 'COFFEE', value: '☕' },
        ]])
      end

      it 'raises an error' do
        expect { region_statistics }.to raise_error(DfE::Bigquery::Relation::UnknownTypeError).with_message("cannot parse this type of value: 'COFFEE'")
      end
    end
  end
end
