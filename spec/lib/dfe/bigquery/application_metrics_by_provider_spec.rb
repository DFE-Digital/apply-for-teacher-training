require 'rails_helper'
require_relative 'bigquery_stubs'

RSpec.describe DfE::Bigquery::ApplicationMetricsByProvider do
  include BigqueryStubs

  let(:client) { instance_double(Google::Apis::BigqueryV2::BigqueryService) }
  let(:response) do
    stub_response(rows: [])
  end

  before do
    allow(DfE::Bigquery).to receive(:client).and_return(client)
  end

  describe '.provider_data' do
    subject(:provider_statistics) do
      described_class.new(cycle_week: 18, provider_id: 1337).provider_data
    end

    let(:response) do
      stub_response(rows: [[
        { name: 'id', type: 'INTEGER', value: '1337' },
        { name: 'cycle_week', type: 'INTEGER', value: '18' },
        { name: 'recruitment_cycle_year', type: 'INTEGER', value: '2024' },
        { name: 'nonprovider_filter', type: 'STRING', value: 'Level' },
        { name: 'nonprovider_filter_category', type: 'STRING', value: 'Primary' },
        { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '100' },
        { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: '200' },
        { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0.5' },
        { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: '10' },
        { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: '5' },
        { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '2.0' },
        { name: 'offer_rate_to_date', type: 'INTEGER', value: '1.2' },
        { name: 'offer_rate_to_same_date_previous_cycle', type: 'INTEGER', value: '1.5' },
        { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: '1' },
        { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: '10' },
        { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0.1' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
        { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'INTEGER', value: '12' },
      ]])
    end

    # Bigq{name: 'uery returns `provider.id` as :id
    let(:bigquery_results) do
      [
        {
          id: 1337,
          cycle_week: 18,
          recruitment_cycle_year: 2024,
          nonprovider_filter: 'Level',
          nonprovider_filter_category: 'Primary',
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
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates: 12,
        },
      ]
    end

    let(:results) do
      [
        {
          provider_id: '1337',
          cycle_week: '18',
          recruitment_cycle_year: '2024',
          nonprovider_filter: 'Level',
          nonprovider_filter_category: 'Primary',
          number_of_candidates_submitted_to_date: '100',
          number_of_candidates_submitted_to_same_date_previous_cycle: '200',
          number_of_candidates_submitted_to_date_as_proportion_of_last_cycle: '0.5',
          number_of_candidates_with_offers_to_date: '10',
          number_of_candidates_with_offers_to_same_date_previous_cycle: '5',
          number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle: '2.0',
          offer_rate_to_date: '1.2',
          offer_rate_to_same_date_previous_cycle: '1.5',
          number_of_candidates_accepted_to_date: '1',
          number_of_candidates_accepted_to_same_date_previous_cycle: '10',
          number_of_candidates_accepted_to_date_as_proportion_of_last_cycle: '0.1',
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: '12',
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: '12',
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle: '0',
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: '12',
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: '12',
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle: '0',
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date: '12',
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates: '12',
        },
      ]
    end

    before do
      allow(client).to receive(:query_job)
        .with(DfE::Bigquery.config.bigquery_project_id, instance_of(Google::Apis::BigqueryV2::QueryRequest))
        .and_return(response)
    end

    it 'returns the first result' do
      expect(provider_statistics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      provider_statistics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10, use_legacy_sql: false)
        SELECT nonprovider_filter, nonprovider_filter_category, cycle_week, recruitment_cycle_year, provider.id, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_offers_to_date, number_of_candidates_with_offers_to_same_date_previous_cycle, number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle, offer_rate_to_date, offer_rate_to_same_date_previous_cycle, number_of_candidates_accepted_to_date, number_of_candidates_accepted_to_same_date_previous_cycle, number_of_candidates_accepted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates
        FROM `1_key_tables.application_metrics_by_provider`
        WHERE provider.id = "1337"
        AND cycle_week = 18
        AND recruitment_cycle_year = 2024
        AND (
          nonprovider_filter_category = "Secondary subject"
          OR (nonprovider_filter_category = "Level" AND nonprovider_filter IN ("Primary", "Secondary"))
          OR nonprovider_filter = "All"
        )
      SQL
    end

    it 'assigns the attributes for the application metrics', :aggregate_failures do
      expect(provider_statistics.first.nonprovider_filter).to eq 'Level'
      expect(provider_statistics.first.nonprovider_filter_category).to eq 'Primary'
      expect(provider_statistics.first.cycle_week).to eq '18'
      expect(provider_statistics.first.recruitment_cycle_year).to eq '2024'
      expect(provider_statistics.first.provider_id).to eq '1337'
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to eq '100'
      expect(provider_statistics.first.number_of_candidates_submitted_to_same_date_previous_cycle).to eq '200'
      expect(provider_statistics.first.number_of_candidates_submitted_to_date_as_proportion_of_last_cycle).to eq '0.5'
      expect(provider_statistics.first.number_of_candidates_with_offers_to_date).to eq '10'
      expect(provider_statistics.first.number_of_candidates_with_offers_to_same_date_previous_cycle).to eq '5'
      expect(provider_statistics.first.number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle).to eq '2.0'
      expect(provider_statistics.first.number_of_candidates_accepted_to_date).to eq '1'
      expect(provider_statistics.first.number_of_candidates_accepted_to_same_date_previous_cycle).to eq '10'
      expect(provider_statistics.first.number_of_candidates_accepted_to_date_as_proportion_of_last_cycle).to eq '0.1'
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date).to eq '12'
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle).to eq '12'
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle).to eq '0'
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date).to eq '12'
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle).to eq '12'
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle).to eq '0'
      expect(provider_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date).to eq '12'
      expect(provider_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates).to eq '12'
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to eq '100'
    end

    context 'when the api returns no data for the provider id' do
      let(:bigquery_results) { [] }
      let(:response) do
        stub_response(rows: [])
      end

      before do
        allow(client).to receive(:query_job).with(anything).and_return(response)
      end

      it 'returns an empty array' do
        expect(provider_statistics).to be_empty
      end
    end
  end

  describe '.national_data' do
    subject(:national_statistics) do
      described_class.new(cycle_week: 18).national_data
    end

    let(:results) do
      [
        {
          cycle_week: '18',
          recruitment_cycle_year: '2024',
          nonprovider_filter: 'Level',
          nonprovider_filter_category: 'Primary',
          number_of_candidates_submitted_to_date: '100',
          number_of_candidates_submitted_to_same_date_previous_cycle: '200',
          number_of_candidates_submitted_to_date_as_proportion_of_last_cycle: '0.5',
          number_of_candidates_with_offers_to_date: '10',
          number_of_candidates_with_offers_to_same_date_previous_cycle: '5',
          number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle: '2.0',
          offer_rate_to_date: '1.2',
          offer_rate_to_same_date_previous_cycle: '1.5',
          number_of_candidates_accepted_to_date: '1',
          number_of_candidates_accepted_to_same_date_previous_cycle: '10',
          number_of_candidates_accepted_to_date_as_proportion_of_last_cycle: '0.1',
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: '12',
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: '12',
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle: '0',
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: '12',
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: '12',
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle: '0',
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date: '12',
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates: '12',
        },

      ]
    end
    let(:response) do
      stub_response(rows: [[
        { name: 'cycle_week', type: 'INTEGER', value: '18' },
        { name: 'recruitment_cycle_year', type: 'INTEGER', value: '2024' },
        { name: 'nonprovider_filter', type: 'STRING', value: 'Level' },
        { name: 'nonprovider_filter_category', type: 'STRING', value: 'Primary' },
        { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '100' },
        { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: '200' },
        { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0.5' },
        { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: '10' },
        { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: '5' },
        { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '2.0' },
        { name: 'offer_rate_to_date', type: 'INTEGER', value: '1.2' },
        { name: 'offer_rate_to_same_date_previous_cycle', type: 'INTEGER', value: '1.5' },
        { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: '1' },
        { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: '10' },
        { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0.1' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
        { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: '12' },
        { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'INTEGER', value: '12' },
      ]])
    end

    before do
      allow(client).to receive(:query_job)
        .with(DfE::Bigquery.config.bigquery_project_id, instance_of(Google::Apis::BigqueryV2::QueryRequest))
        .and_return(response)
    end

    it 'returns the first result' do
      expect(national_statistics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      national_statistics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10, use_legacy_sql: false)
        SELECT nonprovider_filter, nonprovider_filter_category, cycle_week, recruitment_cycle_year, provider.id, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_offers_to_date, number_of_candidates_with_offers_to_same_date_previous_cycle, number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle, offer_rate_to_date, offer_rate_to_same_date_previous_cycle, number_of_candidates_accepted_to_date, number_of_candidates_accepted_to_same_date_previous_cycle, number_of_candidates_accepted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates
        FROM `1_key_tables.application_metrics_by_provider`
        WHERE cycle_week = 18
        AND recruitment_cycle_year = 2024
        AND teach_first_or_iot_filter = "All"
        AND provider_filter_category = "All"
        AND (
          nonprovider_filter_category = "Secondary subject"
          OR (nonprovider_filter_category = "Level" AND nonprovider_filter IN ("Primary", "Secondary"))
          OR (nonprovider_filter = "All")
        )
      SQL
    end

    it 'assigns the attributes for the application metrics', :aggregate_failures do
      expect(national_statistics.first.nonprovider_filter).to eq 'Level'
      expect(national_statistics.first.nonprovider_filter_category).to eq 'Primary'
      expect(national_statistics.first.cycle_week).to eq '18'
      expect(national_statistics.first.recruitment_cycle_year).to eq '2024'
      expect(national_statistics.first.number_of_candidates_submitted_to_date).to eq '100'
      expect(national_statistics.first.number_of_candidates_submitted_to_same_date_previous_cycle).to eq '200'
      expect(national_statistics.first.number_of_candidates_submitted_to_date_as_proportion_of_last_cycle).to eq '0.5'
      expect(national_statistics.first.number_of_candidates_with_offers_to_date).to eq '10'
      expect(national_statistics.first.number_of_candidates_with_offers_to_same_date_previous_cycle).to eq '5'
      expect(national_statistics.first.number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle).to eq '2.0'
      expect(national_statistics.first.number_of_candidates_accepted_to_date).to eq '1'
      expect(national_statistics.first.number_of_candidates_accepted_to_same_date_previous_cycle).to eq '10'
      expect(national_statistics.first.number_of_candidates_accepted_to_date_as_proportion_of_last_cycle).to eq '0.1'
      expect(national_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date).to eq '12'
      expect(national_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle).to eq '12'
      expect(national_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle).to eq '0'
      expect(national_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date).to eq '12'
      expect(national_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle).to eq '12'
      expect(national_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle).to eq '0'
      expect(national_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date).to eq '12'
      expect(national_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates).to eq '12'
      expect(national_statistics.first.number_of_candidates_submitted_to_date).to eq '100'
    end

    context 'when the api returns no data' do
      let(:bigquery_results) { [] }

      let(:response) do
        stub_response(rows: [])
      end

      before do
        allow(client).to receive(:query_job)
          .with(DfE::Bigquery.config.bigquery_project_id, instance_of(Google::Apis::BigqueryV2::QueryRequest))
          .and_return(response)
      end

      it 'returns an empty array' do
        expect(national_statistics).to be_empty
      end
    end
  end

  describe described_class::Result do
    let(:result) { described_class.new({ provider_id: 123, nonprovider_filter: 'Primary' }) }

    describe 'attr_readers' do
      it 'has attr_reader for nonprovider_filter' do
        expect(result).to respond_to(:nonprovider_filter)
      end

      it 'has attr_reader for nonprovider_filter_category' do
        expect(result).to respond_to(:nonprovider_filter_category)
      end
    end

    describe '#attributes' do
      it 'returns the correct #attributes' do
        expect(result.attributes).to include({
          'provider_id' => 123,
          'nonprovider_filter' => 'Primary',
          'number_of_candidates_submitted_to_same_date_previous_cycle' => nil,
        })
      end
    end
  end
end
