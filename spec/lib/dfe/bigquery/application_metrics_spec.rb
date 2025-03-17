require 'rails_helper'

RSpec.describe DfE::Bigquery::ApplicationMetrics, time: Time.zone.local(2023, 11, 20) do
  include DfE::Bigquery::TestHelper

  let(:stub_bigquery_response) do
    stub_bigquery_application_metrics_request(rows: [[
      { name: 'cycle_week', type: 'INTEGER', value: '7' },
      { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '100' },
      { name: 'first_date_in_week', type: 'DATE', value: '2024-03-18' },
      { name: 'subject_filter', type: 'INTEGER', value: nil },
      { name: 'offset', type: 'RECORD', value: {} },
    ]])
  end

  before do
    stub_bigquery_response
  end

  describe '.candidate_headline_statistics' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).candidate_headline_statistics
    end

    let(:results) do
      [
        {
          cycle_week: 7,
          number_of_candidates_submitted_to_date: 100,
          first_date_in_week: Date.parse('2024-03-18'),
          subject_filter: nil,
        },
      ]
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Total excluding Further Education"
        AND nonsubject_filter_category = "Total"
      SQL
    end

    it 'returns the first result' do
      expect(application_metrics.as_json).to eq(results.first.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.number_of_candidates_submitted_to_date).to eq 100
      expect(application_metrics.cycle_week).to eq 7
    end
  end

  describe '.age_group' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).age_group
    end

    let(:results) do
      [
        {
          number_of_candidates_submitted_to_date: 100,
          nonsubject_filter: '25 to 29',
          cycle_week: 7,
        },
      ]
    end

    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(rows: [[
        { name: 'cycle_week', type: 'INTEGER', value: '7' },
        { name: 'nonsubject_filter', type: 'STRING', value: '25 to 29' },
        { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '100' },
      ]])
    end

    before do
      stub_bigquery_response
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Total excluding Further Education"
        AND nonsubject_filter_category = "Age group"
        ORDER BY (
          CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
               WHEN nonsubject_filter='Unknown' THEN 3
               WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
               ELSE 1
          END
        )
        , nonsubject_filter ASC
      SQL
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.number_of_candidates_submitted_to_date).to eq 100
      expect(application_metrics.first.cycle_week).to eq 7
      expect(application_metrics.first.nonsubject_filter).to eq('25 to 29')
    end
  end

  describe '.sex' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).sex
    end

    let(:results) do
      [
        {
          nonsubject_filter: 'Male',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'Female',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'Prefer not to say',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'Other',
          cycle_week: 7,
        },
      ]
    end

    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(rows: [
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'Male' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'Female' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'Prefer not to say' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'Other' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
      ])
    end

    before do
      stub_bigquery_response
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Total excluding Further Education"
        AND nonsubject_filter_category = "Sex"
        ORDER BY (
          CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
               WHEN nonsubject_filter='Unknown' THEN 3
               WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
               ELSE 1
          END
        )
        , nonsubject_filter ASC
      SQL
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to eq 7
      expect(application_metrics.first.nonsubject_filter).to eq('Male')
    end
  end

  describe '.area' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).area
    end

    let(:results) do
      [
        {
          nonsubject_filter: 'London',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'European Economic area',
          cycle_week: 7,
        },
      ]
    end

    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(rows: [
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'London' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'European Economic area' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
      ])
    end

    before do
      stub_bigquery_response
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Total excluding Further Education"
        AND nonsubject_filter_category = "Candidate region"
        ORDER BY (
          CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
               WHEN nonsubject_filter='Unknown' THEN 3
               WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
               ELSE 1
          END
        )
        , nonsubject_filter ASC
      SQL
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to eq 7
      expect(application_metrics.first.nonsubject_filter).to eq('London')
    end
  end

  describe '.phase' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).phase
    end

    let(:results) do
      [
        {
          subject_filter: 'Primary',
          cycle_week: 7,
        },
        {
          subject_filter: 'Secondary',
          cycle_week: 7,
        },
      ]
    end

    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(rows: [
        [
          { name: 'subject_filter', type: 'STRING', value: 'Primary' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'subject_filter', type: 'STRING', value: 'Secondary' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
      ])
    end

    before do
      stub_bigquery_response
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Level"
        AND nonsubject_filter_category = "Total"
        AND subject_filter != "Further Education"
        ORDER BY (
          CASE WHEN subject_filter='Prefer not to say' THEN 4
               WHEN subject_filter='Unknown' THEN 3
               WHEN subject_filter='Other' OR subject_filter='Others' THEN 2
               ELSE 1
          END
        )
        , subject_filter ASC
      SQL
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to eq 7
      expect(application_metrics.first.subject_filter).to eq('Primary')
      expect(application_metrics.last.subject_filter).to eq('Secondary')
    end
  end

  describe '.route_into_teaching' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).route_into_teaching
    end

    let(:results) do
      [
        {
          nonsubject_filter: 'Postgraduate teaching apprenticeship',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'School Direct (salaried)',
          cycle_week: 7,
        },
      ]
    end

    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(rows: [
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'Postgraduate teaching apprenticeship' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'School Direct (salaried)' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
      ])
    end

    before do
      stub_bigquery_response
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Total excluding Further Education"
        AND nonsubject_filter_category = "Route into teaching"
        ORDER BY (
          CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
               WHEN nonsubject_filter='Unknown' THEN 3
               WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
               ELSE 1
          END
        )
        , nonsubject_filter ASC
      SQL
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to eq 7
      expect(application_metrics.first.nonsubject_filter).to eq('Postgraduate teaching apprenticeship')
      expect(application_metrics.last.nonsubject_filter).to eq('School Direct (salaried)')
    end
  end

  describe '.primary_subject' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).primary_subject
    end

    let(:results) do
      [
        {
          subject_filter: 'Primary with English',
          cycle_week: 7,
        },
        {
          subject_filter: 'Primary with Science',
          cycle_week: 7,
        },
      ]
    end

    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(rows: [
        [
          { name: 'subject_filter', type: 'STRING', value: 'Primary with English' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'subject_filter', type: 'STRING', value: 'Primary with Science' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
      ])
    end

    before do
      stub_bigquery_response
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Primary subject"
        AND nonsubject_filter_category = "Total"
        ORDER BY (
          CASE WHEN subject_filter='Prefer not to say' THEN 4
               WHEN subject_filter='Unknown' THEN 3
               WHEN subject_filter='Other' OR subject_filter='Others' THEN 2
               ELSE 1
          END
        )
        , subject_filter ASC
      SQL
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to eq 7
      expect(application_metrics.first.subject_filter).to eq('Primary with English')
      expect(application_metrics.last.subject_filter).to eq('Primary with Science')
    end
  end

  describe '.secondary_subject' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).secondary_subject
    end

    let(:results) do
      [
        {
          subject_filter: 'Magic tricks',
          cycle_week: 7,
        },
        {
          subject_filter: 'Illusion tricks',
          cycle_week: 7,
        },
      ]
    end

    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(rows: [
        [
          { name: 'subject_filter', type: 'STRING', value: 'Magic tricks' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'subject_filter', type: 'STRING', value: 'Illusion tricks' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
      ])
    end

    before do
      stub_bigquery_response
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Secondary subject excluding Further Education"
        AND nonsubject_filter_category = "Total"
        ORDER BY (
          CASE WHEN subject_filter='Prefer not to say' THEN 4
               WHEN subject_filter='Unknown' THEN 3
               WHEN subject_filter='Other' OR subject_filter='Others' THEN 2
               ELSE 1
          END
        )
        , subject_filter ASC
      SQL
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to eq 7
      expect(application_metrics.first.subject_filter).to eq('Magic tricks')
      expect(application_metrics.last.subject_filter).to eq('Illusion tricks')
    end
  end

  describe '.provider_region' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).provider_region
    end

    let(:results) do
      [
        {
          nonsubject_filter: 'Gondor',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'Mordor',
          cycle_week: 7,
        },
      ]
    end

    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(rows: [
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'Gondor' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
        [
          { name: 'nonsubject_filter', type: 'STRING', value: 'Mordor' },
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
        ],
      ])
    end

    before do
      stub_bigquery_response
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      application_metrics
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT *
        FROM `1_key_tables.application_metrics`
        WHERE recruitment_cycle_year = 2024
        AND cycle_week = 7
        AND subject_filter_category = "Total excluding Further Education"
        AND nonsubject_filter_category = "Provider region"
        ORDER BY (
          CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
               WHEN nonsubject_filter='Unknown' THEN 3
               WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
               ELSE 1
          END
        )
        , nonsubject_filter ASC
      SQL
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to eq 7
      expect(application_metrics.first.nonsubject_filter).to eq('Gondor')
      expect(application_metrics.last.nonsubject_filter).to eq('Mordor')
    end
  end

  describe 'when the query returns nil for rows' do
    let(:stub_bigquery_response) do
      stub_bigquery_application_metrics_request(result: false)
    end

    before do
      stub_bigquery_response
    end

    subject(:application_metrics) do
      described_class.new(cycle_week: 7).candidate_headline_statistics
    end

    it 'fails silently' do
      application_metrics
    end
  end

  describe 'when there is an error' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).provider_region
    end

    context 'when there is more than one page' do
      before do
        stub_bigquery_application_metrics_request(page_token: true)
      end

      it 'raises an error' do
        expect { application_metrics }.to raise_error(DfE::Bigquery::Relation::MorePagesError)
      end
    end

    context 'when the query job does not complete in time' do
      before do
        stub_bigquery_application_metrics_request(job_complete: false)
      end

      it 'raises an error' do
        expect { application_metrics }.to raise_error(DfE::Bigquery::Relation::JobIncompleteError)
      end
    end
  end
end
